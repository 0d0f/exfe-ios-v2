//
//  GatherViewController.m
//  EXFE
//
//  Created by huoju on 6/17/12.
//
//

#import "GatherViewController.h"

@interface GatherViewController ()

@end

@implementation GatherViewController

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

    exfeeIdentities=[[NSMutableArray alloc] initWithCapacity:12];
    AppDelegate *app=(AppDelegate *)[[UIApplication sharedApplication] delegate];

    crosstitle.text=[NSString stringWithFormat:@"Meet %@",app.username];
    [crosstitle becomeFirstResponder];

    suggestionTable = [[UITableView alloc] initWithFrame:CGRectMake(0,0,60,60) style:UITableViewStylePlain];
    suggestionTable.dataSource=self;
    suggestionTable.delegate=self;
    
    [exfeeShowview setDataSource:self];
    [exfeeShowview setDelegate:self];
    [self addDefaultIdentity];
    
    map=[[MKMapView alloc] initWithFrame:CGRectMake(149,271,152,117)];
    [self.view addSubview:map];
    
    WildcardGestureRecognizer * tapInterceptor = [[WildcardGestureRecognizer alloc] init];
    tapInterceptor.touchesBeganCallback = ^(NSSet * touches, UIEvent * event) {
        NSLog(@"map click");
        [self ShowPlaceView];
        //        self.lockedOnUserLocation = NO;
    };
    [map addGestureRecognizer:tapInterceptor];

    // Do any additional setup after loading the view from its nib.
}



- (void) addDefaultIdentity{
    AppDelegate *app=(AppDelegate *)[[UIApplication sharedApplication] delegate];
	NSFetchRequest* request = [User fetchRequest];
    NSPredicate *predicate = [NSPredicate
                              predicateWithFormat:@"user_id = %u", app.userid];    
    [request setPredicate:predicate];
	NSArray *users = [[User objectsWithFetchRequest:request] retain];
    
    if(users!=nil && [users count] >0)
    {
        User *user=[users objectAtIndex:0];
        if(user!=nil){
            Invitation *invitation=[Invitation object];
            invitation.rsvp_status=@"ACCEPTED";
            invitation.identity=user.default_identity;
            [exfeeIdentities addObject:invitation];
            [exfeeShowview reloadData];
        }
    }
}
- (IBAction) Gather:(id) sender{
    Identity *by_identity=[Identity object];
    by_identity.identity_id=[NSNumber numberWithInt:174];
    
    Cross *cross=[Cross object];
    cross.title=crosstitle.text;
    cross.cross_description=@"test desc";
    cross.by_identity=by_identity;
//    cross.cross_id=[NSNumber numberWithInt:1];
    Invitation *invitation=[Invitation object];
    invitation.identity=by_identity;
    invitation.by_identity=by_identity;
    invitation.rsvp_status=@"ACCEPTED";
    invitation.host=[NSNumber numberWithBool:YES];

    Exfee *exfee=[Exfee object];
    [exfee addInvitationsObject:invitation];
    cross.exfee = exfee;
    
    [APICrosses GatherCross:cross delegate:self];
}
- (void)dealloc {
	[exfeeIdentities release];
    [suggestIdentities release];
    [map release];
    [super dealloc];
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
- (IBAction) Close:(id) sender{
    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction)textEditBegin:(id)textField {
}

- (void) ShowPlaceView{
    PlaceViewController *placeViewController=[[PlaceViewController alloc]initWithNibName:@"PlaceViewController" bundle:nil];
    placeViewController.gatherview=self;
    [self presentModalViewController:placeViewController animated:YES];
    [placeViewController release];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField {

    NSCharacterSet *split=[NSCharacterSet characterSetWithCharactersInString:@",;"];
    NSArray *identity_list=[textField.text componentsSeparatedByCharactersInSet:split];
    NSString *json=@"";
    for(NSString *identity_input in identity_list)
    {
        NSString *provider=[self findProvider:identity_input];
        if(![provider isEqualToString:@""])
        {
            if(![json isEqualToString:@""])
                json=[json stringByAppendingString:@","];
            
            json=[json stringByAppendingFormat:@"{\"provider\":\"%@\",\"external_username\":\"%@\"}",provider,identity_input];
        }
        NSLog(@"%@",provider);
    }
    json=[NSString stringWithFormat:@"[%@]",json];
    [self getIdentity:json];
    return YES;
}
- (IBAction)textDidChange:(UITextField*)textField
{
    if(ExfeeInput.text!=nil && ExfeeInput.text.length>=1) {
        [APIProfile LoadSuggest:ExfeeInput.text delegate:self];
        [self loadIdentitiesFromDataStore];
    }
    else{
        [suggestionTable removeFromSuperview];
    }
}

- (NSString*) findProvider:(NSString*)external_id{
    
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"; 
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex]; 

    if([emailTest evaluateWithObject:external_id]==YES)
        return @"email";

    NSString *twitterRegex = @"@[A-Za-z0-9.-]+";
    NSPredicate *twitterTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", twitterRegex];
    if([twitterTest evaluateWithObject:external_id]==YES)
        return @"twitter";
    
    return @"";
}
- (void) getIdentity:(NSString*)identity_json{
    
    AppDelegate *app=(AppDelegate *)[[UIApplication sharedApplication] delegate];
    RKClient *client = [RKClient sharedClient];
    NSString *endpoint = [NSString stringWithFormat:@"/identities/get"];

    RKParams* rsvpParams = [RKParams params];
    [rsvpParams setValue:identity_json forParam:@"identities"];

//    [manager.client setValue: forHTTPHeaderField:@"token"];
    [client setValue:app.accesstoken forHTTPHeaderField:@"token"];
    [ExfeeInput setEnabled:NO];
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
                            for (NSDictionary *identitydict in identities)
                            {
                                NSString *external_id=[identitydict objectForKey:@"external_id"];
                                NSString *provider=[identitydict objectForKey:@"provider"];
                                NSString *avatar_filename=[identitydict objectForKey:@"avatar_filename"];
                                NSString *identity_id=[identitydict objectForKey:@"id"];
                                
                                Identity *identity=[Identity object];
                                identity.external_id=external_id;
                                identity.provider=provider;
                                identity.avatar_filename=avatar_filename;
                                identity.identity_id=[NSNumber numberWithInt:[identity_id intValue]];
                                Invitation *invitation =[Invitation object];
                                invitation.rsvp_status=@"ACCEPTED";
                                invitation.identity=identity;
                                [exfeeIdentities addObject:invitation];
                                [exfeeShowview reloadData];
                                [suggestionTable removeFromSuperview];
                                
                            }
                            ExfeeInput.text=@"";
                            [ExfeeInput setEnabled:YES];
                        }
                }
            }else {
                    [ExfeeInput setEnabled:YES];
                //Check Response Body to get Data!
            }
        };
        request.delegate=self;
    }];
    
}

- (void)loadIdentitiesFromDataStore {
        [suggestIdentities release];
        NSFetchRequest* request = [Identity fetchRequest];
        NSSortDescriptor* descriptor = [NSSortDescriptor sortDescriptorWithKey:@"created_at" ascending:NO];

        NSString *inputpredicate=[NSString stringWithFormat:@"*%@*",ExfeeInput.text];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"((name like[c] %@) OR (external_username like[c] %@) OR (external_id like[c] %@) OR (nickname like[c] %@)) AND provider != %@ AND  provider != %@ ",inputpredicate,inputpredicate,inputpredicate,inputpredicate,@"iOSAPN",@"android"];
        [request setPredicate:predicate];
        [request setSortDescriptors:[NSArray arrayWithObject:descriptor]];
        NSMutableArray *temp=[[NSMutableArray alloc]initWithCapacity:10];
        NSArray *suggestwithselected=[[Identity objectsWithFetchRequest:request] retain];
        for (Identity *identity in suggestwithselected){
            BOOL flag=NO;
            for (Invitation *selected in exfeeIdentities){
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
        if([suggestIdentities count]>0)
        {
            [suggestionTable reloadData];
            CGRect rect=ExfeeInput.frame;
            [suggestionTable setFrame:CGRectMake(rect.origin.x, rect.origin.y+rect.size.height, rect.size.width, 200)];
            [suggestionTable setHidden:NO];
            [self.view addSubview:suggestionTable];
        }
        else{
            [suggestionTable removeFromSuperview];
        }
}

- (void) setPlace:(NSDictionary*)placedict{
    Place *_place=[Place object];
    _place.title=[placedict objectForKey:@"title"];
    _place.lat=[NSNumber numberWithDouble:[[placedict objectForKey:@"lat"] doubleValue]];
    _place.lng=[NSNumber numberWithDouble:[[placedict objectForKey:@"lng"] doubleValue]];
    _place.place_description =[placedict objectForKey:@"description"];
    _place.external_id=[placedict objectForKey:@"external_id"];
    _place.provider=[placedict objectForKey:@"provier"];
    
}
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {

    UITouch * touch = [touches anyObject];
    if(touch.phase == UITouchPhaseBegan) {
        [crosstitle resignFirstResponder];
        [map becomeFirstResponder];
    }
//    NSLog(@"click view");
}
#pragma mark RKObjectLoaderDelegate methods

- (void)objectLoader:(RKObjectLoader *)objectLoader didLoadObjects:(NSArray *)objects {

    if([objects count]>0)
    {
        AppDelegate *app=(AppDelegate *)[[UIApplication sharedApplication] delegate];
        if([objectLoader.userData isEqualToString:@"suggest"])
            [self loadIdentitiesFromDataStore];
        else
            [app GatherCrossDidFinish];
    }
}

- (void)objectLoader:(RKObjectLoader *)objectLoader didFailWithError:(NSError *)error {
    NSLog(@"Error!:%@",error);
//    [self stopLoading];
}

#pragma mark UITableView Datasource methods

- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section {
    if(suggestIdentities)
        return [suggestIdentities count];
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"suggest view";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
	{
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
	
    Identity *identity=[suggestIdentities objectAtIndex:indexPath.row];
	cell.textLabel.text = identity.name;
	
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Identity *identity=[suggestIdentities objectAtIndex:indexPath.row];
    Invitation *invitation =[Invitation object];
    invitation.rsvp_status=@"ACCEPTED";
    invitation.identity=identity;

    [exfeeIdentities addObject:invitation];
    [exfeeShowview reloadData];
    [suggestionTable removeFromSuperview];
}

#pragma mark EXImagesCollectionView Datasource methods

- (NSInteger) numberOfimageCollectionView:(EXImagesCollectionView *)imageCollectionView{
    return [exfeeIdentities count];
}
- (UIImage *)imageCollectionView:(EXImagesCollectionView *)imageCollectionView imageAtIndex:(int)index{
    Invitation *invitation =[exfeeIdentities objectAtIndex:index];
    UIImage *avatar = [[ImgCache sharedManager] getImgFrom:invitation.identity.avatar_filename];
    return avatar;
}

#pragma mark EXImagesCollectionView delegate methods
- (void)imageCollectionView:(EXImagesCollectionView *)imageCollectionView didSelectRowAtIndex:(int)index row:(int)row col:(int)col {
    
    NSLog(@"exfee click index:%i, row:%i, col:%i",index,row,col);
}

@end
