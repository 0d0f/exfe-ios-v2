//
//  CrossesViewController.m
//  EXFE
//
//  Created by ju huo on 5/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CrossesViewController.h"
#import <BlocksKit/BlocksKit.h>
#import "CCTemplate.h"

#import "Util.h"
#import "EFKit.h"
#import "EFEntity.h"
#import "EFModel.h"
#import "EFMapKit.h"

#import "NSString+EXFE.h"
#import "UIApplication+EXFE.h"


#import "ProfileViewController.h"
#import "EFLandingViewController.h"
#import "CrossGroupViewController.h"
#import "WidgetConvViewController.h"
#import "WidgetExfeeViewController.h"
#import "EFRouteXViewController.h"

#import "EFHeadView.h"
#import "CrossCard.h"

@interface CrossesViewController ()

@property (nonatomic, strong) UILabel *label_profile;
@property (nonatomic, strong) UILabel *label_gather;
@property (nonatomic, strong) TTTAttributedLabel *welcome_exfe;
@property (nonatomic, strong) UILabel *welcome_more;
@property (nonatomic, strong) UILabel *unverified_title;
@property (nonatomic, strong) TTTAttributedLabel *unverified_description;
@property (nonatomic, strong) EFHeadView *headView;

@property (nonatomic, readonly) EXFEModel *model;


@end

@interface CrossesViewController (Private)
- (EFTabBarViewController *)_detailViewControllerWithCross:(Cross *)cross andId:(NSUInteger)crossId withModel:(EXFEModel*)model;
@end

@implementation CrossesViewController

{}
#pragma mark Getter/Setter
- (EXFEModel *)model
{
    AppDelegate * app = (AppDelegate*)[UIApplication sharedApplication].delegate;
    return app.model;
}

- (Cross*) crossWithId:(NSInteger)cross_id
{
    for (Cross *c in self.crossList) {
        if ([c.cross_id unsignedIntegerValue] == cross_id) {
            return c;
        }
    }
    return nil;
}

#pragma mark UIViewController life cycle
- (id)init
{
    self = [super init];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [Flurry logEvent:@"CROSS_LIST"];
    [self.navigationController setNavigationBarHidden:YES animated:NO];

    self.clearsSelectionOnViewWillAppear = YES;
    
    UITableView * tableView = self.tableView;
    tableView.dataSource = self;
    tableView.delegate = self;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableView.backgroundColor = [UIColor COLOR_WA(0xEE, 0xFF)];
    tableView.alwaysBounceVertical = YES;
    tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    
    UIView *topview = [[UIView alloc] initWithFrame:CGRectMake(0, -480, 320, 480)];
    topview.backgroundColor = [UIColor COLOR_WA(0xEE, 0xFF)];
    [tableView addSubview:topview];
    
    
    // Head View
    EFHeadView *headView = [[EFHeadView alloc] initWithFrame:(CGRect){{0.0f, 9.0f}, {320.0f, 56.0f}}];
    headView.headPressedHandler = ^{
        NSString *urlstr = [NSString stringWithFormat:@"%@://%@%@", [UIApplication sharedApplication].defaultScheme, [EFConfig sharedInstance].scope, @"/profile?animated=yes"];
        NSURL *url = [NSURL URLWithString:urlstr];
        [[UIApplication sharedApplication] openURL:url];
    };
    headView.titlePressedHandler = ^{
        NSString *urlstr = [NSString stringWithFormat:@"%@://%@%@", [UIApplication sharedApplication].defaultScheme, [EFConfig sharedInstance].scope, @"/gather?animated=yes"];
        NSURL *url = [NSURL URLWithString:urlstr];
        [[UIApplication sharedApplication] openURL:url];
    };
    headView.willShowHandler = ^{
        [self.tableView beginUpdates];
        [self.tableView insertSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationFade];
        [self.tableView endUpdates];
    };
    self.headView = headView;
    
    AppDelegate * app = (AppDelegate*)[UIApplication sharedApplication].delegate;
    if ([app.model isLoggedIn]) {
        // 过渡动画
        UIGraphicsBeginImageContext(self.view.bounds.size);
        [[UIImage imageNamed:@"home_bg.png"] drawInRect:self.view.bounds];
        UIImage *defaultBackgroundImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        UIColor *backgroundColor = [UIColor colorWithPatternImage:defaultBackgroundImage];
        
        UIView *defaultView = [[UIView alloc] initWithFrame:self.view.bounds];
        defaultView.backgroundColor = backgroundColor;
        [self.view addSubview:defaultView];
        
        if (self.needHeaderAnimation) {
            self.headView.layer.transform = CATransform3DMakeScale(0.0f, 0.0f, 0.0f);
            self.tableView.scrollEnabled = NO;
            [UIView animateWithDuration:0.233f
                             animations:^{
                                 defaultView.alpha = 0.0f;
                             }
                             completion:^(BOOL finished){
                                 [defaultView removeFromSuperview];
                                 
                                 CAKeyframeAnimation *popAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
                                 popAnimation.values = @[
                                                         [self.headView.layer valueForKey:@"transform"],
                                                         [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.1f, 1.1f, 1.1f)],
                                                         [NSValue valueWithCATransform3D:CATransform3DMakeScale(0.9f, 0.9f, 0.9f)],
                                                         [NSValue valueWithCATransform3D:CATransform3DIdentity]
                                                         ];
                                 popAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
                                 popAnimation.duration = 0.55f;
                                 popAnimation.fillMode = kCAFillModeForwards;
                                 [self.headView.layer addAnimation:popAnimation forKey:@"pop"];
                                 self.headView.layer.transform = CATransform3DIdentity;
                                 
                                 double delayInSeconds = 0.1f;
                                 dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
                                 dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                                     [self.headView showAnimated:YES];
                                 });
                                 
                                 self.tableView.scrollEnabled = YES;
                             }];
        } else {
            defaultView.alpha = 0.0f;
            [defaultView removeFromSuperview];
            [self.headView showAnimated:NO];
        }
        
        [self refreshUI];
    
        //Load cross from remote
        NSDate *updated_at = [[NSUserDefaults standardUserDefaults] objectForKey:@"exfee_updated_at"];
        [app.model loadCrossListAfter:updated_at];

    } else {
        [self.headView showAnimated:NO];
        
        EFLandingViewController *viewController = [[EFLandingViewController alloc] initWithNibName:@"EFLandingViewController" bundle:nil];
        [app.window.rootViewController presentViewController:viewController animated:NO completion:nil];
        
    }
    
    default_background=[UIImage imageNamed:@"x_titlebg_default.jpg"];

    CGFloat scaleFactor = 1.0;
    CGSize targetSize = CGSizeMake((320 - CARD_VERTICAL_MARGIN * 2) * [UIScreen mainScreen].scale, 44 * [UIScreen mainScreen].scale);

    if (default_background.size.width > targetSize.width || default_background.size.height > targetSize.height){
        scaleFactor = MAX((targetSize.width / default_background.size.width), (targetSize.height / default_background.size.height));
    }
    
    UIGraphicsBeginImageContext(targetSize);
    
    CGRect rect = CGRectMake((targetSize.width / 2 - default_background.size.width / 2 * scaleFactor),(0 - default_background.size.height * 198.0f / 495.0f * scaleFactor),default_background.size.width * scaleFactor,default_background.size.height * scaleFactor);
    [default_background drawInRect:rect];
    default_background = UIGraphicsGetImageFromCurrentImageContext();
    
    
    UILabel *label_profile = [[UILabel alloc] initWithFrame:CGRectMake(15, 65, 200, 50)];
    label_profile.backgroundColor = [UIColor clearColor];
    label_profile.textColor = [UIColor COLOR_GRAY];
    label_profile.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:12];
    label_profile.text = NSLocalizedString(@"Your profile here.", nil);
    label_profile.numberOfLines = 1;
    [label_profile sizeToFit];
    self.label_profile = label_profile;
    [self.view addSubview:label_profile];
    
    UILabel *label_gather = [[UILabel alloc] initWithFrame:CGRectMake(15, 65, 200, 50)];
    label_gather.backgroundColor = [UIColor clearColor];
    label_gather.textColor = [UIColor COLOR_GRAY];
    label_gather.textAlignment = NSTextAlignmentRight;
    label_gather.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:12];
    label_gather.text = NSLocalizedString(@"Go hang out with friends.", nil);
    label_gather.numberOfLines = 1;
    [label_gather sizeToFit];
    // Right Alignment
    label_gather.frame = CGRectOffset(label_gather.frame, CGRectGetWidth(self.view.bounds) - 15 - CGRectGetMaxX(label_gather.frame), 0);
    self.label_gather = label_gather;
    [self.view addSubview:label_gather];
    
    TTTAttributedLabel *welcome_exfe = [[TTTAttributedLabel alloc] initWithFrame:CGRectMake(15, CGRectGetMidY(self.view.bounds) - 20, 290, 100)];
    welcome_exfe.backgroundColor = [UIColor clearColor];
    welcome_exfe.textAlignment = NSTextAlignmentCenter;
    welcome_exfe.textColor = [UIColor COLOR_CARBON];
    welcome_exfe.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:30];
    NSString *full = [NSLocalizedString(@"Welcome to {{PRODUCT_APP_NAME}}", nil) templateFromDict:[Util keywordDict]];
    
    [welcome_exfe setText:full afterInheritingLabelAttributesAndConfiguringWithBlock:^NSMutableAttributedString *(NSMutableAttributedString *mutableAttributedString) {
        NSString *highlight = [NSLocalizedString(@"{{PRODUCT_APP_NAME}}", @"Use as search pattern") templateFromDict:[Util keywordDict]];
        NSRange range = [[mutableAttributedString string] rangeOfString:highlight options:NSCaseInsensitiveSearch];
        
        [mutableAttributedString addAttribute:(NSString *)kCTForegroundColorAttributeName value:(id)[UIColor COLOR_BLUE_EXFE].CGColor range:range];
        
        return mutableAttributedString;
    }];
    [welcome_exfe sizeToFit];
    welcome_exfe.frame = CGRectOffset(welcome_exfe.frame, 160 - CGRectGetMidX(welcome_exfe.frame), 0);
    self.welcome_exfe = welcome_exfe;
    [self.view addSubview:welcome_exfe];
    
    UILabel *welcome_more = [[UILabel alloc] initWithFrame:CGRectMake(15, CGRectGetMaxY(welcome_exfe.frame), 290, 100)];
    welcome_more.backgroundColor = [UIColor clearColor];
    welcome_more.textColor = [UIColor COLOR_WA(0x6B, 0xFF)];
    welcome_more.textAlignment = NSTextAlignmentRight;
    welcome_more.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:18];
    welcome_more.text = NSLocalizedString(@"The group utility for gathering.", nil);
    [welcome_more sizeToFit];
    welcome_more.frame = CGRectOffset(welcome_more.frame, 160 - CGRectGetMidX(welcome_more.frame), 0);
    self.welcome_more = welcome_more;
    [self.view addSubview:welcome_more];
    
    TTTAttributedLabel *unverified_description = [[TTTAttributedLabel alloc] initWithFrame:CGRectMake(15, 0, 290, 200)];
    NSString *text = NSLocalizedString(@"To protect privacy, nothing to list here \nuntil your account is verified. Please go to verify first.", nil);
    NSString *link_text = NSLocalizedString(@"go to verify", nil);
    NSRange range = [text rangeOfString:link_text];
    unverified_description.numberOfLines = 0;
    unverified_description.backgroundColor = [UIColor COLOR_WA(0xEE, 0xFF)];
    unverified_description.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:12];
    unverified_description.textColor = [UIColor COLOR_BLACK_19];
    unverified_description.verticalAlignment = TTTAttributedLabelVerticalAlignmentTop;
    unverified_description.textAlignment = NSTextAlignmentCenter;
    NSMutableDictionary *mutableLinkAttributes = [NSMutableDictionary dictionary];
    [mutableLinkAttributes setObject:[UIColor COLOR_BLACK_19] forKey:(NSString*)kCTForegroundColorAttributeName];
    [mutableLinkAttributes setObject:[NSNumber numberWithBool:YES] forKey:(NSString *)kCTUnderlineStyleAttributeName];
    unverified_description.linkAttributes = mutableLinkAttributes;
    unverified_description.delegate = self;
    unverified_description.text = text;
    NSString *urlstr = [NSString stringWithFormat:@"%@://%@%@", [UIApplication sharedApplication].defaultScheme, [EFConfig sharedInstance].scope, @"/profile?animated=yes"];
    NSURL *url = [NSURL URLWithString:urlstr];
    [unverified_description addLinkToURL:url withRange:range];
    [unverified_description sizeToFit];
    
    CGFloat h = CGRectGetHeight(unverified_description.bounds);
    unverified_description.frame = CGRectMake(15, CGRectGetHeight(self.view.bounds) - 15 - h, 290, h + 15);
    self.unverified_description = unverified_description;
    [self.view addSubview:unverified_description];
    
    UILabel *unverified_title = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, 290, 200)];
    unverified_title.font = [UIFont fontWithName:@"HelveticaNeue" size:12];
    unverified_title.textAlignment = NSTextAlignmentCenter;
    unverified_title.textColor = [UIColor COLOR_RED_EXFE];
    unverified_title.backgroundColor = [UIColor COLOR_WA(0xEE, 0xFF)];
    unverified_title.text = NSLocalizedString(@"Unverified account.", nil);
    [unverified_title sizeToFit];
    CGFloat hh = CGRectGetHeight(unverified_title.bounds);
    unverified_title.frame = CGRectMake(15, CGRectGetMinY(unverified_description.frame) - hh, 290, hh);
    self.unverified_title = unverified_title;
    [self.view addSubview:unverified_title];
    
    [self regObserver];
    
    [self refreshWelcome];
}

- (void)dealloc {
    [self unregObserver];
    self.crossList = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
    
    [self refreshUI];
}

- (void)forceSignOut {
    [Util signout];
    
    EFLandingViewController *viewController = [[EFLandingViewController alloc] initWithNibName:@"EFLandingViewController" bundle:nil];
    [self presentViewController:viewController animated:YES completion:nil];
}

#pragma mark KVO methods
- (void)regObserver
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(refreshUI)
                                                 name:EXCrossListDidChangeNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(refreshWelcome)
                                                 name:UIApplicationDidChangeStatusBarFrameNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleLoadMeSuccess:)
                                                 name:kEFNotificationNameLoadMeSuccess
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(refreshUI)
                                                 name:kEFNotificationNameLoadCrossListSuccess
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleNotification:)
                                                 name:kEFNotificationNameLoadMeFailure
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleNotification:)
                                                 name:kEFNotificationNameLoadCrossListFailure
                                               object:nil];
}

- (void)unregObserver
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)handleLoadMeSuccess:(NSNotification *)notif {
    
    [self refreshWelcome];
    
    NSRange range = NSMakeRange(0, 1);
    NSIndexSet *section = [NSIndexSet indexSetWithIndexesInRange:range];
    [self.tableView reloadSections:section withRowAnimation:UITableViewRowAnimationNone];
}

- (void)handleNotification:(NSNotification *)notification {
    NSString *name = notification.name;
    NSDictionary *userInfo = notification.userInfo;
    
    
    if ([name hasSuffix:@".success"] && userInfo) {
        // for success
        NSString *cat = userInfo[@"type"];
        NSNumber *num = userInfo[@"id"];
        
        if ([@"user" isEqualToString:cat]) {
            
        } else {
            // for others
        }
        
    } else if ([name hasSuffix:@".failure"] && userInfo) {
        // for failure
        NSString *cat = userInfo[@"type"];
        NSNumber *num = userInfo[@"id"];
        
        if ([@"user" isEqualToString:cat]) {
            //            if (num && self.model.userId == [num unsignedIntegerValue] ) {
            if ([kEFNotificationNameLoadMeFailure isEqualToString:name]) {
                Meta *meta = userInfo[@"meta"];
                if (meta) {
                    NSInteger c = [meta.code integerValue];
                    NSInteger t = c / 100;
                    
                    switch (t) {
                        case 4:{
                            if (c == 401) {
                                if ([@"invalid_auth" isEqualToString:meta.errorType]) {
                                    NSString *errormsg = NSLocalizedString(@"Authentication failed due to security concerns, please sign in again.", nil);
                                    UIAlertView *alerView = [UIAlertView alertViewWithTitle:@"" message:errormsg];
#ifdef DEBUG
                                    [alerView setCancelButtonWithTitle:NSLocalizedString(@"Cancel", nil) handler:nil];
#endif
                                    [alerView addButtonWithTitle:NSLocalizedString(@"OK", nil) handler:^{ [self forceSignOut];}];
                                    [alerView show];
                                }
                            }
                        } break;
                            
                        default:{
                            
                        } break;
                    }
                } else {
                    NSError *error __attribute__((unused)) = userInfo[@"error"];
                    //                        if ([@"NSCocoaErrorDomain" isEqualToString:error.domain]) {
                    //                            [self.model loadCrossListAfter:self.model.latestModify];
                    //                        }
                }
                
            } else {
                // Other notification
            }
            //            }
        } else if ([@"cross" isEqualToString:cat]) {
            if ([kEFNotificationNameLoadCrossListFailure isEqualToString:name]) {
                Meta *meta = userInfo[@"meta"];
                if (meta) {
                    NSInteger c = [meta.code integerValue];
                    NSInteger t = c / 100;
                    
                    switch (t) {
                        case 4:{
                            if (c == 401) {
                                if ([@"invalid_auth" isEqualToString:meta.errorType]) {
                                    NSString *errormsg = NSLocalizedString(@"Authentication failed due to security concerns, please sign in again.", nil);
                                    UIAlertView *alerView = [UIAlertView alertViewWithTitle:@"" message:errormsg];
#ifdef DEBUG
                                    [alerView setCancelButtonWithTitle:NSLocalizedString(@"Cancel", nil) handler:nil];
#endif
                                    [alerView addButtonWithTitle:NSLocalizedString(@"OK", nil) handler:^{ [self forceSignOut];}];
                                    [alerView show];
                                }
                            }
                        } break;
                            
                        default:{
                            
                        } break;
                    }
                } else {
                    NSError *error __attribute__((unused)) = userInfo[@"error"];
                    //                        if ([@"NSCocoaErrorDomain" isEqualToString:error.domain]) {
                    //                            [self.model loadCrossListAfter:self.model.latestModify];
                    //                        }
                }
            }
        } else {
            // for others
        }
    }
}

#pragma mark Override
- (void)refresh
{
    [super refresh];
    [self.model loadCrossListAfter:self.model.latestModify];
}

#pragma mark Refresh
- (void)refreshUI {
    self.crossList = [self.model getCrossList];
    
    [self refreshWelcome];
    [self.tableView reloadData];
}

- (void)refreshTableViewWithCrossId:(int)cross_id {
    for (int i = 0; i < [self.crossList count]; i++) {
        Cross *c = [self.crossList objectAtIndex:i];
        if ([c.cross_id intValue] == cross_id) {
            [self.tableView beginUpdates];
            [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:i inSection:1]]
                                  withRowAnimation:UITableViewRowAnimationNone];
            [self.tableView endUpdates];
        }
    }
}

- (void)refreshWelcome{
    
    NSInteger count = self.crossList.count;
    
    if (self.label_profile.hidden != (count > 0)) {
        self.label_profile.hidden = count > 0;
    }
    if (self.label_gather.hidden != (count > 0)) {
        self.label_gather.hidden = count > 0;
    }
    if (self.welcome_exfe.hidden != (count > 1)) {
        self.welcome_exfe.hidden = count > 1;
    }
    if (self.welcome_more.hidden != (count > 1)) {
        self.welcome_more.hidden = count > 1;
    }
    
   
    NSSet *identites = [User getDefaultUser].identities;
    NSUInteger c = 0;
    for (Identity *ident in identites) {
        if ([ident.status isEqualToString:@"VERIFYING"]) {
            c ++;
        }
    }
    BOOL needVerify = (c == identites.count && c > 0);
    if (needVerify) {
        if (self.unverified_description.hidden) {
            self.unverified_description.hidden = NO;
        }
        if (self.unverified_title.hidden) {
            self.unverified_title.hidden = NO;
        }
        
        CGRect appFrame = [UIScreen mainScreen].applicationFrame;
        CGFloat h = CGRectGetHeight(self.unverified_description.bounds);
        self.unverified_description.frame = CGRectMake(15, CGRectGetHeight(appFrame) - h + self.tableView.contentOffset.y , 290, h);

        CGFloat hh = CGRectGetHeight(self.unverified_title.bounds);
        self.unverified_title.frame = CGRectMake(15, CGRectGetMinY(self.unverified_description.frame) - hh, 290, hh);
    } else {
        self.unverified_description.hidden = YES;
        self.unverified_title.hidden = YES;
    }
}

#pragma mark - UITableViewDataSource methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.headView.isShowed ? 2 : 1;
}

- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section {
    if (0 == section) {
        return 1;
    } else if (1 == section) {
        return self.crossList.count;
    } else {
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (0 == indexPath.section) {
        NSString *reuseIdentifier = @"Profile";
        static UITableViewCell *profileCell = nil;
        if (!profileCell) {
            profileCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
            profileCell.selectionStyle = UITableViewCellSelectionStyleNone;
            profileCell.contentView.backgroundColor = [UIColor clearColor];
            profileCell.backgroundColor = [UIColor clearColor];
            
            [profileCell.contentView addSubview:self.headView];
        }
        
        User *_user = [User getDefaultUser];
        if (_user) {
            NSString *imageName = _user.avatar_filename;
            
            [[EFDataManager imageManager] loadImageForView:self.headView
                                          setImageSelector:@selector(setHeadImage:)
                                               placeHolder:[UIImage imageNamed:@"portrait_default.png"]
                                                       key:imageName
                                           completeHandler:nil];
        }
        return profileCell;
    } else if (1 == indexPath.section) {
        if (self.crossList == nil) {
            return nil;
        }
        
        NSString* reuseIdentifier = @"Card Cell";
        CrossCard *cell = [self.tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
        if (nil == cell) {
            cell = [[CrossCard alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
        }
        Cross *cross = [self.crossList objectAtIndex:indexPath.row];
        cell.cross_id = cross.cross_id;
        cell.hlTitle = NO;
        cell.hlPlace = NO;
        cell.hlTime = NO;
        cell.hlConversation = NO;
        if (cross.updated != nil){
            if([cross.updated isKindOfClass:[NSDictionary class]]){
                NSDictionary *updated = cross.updated;
                NSEnumerator *enumerator = [updated keyEnumerator];
                NSString *key = nil;
                NSDateFormatter *formatter = [DateTimeUtil defaultDateTimeFormatter];
                while (key = [enumerator nextObject]){
                    NSDictionary *obj = [updated objectForKey:key];
                    NSString *updated_at_str = [obj objectForKey:@"updated_at"];
                    NSDate *updated_at = [formatter dateFromString:updated_at_str];
                    
                    BOOL highlignt = YES;
                    if (cross.touched_at) {
                        highlignt = highlignt && [updated_at compare: cross.touched_at] == NSOrderedDescending;
                    }
                    if (cross.read_at) {
                        highlignt = highlignt && [updated_at compare: cross.read_at] == NSOrderedDescending;
                    } 
                    
                    if (highlignt) {
                        if([key isEqualToString:@"title"]) {
                            cell.hlTitle = YES;
                        } else if([key isEqualToString:@"place"]) {
                            cell.hlPlace = YES;
                        } else if([key isEqualToString:@"time"]) {
                            cell.hlTime = YES;
                        } else if([key isEqualToString:@"conversation"]) {
                            cell.hlConversation = YES;
                        }
                    }
                }
            }
        }
        
        cell.title = cross.title;
        cell.conversationCount = [cross.conversation_count intValue];
        if(cross.place == nil){
            cell.place = @"";
        }else if (cross.place.title == nil || [cross.place.title isEqualToString:@""]){
            if ([cross.place hasGeo]) {
                cell.place = NSLocalizedString(@"Somewhere", nil); // We did have location without title
            }else{
                cell.place = @"";
            }
        }else{
            cell.place = cross.place.title;
        }
        
        if (cross.time != nil){
            NSString *time = [[cross.time getTimeTitle] sentenceCapitalizedString];
            //[time retain];
            if (time == nil || time.length == 0) {
                cell.time = @"";
            }else{
                cell.time = [NSString stringWithFormat:@"%@", time];
            }
            //[time release];
        }else{
            cell.time = @"";
        }
        
        NSString *avatarimgurl = nil;
        for(Invitation *invitation in cross.exfee.invitations) {
            NSInteger connected_uid = [invitation.identity.connected_user_id unsignedIntegerValue];
            if (connected_uid == self.model.userId) {
                if(invitation && invitation.invited_by &&
                   invitation.invited_by.avatar_filename ) {
                    avatarimgurl=invitation.invited_by.avatar_filename;
                    break;
                }
            } else if (connected_uid < 0){
                // Unverified identity: connected_uid + identity_id == 0
                // Concern: performace issue?
//                NSFetchRequest* request = [User fetchRequest];
//                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"user_id = %u", [EFAPIServer sharedInstance].user_id];
//                [request setPredicate:predicate];
//                NSArray *users = [[User objectsWithFetchRequest:request] retain];
//                if(users != nil && [users count] > 0)
//                {
//                    User *_user = [users objectAtIndex:0];
//                    for(Identity *identity in _user.identities){
//                        if([identity.identity_id intValue] + connected_uid == 0){
//                            if(invitation && invitation.invited_by &&
//                               invitation.invited_by.avatar_filename ) {
//                                avatarimgurl = invitation.invited_by.avatar_filename;
//                            }
//                            break;
//                        }
//                    }
//                }
            }
        }
        if (!avatarimgurl) {
            cell.avatar = nil;
        } else {
            [[EFDataManager imageManager] loadImageForView:cell
                                          setImageSelector:@selector(setAvatar:)
                                               placeHolder:[UIImage imageNamed:@"portrait_default.png"]
                                                       key:avatarimgurl
                                           completeHandler:nil];
        }
        
        NSString *backimgurl =nil;
        NSArray *widgets = cross.widget;
        for(NSDictionary *widget in widgets) {
            if([[widget objectForKey:@"type"] isEqualToString:@"Background"]) {
                backimgurl=[Util getBackgroundLink:[widget objectForKey:@"image"]];
            }
        }
        
        CGSize targetSize = CGSizeMake((320 - CARD_VERTICAL_MARGIN * 2) * [UIScreen mainScreen].scale, 44 * [UIScreen mainScreen].scale);
        static UIImage *defaultImage = nil;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            defaultImage = [[EFDataManager imageManager] resizeImage:[UIImage imageNamed:@"x_titlebg_default.jpg"] toSize:targetSize];
        });
        
        
        if (backimgurl == nil || backimgurl.length <= 5) {
            cell.bannerimg = defaultImage;
        } else {
            NSString *extname = [backimgurl substringFromIndex:[backimgurl length] - 3];
            
            if ([extname isEqualToString:@"bg/"]) {
                cell.bannerimg = defaultImage;
            } else {
                [[EFDataManager imageManager] loadImageForView:cell
                                              setImageSelector:@selector(setBannerimg:)
                                                          size:targetSize
                                                   placeHolder:defaultImage
                                                           key:backimgurl
                                               completeHandler:nil];
            }
        }

        cell.delegate = self;
      
        return cell;
    } else {
        return nil;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 0){
        return 70;
    }else {
        return 90;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1) {
        Cross *cross = [self.crossList objectAtIndex:indexPath.row];
        
        cross.read_at = [NSDate date];
        if (cross.updated != nil) {
            [self.tableView beginUpdates];
            [self.tableView reloadRowsAtIndexPaths:@[indexPath]
                                  withRowAnimation:UITableViewRowAnimationNone];
            [self.tableView endUpdates];
        }
        NSString *urlstr = [NSString stringWithFormat:@"%@://%@/!%@%@", [UIApplication sharedApplication].defaultScheme, [EFConfig sharedInstance].scope, cross.cross_id, @"?animated=yes"];
        NSURL *url = [NSURL URLWithString:urlstr];
        [[UIApplication sharedApplication] openURL:url];
        
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [super scrollViewDidScroll:scrollView];
    [self refreshWelcome];
}

#pragma mark - View Push methods

- (BOOL)pushToCross:(NSInteger)crossId {
    return [self showCross:crossId withTabClass:NSClassFromString(@"CrossGroupViewController") animated:NO];
}

- (BOOL)pushToConversation:(NSInteger)crossId {
    return [self showCross:crossId withTabClass:NSClassFromString(@"WidgetConvViewController") animated:NO];
}

- (BOOL)showCross:(NSInteger)crossId withTabClass:(Class)class animated:(BOOL)animated
{
    Cross *cross = [self crossWithId:crossId];
    
    [self.navigationController popToRootViewControllerAnimated:NO];
    EFTabBarViewController *tabBarViewController = [self _detailViewControllerWithCross:cross andId:crossId withModel:self.model];
    __weak EFTabBarViewController *weakTab = tabBarViewController;
    tabBarViewController.viewInitHandler = ^{
        EFTabBarViewController * strongTab = weakTab;
        if (!strongTab) {
            return;
        }
        NSUInteger toJumpIndex = class ? [strongTab indexOfViewControllerForClass:class] : strongTab.defaultIndex;
        NSAssert(toJumpIndex != NSNotFound, @"MUST be there!");
        
        [strongTab.tabBar setSelectedIndex:toJumpIndex];
    };
    
    [self.navigationController pushViewController:tabBarViewController animated:animated];
    
    return YES;
    
    return NO;
}

- (void)showProfileViewWithAnimated:(BOOL)animated
{
    ProfileViewController *profileViewController = [[ProfileViewController alloc]initWithNibName:@"ProfileViewController" bundle:nil];
    profileViewController.model = self.model;
    profileViewController.user = [User getDefaultUser];
    [self.navigationController pushViewController:profileViewController animated:animated];
    
}
- (void)showGatherViewWithAnimated:(BOOL)animated
{
    NewGatherViewController *gatherViewController = [[NewGatherViewController alloc]initWithNibName:@"NewGatherViewController" bundle:nil];
    [self.navigationController pushViewController:gatherViewController animated:animated];
}

#pragma mark - CrossCardDelegate
- (void)onClickConversation:(UIView *)card {
    [Flurry logEvent:@"CLICK_CROSS_CARD_CONVERSATION"];
    CrossCard *c = (CrossCard *)card;
    NSString *urlstr = [NSString stringWithFormat:@"%@://%@/!%@%@", [UIApplication sharedApplication].defaultScheme, [EFConfig sharedInstance].scope, c.cross_id, @"/conversation?animated=yes"];
    NSURL *url = [NSURL URLWithString:urlstr];
    [[UIApplication sharedApplication] openURL:url];
}

#pragma mark - Private

- (EFTabBarViewController *)_detailViewControllerWithCross:(Cross *)cross andId:(NSUInteger)crossId withModel:(EXFEModel *)model
{
    // CrossGroupViewController
    CrossGroupViewController *crossGroupViewController = [[CrossGroupViewController alloc] initWithModel:model];
    
    EFTabBarItem *tabBarItem1 = [EFTabBarItem tabBarItemWithImage:[UIImage imageNamed:@"widget_x_30.png"]];
    tabBarItem1.highlightImage = [UIImage imageNamed:@"widget_x_30shine.png"];
    tabBarItem1.tabBarItemLevel = kEFTabBarItemLevelNormal;
    tabBarItem1.defaultOrder = 0;
    
    crossGroupViewController.customTabBarItem = tabBarItem1;
    crossGroupViewController.tabBarStyle = kEFTabBarStyleDoubleHeight;
    crossGroupViewController.shadowImage = [UIImage imageNamed:@"tabshadow_x.png"];
    
    // ConvViewController
    WidgetConvViewController *conversationViewController =  [[WidgetConvViewController alloc] initWithModel:model];
    
    NSUInteger conversationCount = [cross.conversation_count unsignedIntegerValue];
    
    EFTabBarItem *tabBarItem2 = [EFTabBarItem tabBarItemWithImage:[UIImage imageNamed:@"widget_conv_30.png"]];
    tabBarItem2.highlightImage = [UIImage imageNamed:@"widget_conv_30shine.png"];
    tabBarItem2.titleEnable = YES;
    tabBarItem2.title = conversationCount > 0 ? [NSString stringWithFormat:@"%u", conversationCount] : nil;
    tabBarItem2.tabBarItemLevel = kEFTabBarItemLevelNormal;
    tabBarItem2.defaultOrder = 1;
    
    conversationViewController.customTabBarItem = tabBarItem2;
    conversationViewController.tabBarStyle = kEFTabBarStyleNormal;
    conversationViewController.shadowImage = [UIImage imageNamed:@"tabshadow_conv.png"];
    
    // ExfeeViewController
    WidgetExfeeViewController *exfeeViewController = [[WidgetExfeeViewController alloc] initWithModel:model];
//    exfeeViewController.exfee = cross.exfee;
//    __weak Exfee * weakExfee = exfeeViewController.exfee;
//    exfeeViewController.onExitBlock = ^{
//        [crossGroupViewController performSelector:@selector(fillExfee:)
//                                       withObject:weakExfee];
//    };
    
    EFTabBarItem *tabBarItem3 = [EFTabBarItem tabBarItemWithImage:[UIImage imageNamed:@"widget_exfee_30.png"]];
    tabBarItem3.highlightImage = [UIImage imageNamed:@"widget_exfee_30shine.png"];
    tabBarItem3.tabBarItemLevel = kEFTabBarItemLevelNormal;
    tabBarItem3.defaultOrder = 2;
    
    exfeeViewController.customTabBarItem = tabBarItem3;
    exfeeViewController.tabBarStyle = kEFTabBarStyleNormal;
    exfeeViewController.shadowImage = [UIImage imageNamed:@"tabshadow_x.png"];
    
    // MadaurerMapViewController
    EFRouteXViewController *routeXViewController = [[EFRouteXViewController alloc] initWithNibName:@"EFRouteXViewController" bundle:nil];
    routeXViewController.model = model;
    
    EFTabBarItem *tabBarItem4 = [EFTabBarItem tabBarItemWithImage:[UIImage imageNamed:@"widget_routex_30.png"]];
    tabBarItem4.highlightImage = [UIImage imageNamed:@"widget_routex_30shine.png"];
    tabBarItem4.defaultOrder = 3;
    
    if (cross) {
        BOOL shouldRouteXVisible = NO;
        for (NSDictionary *widgetInfo in cross.widget) {
            NSString *type = [widgetInfo valueForKey:@"type"];
            if ([type isEqualToString:@"routex"]) {
                if ([NSNull null] != (NSNull *)[widgetInfo valueForKey:@"my_status"]) {
                    shouldRouteXVisible = YES;
                }
                
                NSNumber *isDefaultNumber = [widgetInfo valueForKey:@"default"];
                if (isDefaultNumber) {
                    shouldRouteXVisible = YES;
                    
                    if ([isDefaultNumber boolValue]) {
                        tabBarItem4.tabBarItemLevel = kEFTabBarItemLevelDefault;
                        
                        tabBarItem1.tabBarItemLevel = kEFTabBarItemLevelLow;
                        tabBarItem2.tabBarItemLevel = kEFTabBarItemLevelLow;
                        tabBarItem3.tabBarItemLevel = kEFTabBarItemLevelLow;
                    } else {
                        tabBarItem4.tabBarItemLevel = kEFTabBarItemLevelNormal;
                    }
                }
            }
        }
        
        if (!shouldRouteXVisible) {
            tabBarItem4.tabBarItemLevel = kEFTabBarItemLevelLow;
        }
    } else {
        tabBarItem4.tabBarItemLevel = kEFTabBarItemLevelLow;
    }
    
    routeXViewController.customTabBarItem = tabBarItem4;
    routeXViewController.tabBarStyle = kEFTabBarStyleNormal;
    routeXViewController.shadowImage = nil;
    routeXViewController.model = model;
    
    // Init TabBarViewController
    EFCrossTabBarViewController *tabBarViewController = [[EFCrossTabBarViewController alloc] initWithViewControllers:[NSMutableArray arrayWithObjects:crossGroupViewController, conversationViewController, exfeeViewController, routeXViewController, nil]];
    tabBarViewController.model = self.model;
    tabBarViewController.crossId = crossId;
    if (cross) {
        tabBarViewController.cross = cross;
    }
    tabBarViewController.crossId = crossId;
    
    __weak EFTabBarViewController *weakTab = tabBarViewController;
    tabBarViewController.titlePressedHandler = ^{
        EFTabBarViewController *strongTab = weakTab;
        if (!strongTab) {
            return;
        }
        if (crossGroupViewController == strongTab.selectedViewController) {
            NSInteger arg = 0x0101;
            [crossGroupViewController showPopup:arg];
        }
    };
    
    tabBarViewController.backButtonActionHandler = ^{
        RKObjectManager *objectManager = (RKObjectManager *)model.objectManager;
        [objectManager.operationQueue cancelAllOperations];
        [self.navigationController popToRootViewControllerAnimated:YES];
    };
    
    return tabBarViewController;
}

#pragma mark TTTAttributedLabelDelegate
/**
 Tells the delegate that the user did select a link to a URL.
 
 @param label The label whose link was selected.
 @param url The URL for the selected link.
 */
- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithURL:(NSURL *)url
{
    [[UIApplication sharedApplication] openURL:url];
}


@end

@implementation CrossesViewController (URLNavigation)

- (BOOL)pushTo:(NSArray *)pathComponents animated:(BOOL)animated
{
    if (pathComponents.count > 0) {
        NSString *root = [pathComponents objectAtIndex:0];
        if ([root hasPrefix:@"+"] || [root hasPrefix:@"%2b"]) {
            // identity for phone number
            return NO;
        } else if ([root rangeOfString:@"@"].location != NSNotFound) {
            // identity
            return NO;
        } else if ([root hasPrefix:@"!"]) {
            // cross with id
            NSString * crossIdString = [root substringFromIndex:1];
            NSCharacterSet *alphaNums = [NSCharacterSet decimalDigitCharacterSet];
            NSCharacterSet *inStringSet = [NSCharacterSet characterSetWithCharactersInString:crossIdString];
            BOOL valid = [alphaNums isSupersetOfSet:inStringSet];
            if (valid) {
                if (self.navigationController.viewControllers.count > 1) {
                    [self.navigationController popToRootViewControllerAnimated:NO];
                }
                NSInteger crossId = [crossIdString integerValue];
                Class cls = nil;    //[CrossGroupViewController class];
                if (pathComponents.count > 1) {
                    NSString *tab = [pathComponents objectAtIndex:1];
                    if ([@"conversation" caseInsensitiveCompare:tab] == NSOrderedSame) {
                        cls = [WidgetConvViewController class];
                    } else if ([@"exfee" caseInsensitiveCompare:tab] == NSOrderedSame) {
                        cls = [WidgetExfeeViewController class];
                    } else if ([@"routex" caseInsensitiveCompare:tab] == NSOrderedSame) {
                        cls = [EFRouteXViewController class];
                    }
                }
                [self showCross:crossId withTabClass:cls animated:animated];
                return YES;
            }
        } else if ([@"profile" caseInsensitiveCompare:root] == NSOrderedSame) {
            if (self.navigationController.viewControllers.count > 1) {
                [self.navigationController popToRootViewControllerAnimated:NO];
            }
            if ([self.model isLoggedIn]) {
                [self showProfileViewWithAnimated:animated];
            }
            return YES;
        } else if ([@"gather" caseInsensitiveCompare:root] == NSOrderedSame) {
            if (self.navigationController.viewControllers.count > 1) {
                [self.navigationController popToRootViewControllerAnimated:NO];
            }
            if ([self.model isLoggedIn]) {
                [self showGatherViewWithAnimated:animated];
            }
            return YES;
        }
    }
    return NO;
}

@end
