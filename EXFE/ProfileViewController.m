//
//  ProfileViewController.m
//  EXFE
//
//  Created by ju huo on 6/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ProfileViewController.h"
#import <BlocksKit/BlocksKit.h>
#import "User+EXFE.h"
#import "Identity+EXFE.h"
#import "CrossesViewController.h"
#import "AppDelegate.h"
#import "WCAlertView.h"
#import "EFAPIServer.h"
#import "EFRomeViewController.h"
#import "EFKit.h"
#import "EFModel.h"
#import "EFChangePasswordViewController.h"
#import "EFEditProfileViewController.h"
#import "AYUIButton.h"

#define DECTOR_HEIGHT                    (100)

@interface ProfileViewController ()

@property (nonatomic, strong) UIButton *btnSignOut;
@property (nonatomic, strong) UIButton *btnForgetPassword;

@end

@implementation ProfileViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(receiveRefreshNotification:)
                                                     name:NotificationRefreshUserSelf
                                                   object:nil];

    }
    return self;
}

- (void) receiveRefreshNotification:(NSNotification *) notification
{
    // [notification name] should always be @"TestNotification"
    // unless you use this method for observation of other notifications
    // as well.
    
    if ([NotificationRefreshUserSelf isEqualToString:[notification name]]){
//        NSLog (@"Successfully received the test notification!");
        
        [self syncUser];
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [Flurry logEvent:@"VIEW_PROFILE"];
    
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
    }
    [self.view addSubview:headerView];
    
    btnBack = [UIButton buttonWithType:UIButtonTypeCustom ];
    [btnBack setFrame:CGRectMake(0, DECTOR_HEIGHT / 2 - 44 / 2, 40, 44)];
    btnBack.imageEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, 0.0, 20.0);
    btnBack.backgroundColor = [UIColor clearColor];
    [btnBack setImage:[UIImage imageNamed:@"back.png"] forState:UIControlStateNormal];
    [btnBack setImage:[UIImage imageNamed:@"back_pressed.png"] forState:UIControlStateHighlighted];
    [btnBack addTarget:self action:@selector(gotoBack:) forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchDragExit];
    [self.view  addSubview:btnBack];
    
    UISwipeGestureRecognizer *swipeHeaderTap = [UISwipeGestureRecognizer recognizerWithHandler:^(UIGestureRecognizer *sender, UIGestureRecognizerState state, CGPoint point) {
        if (sender.state == UIGestureRecognizerStateEnded) {
            [btnBack sendActionsForControlEvents:UIControlEventTouchUpInside];
        }
    }];
    [headerView addGestureRecognizer:swipeHeaderTap];
    
    UITapGestureRecognizer *tapHeader = [UITapGestureRecognizer recognizerWithHandler:^(UIGestureRecognizer *sender, UIGestureRecognizerState state, CGPoint location) {
        if (sender.state == UIGestureRecognizerStateEnded) {
            // open edit
        }
    }];
    [headerView addGestureRecognizer:tapHeader];
    
    tableview.backgroundColor = [UIColor clearColor];
    tableview.opaque = NO;
    tableview.backgroundView = nil;
    tableview.frame = CGRectMake(0, DECTOR_HEIGHT, CGRectGetWidth(b), CGRectGetHeight(b) - DECTOR_HEIGHT);
    tableview.delegate = self;
    tableview.dataSource = self;
    
    [self refreshUI];
    
    UITapGestureRecognizer *tapHeaderRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapProfileHeader:)];
    [headerView addGestureRecognizer:tapHeaderRecognizer];
    
    [self syncUser];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleLoadMeSuccess:)
                                                 name:kEFNotificationNameLoadMeSuccess
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleUserChange:)
                                                 name:kEFNotificationChangeUserBasicProfileSuccess
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleUserChange:)
                                                 name:kEFNotificationUpdateUserAvatarSuccess
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleIdentityChange:)
                                                 name:kEFNotificationUpdateIdentitySuccess
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleIdentityChange:)
                                                 name:kEFNotificationUpdateIdentityAvatarSuccess
                                               object:nil];
}

- (void)gotoBack:(UIButton*)sender{
    [[RKObjectManager sharedManager].operationQueue cancelAllOperations];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)handleLoadMeSuccess:(NSNotification *)notif {
    self.user = [User getDefaultUser];
    [self refreshUI];
}

- (void)handleUserChange:(NSNotification *)notif
{
    [self syncUser];
}

- (void)handleIdentityChange:(NSNotification *)notif
{
    [self syncUser];
}

- (void)syncUser {
    [self.model loadMe];
}

- (void)tapProfileHeader:(UITapGestureRecognizer*)sender
{
    CGPoint location = [sender locationInView:sender.view];
//    UIView *tappedView = [sender.view hitTest:location withEvent:nil];
    if (CGRectContainsPoint(username.frame, location)) {
        [[UIApplication sharedApplication] setStatusBarHidden:YES];
        EFEditProfileViewController* vc = [[EFEditProfileViewController alloc] initWithModel:self.model];
        vc.readonly = false;
        vc.user = self.user;
        [self presentModalViewController:vc animated:YES];
    } else if (CGRectContainsPoint(useravatar.frame, location)){
        FullScreenViewController *viewcontroller = [[FullScreenViewController alloc] initWithNibName:@"FullScreenViewController" bundle:nil];
        viewcontroller.wantsFullScreenLayout = YES;
        viewcontroller.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        viewcontroller.image = useravatar.image;
        [self presentModalViewController:viewcontroller animated:YES];
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
        
        NSString *imageKey = user.avatar_filename;
        UIImage *defaultImage = [UIImage imageNamed:@"portrait_default.png"];
        
        if (!imageKey) {
            useravatar.image = defaultImage;
        } else {
            if ([[EFDataManager imageManager] isImageCachedInMemoryForKey:imageKey]) {
                useravatar.image = [[EFDataManager imageManager] cachedImageInMemoryForKey:imageKey];
            } else {
                useravatar.image = defaultImage;
                [[EFDataManager imageManager] cachedImageForKey:imageKey
                                                completeHandler:^(UIImage *image){
                                                    if (image) {
                                                        useravatar.image = image;
                                                    }
                                                }];
            }
        }
    }
}

- (void)fillProfileBody:(User*)user{
    NSArray* data = [self prepareTableData];
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
    
    NSArray *identitiesData = [NSArray arrayWithObjects:[sorted_identities_section mutableCopy],devices_section, nil];
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
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"addidentitybutton"];
        }
        cell.textLabel.text = NSLocalizedString(@"Add identity...", nil);
        cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:16];
        return cell;
    }
    Identity *identity = [[_identitiesData objectAtIndex:[indexPath section]]  objectAtIndex:indexPath.row];
    
    if([indexPath section]==0)
    {
        NSString *imageKey = identity.avatar_filename;
        UIImage *defaultImage = [UIImage imageNamed:@"portrait_default.png"];
        
        if (!imageKey) {
            [cell setAvartar:defaultImage];
        } else {
            if ([[EFDataManager imageManager] isImageCachedInMemoryForKey:imageKey]) {
                UIImage *image = [[EFDataManager imageManager] cachedImageInMemoryForKey:imageKey];
                [cell setAvartar:image];
            } else {
                [cell setAvartar:defaultImage];
                [[EFDataManager imageManager] cachedImageForKey:imageKey
                                                completeHandler:^(UIImage *image){
                                                    if (image) {
                                                        [cell setAvartar:image];
                                                    }
                                                }];
            }
        }
        
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
        CGFloat padding = 10;
        CGFloat base1line = 10;
        CGFloat base2line = 70;
        
        if(footerView == nil) {
            footerView  = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 10 + 62 + 44)];
//            footerView.backgroundColor = [UIColor lightGrayColor];
            
            AYUIButton *btnSignOut = [AYUIButton buttonWithType:UIButtonTypeCustom];
            
            NSMutableAttributedString *str1 = [[NSMutableAttributedString alloc] initWithString:NSLocalizedString(@"Sign out", nil)];            NSUInteger length = str1.length;
            [str1 addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range:NSMakeRange(0, length)];
            [str1 addAttribute:NSForegroundColorAttributeName value:[UIColor COLOR_RED_EXFE] range:NSMakeRange(0, length)];
            [btnSignOut setAttributedTitle:str1 forState:UIControlStateNormal];
            [btnSignOut.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:18]];
            [btnSignOut setFrame:CGRectMake(197, base1line, 113, 40)];
            [btnSignOut setBackgroundColor:[UIColor clearColor] forState:UIControlStateNormal];
            [btnSignOut setBackgroundColor:[UIColor COLOR_WA(0x00, 0x0A)] forState:UIControlStateHighlighted];
            btnSignOut.layer.cornerRadius = 4;
            [btnSignOut addTarget:self action:@selector(Logout) forControlEvents:UIControlEventTouchUpInside];
            [footerView addSubview:btnSignOut];
            self.btnSignOut = btnSignOut;
            
            AYUIButton *btnForgetPassword = [AYUIButton buttonWithType:UIButtonTypeCustom];
            [btnForgetPassword.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:18]];
            [btnForgetPassword setFrame:CGRectMake(padding, base1line, 188, 40)];
            [btnForgetPassword setBackgroundColor:[UIColor clearColor] forState:UIControlStateNormal];
            [btnForgetPassword setBackgroundColor:[UIColor COLOR_WA(0x00, 0x0A)] forState:UIControlStateHighlighted];
            [btnForgetPassword addTarget:self action:@selector(forgetPwd:) forControlEvents:UIControlEventTouchUpInside];
            [footerView addSubview:btnForgetPassword];
            self.btnForgetPassword = btnForgetPassword;
            
            UIButton *buttonrome = [UIButton buttonWithType:UIButtonTypeCustom];
            [buttonrome setTitle:NSLocalizedString(@"“Rome wasn't built in a day.”", nil) forState:UIControlStateNormal];
            [buttonrome.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:18]];
            [buttonrome setTitleColor:[UIColor COLOR_BLUE_EXFE] forState:UIControlStateNormal];
            [buttonrome setFrame:CGRectMake(35, base2line, 250, 25)];
            [buttonrome setBackgroundColor:[UIColor clearColor]];
            buttonrome.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
            buttonrome.backgroundColor = [UIColor COLOR_WA(0xE6, 0xFF)];
            buttonrome.layer.cornerRadius = 4;
            buttonrome.layer.masksToBounds = YES;
            [buttonrome addTarget:self action:@selector(showRome) forControlEvents:UIControlEventTouchUpInside];
            [footerView addSubview:buttonrome];
        }
        
        NSString *title = nil;
        if ([self.user.password boolValue]) {
            self.btnForgetPassword.hidden = NO;
            title = NSLocalizedString(@"Change password...", nil);
        } else {
            self.btnForgetPassword.hidden = YES;
            title = NSLocalizedString(@"Set password...", nil);
        }
        NSMutableAttributedString *str3 = [[NSMutableAttributedString alloc] initWithString:title];
        NSUInteger length = str3.length;
        [str3 addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range:NSMakeRange(0, length)];
        [str3 addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:NSMakeRange(0, length)];
        [self.btnForgetPassword setAttributedTitle:str3 forState:UIControlStateNormal];
        
        return footerView;
    }
    return nil;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        int count = [[_identitiesData objectAtIndex:indexPath.section] count];
        return count != indexPath.row;
    }
    return NO;
}

- (void)showRome {
    EFRomeViewController *romeViewController = [[EFRomeViewController alloc] init];
    EFPresentCardController *presentCardController = [[EFPresentCardController alloc] initWithContentViewController:romeViewController];
    romeViewController.closeButtonPressedHandler = ^{
        [presentCardController dismissAnimated:YES
                         withCompletionHandler:nil];
    };
    
    [presentCardController presentFromViewController:self
                                            animated:YES];
    
}

#pragma mark UITableViewDelegate methods
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    int count = [[_identitiesData objectAtIndex:indexPath.section] count];
    if (indexPath.section == 0) {
        if (count == indexPath.row) {
            EFAddIdentityViewController *addidentityView=[[EFAddIdentityViewController alloc]initWithNibName:@"EFAddIdentityViewController" bundle:nil];
            [self.navigationController pushViewController:addidentityView animated:YES];
        }else {
            Identity *identity = [[_identitiesData objectAtIndex:[indexPath section]]  objectAtIndex:indexPath.row];
            if (![@"CONNECTED" isEqualToString:identity.status]) {
                return;
            }
            ProviderType pt = [Identity getProviderTypeByString:identity.provider];
            
            [[UIApplication sharedApplication] setStatusBarHidden:YES];
            EFEditProfileViewController* vc = [[EFEditProfileViewController alloc] initWithModel:self.model];
            vc.readonly = (pt == kProviderTyperAuthorization);
            vc.identity = identity;
            [self presentViewController:vc animated:YES completion:nil];
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
    
    [self.model.apiServer removeUserIdentity:identity_id
                                             success:^(AFHTTPRequestOperation *operation, id responseObject) {
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
                                                                         
                                                                         if(response_identity_id==identity_id && response_user_id == self.model.userId){
                                                                             [self deleteIdentityUI:identity_id];
                                                                         }
                                                                     }
                                                                 }
                                                             }
                                                         }
                                                     }
                                                 }
                                             }
                                             failure:nil];
}

- (void) Logout {
    [Util signout];
}

- (void) forgetPwd:(id)view
{
    if (self.user.password) {
        EFChangePasswordViewController *viewController = [[EFChangePasswordViewController alloc] initWithModel:self.model];
        viewController.user = self.user;
        [self presentModalViewController:viewController animated:YES];
    } else {
        // set password
        // popup
        //  may login verify for 401 xxx
        // 
    }
    
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
            NSString *msg=NSLocalizedString(@"Identity authorization has been revoked, please re-authorize.", nil);
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Identity Verification", nil) message:msg delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) otherButtonTitles:NSLocalizedString(@"Re-authorize", nil), nil];
            alert.tag=identity_id;
            [alert show];
        }else{
            NSString *msg=NSLocalizedString(@"Unverified identity, please check your email for instructions.\nRe-send verification email?", nil);
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Identity Verification", nil) message:msg delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) otherButtonTitles:NSLocalizedString(@"Send", nil), nil];
            alert.tag=identity_id;
            [alert show];
            
        }
    }
}

- (void) doVerify:(int)identity_id{
    
    [self.model.apiServer verifyUserIdentity:identity_id
                                    success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                        if ([operation.response statusCode] == 200){
                                            if([responseObject isKindOfClass:[NSDictionary class]]) {
                                                NSDictionary *body = responseObject;
                                                NSNumber *code = [body valueForKeyPath:@"meta.code"];
                                                if (code) {
                                                    NSInteger c = [code integerValue];
                                                    NSInteger t = c / 100;
                                                    switch (t) {
                                                        case 2:{
                                                            if (c == 200) {
                                                                NSString *action = [body valueForKeyPath:@"response.action"];
                                                                
                                                                if ([@"REDIRECT" isEqualToString:action]) {
                                                                    NSString * url = [body valueForKeyPath:@"response.url"];
                                                                    if (url.length > 0) {
                                                                        NSDictionary *identity = [body valueForKeyPath:@"response.identity"];
                                                                        Provider provider = [Identity getProviderCode:[identity valueForKey:@"provider"]];
                                                                        
                                                                        OAuthLoginViewController *oauth = [[OAuthLoginViewController alloc] initWithNibName:@"OAuthLoginViewController" bundle:nil];
                                                                        oauth.provider = provider;
                                                                        oauth.delegate = self;
                                                                        oauth.oAuthURL = url;
                                                                        switch (provider) {
                                                                            case kProviderTwitter:
                                                                                oauth.matchedURL = @"https://api.twitter.com/oauth/auth";
                                                                                oauth.javaScriptString = [NSString stringWithFormat:@"document.getElementById('username_or_email').value='%@';", [identity valueForKey:@"external_id"]];
                                                                                break;
                                                                            case kProviderFacebook:
                                                                                oauth.matchedURL = @"http://m.facebook.com/login.php?";
                                                                                oauth.javaScriptString = [NSString stringWithFormat:@"document.getElementsByName('email')[0].value='%@';", [identity valueForKey:@"external_username"]];
                                                                                break;
                                                                            default:
                                                                                oauth.matchedURL = nil;
                                                                                oauth.javaScriptString = nil;
                                                                                break;
                                                                        }
                                                                        
                                                                        [self presentModalViewController:oauth animated:YES];

                                                                    }
                                                                }
                                                            }
                                                        }  break;
                                                        case 3:{
                                                            
                                                        }  break;
                                                        case 4:{
                                                            
                                                        }  break;
                                                        case 5:{
                                                            
                                                        }  break;
                                                        default:
                                                            break;
                                                    }
                                                }
                                            }
                                        }
                                    }
                                    failure:nil];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    //tag 101: save cross
    //tag 102: save exfee
    if (buttonIndex == 0){//cancel
        
    } else if(buttonIndex == 1) {//retry
        int identity_id = alertView.tag;
        if (identity_id > 0) {
            [self doVerify:identity_id];
        }
    }
}

#pragma mark OAuthlogin Delegate
- (void)OAuthloginViewControllerDidCancel:(UIViewController *)oauthlogin {
    [oauthlogin dismissModalViewControllerAnimated:YES];
}

- (void)OAuthloginViewControllerDidSuccess:(OAuthLoginViewController *)oauthloginViewController userid:(NSString*)userid username:(NSString*)username external_id:(NSString*)external_id token:(NSString*)token
{
    [self.navigationController dismissModalViewControllerAnimated:YES];
    [self syncUser];
}

@end
