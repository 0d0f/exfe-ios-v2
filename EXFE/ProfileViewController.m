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
    if(identitiesData != nil)
        [identitiesData release];
    [super dealloc];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"x_bg.png"]]];

    tableview.backgroundColor = [UIColor clearColor];
    tableview.opaque = NO;
    tableview.backgroundView = nil;
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

- (void) refreshIdentities{
    AppDelegate *app=(AppDelegate *)[[UIApplication sharedApplication] delegate];
    [APIProfile LoadUsrWithUserId:app.userid delegate:self];
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
	NSFetchRequest* request = [User fetchRequest];
    NSPredicate *predicate = [NSPredicate
                              predicateWithFormat:@"user_id = %u", app.userid];    
    [request setPredicate:predicate];
	NSArray *users = [[User objectsWithFetchRequest:request] retain];
    
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
            
            return [[(Identity*)a order] compare:[(Identity*)b order]];
        }];
        
        [identitiesData addObject:[[sorted_identities_section mutableCopy] autorelease]  ];
        [identitiesData addObject:devices_section];
        [devices_section release];
        [identities_section release];
    }
    [users release];
    [tableview reloadData];
}


#pragma Mark - RKRequestDelegate
- (void)objectLoader:(RKObjectLoader *)objectLoader didLoadObjects:(NSArray *)objects {
   
        [self loadObjectsFromDataStore];
}

- (void)objectLoader:(RKObjectLoader *)objectLoader didFailWithError:(NSError *)error {
    NSLog(@"Error!:%@",error);
}

#pragma mark UITableViewDataSource methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [identitiesData count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    int count=[[identitiesData objectAtIndex:section] count];
    if(section==0)
        count=count+1;
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
        if([identity.provider isEqualToString:@"email"])
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
-(UIView*)tableView:(UITableView*)tableView viewForHeaderInSection:(NSInteger)section
{
    if(section == 0){
        if(headerView==nil){
            AppDelegate *app=(AppDelegate *)[[UIApplication sharedApplication] delegate];

            NSFetchRequest* request = [User fetchRequest];
            NSPredicate *predicate = [NSPredicate
                                      predicateWithFormat:@"user_id = %u", app.userid];
            [request setPredicate:predicate];
            NSArray *users = [[User objectsWithFetchRequest:request] retain];
            
            
            
            headerView=[[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 111)];
            useravatar=[[UIImageView alloc] initWithFrame:CGRectMake(20, 16, 64, 64)];

            useravatar.layer.cornerRadius=2;
            useravatar.clipsToBounds = YES;
            [headerView addSubview:useravatar];
            
            username=[[UILabel alloc] initWithFrame:CGRectMake(100, 16, 160, 54)];
            username.backgroundColor=[UIColor clearColor];
            username.lineBreakMode=UILineBreakModeWordWrap;
            username.numberOfLines = 0;
            username.textColor=FONT_COLOR_51;
            username.font=[UIFont fontWithName:@"HelveticaNeue-Bold" size:20];
            username.shadowColor=[UIColor whiteColor];
            username.shadowOffset=CGSizeMake(0, 1);
            [headerView addSubview:username];
            if(users!=nil && [users count] >0)
            {
                User *_user=[users objectAtIndex:0];
                NSString* imgName = _user.avatar_filename;
                if(imgName!=nil)
                {
                    UIImage *image=[[ImgCache sharedManager] getImgFromCache:imgName];
                    if(image==nil ||[image isEqual:[NSNull null]])
                        useravatar.image=[UIImage imageNamed:@"portrait_default.png"];
                    else
                        useravatar.image=image;
                }
                username.text=_user.name;
            }
            else
                useravatar.image=[UIImage imageNamed:@"portrait_default.png"];

            
        }
        return headerView;
    }
    return nil;
}
-(CGFloat)tableView:(UITableView*)tableView heightForHeaderInSection:(NSInteger)section
{
    if(section == 0)
        return 111.0;
    return 15.0;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if(section == [identitiesData count]-1)
        return 60;
    return 1.0;
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    if (section==0)
        return nil;
    if (section==1)
    if(footerView == nil) {
        footerView  = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 44)];

        buttonsignout = [UIButton buttonWithType:UIButtonTypeCustom];
        [buttonsignout setTitle:@"Sign Out" forState:UIControlStateNormal];
        [buttonsignout.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:18]];
        [buttonsignout setTitleColor:FONT_COLOR_FA forState:UIControlStateNormal];
        [buttonsignout setBackgroundImage:[[UIImage imageNamed:@"btn_red_44.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 6, 0, 6)]  forState:UIControlStateNormal];

        
        [buttonsignout setFrame:CGRectMake(200, 10, 100, 44)];
        [buttonsignout setBackgroundColor:[UIColor clearColor]];
        [buttonsignout addTarget:self action:@selector(Logout) forControlEvents:UIControlEventTouchUpInside];
        [footerView addSubview:buttonsignout];
        
        UIButton* back = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [back setTitle:@"Back" forState:UIControlStateNormal];
        [back.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:17]];
        [back setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [back setFrame:CGRectMake(20, 10, 100,44)];
        [back setBackgroundColor:[UIColor clearColor]];
        [back addTarget:self action:@selector(gotoBack) forControlEvents:UIControlEventTouchUpInside];
        [footerView addSubview:back];
    }
    
    //return the view for the footer
    return footerView;
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
    RKClient *client = [RKClient sharedClient];
    [client setBaseURL:[RKURL URLWithBaseURLString:API_V2_ROOT]];
    NSString *endpoint = [NSString stringWithFormat:@"/users/%u/deleteIdentity",app.userid];
    
    RKParams* rsvpParams = [RKParams params];
    [rsvpParams setValue:[NSNumber numberWithInt:identity_id] forParam:@"identity_id"];
    
    [client setValue:app.accesstoken forHTTPHeaderField:@"token"];
    [client post:endpoint usingBlock:^(RKRequest *request){
        request.method=RKRequestMethodPOST;
        request.params=rsvpParams;
        request.onDidLoadResponse=^(RKResponse *response){
//            [spin setHidden:YES];
            //                [MBProgressHUD hideHUDForView:self.view animated:YES];
            if (response.statusCode == 200) {
                NSDictionary *body=[response.body objectFromJSONData];
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
            
        };
        request.onDidFailLoadWithError=^(NSError *error){
//            [spin setHidden:YES];
            
            NSLog(@"error %@",error);
            //                [MBProgressHUD hideHUDForView:self.view animated:YES];
        };
    }];
    
}
- (void) Logout {
    [Util signout];
}

- (void) gotoBack {
    [self.navigationController popToRootViewControllerAnimated:YES];
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
    RKClient *client = [RKClient sharedClient];
    [client setBaseURL:[RKURL URLWithBaseURLString:API_V2_ROOT]];
    NSString *endpoint = [NSString stringWithFormat:@"/users/VerifyUserIdentity"];
    
    RKParams* rsvpParams = [RKParams params];
    [rsvpParams setValue:[NSNumber numberWithInt:identity_id] forParam:@"identity_id"];
    NSString *callback=@"oauth://handleOAuthAddIdentity";
    [rsvpParams setValue:callback forParam:@"device_callback"];
    [rsvpParams setValue:@"iOS" forParam:@"device"];
    
    AppDelegate *app=(AppDelegate *)[[UIApplication sharedApplication] delegate];
    [client setValue:app.accesstoken forHTTPHeaderField:@"token"];
    
    [client post:endpoint usingBlock:^(RKRequest *request){
        request.method=RKRequestMethodPOST;
        request.params=rsvpParams;
        request.onDidLoadResponse=^(RKResponse *response){
            //                [MBProgressHUD hideHUDForView:self.view animated:YES];
            if (response.statusCode == 200) {
                NSDictionary *body=[response.body objectFromJSONData];
                
                if([body isKindOfClass:[NSDictionary class]]) {
                    id code=[[body objectForKey:@"meta"] objectForKey:@"code"];
                    if(code){
                        if([code intValue]==200) {
                            NSDictionary *responseobj=[body objectForKey:@"response"];
                            if([[responseobj objectForKey:@"action"] isEqualToString:@"REDIRECT"])
                            {
//                                NSLog(@"url: %@",[responseobj objectForKey:@"url"]);
                                OAuthAddIdentityViewController *oauth=[[OAuthAddIdentityViewController alloc] initWithNibName:@"OAuthAddIdentityViewController" bundle:nil];
                                oauth.parentView=self;
                                oauth.oauth_url=[responseobj objectForKey:@"url"];
                                [self presentModalViewController:oauth animated:YES];

                            }
                            //                                if([responseobj isKindOfClass:[NSDictionary class]]){
                            //                                    if([responseobj objectForKey:@"url"]!=nil){
                            //                                        OAuthAddIdentityViewController *oauth=[[OAuthAddIdentityViewController alloc] initWithNibName:@"OAuthAddIdentityViewController" bundle:nil];
                            //                                        oauth.parentView=self;
                            //                                        oauth.oauth_url=[responseobj objectForKey:@"url"];
                            //                                        [self presentModalViewController:oauth animated:YES];
                            //                                    }else{
                            //                                        [self.navigationController popViewControllerAnimated:YES];
                            //                                    }
                            //                                }
                        }
                        else{
                            //                                if([[body objectForKey:@"meta"] objectForKey:@"errorType"]!=nil && [[[body objectForKey:@"meta"] objectForKey:@"errorType"] isEqualToString:@"no_connected_identity"] ){
                            //                                    NSLog(@"error:%@",[[body objectForKey:@"meta"] objectForKey:@"errorType"]);
                            //                                }
                        }
                    }
                }
            }
            
        };
        request.onDidFailLoadWithError=^(NSError *error){
            NSLog(@"error %@",error);
            //                [MBProgressHUD hideHUDForView:self.view animated:YES];
        };
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
