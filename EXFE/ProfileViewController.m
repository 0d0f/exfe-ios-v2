//
//  ProfileViewController.m
//  EXFE
//
//  Created by ju huo on 6/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ProfileViewController.h"
#import <BlocksKit/BlocksKit.h>
#import "CCTemplate.h"

#import "EFKit.h"
#import "EFAPIServer.h"

#import "CrossesViewController.h"
#import "EFRomeViewController.h"
#import "EFChangePasswordViewController.h"
#import "EFEditProfileViewController.h"
#import "EFAuthenticationViewController.h"
#import "OAuthLoginViewController.h"

#import "WCAlertView.h"
#import "MBProgressHUD.h"
#import "AYUIButton.h"

#define DECTOR_HEIGHT                    (100)

@interface ProfileViewController ()

@property (nonatomic, strong) UIButton *btnSignOut;
@property (nonatomic, strong) UIButton *btnChangePassword;

@property (nonatomic, strong) UILabel *hintError;

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
//        RKLogTrace (@"Successfully received the test notification!");
        
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
        username.lineBreakMode = NSLineBreakByWordWrapping;
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
    
    {// Overlay error hint
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 46)];
        label.textColor = [UIColor COLOR_RED_EXFE];
        label.font = [UIFont fontWithName:@"HelveticaNeue" size:18.0];
        label.backgroundColor = [UIColor clearColor];
        label.numberOfLines = 1;
        label.backgroundColor = [UIColor whiteColor];
        label.hidden = YES;
        label.textAlignment = NSTextAlignmentRight;
        UITapGestureRecognizer *tap = [UITapGestureRecognizer recognizerWithHandler:^(UIGestureRecognizer *sender, UIGestureRecognizerState state, CGPoint location) {
            [self hide:sender.view withAnmated:NO];
        }];
        [label addGestureRecognizer:tap];
        label.userInteractionEnabled = true;
        self.hintError = label;
    }
    
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
        [self.navigationController pushViewController:vc animated:YES];
    } else if (CGRectContainsPoint(useravatar.frame, location)){
        FullScreenViewController *viewcontroller = [[FullScreenViewController alloc] initWithNibName:@"FullScreenViewController" bundle:nil];
        viewcontroller.wantsFullScreenLayout = YES;
        viewcontroller.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        viewcontroller.defaultImage = useravatar.image;
        viewcontroller.imageUrl = self.user.avatar.original;
        [self presentViewController:viewcontroller animated:YES completion:nil];
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
    [self fillChangePassword:[_user.password boolValue]];
}

- (void)fillProfileHeader:(User *)user{
    if (user) {
        username.text = user.name;
        
        NSString *imageKey = user.avatar_filename;
        UIImage *defaultImage = [UIImage imageNamed:@"portrait_default.png"];
        
        if (!imageKey) {
            useravatar.image = defaultImage;
        } else {
            [[EFDataManager imageManager] loadImageForView:useravatar
                                          setImageSelector:@selector(setImage:)
                                               placeHolder:defaultImage
                                                       key:imageKey
                                           completeHandler:nil];
        }
    }
}

- (void)fillProfileBody:(User*)user{
    NSArray* data = [self prepareTableData];
    _identitiesData = data;
    
    [tableview reloadData];
}

- (void)fillChangePassword:(BOOL)hasPassword
{
    NSString *title = nil;
    if ([self.user.password boolValue]) {
        title = NSLocalizedString(@"Change password", nil);
    } else {
        title = NSLocalizedString(@"Set password", nil);
    }
    NSMutableAttributedString *str3 = [[NSMutableAttributedString alloc] initWithString:title];
    NSUInteger length = str3.length;
    [str3 addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range:NSMakeRange(0, length)];
    [str3 addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:NSMakeRange(0, length)];
    [self.btnChangePassword setAttributedTitle:str3 forState:UIControlStateNormal];
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
        cell.textLabel.text = NSLocalizedString(@"Add identity", @"Profile");
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
            [[EFDataManager imageManager] loadImageForView:cell
                                          setImageSelector:@selector(setAvartar:)
                                               placeHolder:defaultImage
                                                       key:imageKey
                                           completeHandler:nil];
        }
        
        [cell setLabelName:[identity getDisplayName]];
        [cell setLabelIdentity:[identity getDisplayIdentity]];
        
        if(identity.provider!=nil && ![identity.provider isEqualToString:@""]){
            Provider p = [Identity getProviderCode:identity.provider];
            NSString *iconname= [Identity getIdentityImageNameByProvider:p];
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
            
            NSMutableAttributedString *str1 = [[NSMutableAttributedString alloc] initWithString:NSLocalizedString(@"Sign out", nil)];
            NSUInteger length = str1.length;
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
            
            AYUIButton *btnChangePassword = [AYUIButton buttonWithType:UIButtonTypeCustom];
            [btnChangePassword.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:18]];
            [btnChangePassword setFrame:CGRectMake(padding, base1line, 188, 40)];
            [btnChangePassword setBackgroundColor:[UIColor clearColor] forState:UIControlStateNormal];
            [btnChangePassword setBackgroundColor:[UIColor COLOR_WA(0x00, 0x0A)] forState:UIControlStateHighlighted];
            [btnChangePassword addTarget:self action:@selector(changePwd:) forControlEvents:UIControlEventTouchUpInside];
            [footerView addSubview:btnChangePassword];
            self.btnChangePassword = btnChangePassword;
            
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
        
        [self fillChangePassword:[self.user.password boolValue]];
        
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
            vc.readonly = (pt != kProviderTypeVerification);
            vc.identity = identity;
            [self.navigationController pushViewController:vc animated:YES];
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
                                                 if ([operation.response statusCode] == 200){
                                                     if([responseObject isKindOfClass:[NSDictionary class]]) {
                                                         NSDictionary *body = responseObject;
                                                         NSNumber *code = [body valueForKeyPath:@"meta.code"];
                                                         if(code){
                                                             NSInteger c = [code integerValue];
                                                             NSInteger t = c / 100;
                                                             switch (t) {
                                                                 case 2:{
                                                                     NSString *identity_id_str = [body valueForKeyPath:@"response.identity_id"];
                                                                     NSString *user_id_str = [body valueForKeyPath:@"response.user_id"];
                                                                     if (identity_id_str != nil && user_id_str != nil) {
                                                                         NSInteger response_identity_id = [identity_id_str integerValue];
                                                                         NSInteger response_user_id = [user_id_str integerValue];
                                                                         
                                                                         if (response_identity_id == identity_id && response_user_id == self.model.userId) {
                                                                             [self deleteIdentityUI:identity_id];
                                                                         }
                                                                     }
                                                                     
                                                                     NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
                                                                     [ud removeObjectForKey:@"exfee_updated_at"];
                                                                     [[NSUserDefaults standardUserDefaults] synchronize];
                                                                 }   break;
                                                                     
                                                                 default:
                                                                     break;
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

- (void) changePwd:(UIControl *)view
{
    if ([self.user.password boolValue]) {
        EFChangePasswordViewController *viewController = [[EFChangePasswordViewController alloc] initWithModel:self.model];
        viewController.user = self.user;
        [self presentViewController:viewController animated:YES completion:nil];
    } else {
        [self setPwd:view];
    }
    
}

- (void)setPwd:(UIControl *)view
{
    [self setPasswordWithErrorMessage:nil];
}

//- (void) twoStep:(UIControl *)view
//{
//    EFAuthenticationViewController *vc = [[EFAuthenticationViewController alloc] initWithModel:self.model];
//    vc.user = self.user;
//    vc.nextStep = ^void(void){
//        RKLogTrace(@"call next step");
//    };
//    [self presentViewController:vc animated:YES completion:nil];
//}

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
        Provider p = [Identity getProviderCode:identity.provider];
        
        if(p == kProviderTwitter || p == kProviderFacebook){
            NSString *msg=NSLocalizedString(@"Identity authorization has been revoked, please re-authorize.", nil);
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Identity Verification", nil) message:msg delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) otherButtonTitles:NSLocalizedString(@"Re-authorize", nil), nil];
            alert.tag=identity_id;
            [alert show];
        }else{
            NSString *msg = NSLocalizedString(@"Unverified identity. Please check your email for instructions.\nRequest verification again?", @"Profile Table cell");
            if (p == kProviderPhone) {
                msg = NSLocalizedString(@"Unverified identity. Please check your message for instructions.\nRequest verification again?", @"Profile Table cell");
            }
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
                                                                        
                                                                        OAuthLoginViewController *oauth = [[OAuthLoginViewController alloc] initWithNibName:@"OAuthLoginViewController" bundle:nil provider:provider];
                                                                        oauth.onSuccess = ^(NSDictionary * params){
                                                                            [self syncUser];
                                                                        };
                                                                        oauth.oAuthURL = url;
                                                                        oauth.external_username = [identity valueForKey:@"external_username"];
                                                                        [self presentViewController:oauth animated:YES completion:nil];

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


#pragma mark - Private
- (void)showErrorInfo:(NSString*)error over:(UIView*)view on:(UIView*)parent
{
    [_hintError removeFromSuperview];
    _hintError.text = error;
    _hintError.backgroundColor = [UIColor COLOR_WA(250, 217)];
    _hintError.frame = (CGRect){{16, 58}, {252, 35}};
    _hintError.alpha = 1.0;
    [parent addSubview:_hintError];
    _hintError.hidden = NO;
    [self performBlock:^(id sender) {
        if (_hintError.hidden == NO) {
            [self hide:_hintError withAnmated:YES];
        }
    }
            afterDelay:5];
}

- (void)hide:(UIView *)view withAnmated:(BOOL)animated
{
    if (animated) {
        [UIView animateWithDuration:0.5 animations:^{
            _hintError.alpha = 0.0;
        } completion:^(BOOL finished) {
            _hintError.hidden = YES;
            _hintError.alpha = 1.0;
        }];
    } else {
        _hintError.hidden = YES;
        _hintError.alpha = 1.0;
    }
}

- (void) setPasswordWithErrorMessage:(NSString*)msg
{
    [WCAlertView showAlertWithTitle:NSLocalizedString(@"Set Password", nil)
                            message:nil
                 customizationBlock:^(WCAlertView *alertView) {
                     alertView.alertViewStyle = UIAlertViewStyleSecureTextInput;
                     UITextField *textField = [alertView textFieldAtIndex:0];
                     textField.placeholder = [NSLocalizedString(@"Set {{PRODUCT_NAME}} password", nil) templateFromDict:[Util keywordDict]];
                     textField.textAlignment = NSTextAlignmentCenter;
                     //                     textField.delegate = self;
                     if (msg) {
                         [self showErrorInfo:msg over:textField on:[textField superview]];
                     }
                 }
                    completionBlock:^(NSUInteger buttonIndex, WCAlertView *alertView) {
                        if (buttonIndex == 0) {
                            UITextField *textField = [alertView textFieldAtIndex:0];
                            NSString *password = [NSString stringWithString:textField.text];
                            
                            if (password.length < 4) {
                                [self setPasswordWithErrorMessage:@"Invalid password."];
                                return;
                            }
                            
                            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                            hud.mode = MBProgressHUDModeIndeterminate;
                            
//                            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
//                                UITapGestureRecognizer *tap = [UITapGestureRecognizer recognizerWithHandler:^(UIGestureRecognizer *sender, UIGestureRecognizerState state, CGPoint location) {
//                                    [hud hide:YES];
//                                }];
//                                [hud addGestureRecognizer:tap];
//                            });
                            
                            [self.model.apiServer changePassword:nil
                                                            with:password
                                                         success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                                             [MBProgressHUD hideHUDForView:self.view animated:YES];
                                                             if ([operation.response statusCode] == 200) {
                                                                 if([responseObject isKindOfClass:[NSDictionary class]]) {
                                                                     NSDictionary *body = responseObject;
                                                                     NSNumber *code = [body valueForKeyPath:@"meta.code"];
                                                                     if (code) {
                                                                         NSInteger c = [code integerValue];
                                                                         NSInteger t = c / 100;
                                                                         switch (t) {
                                                                             case 2:{
                                                                                 // c == 200
                                                                                 NSString *token = [body valueForKey:@"response.token"];
                                                                                 if (token.length > 0) {
                                                                                     _model.userToken = token;
                                                                                     [_model saveUserData];
                                                                                     
                                                                                 } else {
                                                                                     // error
                                                                                 }
                                                                             }
                                                                                 break;
                                                                             case 3:{
                                                                                 
                                                                             }  break;
                                                                             case 4:{
                                                                                 NSString *errorType = [body valueForKeyPath:@"meta.errorType"];
                                                                                 if (c == 400) {
                                                                                     if ([@"weak_password" isEqualToString:errorType]) {
                                                                                         // error: "Weak password."
                                                                                         [self setPasswordWithErrorMessage:@"Invalid password."];
                                                                                         
                                                                                     }
                                                                                 } else if (c == 401){
                                                                                     if ([@"no_signin" isEqualToString:errorType]) {
                                                                                         // error: "Not sign in"
                                                                                         // login
                                                                                     } else if ([@"authenticate_timeout" isEqualToString:errorType]) {
                                                                                         // error: "Authenticate timeout."
                                                                                         // [self showInlineError:NSLocalizedString(@"Set password failed.", nil) with:NSLocalizedString(@"Authentication token expired, please retry.", nil)];
                                                                                     } else if ([@"token_staled" isEqualToString:errorType]) {
                                                                                         EFAuthenticationViewController *vc = [[EFAuthenticationViewController alloc] initWithModel:self.model];
                                                                                         vc.user = self.user;
                                                                                         vc.nextStep = ^void(void){
                                                                                             [self syncUser];
                                                                                         };
                                                                                         [self presentViewController:vc animated:YES completion:nil];
                                                                                     }
                                                                                 }
                                                                                 
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
                                                         failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                             [MBProgressHUD hideHUDForView:self.view animated:YES];
                                                         }];
                        }
                        
                    }
                  cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
                  otherButtonTitles:NSLocalizedString(@"Done", nil), nil];
}
@end
