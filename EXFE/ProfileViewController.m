//
//  ProfileViewController.m
//  EXFE
//
//  Created by ju huo on 6/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ProfileViewController.h"
#import "APIProfile.h"
#import "ImgCache.h"
#import "User+EXFE.h"
#import "Identity+EXFE.h"
#import "CrossesViewController.h"
#import "AppDelegate.h"
#import "WCAlertView.h"


#define DECTOR_HEIGHT                    (100)

@interface ProfileViewController ()

@end

@implementation ProfileViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (void)dealloc
{
    [username release];
    [useravatar release];
    
    [headerView release];
    
    [_identitiesData release];
    [super dealloc];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    CGRect b = self.view.bounds;
    
    headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(b), DECTOR_HEIGHT)];
    {
        useravatar = [[UIImageView alloc] initWithFrame:CGRectMake(233, 18, 64, 64)];
        useravatar.layer.cornerRadius = 2;
        useravatar.clipsToBounds = YES;
        [headerView addSubview:useravatar];
        
        UIImageView * mask = [[UIImageView alloc] initWithFrame:headerView.bounds];
        mask.image = [UIImage imageNamed:@"profile_title_mask.png"];
        [headerView addSubview:mask];
        [mask release];
        
        username = [[UILabel alloc] initWithFrame:CGRectMake(40, DECTOR_HEIGHT / 2 - 56 / 2, 180, 56)];
        username.backgroundColor = [UIColor clearColor];
        username.lineBreakMode = UILineBreakModeWordWrap;
        username.numberOfLines = 2;
        username.textColor = [UIColor COLOR_SNOW];
        username.font=[UIFont fontWithName:@"HelveticaNeue-Bold" size:20];
        username.shadowColor = [UIColor blackColor];
        username.shadowOffset = CGSizeMake(0, 1);
        [headerView addSubview:username];
        
        UIView *shadow = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMinX(headerView.bounds), CGRectGetMaxY(headerView.bounds) - 4, CGRectGetWidth(headerView.bounds), 4)];
        [shadow setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"shadow_4up.png"]]];
        [headerView addSubview:shadow];
        [shadow release];
    }
    [self.view addSubview:headerView];
    
    btnBack = [UIButton buttonWithType:UIButtonTypeCustom ];
    [btnBack setFrame:CGRectMake(0, DECTOR_HEIGHT / 2 - 44 / 2, 20, 44)];
    btnBack.backgroundColor = [UIColor COLOR_WA(0x33, 0xAA)];
    [btnBack setImage:[UIImage imageNamed:@"back.png"] forState:UIControlStateNormal];
    [btnBack setImage:[UIImage imageNamed:@"back_pressed.png"] forState:UIControlStateHighlighted];
    [btnBack addTarget:self action:@selector(gotoBack:) forControlEvents:UIControlEventTouchUpInside];
    [self.view  addSubview:btnBack];
    
//    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"x_bg.png"]]];

    tableview.backgroundColor = [UIColor clearColor];
    tableview.opaque = NO;
    tableview.backgroundView = nil;
    tableview.frame = CGRectMake(0, DECTOR_HEIGHT, CGRectGetWidth(b), CGRectGetHeight(b) - DECTOR_HEIGHT);
    
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(touchesBegan:)];
    [gestureRecognizer setCancelsTouchesInView:NO];
    [tableview addGestureRecognizer:gestureRecognizer];
    [gestureRecognizer release];
    
    tableview.delegate=self;
    tableview.dataSource=self;
    
    
    [self refreshUI];
    
    UITapGestureRecognizer *tapHeaderRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapProfileHeader:)];
    [headerView addGestureRecognizer:tapHeaderRecognizer];
    [tapHeaderRecognizer release];
    
    [self syncUser];
}

- (void)gotoBack:(UIButton*)sender{
    [[RKObjectManager sharedManager].operationQueue cancelAllOperations];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void) syncUser{
    int user_id = [self.user.user_id intValue];
    [APIProfile LoadUsrWithUserId:user_id
                        success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                            self.user = [User getUserById:user_id];
                            [self refreshUI];
                        }
                        failure:^(RKObjectRequestOperation *operation, NSError *error) {
                            NSLog(@"Error!:%@",error);
                        }];
}


- (void)touchesBegan:(UITapGestureRecognizer*)sender{
    CGPoint location= [sender locationInView:footerView];
    
    CGRect signoutbuttonRect = [buttonsignout frame];
    if(CGRectContainsPoint(signoutbuttonRect, location))
    {
        [self Logout];
    }
    
}

- (void)tapProfileHeader:(UITapGestureRecognizer*)sender
{
    CGPoint location = [sender locationInView:sender.view];
//    UIView *tappedView = [sender.view hitTest:location withEvent:nil];
    if (CGRectContainsPoint(username.frame, location)) {
        [WCAlertView showAlertWithTitle:@"Set name"
                                message:nil
                     customizationBlock:^(WCAlertView *alertView) {
                         alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
                         UITextField *field = [alertView textFieldAtIndex:0];
                         field.text = username.text;
                         
                    }
                        completionBlock:^(NSUInteger buttonIndex, WCAlertView *alertView) {
                            // Cancel 1
                            // Set 0
                            if (buttonIndex == 0) {
                                UITextField *field = [alertView textFieldAtIndex:0];
                                NSString *name = field.text;
                                if (name && name.length > 0) {
                                    [APIProfile updateName:name success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                        if ([operation.response statusCode] == 200 && [responseObject isKindOfClass:[NSDictionary class]]){
                                            NSDictionary *body=responseObject;
                                            if([body isKindOfClass:[NSDictionary class]]) {
                                                id code=[[body objectForKey:@"meta"] objectForKey:@"code"];
                                                if(code){
                                                    if([code intValue]==200) {
                                                        NSDictionary *responseobj=[body objectForKey:@"response"];
                                                        if([responseobj isKindOfClass:[NSDictionary class]]){
                                                            // We need new server api to support restful action to avoid following requests.
                                                            [self syncUser];
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                        
                                    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                    }];
                                }
                            }
                        }
                      cancelButtonTitle:@"Cancel"
                      otherButtonTitles:@"Set", nil];
        
    } else if (CGRectContainsPoint(useravatar.frame, location)){
        FullScreenViewController *viewcontroller = [[FullScreenViewController alloc] initWithNibName:@"FullScreenViewController" bundle:nil];
        viewcontroller.wantsFullScreenLayout = YES;
        viewcontroller.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        viewcontroller.image = useravatar.image;
        [self presentModalViewController:viewcontroller animated:YES];
        [viewcontroller release];
    }
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)refreshUI{
    [self fillProfileHeader:_user];
    [self fillProfileBody:_user];
}

- (void)fillProfileHeader:(User *)user{
    if (user) {
        username.text = user.name;
        [[ImgCache sharedManager] fillAvatar:useravatar with:user.avatar_filename byDefault:[UIImage imageNamed:@"portrait_default.png"]];
    }
}

- (void)fillProfileBody:(User*)user{
    NSArray* data = [self prepareTableData];
    [data retain];
    [_identitiesData release];
    _identitiesData = data;
    
    [tableview reloadData];
}

- (NSArray*)prepareTableData {

        
    NSMutableArray* identities_section=[[NSMutableArray alloc] initWithCapacity:10];
    NSMutableArray* devices_section=[[NSMutableArray alloc] initWithCapacity:5];
    
    for (Identity *identity in _user.identities)
    {
        if([identity.status isEqualToString:@"CONNECTED"] || [identity.status isEqualToString:@"VERIFYING"]|| [identity.status isEqualToString:@"REVOKED"])
        {
            if([identity.provider isEqualToString:@"iOSAPN"]|| [identity.provider isEqualToString:@"Android"])
            {
                [devices_section addObject:identity];
            }
            else {
                [identities_section addObject:identity];
            }
        }
    }
    NSArray *sorted_identities_section;
    sorted_identities_section = [identities_section sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
        return [[(Identity*)a a_order] compare:[(Identity*)b a_order]];
    }];
    
    NSArray *identitiesData = [NSArray arrayWithObjects:[[sorted_identities_section mutableCopy] autorelease],devices_section, nil];
    [devices_section release];
    [identities_section release];
    return identitiesData;
}

#pragma mark UITableViewDataSource methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [_identitiesData count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    int count = [[_identitiesData objectAtIndex:section] count];
    if(section == 0){
        BOOL connected = NO;
        for(Identity *identity in _user.identities){
            if([identity.status isEqualToString:@"CONNECTED"])
                connected = YES;
        }
        if(connected == YES)
            count = count + 1;
    }
    return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

	NSString* reuseIdentifier = @"Profile Cell";
    ProfileCellView *cell = (ProfileCellView*)[tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    
    if(nil == cell) {
        [[NSBundle mainBundle] loadNibNamed:@"ProfileCellView" owner:self options:nil];
        cell = tblCell;
    }
    if([indexPath section] == 0 && indexPath.row == [[_identitiesData objectAtIndex:[indexPath section]] count]){
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"addidentitybutton"];
        if (cell == nil) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"addidentitybutton"] autorelease];
        }
        cell.textLabel.text = @"Add identity...";
        cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:16];
        return cell;
    }
    Identity *identity = [[_identitiesData objectAtIndex:[indexPath section]]  objectAtIndex:indexPath.row];
    
    if([indexPath section]==0)
    {
        
        [[ImgCache sharedManager] fillAvatarWith: identity.avatar_filename
                                       byDefault: [UIImage imageNamed:@"portrait_default.png"]
                                          using: ^(UIImage* image){
                                              [cell setAvartar:image];
                                          }];
        
        [cell setLabelName:[identity getDisplayName]];
        [cell setLabelIdentity:[identity getDisplayIdentity]];
        
        if(identity.provider!=nil && ![identity.provider isEqualToString:@""]){
            
            NSString *iconname=[NSString stringWithFormat:@"identity_%@_18_grey.png",identity.provider];
            UIImage *icon=[UIImage imageNamed:iconname];
            [cell setProvider:icon];
        }
        
        [cell setStatusText:@""];

        cell.identity_id=[identity.identity_id intValue];
        if(![identity.status isEqualToString:@"CONNECTED"])
        {
            NSString *statusname=[NSString stringWithFormat:@"exclamation.png"];
            UIImage *statusnameicon=[UIImage imageNamed:statusname];
            [cell setStatus:statusnameicon];
            [cell setVerifyAction:self action:@selector(showAlert:)];
            if([identity.status isEqualToString:@"VERIFYING"])
                [cell setStatusText:@"Verifying..."];
            else
                [cell setStatusText:@"revoked"];
        }
        return cell;
    }
    else
    {
        NSString *iconname=@"";
        if([identity.provider isEqualToString:@"iOSAPN"])
            iconname=@"device_iphone.png";
        else if([identity.provider isEqualToString:@"android"])
            iconname=@"device_android.png";
           
        if(![iconname isEqualToString:@""])
        {
            UIImage *img = [UIImage imageNamed:iconname];
            [cell setAvartar:img];
        }
        [cell setLabelStatus:1];
        [cell setLabelName:identity.external_username];
        
        
        if([identity.external_id isEqualToString:[[NSUserDefaults standardUserDefaults] stringForKey:@"devicetoken"]])
        {
            [cell IsThisDevice:@""];
        }
        return cell;
    }    
	return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if(section == [_identitiesData count] - 1)
        return 10+62+44;
    return 1.0;
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    if (section == 1){
        if(footerView == nil) {
            footerView  = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 10+62+44)];
            
            buttonsignout = [UIUnderlinedButton buttonWithType:UIButtonTypeCustom];
            [buttonsignout setTitle:@"Sign out" forState:UIControlStateNormal];
            [buttonsignout.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:16]];
            [buttonsignout setTitleColor:[UIColor COLOR_RGB(0xE5, 0x2E, 0x53)] forState:UIControlStateNormal];
            [buttonsignout setFrame:CGRectMake(200, 64, 100, 44)];
            [buttonsignout setBackgroundColor:[UIColor clearColor]];
            [buttonsignout addTarget:self action:@selector(Logout) forControlEvents:UIControlEventTouchUpInside];
            [footerView addSubview:buttonsignout];

            UIUnderlinedButton *buttonhere = [UIUnderlinedButton buttonWithType:UIButtonTypeCustom];
            [buttonhere setTitle:@"Here" forState:UIControlStateNormal];
            [buttonhere.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:16]];
            [buttonhere setTitleColor:[UIColor COLOR_RGB(0xE5, 0x2E, 0x53)] forState:UIControlStateNormal];
            [buttonhere setFrame:CGRectMake(10, 64, 100, 44)];
            [buttonhere setBackgroundColor:[UIColor clearColor]];
            [buttonhere addTarget:self action:@selector(showHere) forControlEvents:UIControlEventTouchUpInside];
            [footerView addSubview:buttonhere];

          
            UIButton *buttonrome = [UIButton buttonWithType:UIButtonTypeCustom];
            [buttonrome setTitle:@"“Rome wasn't built in a day.”" forState:UIControlStateNormal];
            [buttonrome.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Italic" size:16]];
            [buttonrome setTitleColor:[UIColor COLOR_RGB(127, 127, 127)] forState:UIControlStateNormal];
            [buttonrome setFrame:CGRectMake(40, 20, 240, 25)];
            [buttonrome setBackgroundColor:[UIColor clearColor]];
            buttonrome.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
            buttonrome.backgroundColor = [UIColor COLOR_WA(0xE6, 0xFF)];
            buttonrome.layer.cornerRadius = 12.5;
            buttonrome.layer.masksToBounds = YES;
            [buttonrome addTarget:self action:@selector(showRome) forControlEvents:UIControlEventTouchUpInside];
            [footerView addSubview:buttonrome];
            
            
        }
        return footerView;
    }
    return nil;
}

- (void) showRome{
    WelcomeView *welcome=[[WelcomeView alloc] initWithFrame:self.view.bounds];
    [welcome setBackgroundColor:[UIColor colorWithWhite:0 alpha:0.5f]];
//    welcome.parent=self;
    
    [self.view addSubview:welcome];
    [self.view bringSubviewToFront:welcome];
//    self.tableView.bounces=NO;
    [welcome release];
}

- (void)showHere{
    HereViewController *here =[[HereViewController alloc] initWithNibName:nil bundle:nil];
    [self presentModalViewController:here animated:YES];
    [here release];
}

#pragma mark UITableViewDelegate methods
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    int count = [[_identitiesData objectAtIndex:indexPath.section] count];
    if (indexPath.section == 0) {
        if (count == indexPath.row) {
            AddIdentityViewController *addidentityView=[[[AddIdentityViewController alloc]initWithNibName:@"AddIdentityViewController" bundle:nil] autorelease];
            addidentityView.profileview=self;
            [self.navigationController pushViewController:addidentityView animated:YES];
        }else {
            Identity *identity = [[_identitiesData objectAtIndex:[indexPath section]]  objectAtIndex:indexPath.row];
            [WCAlertView showAlertWithTitle:@"Set name for"
                                    message:[identity getDisplayIdentity]
                         customizationBlock:^(WCAlertView *alertView) {
                             alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
                             UITextField *field = [alertView textFieldAtIndex:0];
                             field.text = identity.name;
                             field.placeholder = [identity getDisplayName];
                         }
                            completionBlock:^(NSUInteger buttonIndex, WCAlertView *alertView) {
                                // Cancel 1
                                // Set 0
                                [tableView deselectRowAtIndexPath:indexPath animated:YES];
                                if (buttonIndex == 0) {
                                    UITextField *field = [alertView textFieldAtIndex:0];
                                    NSString *name = field.text;
                                    if (name && name.length > 0) {
                                        [APIProfile updateIdentity:identity name:name andBio:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                            if ([operation.response statusCode] == 200 && [responseObject isKindOfClass:[NSDictionary class]]){
                                                NSDictionary *body=responseObject;
                                                if([body isKindOfClass:[NSDictionary class]]) {
                                                    id code=[[body objectForKey:@"meta"] objectForKey:@"code"];
                                                    if(code){
                                                        if([code intValue]==200) {
                                                            NSDictionary *responseobj=[body objectForKey:@"response"];
                                                            if([responseobj isKindOfClass:[NSDictionary class]]){
                                                                // We need new server api to support restful action to avoid following requests.
                                                                [self syncUser];
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                            
                                        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                        }];
                                    }
                                }
                            }
                          cancelButtonTitle:@"Cancel"
                          otherButtonTitles:@"Set", nil];
        }
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        if(indexPath.section == 0){
            Identity *identity = [[_identitiesData objectAtIndex:[indexPath section]]  objectAtIndex:indexPath.row];
            [self deleteIdentity:[identity.identity_id intValue]];
        }
    }
}

- (NSIndexPath*) getIndexById:(int)identity_id{
    NSInteger section = 0;
    for(NSArray *identitysection in _identitiesData)
    {
        NSInteger idx = 0;
        for(Identity *identity in identitysection){
            if([identity.identity_id intValue] == identity_id){
                NSIndexPath *path = [NSIndexPath indexPathForRow:idx inSection:section];
                return path;
            }
            idx++;
        }
        section++;
    }
    return nil;
}

- (void) deleteIdentityUI:(int)identity_id{
    NSIndexPath *path=[self getIndexById:identity_id];
    [((NSMutableArray*)[_identitiesData objectAtIndex:path.section]) removeObjectAtIndex:path.row];
    [tableview beginUpdates];
    [tableview deleteRowsAtIndexPaths:[NSArray arrayWithObject:path]  withRowAnimation:UITableViewRowAnimationFade];
    [tableview endUpdates];
}

- (void) deleteIdentity:(int)identity_id{
    
    AppDelegate *app=(AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSString *endpoint = [NSString stringWithFormat:@"%@/users/%u/deleteIdentity",API_ROOT,app.userid];
    RKObjectManager *objectManager = [RKObjectManager sharedManager];
    objectManager.HTTPClient.parameterEncoding=AFFormURLParameterEncoding;
    [objectManager.HTTPClient setDefaultHeader:@"token" value:app.accesstoken];
    [objectManager.HTTPClient postPath:endpoint parameters:@{@"identity_id":[NSNumber numberWithInt:identity_id]} success:^(AFHTTPRequestOperation *operation, id responseObject) {
      if ([operation.response statusCode] == 200 && [responseObject isKindOfClass:[NSDictionary class]]){
        NSDictionary *body=responseObject;
        if([body isKindOfClass:[NSDictionary class]]) {
            id code=[[body objectForKey:@"meta"] objectForKey:@"code"];
            if(code){
                if([code intValue]==200) {
                    NSDictionary *responseobj=[body objectForKey:@"response"];
                    if([responseobj isKindOfClass:[NSDictionary class]]){
                        NSString *identity_id_str=[responseobj objectForKey:@"identity_id"];
                        NSString *user_id_str=[responseobj objectForKey:@"user_id"];
                        if(identity_id_str!=nil && user_id_str!=nil){
                            int response_identity_id=[identity_id_str intValue];
                            int response_user_id=[user_id_str intValue];
                            if(response_identity_id==identity_id && response_user_id==app.userid){
                                [self deleteIdentityUI:identity_id];
                            }
                        }
                    }
                }
            }
        }
      }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
      
    }];
}
- (void) Logout {
    [Util signout];
}

- (Identity*) getIdentityById:(int)identity_id{
        for(NSArray *identitysection in _identitiesData)
        {
            for(Identity *identity in identitysection){
                if([identity.identity_id intValue] ==identity_id)
                    return identity;
            }
        }
    return nil;
}

- (void) showAlert:(id)sender{
//    api.local.exfe.com/v2/users/VerifyUserIdentity?token=xxxxxxxxxx identity_id=233
    
    UIButton *button=(UIButton*)sender;
    int identity_id=button.tag;
    Identity *identity=[self getIdentityById:identity_id];
    if(identity_id>0 && identity!=nil) {
        
        if([identity.provider isEqualToString:@"twitter"] || [identity.provider isEqualToString:@"facebook"]){
            NSString *msg=@"Identity authorization has been revoked, please re-authorize.";
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Identity Verification" message:msg delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Re-authorize",nil];
            alert.tag=identity_id;
            [alert show];
            [alert release];
        }else{
            NSString *msg=@"Unverified identity, please check your email for instructions.\nRe-send verification email?";
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Identity Verification" message:msg delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Send",nil];
            alert.tag=identity_id;
            [alert show];
            [alert release];
            
        }
    }
}

- (void) doVerify:(int)identity_id{
  AppDelegate *app=(AppDelegate *)[[UIApplication sharedApplication] delegate];
  NSString *callback=@"oauth://handleOAuthAddIdentity";
  NSString *endpoint = [NSString stringWithFormat:@"%@/users/VerifyUserIdentity",API_ROOT];
  RKObjectManager *objectManager = [RKObjectManager sharedManager];
  objectManager.HTTPClient.parameterEncoding=AFFormURLParameterEncoding;
  [objectManager.HTTPClient setDefaultHeader:@"token" value:app.accesstoken];
  [objectManager.HTTPClient postPath:endpoint parameters:@{@"identity_id":[NSNumber numberWithInt:identity_id],@"device_callback":callback,@"device":@"iOS"} success:^(AFHTTPRequestOperation *operation, id responseObject) {
    if ([operation.response statusCode] == 200 && [responseObject isKindOfClass:[NSDictionary class]]){
      NSDictionary *body=responseObject;
      if([body isKindOfClass:[NSDictionary class]]) {
            id code=[[body objectForKey:@"meta"] objectForKey:@"code"];
            if(code){
                if([code intValue]==200) {
                    NSDictionary *responseobj=[body objectForKey:@"response"];
                    if([[responseobj objectForKey:@"action"] isEqualToString:@"REDIRECT"])
                    {
                        OAuthAddIdentityViewController *oauth=[[OAuthAddIdentityViewController alloc] initWithNibName:@"OAuthAddIdentityViewController" bundle:nil];
                        oauth.parentView=self;
                        oauth.oauth_url=[responseobj objectForKey:@"url"];
                        [self presentModalViewController:oauth animated:YES];
                        [oauth release];

                    }
                }
                else{
                }
            }
        }
      }

    
  } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
    
  }];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    //tag 101: save cross
    //tag 102: save exfee
    if(buttonIndex==0)//cancel
    {
    }else if(buttonIndex==1) //retry
    {
        int identity_id=alertView.tag;
        if(identity_id>0) {
            [self doVerify:identity_id];
        }
    }
}

@end
