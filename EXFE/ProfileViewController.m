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
#import "Identity.h"
#import "CrossesViewController.h"
#import "AppDelegate.h"


#define DECTOR_HEIGHT                    (100)

@interface ProfileViewController ()

@end

@implementation ProfileViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        CGRect b = self.view.bounds;
        // Custom initialization
        headerView = [[EXCurveView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(b), DECTOR_HEIGHT) withCurveFrame:CGRectNull];
        //headerView.backgroundColor = [UIColor blueColor];
        
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
        
        [self.view addSubview:headerView];
        [shadow release];
        
        btnBack = [UIButton buttonWithType:UIButtonTypeCustom ];
        [btnBack setFrame:CGRectMake(0, DECTOR_HEIGHT / 2 - 44 / 2, 20, 44)];
        btnBack.backgroundColor = [UIColor COLOR_WA(0x33, 0xAA)];
        [btnBack setImage:[UIImage imageNamed:@"back.png"] forState:UIControlStateNormal];
        [btnBack setImage:[UIImage imageNamed:@"back_pressed.png"] forState:UIControlStateHighlighted];
        [btnBack addTarget:self action:@selector(gotoBack:) forControlEvents:UIControlEventTouchUpInside];
        [self.view  addSubview:btnBack];
        
    }
    return self;
}
- (void)dealloc
{
    [username release];
    if(identitiesData != nil)
        [identitiesData release];
    [super dealloc];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"x_bg.png"]]];
    CGRect b = self.view.bounds;
    //CGRect f = self.view.frame;
    
    AppDelegate *app=(AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"User"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"user_id = %u", app.userid];
    [request setPredicate:predicate];
    RKObjectManager *objectManager = [RKObjectManager sharedManager];
    NSArray *users = [objectManager.managedObjectStore.mainQueueManagedObjectContext executeFetchRequest:request error:nil];

    if(users != nil && [users count] > 0)
    {
        User *_user = [users objectAtIndex:0];
        NSString* imgName = _user.avatar_filename;
        if(imgName!=nil)
        {
            UIImage *image=[[ImgCache sharedManager] getImgFromCache:imgName];
            if(image==nil ||[image isEqual:[NSNull null]]){
                useravatar.image = [UIImage imageNamed:@"portrait_default.png"];
            }else{
                useravatar.image = image;
            }
        }
        username.text =_user.name;
    }
    else{
        useravatar.image=[UIImage imageNamed:@"portrait_default.png"];
    }
//    [users release];
    tableview.backgroundColor = [UIColor clearColor];
    tableview.opaque = NO;
    tableview.backgroundView = nil;
    tableview.frame = CGRectMake(0, DECTOR_HEIGHT, CGRectGetWidth(b), CGRectGetHeight(b) - DECTOR_HEIGHT);
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(touchesBegan:)];
    [gestureRecognizer setCancelsTouchesInView:NO];
    [tableview addGestureRecognizer:gestureRecognizer];
    [gestureRecognizer release];
    
    [tableview reloadData];
    tableview.delegate=self;
    tableview.dataSource=self;
    [self loadObjectsFromDataStore];
    [self refreshIdentities];
    
}



- (void)gotoBack:(UIButton*)sender{
    [[RKObjectManager sharedManager].operationQueue cancelAllOperations];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void) refreshIdentities{
    AppDelegate *app=(AppDelegate *)[[UIApplication sharedApplication] delegate];
  [APIProfile LoadUsrWithUserId:app.userid success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
    [self loadObjectsFromDataStore];
  } failure:^(RKObjectRequestOperation *operation, NSError *error) {
    NSLog(@"Error!:%@",error);
  }];
}


- (void)touchesBegan:(UITapGestureRecognizer*)sender{
    CGPoint location = [sender locationInView:sender.view];
    CGRect useravatarRect=[useravatar frame];
    
    if(CGRectContainsPoint(useravatarRect, location))
    {
        FullScreenViewController *viewcontroller=[[FullScreenViewController alloc] initWithNibName:@"FullScreenViewController" bundle:nil];
        viewcontroller.wantsFullScreenLayout=YES;
        viewcontroller.modalTransitionStyle=UIModalTransitionStyleCrossDissolve;
        viewcontroller.image=useravatar.image;
        [self presentModalViewController:viewcontroller animated:YES];
        [viewcontroller release];
    }
    else{
        CGPoint location2= [sender locationInView:footerView];
        
        CGRect signoutbuttonRect=[buttonsignout frame];
        if(CGRectContainsPoint(signoutbuttonRect, location2))
        {
            [self Logout];
        }
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

- (void)loadObjectsFromDataStore {
    AppDelegate *app=(AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"User"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"user_id = %u", app.userid];
    [request setPredicate:predicate];
    RKObjectManager *objectManager = [RKObjectManager sharedManager];
    NSArray *users = [objectManager.managedObjectStore.mainQueueManagedObjectContext executeFetchRequest:request error:nil];

    if(users!=nil && [users count] >0)
    {
        user=[users objectAtIndex:0];
        username.text=user.name;
        if(identitiesData!=nil)
        {
            [identitiesData release];
        }
        NSMutableArray* identities_section=[[NSMutableArray alloc] initWithCapacity:10];
        NSMutableArray* devices_section=[[NSMutableArray alloc] initWithCapacity:5];
        identitiesData=[[NSMutableArray alloc] initWithCapacity:2];
        
        NSString* imgName = user.avatar_filename; 
        usernametext=imgName;
        if(imgName!=nil)
        {
            UIImage *image=[[ImgCache sharedManager] getImgFromCache:imgName];
            if(image==nil ||[image isEqual:[NSNull null]]){
                useravatar.image=[UIImage imageNamed:@"portrait_default.png"];
                dispatch_queue_t imgQueue = dispatch_queue_create("fetchimg thread", NULL);
                dispatch_async(imgQueue, ^{
                    UIImage *image=[[ImgCache sharedManager] getImgFrom:imgName];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if(image!=nil && ![image isEqual:[NSNull null]]){
                            [useravatar setImage:image];
                            [useravatar setNeedsDisplay];
                        }
                    });
                });
                dispatch_release(imgQueue);
            }else{
                useravatarimg=image;
                [useravatar setImage:image];
//                useravatar.image=[UIImage imageNamed:@"portrait_default.png"];
                [useravatar setNeedsDisplay];
            }
        }
        
        for (Identity *identity in user.identities)
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
        
        [identitiesData addObject:[[sorted_identities_section mutableCopy] autorelease]  ];
        [identitiesData addObject:devices_section];
        [devices_section release];
        [identities_section release];
    }
//    [users release];
    [tableview reloadData];
}

#pragma mark UITableViewDataSource methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [identitiesData count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    int count=[[identitiesData objectAtIndex:section] count];
    if(section==0){
      BOOL connected=NO;
      for(Identity *identity in user.identities){
        if([identity.status isEqualToString:@"CONNECTED"])
           connected=YES;
      }
      if(connected==YES)
        count=count+1;
    }
    return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

	NSString* reuseIdentifier = @"Profile Cell";
    ProfileCellView *cell=(ProfileCellView*)[tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    
    if(nil == cell) {
        [[NSBundle mainBundle] loadNibNamed:@"ProfileCellView" owner:self options:nil];
        cell = tblCell;
    }
    if([indexPath section]==0 && indexPath.row==[[identitiesData objectAtIndex:0] count]){
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"addidentitybutton"];
        if (cell == nil) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"addidentitybutton"] autorelease];
        }
        cell.textLabel.text=@"Add identity...";
        cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:16];
        return cell;
    }
    Identity *identity=[[identitiesData objectAtIndex:[indexPath section]]  objectAtIndex:indexPath.row];
    
    if([indexPath section]==0)
    {
        if(identity.avatar_filename==nil || [identity.avatar_filename isEqualToString:@""] )
        {
            UIImage *img = [UIImage imageNamed:@"portrait_default.png"];
            if((NSNull*)img!=[NSNull null])
                [cell setAvartar:img];
        }
        else
        {
            NSString* imgName = identity.avatar_filename;
            NSString *imgurl = [ImgCache getImgUrl:imgName];
            UIImage *img = [[ImgCache sharedManager] getImgFrom:imgurl];
            if((NSNull*)img!=[NSNull null])
                [cell setAvartar:img];
        }
        if(![identity.name isEqualToString:@""])
            [cell setLabelName:identity.name];
        else
            [cell setLabelName:identity.external_id];

        if([identity.provider isEqualToString:@"email"] ||[identity.provider isEqualToString:@"phone"])
            [cell setLabelIdentity:identity.external_id];
        else{
            [cell setLabelIdentity:[NSString stringWithFormat:@"%@@%@",identity.external_username,identity.provider]];
        }
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
    if(section == [identitiesData count]-1)
        return 10+62+44;
    return 1.0;
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    if (section==0)
        return nil;
    if (section==1)
    if(footerView == nil) {
        footerView  = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 10+62+44)];

        buttonsignout = [UIUnderlinedButton buttonWithType:UIButtonTypeCustom];
        [buttonsignout setTitle:@"Sign out" forState:UIControlStateNormal];
        [buttonsignout.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:16]];
        [buttonsignout setTitleColor:[UIColor COLOR_RGB(0xE5, 0x2E, 0x53)] forState:UIControlStateNormal];
//        [buttonsignout setBackgroundImage:[[UIImage imageNamed:@"btn_red_44.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 6, 0, 6)]  forState:UIControlStateNormal];
        [buttonsignout setFrame:CGRectMake(200, 64, 100, 44)];
        [buttonsignout setBackgroundColor:[UIColor clearColor]];
        [buttonsignout addTarget:self action:@selector(Logout) forControlEvents:UIControlEventTouchUpInside];
        [footerView addSubview:buttonsignout];

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
    
    //return the view for the footer
    return footerView;
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
#pragma mark UITableViewDelegate methods
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    int count=[[identitiesData objectAtIndex:indexPath.section] count];
    if(indexPath.section==0 && count==indexPath.row){
        AddIdentityViewController *addidentityView=[[[AddIdentityViewController alloc]initWithNibName:@"AddIdentityViewController" bundle:nil] autorelease];
        addidentityView.profileview=self;
        [self.navigationController pushViewController:addidentityView animated:YES];
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        if(indexPath.section==0){
            Identity *identity=[[identitiesData objectAtIndex:[indexPath section]]  objectAtIndex:indexPath.row];
            [self deleteIdentity:[identity.identity_id intValue]];
        }
    }
}

- (NSIndexPath*) getIndexById:(int)identity_id{
    NSInteger section=0;
    for(NSArray *identitysection in identitiesData)
    {
        NSInteger idx=0;
        for(Identity *identity in identitysection){
            if([identity.identity_id intValue] ==identity_id){
                NSIndexPath *path=[NSIndexPath indexPathForRow:idx inSection:section];
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
    [((NSMutableArray*)[identitiesData objectAtIndex:path.section]) removeObjectAtIndex:path.row];
    [tableview beginUpdates];
    [tableview deleteRowsAtIndexPaths:[NSArray arrayWithObject:path]  withRowAnimation:UITableViewRowAnimationFade];
    [tableview endUpdates];
}

- (void) deleteIdentity:(int)identity_id{
    
    AppDelegate *app=(AppDelegate *)[[UIApplication sharedApplication] delegate];
//RESTKIT0.2
//    RKClient *client = [RKClient sharedClient];
//    [client setBaseURL:[RKURL URLWithBaseURLString:API_V2_ROOT]];
//    NSString *endpoint = [NSString stringWithFormat:@"/users/%u/deleteIdentity",app.userid];
//    
//    RKParams* rsvpParams = [RKParams params];
//    [rsvpParams setValue:[NSNumber numberWithInt:identity_id] forParam:@"identity_id"];
//    
//    [client setValue:app.accesstoken forHTTPHeaderField:@"token"];
//    [client post:endpoint usingBlock:^(RKRequest *request){
//        request.method=RKRequestMethodPOST;
//        request.params=rsvpParams;
//        request.onDidLoadResponse=^(RKResponse *response){
////            [spin setHidden:YES];
//            //                [MBProgressHUD hideHUDForView:self.view animated:YES];
//            if (response.statusCode == 200) {
//                NSDictionary *body=[response.body objectFromJSONData];
//                if([body isKindOfClass:[NSDictionary class]]) {
//                    id code=[[body objectForKey:@"meta"] objectForKey:@"code"];
//                    if(code){
//                        if([code intValue]==200) {
//                            NSDictionary *responseobj=[body objectForKey:@"response"];
//                            if([responseobj isKindOfClass:[NSDictionary class]]){
//                                NSString *identity_id_str=[responseobj objectForKey:@"identity_id"];
//                                NSString *user_id_str=[responseobj objectForKey:@"user_id"];
//                                if(identity_id_str!=nil && user_id_str!=nil){
//                                    int response_identity_id=[identity_id_str intValue];
//                                    int response_user_id=[user_id_str intValue];
//                                    if(response_identity_id==identity_id && response_user_id==app.userid){
//                                        [self deleteIdentityUI:identity_id];
//                                    }
//                                }
//                                
//                            }
//                        }
//                        
//                    }
//                }
//
//            }
//            
//        };
//        request.onDidFailLoadWithError=^(NSError *error){
////            [spin setHidden:YES];
//            
////            NSLog(@"error %@",error);
//            //                [MBProgressHUD hideHUDForView:self.view animated:YES];
//        };
//    }];
  
}
- (void) Logout {
    [Util signout];
}

- (Identity*) getIdentityById:(int)identity_id{
        for(NSArray *identitysection in identitiesData)
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
//RESTKIT0.2  
//    RKClient *client = [RKClient sharedClient];
//    [client setBaseURL:[RKURL URLWithBaseURLString:API_V2_ROOT]];
//    NSString *endpoint = [NSString stringWithFormat:@"/users/VerifyUserIdentity"];
//    
//    RKParams* rsvpParams = [RKParams params];
//    [rsvpParams setValue:[NSNumber numberWithInt:identity_id] forParam:@"identity_id"];
//    NSString *callback=@"oauth://handleOAuthAddIdentity";
//    [rsvpParams setValue:callback forParam:@"device_callback"];
//    [rsvpParams setValue:@"iOS" forParam:@"device"];
//    
//    AppDelegate *app=(AppDelegate *)[[UIApplication sharedApplication] delegate];
//    [client setValue:app.accesstoken forHTTPHeaderField:@"token"];
//    
//    [client post:endpoint usingBlock:^(RKRequest *request){
//        request.method=RKRequestMethodPOST;
//        request.params=rsvpParams;
//        request.onDidLoadResponse=^(RKResponse *response){
//            //                [MBProgressHUD hideHUDForView:self.view animated:YES];
//            if (response.statusCode == 200) {
//                NSDictionary *body=[response.body objectFromJSONData];
//                
//                if([body isKindOfClass:[NSDictionary class]]) {
//                    id code=[[body objectForKey:@"meta"] objectForKey:@"code"];
//                    if(code){
//                        if([code intValue]==200) {
//                            NSDictionary *responseobj=[body objectForKey:@"response"];
//                            if([[responseobj objectForKey:@"action"] isEqualToString:@"REDIRECT"])
//                            {
////                                NSLog(@"url: %@",[responseobj objectForKey:@"url"]);
//                                OAuthAddIdentityViewController *oauth=[[OAuthAddIdentityViewController alloc] initWithNibName:@"OAuthAddIdentityViewController" bundle:nil];
//                                oauth.parentView=self;
//                                oauth.oauth_url=[responseobj objectForKey:@"url"];
//                                [self presentModalViewController:oauth animated:YES];
//                                [oauth release];
//
//                            }
//                            //                                if([responseobj isKindOfClass:[NSDictionary class]]){
//                            //                                    if([responseobj objectForKey:@"url"]!=nil){
//                            //                                        OAuthAddIdentityViewController *oauth=[[OAuthAddIdentityViewController alloc] initWithNibName:@"OAuthAddIdentityViewController" bundle:nil];
//                            //                                        oauth.parentView=self;
//                            //                                        oauth.oauth_url=[responseobj objectForKey:@"url"];
//                            //                                        [self presentModalViewController:oauth animated:YES];
//                            //                                    }else{
//                            //                                        [self.navigationController popViewControllerAnimated:YES];
//                            //                                    }
//                            //                                }
//                        }
//                        else{
//                            //                                if([[body objectForKey:@"meta"] objectForKey:@"errorType"]!=nil && [[[body objectForKey:@"meta"] objectForKey:@"errorType"] isEqualToString:@"no_connected_identity"] ){
//                            //                                    NSLog(@"error:%@",[[body objectForKey:@"meta"] objectForKey:@"errorType"]);
//                            //                                }
//                        }
//                    }
//                }
//            }
//            
//        };
//        request.onDidFailLoadWithError=^(NSError *error){
////            NSLog(@"error %@",error);
//            //                [MBProgressHUD hideHUDForView:self.view animated:YES];
//        };
//    }];
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
