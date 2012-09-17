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
    toolbar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 47)];
    [toolbar setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"navbar.png"]]];
    [self.view addSubview:toolbar];

    suggestionTable=[[UITableView alloc] initWithFrame:CGRectMake(0, 44, 320, 460-44) style:UITableViewStylePlain];
    [self.view addSubview:suggestionTable];
    suggestionTable.dataSource=self;
    suggestionTable.delegate=self;
    
    exfeeList=[[EXBubbleScrollView alloc] initWithFrame:CGRectMake(5, 7, 255, 30)];
    [exfeeList setContentSize:CGSizeMake(exfeeList.frame.size.width, 30)];
    [exfeeList setEXBubbleDelegate:self];
    
    [toolbar addSubview:exfeeList];
    
    
    inputleftmask=[[UIImageView alloc] initWithFrame:CGRectMake(exfeeList.frame.origin.x,exfeeList.frame.origin.y , 40, 30)];
    inputleftmask.image=[UIImage imageNamed:@"exfee_inputfield.png"];

    
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    UIBezierPath *roundedPath =
    [UIBezierPath bezierPathWithRoundedRect:inputleftmask.bounds byRoundingCorners:UIRectCornerTopLeft | UIRectCornerBottomLeft cornerRadii:CGSizeMake(15.f, 15.f)];
    maskLayer.path = [roundedPath CGPath];
    inputleftmask.layer.mask=maskLayer;
    inputleftmask.layer.masksToBounds = YES;
    [inputleftmask setHidden:YES];
    [toolbar addSubview:inputleftmask];

    
    inputframeview=[[UIImageView alloc] initWithFrame:exfeeList.frame];
    inputframeview.image=[UIImage imageNamed:@"textfield_navbar_frame.png"];
    inputframeview.contentMode    = UIViewContentModeScaleToFill;
    inputframeview.contentStretch = CGRectMake(0.5, 0.5, 0, 0);
    
    [toolbar addSubview:inputframeview];
    exfeeList.layer.cornerRadius=15;
    [self changeLeftIconWhite:NO];
  
    UIView *leftestview = [[UIView alloc] initWithFrame:CGRectMake(0-320, 0, 320,exfeeList.frame.size.height)];
    leftestview.backgroundColor=FONT_COLOR_HL;
    [exfeeList addSubview:leftestview];
    [leftestview release];
    
    UIImage *btn_dark = [UIImage imageNamed:@"btn_dark.png"];
    UIImageView *backimg=[[UIImageView alloc] initWithFrame:CGRectMake(255+5+5, 7, 50, 31)];
    backimg.image=btn_dark;
    backimg.contentMode=UIViewContentModeScaleToFill;
    backimg.contentStretch = CGRectMake(0.5, 0.5, 0, 0);
    [toolbar addSubview:backimg];
    [backimg release];
    
    UIButton *doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [doneButton setTitle:@"Done" forState:UIControlStateNormal];
    [doneButton.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:12]];
    doneButton.frame = CGRectMake(255+5+5, 7, 50, 30);
    [doneButton addTarget:self action:@selector(done:) forControlEvents:UIControlEventTouchUpInside];
    [toolbar addSubview:doneButton];
    
}
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
}

- (void) changeLeftIconWhite:(BOOL)iswhite{
    if(inputlefticon==nil)
    {
        inputlefticon=[[UIImageView alloc] initWithFrame:CGRectMake(exfeeList.frame.origin.x+6, 14, 18, 18)];
        [toolbar addSubview:inputlefticon];
    }
    
    if(iswhite==YES){
        inputlefticon.image=[UIImage imageNamed:@"exfee_18_white.png"];
        [inputleftmask setHidden:NO];
    }
    else{
        inputlefticon.image=[UIImage imageNamed:@"exfee_18.png"];
        [inputleftmask setHidden:YES];
    }

}

- (void) ErrorHint:(BOOL)hidden content:(NSString*)content{
    CGRect suggectrect=[suggestionTable frame];
    if(hidden==YES){
        suggectrect.origin.y-=44;
        suggectrect.size.height+=44;
    }else{
        suggectrect.origin.y+=44;
        suggectrect.size.height-=44;
    }
    if(errorHint==nil){
        errorHint=[[UIView alloc] initWithFrame:CGRectMake(0, 44, self.view.frame.size.width, 44)];
        [self.view addSubview:errorHint];
        errorHinticon=[[UIImageView alloc] initWithFrame:CGRectMake(12, 13, 18, 18)];
        errorHinticon.image=[UIImage imageNamed:@"exclamation.png"];
        [errorHint addSubview:errorHinticon];
        errorHintLabel=[[UILabel alloc] initWithFrame:CGRectMake(12+18+6+6, 13,self.view.frame.size.width-(12+18+6+6)-5 , 21)];
        errorHintLabel.backgroundColor=[UIColor clearColor];
        [errorHintLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:18]];
        [errorHintLabel setTextColor:[UIColor colorWithRed:204/255.0f green:81/255.0f blue:71/255.0f alpha:1]];
        [errorHintLabel setShadowColor:[UIColor blackColor]];
        [errorHintLabel setShadowOffset:CGSizeMake(0, 1)];
        [errorHint addSubview:errorHintLabel];
    }
    errorHintLabel.text=content;
    [UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.3];
    [suggestionTable setFrame:suggectrect];
    [UIView commitAnimations];
    
    if(hidden==YES){
        [errorHint setHidden:YES];
        CABasicAnimation *fadeoutAnimation=[CABasicAnimation animationWithKeyPath:@"opacity"];

        fadeoutAnimation.fillMode = kCAFillModeForwards;
        fadeoutAnimation.duration=0.5;
        fadeoutAnimation.removedOnCompletion =NO;
        fadeoutAnimation.fromValue=[NSNumber numberWithFloat:1.0];
        fadeoutAnimation.toValue=[NSNumber numberWithFloat:0.0];
        [errorHint.layer addAnimation:fadeoutAnimation forKey:@"fadeout"];
    }else{
        [errorHint setHidden:NO];
        CABasicAnimation *fadeoutAnimation=[CABasicAnimation animationWithKeyPath:@"opacity"];
        fadeoutAnimation.fillMode = kCAFillModeForwards;
        fadeoutAnimation.duration=0.5;
        fadeoutAnimation.removedOnCompletion =NO;
        fadeoutAnimation.fromValue=[NSNumber numberWithFloat:0.0];
        fadeoutAnimation.toValue=[NSNumber numberWithFloat:1.0];
        [errorHint.layer addAnimation:fadeoutAnimation forKey:@"fadein"];
    }


}
- (void)dealloc {
    [inputlefticon release];
    [errorHinticon release];
    [errorHintLabel release];
    [errorHint release];
    [super dealloc];
}
- (BOOL) showErrorHint{
    if([(GatherViewController*)gatherview exfeeIdentitiesCount]+[exfeeList bubblecount]>=12){
        if(errorHint==nil||[errorHint isHidden]==YES){
            [self ErrorHint:NO content:@"12 exfees maximum"];
        }
        return YES;
    }
    else{
        if(errorHint!=nil && [errorHint isHidden]==NO)
            [self ErrorHint:YES content:@""];
    }
    return NO;
}


- (IBAction) Close:(id) sender{
    [self dismissModalViewControllerAnimated:YES];    
}
- (void) done:(id)sender{
    NSArray *customobjects=[exfeeList bubbleCustomObjects];
    for(Invitation* invitation in customobjects)
        [(GatherViewController*)gatherview addExfee:invitation];
    [self dismissModalViewControllerAnimated:YES];    
}
- (IBAction)textDidChange:(UITextField*)textField{
    if(exfeeInput.text!=nil && exfeeInput.text.length>=1) {
        //[exfeeList bubblecount]+
        
        showInputinSuggestion=YES;
        [APIProfile LoadSuggest:exfeeInput.text delegate:self];
        [self loadIdentitiesFromDataStore:exfeeInput.text];
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

- (void)loadIdentitiesFromDataStore:(NSString*)input{
    [suggestIdentities release];
    suggestIdentities=nil;
    NSFetchRequest* request = [Identity fetchRequest];
    NSSortDescriptor* descriptor = [NSSortDescriptor sortDescriptorWithKey:@"created_at" ascending:NO];
    
    NSString *inputpredicate=[NSString stringWithFormat:@"*%@*",input];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"((name like[c] %@) OR (external_username like[c] %@) OR (external_id like[c] %@) OR (nickname like[c] %@)) AND provider != %@ AND  provider != %@ ",inputpredicate,inputpredicate,inputpredicate,inputpredicate,@"iOSAPN",@"android"];
    [request setPredicate:predicate];
    [request setSortDescriptors:[NSArray arrayWithObject:descriptor]];
    NSMutableArray *temp=[[NSMutableArray alloc]initWithCapacity:10];
    NSArray *suggestwithselected=[[Identity objectsWithFetchRequest:request] retain];
    for (Identity *identity in suggestwithselected){
        BOOL flag=NO;
        
        for (Invitation *selected in ((GatherViewController*)gatherview).exfeeIdentities){
            if([selected.identity.identity_id intValue]==[identity.identity_id intValue])
            {
                flag=YES;
                continue;
            }
        }
        for (Invitation *selected in exfeeList.bubbleCustomObjects){
            if([selected.identity.identity_id intValue]==[identity.identity_id intValue])
            {
                flag=YES;
                continue;
            }
        }

        
        if(flag==NO)
            [temp addObject:identity];
    }
    
    suggestIdentities=[temp retain];
    [temp release];
    [suggestionTable reloadData];
}
- (IBAction)editingDidEnd:(UITextField*)textField{
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
//    [self addByText];
    return NO;
}

//- (void) addByText{
//    NSCharacterSet *split=[NSCharacterSet characterSetWithCharactersInString:@",;"];
//    NSArray *identity_list=[exfeeInput.text componentsSeparatedByCharactersInSet:split];
//    NSString *json=@"";
//    for(NSString *identity_input in identity_list) {
//        NSString *provider=[Util findProvider:identity_input];
//        if(![provider isEqualToString:@""]) {
//            if(![json isEqualToString:@""])
//                json=[json stringByAppendingString:@","];
//            json=[json stringByAppendingFormat:@"{\"provider\":\"%@\",\"external_username\":\"%@\"}",provider,identity_input];
//        }
//    }
//    json=[NSString stringWithFormat:@"[%@]",json];
//    [self getIdentity:json];
//}

- (void) addByInputIdentity:(NSString*)input{

    NSString *json=@"";
    NSString *provider=[Util findProvider:input];
    if(![provider isEqualToString:@""]) {
        if(![json isEqualToString:@""])
            json=[json stringByAppendingString:@","];
        json=[json stringByAppendingFormat:@"{\"provider\":\"%@\",\"external_username\":\"%@\"}",provider,input];
    }
    json=[NSString stringWithFormat:@"[%@]",json];
    
    AppDelegate *app=(AppDelegate *)[[UIApplication sharedApplication] delegate];
    RKClient *client = [RKClient sharedClient];
    [client setBaseURL:[RKURL URLWithBaseURLString:API_V2_ROOT]];

    NSString *endpoint = [NSString stringWithFormat:@"/identities/get"];
    
    RKParams* rsvpParams = [RKParams params];
    [rsvpParams setValue:json forParam:@"identities"];
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
                                invitation.by_identity=((GatherViewController*)gatherview).default_user.default_identity;
                                [exfeeList addBubble:input customObject:invitation];
                                if([exfeeList bubblecount]>0)
                                    [self changeLeftIconWhite:YES];

                            }
                        }
                }
            }
        };
        request.onDidFailLoadWithError=^(NSError *error){
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
    
        if(identity.provider!=nil && ![identity.provider isEqualToString:@""]){

            NSString *iconname=[NSString stringWithFormat:@"identity_%@_18_grey.png",identity.provider];
            UIImage *icon=[UIImage imageNamed:iconname];
            cell.providerIcon=icon;
        }
        if(identity.avatar_filename!=nil) {
            UIImage *avatar = [[ImgCache sharedManager] getImgFromCache:identity.avatar_filename];
            if(avatar==nil || [avatar isEqual:[NSNull null]])
            {
                cell.avatar=[UIImage imageNamed:@"portrait_default.png"];
                dispatch_queue_t imgQueue = dispatch_queue_create("fetchimg thread", NULL);
                dispatch_async(imgQueue, ^{
                    UIImage *avatar = [[ImgCache sharedManager] getImgFrom:identity.avatar_filename];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if(avatar!=nil && ![avatar isEqual:[NSNull null]]) {
                            cell.avatar=avatar;
                        }
                    });
                });
                dispatch_release(imgQueue);
            }
            else
                cell.avatar=avatar;
        }
//    }
    return cell;
    
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Identity *identity=[suggestIdentities objectAtIndex:indexPath.row];
    Invitation *invitation =[Invitation object];
    invitation.rsvp_status=@"NORESPONSE";
    invitation.identity=identity;
    invitation.by_identity=((GatherViewController*)gatherview).default_user.default_identity;


    NSString *identity_name=identity.nickname;
    if(identity_name==nil || [identity_name isEqualToString:@""])
        identity_name=identity.name;
    if(identity_name==nil || [identity_name isEqualToString:@""])
        identity_name=identity.external_username;
    if(identity_name==nil || [identity_name isEqualToString:@""])
        identity_name=identity.external_id;
    
    [exfeeList addBubble:identity_name customObject:invitation];
    if([exfeeList bubblecount]>0)
        [self changeLeftIconWhite:YES];

//    [self ErrorHint:NO content:@"12 exfees maximum"];
//    [self changeLeftIcon];
}
#pragma mark RKObjectLoaderDelegate methods

- (void)objectLoader:(RKObjectLoader *)objectLoader didLoadObjects:(NSArray *)objects {
    
    if([objects count]>0) {
        if([objectLoader.userData isEqualToString:@"suggest"])
            [self loadIdentitiesFromDataStore:[exfeeList getInput]];
    }
}

- (void)objectLoader:(RKObjectLoader *)objectLoader didFailWithError:(NSError *)error {
    //    [self stopLoading];
}

#pragma mark EXBubbleScrollViewDelegate methods
- (void) deleteLastBubble:(EXBubbleScrollView *)bubbleScrollView deletedbubble:(EXBubbleButton*)bubble{
    [self showErrorHint];
    if([exfeeList bubblecount]==0)
        [self changeLeftIconWhite:NO];

}


- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
//    if(scrollView.contentOffset.x>5&&scrollView.contentOffset.x<20)
//        [self changeLeftIconWhite:NO];
//    if(scrollView.contentOffset.x>20)
//        [self changeLeftIconWhite:YES];
//    else
//        [self changeLeftIconWhite:NO];
}
- (void)OnInputConfirm:(EXBubbleScrollView *)bubbleScrollView textField:(UITextField*)textfield{
//    [self getIdentity:json];
    NSString *inputtext=[textfield.text stringByTrimmingCharactersInSet:
                         [NSCharacterSet whitespaceAndNewlineCharacterSet]];

    [self addByInputIdentity:inputtext];
}
- (id)customObject:(EXBubbleScrollView *)bubbleScrollView input:(NSString*)input{
    NSDictionary *dictionary=[[[NSDictionary alloc] initWithObjectsAndKeys:input,@"name",@"id",@"id", nil ] autorelease];
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
- (BOOL) inputTextChange:(EXBubbleScrollView *)bubbleScrollView input:(NSString*)input{
    if(input!=nil && input.length>=1) {
        if([self showErrorHint]==YES)
            return YES;
        showInputinSuggestion=YES;
        [APIProfile LoadSuggest:input delegate:self];
        [self loadIdentitiesFromDataStore:input];
    }
    if(input==nil || [input isEqualToString:@""])
    {
        if(suggestIdentities!=nil){
            [suggestIdentities release];
            suggestIdentities=nil;
            [suggestionTable reloadData];
        }
    }
    return YES;
}
@end
