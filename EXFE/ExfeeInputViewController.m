//
//  ExfeeInputViewController.m
//  EXFE
//
//  Created by huoju on 7/25/12.
//
//

#import "ExfeeInputViewController.h"

@interface ExfeeInputViewController ()

@end

@implementation ExfeeInputViewController
@synthesize gatherview;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [exfeeInput setPlaceholder:@"Invite friends by name, email…"];
    [exfeeInput setBorderStyle:UITextBorderStyleRoundedRect];
    [exfeeInput setAutocorrectionType:UITextAutocorrectionTypeNo];
    
    suggestionTable=[[UITableView alloc] initWithFrame:CGRectMake(0, 44+6+44, 320, 460-44-6-44) style:UITableViewStylePlain];
    [self.view addSubview:suggestionTable];
    suggestionTable.dataSource=self;
    suggestionTable.delegate=self;
    
    
    exfeeList=[[EXBubbleScrollView alloc] initWithFrame:CGRectMake(0, 44+6, self.view.frame.size.width, 44)];
    [exfeeList setContentSize:CGSizeMake(self.view.frame.size.width, 44)];
    [exfeeList setDelegate:self];

    [self.view addSubview:exfeeList];
}
- (IBAction) Close:(id) sender{
    [self dismissModalViewControllerAnimated:YES];    
}

- (IBAction)textDidChange:(UITextField*)textField{
    if(exfeeInput.text!=nil && exfeeInput.text.length>=1) {
        showInputinSuggestion=YES;
        [APIProfile LoadSuggest:exfeeInput.text delegate:self];
        [self loadIdentitiesFromDataStore];
    }
    if(exfeeInput.text==nil || [exfeeInput.text isEqualToString:@""])
    {
        if(suggestIdentities!=nil){
            [suggestIdentities release];
            suggestIdentities=nil;
            [suggestionTable reloadData];
        }
    }

}
- (IBAction)editingDidBegan:(UITextField*)textField{
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)loadIdentitiesFromDataStore {
    [suggestIdentities release];
    suggestIdentities=nil;
    NSFetchRequest* request = [Identity fetchRequest];
    NSSortDescriptor* descriptor = [NSSortDescriptor sortDescriptorWithKey:@"created_at" ascending:NO];
    
    NSString *inputpredicate=[NSString stringWithFormat:@"*%@*",exfeeInput.text];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"((name like[c] %@) OR (external_username like[c] %@) OR (external_id like[c] %@) OR (nickname like[c] %@)) AND provider != %@ AND  provider != %@ ",inputpredicate,inputpredicate,inputpredicate,inputpredicate,@"iOSAPN",@"android"];
    [request setPredicate:predicate];
    [request setSortDescriptors:[NSArray arrayWithObject:descriptor]];
    NSMutableArray *temp=[[NSMutableArray alloc]initWithCapacity:10];
    NSArray *suggestwithselected=[[Identity objectsWithFetchRequest:request] retain];
    for (Identity *identity in suggestwithselected){
        BOOL flag=NO;
//        for (Invitation *selected in exfeeIdentities){
//            if([selected.identity.identity_id intValue]==[identity.identity_id intValue])
//            {
//                flag=YES;
//                continue;
//            }
//        }
        if(flag==NO)
            [temp addObject:identity];
    }
    
    suggestIdentities=[temp retain];
    [temp release];
    [suggestionTable reloadData];
}
- (IBAction)editingDidEnd:(UITextField*)textField{
    NSLog(@"%@",textField.text);
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self addByText];
    return NO;
}

- (void) addByText{
    NSCharacterSet *split=[NSCharacterSet characterSetWithCharactersInString:@",;"];
    NSArray *identity_list=[exfeeInput.text componentsSeparatedByCharactersInSet:split];
    NSString *json=@"";
    for(NSString *identity_input in identity_list) {
        NSString *provider=[Util findProvider:identity_input];
        if(![provider isEqualToString:@""]) {
            if(![json isEqualToString:@""])
                json=[json stringByAppendingString:@","];
            json=[json stringByAppendingFormat:@"{\"provider\":\"%@\",\"external_username\":\"%@\"}",provider,identity_input];
        }
    }
    json=[NSString stringWithFormat:@"[%@]",json];
    [self getIdentity:json];
}

- (void) getIdentity:(NSString*)identity_json{
    
    AppDelegate *app=(AppDelegate *)[[UIApplication sharedApplication] delegate];
    RKClient *client = [RKClient sharedClient];
    NSString *endpoint = [NSString stringWithFormat:@"/identities/get"];
    
    RKParams* rsvpParams = [RKParams params];
    [rsvpParams setValue:identity_json forParam:@"identities"];
    [client setValue:app.accesstoken forHTTPHeaderField:@"token"];
    [client post:endpoint usingBlock:^(RKRequest *request){
        request.method=RKRequestMethodPOST;
        request.params=rsvpParams;
        request.onDidLoadResponse=^(RKResponse *response){
            if (response.statusCode == 200) {
                NSDictionary *body=[response.body objectFromJSONData];
                if([body isKindOfClass:[NSDictionary class]]) {
                    id code=[[body objectForKey:@"meta"] objectForKey:@"code"];
                    if(code)
                        if([code intValue]==200) {
                            NSDictionary* response = [body objectForKey:@"response"];
                            NSArray *identities = [response objectForKey:@"identities"];
                            for (NSDictionary *identitydict in identities) {
                                NSString *external_id=[identitydict objectForKey:@"external_id"];
                                NSString *provider=[identitydict objectForKey:@"provider"];
                                NSString *avatar_filename=[identitydict objectForKey:@"avatar_filename"];
                                NSString *identity_id=[identitydict objectForKey:@"id"];
                                NSString *name=[identitydict objectForKey:@"name"];
                                NSString *nickname=[identitydict objectForKey:@"nickname"];
                                
                                Identity *identity=[Identity object];
                                identity.external_id=external_id;
                                identity.provider=provider;
                                identity.avatar_filename=avatar_filename;
                                identity.name=name;
                                identity.nickname=nickname;
                                identity.identity_id=[NSNumber numberWithInt:[identity_id intValue]];
                                Invitation *invitation =[Invitation object];
                                invitation.rsvp_status=@"NORESPONSE";
                                invitation.identity=identity;
                                
                                [(GatherViewController*)gatherview addExfee:invitation];
                                [self dismissModalViewControllerAnimated:YES];

//                                [exfeeIdentities addObject:invitation];
//                                [exfeeSelected addObject:[NSNumber numberWithBool:NO]];
//                                [exfeeShowview reloadData];
//                                [suggestionTable removeFromSuperview];
                                
                            }
                            exfeeInput.text=@"";
                            [exfeeInput setEnabled:YES];
                        }
                }
            }else {
                [exfeeInput setEnabled:YES];
                //Check Response Body to get Data!
            }
        };
        request.delegate=self;
    }];
    
}

#pragma mark UITableView Datasource methods

- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section {
//    int input=0;
//    if(showInputinSuggestion==YES)
//        input=1;
    if(suggestIdentities)
    {
        return [suggestIdentities count];
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"suggest view";
    GatherExfeeInputCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
	{
        cell = [[[GatherExfeeInputCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
//    if(showInputinSuggestion==YES&&indexPath.row==0)
//    {
//        cell.title = exfeeInput.text;
//    }
//    else{
        int row=indexPath.row;
//        if(showInputinSuggestion==YES)
//            row-=1;
            
        Identity *identity=[suggestIdentities objectAtIndex:row];
        cell.title = identity.name;
        if(cell.title==nil || [cell.title isEqualToString:@""])
            cell.title = identity.external_username;
        
        if([identity.provider isEqualToString:@"twitter"])
            cell.subtitle =[NSString stringWithFormat:@"@%@",identity.external_username];
        else
            cell.subtitle =identity.external_id;
        
        if(identity.avatar_filename!=nil) {
            dispatch_queue_t imgQueue = dispatch_queue_create("fetchimg thread", NULL);
            dispatch_async(imgQueue, ^{
                UIImage *avatar = [[ImgCache sharedManager] getImgFrom:identity.avatar_filename];
                dispatch_async(dispatch_get_main_queue(), ^{
                    if(avatar!=nil && ![avatar isEqual:[NSNull null]]) {
                        cell.avatar=avatar;
//                        cell.imageView.image=avatar;
                    }
                });
            });
            dispatch_release(imgQueue);        
        }
//    }
    return cell;
    
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    //TODO: add exfee to the selected toolbar, don't dismess this view!
    
//    if(showInputinSuggestion==YES && indexPath.row==0 )
//    {
//        [self addByText];
//    }
//    else{
//        int row=indexPath.row;
//        if(showInputinSuggestion==YES )
//            row-=1;
    Identity *identity=[suggestIdentities objectAtIndex:indexPath.row];

    //    [selectedIdentities addObject:identity];
//    [selectedexfee reloadData];
//        Invitation *invitation =[Invitation object];
//        invitation.rsvp_status=@"NORESPONSE";
//        invitation.identity=identity;
//        [(GatherViewController*)gatherview addExfee:invitation];
//        [self dismissModalViewControllerAnimated:YES];
//    }
}
#pragma mark RKObjectLoaderDelegate methods

- (void)objectLoader:(RKObjectLoader *)objectLoader didLoadObjects:(NSArray *)objects {
    
    if([objects count]>0)
    {
        if([objectLoader.userData isEqualToString:@"suggest"])
            [self loadIdentitiesFromDataStore];
    }
}

- (void)objectLoader:(RKObjectLoader *)objectLoader didFailWithError:(NSError *)error {
    NSLog(@"Error!:%@",error);
    //    [self stopLoading];
}

#pragma mark EXBubbleScrollViewDelegate methods
- (void)OnInputConfirm:(EXBubbleScrollView *)bubbleScrollView textField:(UITextField*)textfield{
    [bubbleScrollView addBubble:textfield.text];
    
}
- (id)customObject:(EXBubbleScrollView *)bubbleScrollView input:(NSString*)input{
    NSDictionary *dictionary=[[NSDictionary alloc] initWithObjectsAndKeys:input,@"name",@"id",@"id", nil ];
    return dictionary;
}
- (BOOL)isInputValid:(EXBubbleScrollView *)bubbleScrollView input:(NSString*)input{
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    BOOL isemail= [emailTest evaluateWithObject:input];
    if(isemail==YES)
        return YES;
    
    NSString *twitterRegex = @"@[A-Za-z0-9]+";
    NSPredicate *twitterTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", twitterRegex];
    BOOL istwitter= [twitterTest evaluateWithObject:input];
    if(istwitter==YES)
        return YES;
    return NO;
}

@end
