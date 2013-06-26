//
//  CrossesViewController.m
//  EXFE
//
//  Created by ju huo on 5/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CrossesViewController.h"
#import "ProfileViewController.h"
#import "EFLandingViewController.h"
#import "Cross.h"
#import "Exfee+EXFE.h"
#import "User+EXFE.h"
#import "Identity+EXFE.h"
#import "Rsvp.h"
#import "CrossCard.h"
#import "Util.h"
#import "CrossTime+Helper.h"
#import "EFTime+Helper.h"
#import "Place+Helper.h"
#import "NSString+EXFE.h"
#import "CrossGroupViewController.h"
#import "EFAPIServer.h"
#import "EFHeadView.h"
#import "EFKit.h"
#import "WidgetConvViewController.h"
#import "WidgetExfeeViewController.h"
#import "EFModel.h"


@interface CrossesViewController ()
@property (nonatomic, retain) EFHeadView *headView;
@end

@interface CrossesViewController (Private)
- (EFTabBarViewController *)_detailViewControllerWithCross:(Cross *)cross;
@end

@implementation CrossesViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)setCrossList:(NSArray *)crossList
{
    if (_crossList != crossList) {
        NSArray *tempList = crossList;
        // WALKAROUND: clean duplicate
//        if (tempList != nil) {
//            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
//            for (Cross *x in crossList) {
//                NSString *key = [x.cross_id stringValue];
//                Cross *previous = [dict objectForKey:key];
//                if (previous == nil) {
//                    [dict setObject:x forKey:key];
//                } else {
//                    if ([DateTimeUtil secondsBetween:previous.updated_at with:x.updated_at]) {
//                        [dict removeObjectForKey:key];
//                        [dict setObject:x forKey:key];
//                    }
//                }
//            }
//            if (tempList.count > dict.count) {
//                tempList = [dict allValues];
//            }
//        }
        [tempList retain];
        [_crossList release];
        _crossList = tempList;
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    [Flurry logEvent:@"CROSS_LIST"];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    
    // Head View
    EFHeadView *headView = [[EFHeadView alloc] initWithFrame:(CGRect){{0.0f, 9.0f}, {320.0f, 56.0f}}];
    headView.headPressedHandler = ^{
        [self ShowProfileView];
    };
    headView.titlePressedHandler = ^{
        [self ShowGatherView];
    };
    headView.willShowHandler = ^{
        [self.tableView beginUpdates];
        [self.tableView insertSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationFade];
        [self.tableView endUpdates];
    };
    
    self.headView = headView;
    [headView release];
    
    //
    CGRect appFrame = [[UIScreen mainScreen] applicationFrame];
    [self.view setFrame:appFrame];
    self.view.backgroundColor = [UIColor COLOR_RGB(0xEE, 0xEE, 0xEE)];
    
    self.tableView.separatorStyle=UITableViewCellSeparatorStyleNone;

    [[UIBarButtonItem appearance] setBackButtonBackgroundImage:[[UIImage imageNamed:@"btn_back.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 15, 0, 6)]
                                                      forState:UIControlStateNormal
                                                    barMetrics:UIBarMetricsDefault];
    current_cellrow = -1;
    self.tableView.backgroundColor = [UIColor COLOR_RGB(0xEE, 0xEE, 0xEE)];
    //UIView *topview = [[UIView alloc] initWithFrame:CGRectOffset(screenframe, 0, CGRectGetHeight(screenframe))];
    UIView *topview = [[UIView alloc] initWithFrame:CGRectMake(0, -480, 320, 480)];
    topview.backgroundColor = [UIColor COLOR_RGB(0xEE, 0xEE, 0xEE)];
    [self.tableView addSubview:topview];
    [topview release];
    [super viewDidLoad];
    
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
        [defaultView release];
        
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
        
        [self loadObjectsFromDataStore];
        [self refreshCrosses:@"crossupdateview"];
    } else {
        [self.headView showAnimated:NO];
        
//        EFLandingViewController *viewController = [[[EFLandingViewController alloc] initWithNibName:@"EFLandingViewController" bundle:nil] autorelease];
        EFLandingViewController *viewController = [[EFLandingViewController alloc] initWithNibName:@"EFLandingViewController" bundle:nil];
        [app.window.rootViewController presentModalViewController:viewController animated:NO];
        
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
    
    label_profile = [[UILabel alloc] initWithFrame:CGRectMake(15, 70, 130, 31)];
    label_profile.backgroundColor = [UIColor clearColor];
    label_profile.textColor = [UIColor COLOR_WA(0x6B, 0xFF)];
    label_profile.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:14];
    label_profile.text = @"Manage identities to \nreveal who your are.";
    label_profile.numberOfLines = 2;
    [label_profile sizeToFit];
    //label_profile.hidden = YES;
    [self.view addSubview:label_profile];
    
    label_gather = [[UILabel alloc] initWithFrame:CGRectMake(220, 70, 130, 31)];
    label_gather.backgroundColor = [UIColor clearColor];
    label_gather.textColor = [UIColor COLOR_WA(0x6B, 0xFF)];
    label_gather.textAlignment = NSTextAlignmentRight;
    label_gather.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:14];
    label_gather.text = @"Hang out with\n friends.";
    label_gather.numberOfLines = 2;
    [label_gather sizeToFit];
    //label_gather.hidden = YES;
    label_gather.frame = CGRectOffset(label_gather.frame, 305 - CGRectGetMaxX(label_gather.frame), 0);
    [self.view addSubview:label_gather];
    
    welcome_exfe = [[EXAttributedLabel alloc] initWithFrame:CGRectMake(32, 250, 260, 35)];
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:@"Welcome to EXFE"];
    CTFontRef fontref=CTFontCreateWithName(CFSTR("HelveticaNeue-Light"), 30.0, NULL);
    [attrStr addAttribute:(NSString*)kCTFontAttributeName value:(id)fontref range:NSMakeRange(0, [attrStr length])];
    [attrStr addAttribute:(NSString*)kCTForegroundColorAttributeName value:(id)[UIColor COLOR_BLACK].CGColor range:NSMakeRange(0,11)];
    [attrStr addAttribute:(NSString*)kCTForegroundColorAttributeName value:(id)[UIColor COLOR_BLUE_EXFE].CGColor range:NSMakeRange(11,4)];
    CTTextAlignment alignment = kCTCenterTextAlignment;
    CTParagraphStyleSetting paragraphsetting[3] = {
        {kCTParagraphStyleSpecifierAlignment, sizeof(alignment), &alignment},
    };
    CTParagraphStyleRef paragraphstyle = CTParagraphStyleCreate(paragraphsetting, 3);
    [attrStr addAttribute:(id)kCTParagraphStyleAttributeName value:(id)paragraphstyle range:NSMakeRange(0,[attrStr length])];
    CFRelease(paragraphstyle);
    CFRelease(fontref);
    welcome_exfe.attributedText = attrStr;
    [attrStr release];
    welcome_exfe.backgroundColor = [UIColor clearColor];
    //welcome_exfe.hidden = YES;
    welcome_exfe.frame = CGRectOffset(welcome_exfe.frame, 160 - CGRectGetMidX(welcome_exfe.frame), 0);
    [self.view addSubview:welcome_exfe];
    
    welcome_more = [[UILabel alloc] initWithFrame:CGRectMake(32, 285, 300, 23)];
    welcome_more.backgroundColor = [UIColor clearColor];
    welcome_more.textColor = [UIColor COLOR_WA(0x6B, 0xFF)];
    welcome_more.textAlignment = NSTextAlignmentRight;
    welcome_more.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:18];
    welcome_more.text = @"The group utility for gathering.";
    [welcome_more sizeToFit];
    //welcome_more.hidden = YES;
    welcome_more.frame = CGRectOffset(welcome_more.frame, 160 - CGRectGetMidX(welcome_more.frame), 0);
    [self.view addSubview:welcome_more];
    
    if (self.crossChangeObserver == nil) {
        self.crossChangeObserver = [[NSNotificationCenter defaultCenter] addObserverForName:EXCrossListDidChangeNotification
                                                                                     object:nil
                                                                                      queue:[NSOperationQueue mainQueue]
                                                                                 usingBlock:^(NSNotification *note) {
                                                                                     [self loadObjectsFromDataStore];
                                                                                 }];
    }
    [self refreshWelcome];
    
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleLoadMeSuccess:)
                                                 name:kEFNotificationNameLoadMeSuccess
                                               object:nil];
}

- (Cross*) crossWithId:(int)cross_id{
    for(Cross *c in self.crossList)
    {
        if([c.cross_id intValue]==cross_id)
            return c;
    }
    return nil;
}
- (void)viewDidUnload
{
    
    [super viewDidUnload];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    if (self.crossChangeObserver) {
        [[NSNotificationCenter defaultCenter] removeObserver:self.crossChangeObserver];
    }
    
    self.crossList = nil;
    [_headView release];
    
//    if(cellDateTime){
//        [cellDateTime release];
//        cellDateTime=nil;
//    }
//    [settingButton release];
//    [gatherax release];
    [label_profile release];
    [label_gather release];
    [welcome_exfe release];
    [welcome_more release];
    [super dealloc];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
    [self.tableView reloadData];
}

- (void)handleLoadMeSuccess:(NSNotification *)notif {
    NSRange range = NSMakeRange(0, 1);
    NSIndexSet *section = [NSIndexSet indexSetWithIndexesInRange:range];
    [self.tableView reloadSections:section withRowAnimation:UITableViewRowAnimationNone];
}

- (void)ShowProfileView{
    RKObjectManager *manager=[RKObjectManager sharedManager];
    [manager.HTTPClient.operationQueue cancelAllOperations];
    ProfileViewController *profileViewController=[[ProfileViewController alloc]initWithNibName:@"ProfileViewController" bundle:nil];
    profileViewController.user = [User getDefaultUser];
    [self.navigationController pushViewController:profileViewController animated:YES];
    [profileViewController release];
    
}
- (void)ShowGatherView{
    NewGatherViewController *gatherViewController=[[NewGatherViewController alloc]initWithNibName:@"NewGatherViewController" bundle:nil];
    
    [self.navigationController pushViewController:gatherViewController animated:YES];
    [gatherViewController release];
}

- (void) refreshCrosses:(NSString*)source{
    [self refreshCrosses:(NSString*)source withCrossId:0];
}

- (void)refreshCrosses:(NSString*)source withCrossId:(int)cross_id {
    
    NSString *updated_at=@"";
    NSDate *date_updated_at = [[NSUserDefaults standardUserDefaults] objectForKey:@"exfee_updated_at"];
    if (date_updated_at != nil) {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss ZZZ"];
        [formatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
        updated_at = [formatter stringFromDate:date_updated_at];
        [formatter release];
    }
    if ([source isEqualToString:@"crossview_init"]) {
        //        hud=[MBProgressHUD showHUDAddedTo:self.view animated:YES];
        //        hud.labelText = @"Loading";
        //        hud.mode=MBProgressHUDModeCustomView;
        //        EXSpinView *bigspin = [[EXSpinView alloc] initWithPoint:CGPointMake(0, 0) size:40];
        //        [bigspin startAnimating];
        //        hud.customView=bigspin;
        //        [bigspin release];
    }
    
    //  source:[NSDictionary dictionaryWithObjectsAndKeys:source,@"name",[NSNumber numberWithInt:cross_id],@"cross_id", nil]
    AppDelegate * app = (AppDelegate*)[UIApplication sharedApplication].delegate;
    [app.model.apiServer loadCrossesAfter:updated_at
                                           success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                               
                                               int notification=0;
                                               if([[mappingResult array] count]>0)
                                               {
                                                   //        NSString *source=[objectLoader.userData objectForKey:@"name" ];
                                                   //          NSString *exfee_updated_at=[[NSUserDefaults standardUserDefaults] objectForKey:@"exfee_updated_at"];
                                                   NSDate *last_updated_at=[[NSUserDefaults standardUserDefaults] objectForKey:@"exfee_updated_at"];
                                                   //          BOOL needsave=NO;
                                                   BOOL isError=NO;
                                                   Meta *meta=(Meta*)[[mappingResult dictionary] objectForKey:@"meta"];
                                                   if(meta!=nil){
                                                       if([meta.code intValue]!=200){
                                                           [Util showErrorWithMetaObject:meta delegate:self];
                                                           isError=YES;
                                                       }
                                                   }
                                                   if(isError==NO){
                                                       NSArray *crosses=(NSArray*)[[mappingResult dictionary] objectForKey:@"response.crosses"];
                                                       for (Cross *cross in crosses){
                                                           id updated=cross.updated;
                                                           NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                                                           [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss ZZZ"];
                                                           [formatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
                                                           NSDate *cross_updated_at = [formatter dateFromString:cross.updated_at];
                                                           [formatter release];
                                                           
                                                           if([updated isKindOfClass:[NSDictionary class]]){
                                                               NSEnumerator *enumerator=[(NSDictionary*)updated keyEnumerator];
                                                               NSString *key=nil;
                                                               NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                                                               [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                                                               [formatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
                                                               
                                                               while (key = [enumerator nextObject]){
                                                                   NSDictionary *obj=[(NSDictionary*) updated objectForKey:key];
                                                                   NSString *updated_at_str=[obj objectForKey:@"updated_at"];
                                                                   if([updated_at_str isKindOfClass:[NSString class]]) {
                                                                       NSDate *updated_at =[NSDate date];
                                                                       if([updated_at_str length]>19){
                                                                           updated_at_str=[updated_at_str substringToIndex:19];
                                                                           updated_at = [formatter dateFromString:updated_at_str];
                                                                           
                                                                           if(last_updated_at==nil)
                                                                               last_updated_at=updated_at;
                                                                           else{
                                                                               last_updated_at=[updated_at laterDate:last_updated_at];
                                                                           }
                                                                           
                                                                           
                                                                       }
                                                                       
                                                                       if([updated_at compare: cross_updated_at] == NSOrderedDescending || [updated_at compare: cross_updated_at] == NSOrderedSame) {
                                                                           if([[obj objectForKey:@"identity_id"] isKindOfClass:[NSNumber class]]) {
                                                                               NSNumber *identity_id = [obj objectForKey:@"identity_id"];
                                                                               if ([[User getDefaultUser] isMeByIdentityId:identity_id] == NO){
                                                                                   notification++;
                                                                               }
                                                                           }
                                                                       }
                                                                   }
                                                               }
                                                               [formatter release];
                                                           }
                                                           if(cross.updated_at!=nil){
                                                               //                  if([source isEqualToString:@"crossview"]){
                                                               //                      if(exfee_updated_at==nil){
                                                               //                          cross.read_at=[NSDate date];
                                                               //                          needsave=YES;
                                                               //                      }
                                                               //                  }
                                                               if(last_updated_at==nil)
                                                                   last_updated_at=cross_updated_at;
                                                               else{
                                                                   last_updated_at=[cross_updated_at laterDate:last_updated_at];
                                                               }
                                                           }
                                                       }
                                                       
                                                       [[NSUserDefaults standardUserDefaults] setObject:last_updated_at forKey:@"exfee_updated_at"];
                                                       [[NSUserDefaults standardUserDefaults] synchronize];
                                                       if(![source isEqualToString:@"crossview"] && notification>0){
                                                           // show update hints
                                                       }
                                                       if ([source isEqualToString:@"gatherview"]) {
                                                           AppDelegate *app=(AppDelegate *)[[UIApplication sharedApplication] delegate];
                                                           [app.navigationController dismissModalViewControllerAnimated:YES];
                                                       }
                                                       else if([source isEqualToString:@"pushtocross"]) {
                                                           Cross *cross = [self crossWithId:cross_id];
                                                           
                                                           EFTabBarViewController *tabBarViewController = [self _detailViewControllerWithCross:cross];
                                                           [self.navigationController pushViewController:tabBarViewController animated:NO];
                                                       }
                                                       else if([source isEqualToString:@"pushtoconversation"]) {
                                                           Cross *cross = [self crossWithId:cross_id];
                                                           
                                                           Class toJumpClass = NSClassFromString(@"WidgetConvViewController");
                                                           EFTabBarViewController *tabBarViewController = [self _detailViewControllerWithCross:cross];
                                                           tabBarViewController.viewWillAppearHandler = ^{
                                                               NSUInteger toJumpIndex = [tabBarViewController indexOfViewControllerForClass:toJumpClass];
                                                               NSAssert(toJumpIndex != NSNotFound, @"应该必须可找到");
                                                               
                                                               [tabBarViewController.tabBar setSelectedIndex:toJumpIndex];
                                                           };
                                                           
                                                           [self.navigationController pushViewController:tabBarViewController animated:NO];
                                                           
                                                       }
                                                       else if([source isEqualToString:@"crossupdateview"] || [source isEqualToString:@"crossview"] || [source isEqualToString:@"crossview_init"]) {
                                                           [self loadObjectsFromDataStore];
                                                       }
                                                   }
                                               }
                                               [self loadObjectsFromDataStore];
                                               
                                               //
                                               [self stopLoading];
                                               if(hud)
                                                   [MBProgressHUD hideHUDForView:self.view animated:YES];
                                               
                                           }
                                           failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                               if(alertShowflag==NO){
                                                   alertShowflag=YES;
                                                   [Util showConnectError:error delegate:self];
                                               }
                                               [self stopLoading];
                                               if(hud)
                                                   [MBProgressHUD hideHUDForView:self.view animated:YES];
                                           }];
    
}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)loadObjectsFromDataStore {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Cross"];
	NSSortDescriptor* descriptor = [NSSortDescriptor sortDescriptorWithKey:@"updated_at" ascending:NO];
	[request setSortDescriptors:[NSArray arrayWithObject:descriptor]];
    RKObjectManager *objectManager = [RKObjectManager sharedManager];
    
    // ignore duplicate objects
    [objectManager.managedObjectStore.mainQueueManagedObjectContext performBlockAndWait:^{
        NSArray *crosses = [objectManager.managedObjectStore.mainQueueManagedObjectContext executeFetchRequest:request error:nil];
        NSMutableArray *filteredCrosses = [[NSMutableArray alloc] initWithCapacity:[crosses count]];
        @autoreleasepool {
            NSMutableDictionary *crossAddDict = [NSMutableDictionary dictionaryWithCapacity:[crosses count]];
            
            for (Cross *cross in crosses) {
                NSString *key = [NSString stringWithFormat:@"%d", [cross.cross_id intValue]];
                if (![crossAddDict valueForKey:key]) {
                    [filteredCrosses addObject:cross];
                    [crossAddDict setValue:@"YES" forKey:key];
                }
            }
        }
        
        self.crossList = filteredCrosses;
        [filteredCrosses release];
    }];
    
    [self refreshWelcome];
    [self.tableView reloadData];
}

- (void)refresh
{
    [self refreshCrosses:@"crossupdateview"];
}

- (NSInteger)getCrossCount{
    return self.crossList.count;
}

- (void)refreshWelcome{
    NSInteger count = [self getCrossCount];
    
    if (label_profile.hidden != (count > 0)) {
        label_profile.hidden = count > 0;
    }
    if (label_gather.hidden != (count > 0)) {
        label_gather.hidden = count > 0;
    }
    if (welcome_exfe.hidden != (count > 2)) {
        welcome_exfe.hidden = count > 2;
    }
    if (welcome_more.hidden != (count > 2)) {
        welcome_more.hidden = count > 2;
    }
}

- (void)emptyView{
    self.crossList = nil;
    [self refreshWelcome];
    [self.tableView reloadData];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 500) {
        if (buttonIndex == alertView.firstOtherButtonIndex) {
            [Util signout];
            
            EFLandingViewController *viewController = [[[EFLandingViewController alloc] initWithNibName:@"EFLandingViewController" bundle:nil] autorelease];
            [self presentModalViewController:viewController animated:NO];
        }
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
        return [self getCrossCount];
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
        NSString *imgName = _user.avatar_filename;
        
        if ([[EFDataManager imageManager] isImageCachedInMemoryForKey:imgName]) {
            self.headView.headImage = [[EFDataManager imageManager] cachedImageInMemoryForKey:imgName];
        } else {
            [[EFDataManager imageManager] cachedImageForKey:imgName
                                            completeHandler:^(UIImage *image){
                                                self.headView.headImage = image;
                                            }];
        }
        
        return profileCell;
    } else if (1 == indexPath.section) {
        if (self.crossList == nil) {
            return nil;
        }
        
        NSString* reuseIdentifier = @"Card Cell";
        CrossCard *cell =[self.tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
        if (nil == cell) {
            cell = [[[CrossCard alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier] autorelease];
        }
        Cross *cross=[self.crossList objectAtIndex:indexPath.row ];
        cell.cross_id=cross.cross_id;
        cell.hlTitle = NO;
        cell.hlPlace = NO;
        cell.hlTime = NO;
        cell.hlConversation = NO;
        if (cross.updated != nil){
            id updated = cross.updated;
            if([updated isKindOfClass:[NSDictionary class]]){
                NSEnumerator *enumerator=[(NSDictionary*)updated keyEnumerator];
                NSString *key=nil;
                NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                [formatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
                
                while (key = [enumerator nextObject]){
                    NSDictionary *obj=[(NSDictionary*) updated objectForKey:key];
                    NSString *updated_at_str=[obj objectForKey:@"updated_at"];
                    NSDate *updated_at =[NSDate date];
                    if([updated_at_str isKindOfClass:[NSString class]]){
                        if([updated_at_str length]>19)
                            updated_at_str=[updated_at_str substringToIndex:19];
                        updated_at = [formatter dateFromString:updated_at_str];
                    }
                    if([updated_at compare: cross.read_at] == NSOrderedDescending || cross.read_at==nil) {
                        if([key isEqualToString:@"title"])
                            cell.hlTitle=YES;
                        else if([key isEqualToString:@"place"])
                            cell.hlPlace=YES;
                        else if([key isEqualToString:@"time"])
                            cell.hlTime=YES;
                        else if([key isEqualToString:@"conversation"])
                            cell.hlConversation=YES;
                    }
                }
                [formatter release];
            }
        }
        cell.title=cross.title;
        cell.conversationCount = [cross.conversation_count intValue];
        if(cross.place == nil){
            cell.place = @"";
        }else if (cross.place.title == nil || [cross.place.title isEqualToString:@""]){
            if ([cross.place hasGeo]) {
                cell.place = @"Somewhere"; // We did have location without title
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
        
        
        AppDelegate * app = (AppDelegate *)[UIApplication sharedApplication].delegate;
        NSString *avatarimgurl=nil;
        for(Invitation *invitation in cross.exfee.invitations) {
            NSInteger connected_uid = [invitation.identity.connected_user_id integerValue];
            if (connected_uid == app.model.userId) {
                if(invitation && invitation.invited_by &&
                   invitation.invited_by.avatar_filename ) {
                    avatarimgurl=invitation.invited_by.avatar_filename;
                    break;
                }
            }else if (connected_uid < 0){
                // Unverified identity: connected_uid + identity_git id == 0
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
//                [users release];
            }
        }
        if (!avatarimgurl) {
            cell.avatar = nil;
        } else {
            if ([[EFDataManager imageManager] isImageCachedInMemoryForKey:avatarimgurl]) {
                cell.avatar = [[EFDataManager imageManager] cachedImageInMemoryForKey:avatarimgurl];
            } else {
                [[EFDataManager imageManager] cachedImageForKey:avatarimgurl
                                                completeHandler:^(UIImage *image){
                                                    if (image) {
                                                        cell.avatar = image;
                                                    }
                                                }];
            }
        }
        
      NSString *backimgurl=nil;
        NSArray *widgets = cross.widget;
        for(NSDictionary *widget in widgets) {
            if([[widget objectForKey:@"type"] isEqualToString:@"Background"]) {
                backimgurl=[Util getBackgroundLink:[widget objectForKey:@"image"]];
            }
        }
      CGSize targetSize = CGSizeMake((320 - CARD_VERTICAL_MARGIN * 2) * [UIScreen mainScreen].scale, 44 * [UIScreen mainScreen].scale);
      if(backimgurl==nil || backimgurl.length<=5){
        cell.bannerimg=nil;
      }else{
        NSString *extname=[backimgurl substringFromIndex:[backimgurl length]-3];
        if([extname isEqualToString:@"bg/"]){
          cell.bannerimg=nil;
        }else{
          UIImage *backimg=[[ImgCache sharedManager] getImgFromCache:backimgurl withSize:targetSize];
          if(backimg != nil && ![backimg isEqual:[NSNull null]]){
            cell.bannerimg=backimg;
          }
          else
          {
            dispatch_queue_t imgQueue = dispatch_queue_create("fetchimg thread", NULL);
            dispatch_async(imgQueue, ^{
              UIImage *image=[[ImgCache sharedManager] getImgFrom:backimgurl withSize:targetSize];
              cell.bannerimg=nil;
              dispatch_async(dispatch_get_main_queue(), ^{
                cell.bannerimg = image;
              });
            });
            dispatch_release(imgQueue);
          }
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
        
        if (cross.updated != nil) {
            id updated = cross.updated;
            if ([updated isKindOfClass:[NSDictionary class]]) {
                NSEnumerator *enumerator = [(NSDictionary*)updated keyEnumerator];
                NSString *key = nil;
                
                while (key = [enumerator nextObject]) {
                    NSDictionary *obj = [(NSDictionary*) updated objectForKey:key];
                    NSString *updated_at_str = [obj objectForKey:@"updated_at"];
                    
                    if (updated_at_str != nil && [updated_at_str length] > 19) {
                        updated_at_str = [updated_at_str substringToIndex:19];
                    }
                    
                    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                    [formatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
                    NSDate *updated_at = [formatter dateFromString:updated_at_str];
                    [formatter release];
                    if (cross.read_at == nil) {
                        cross.read_at=updated_at;
                    } else {
                        cross.read_at=[cross.read_at laterDate:updated_at];
                    }
                }
                
                [self.tableView beginUpdates];
                [self.tableView reloadRowsAtIndexPaths:@[indexPath]
                                      withRowAnimation:UITableViewRowAnimationNone];
                [self.tableView endUpdates];
            }
        }
        
        EFTabBarViewController *tabBarViewController = [self _detailViewControllerWithCross:cross];
        [self.navigationController pushViewController:tabBarViewController animated:YES];
        
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
        current_cellrow = indexPath.row;
    }
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

- (void)refreshCell {
    if( current_cellrow>=0 ) {
        [self.tableView beginUpdates];
        [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:current_cellrow inSection:0]]
                          withRowAnimation:UITableViewRowAnimationNone];
        [self.tableView endUpdates];
    }

    current_cellrow = -1;
}

- (void)alertsignout {
    [Util signout];
}

#pragma mark - View Push methods

- (BOOL)pushToCross:(int)cross_id {
    Cross *cross = [self crossWithId:cross_id];
    if (cross != nil) {
        [self.navigationController popToRootViewControllerAnimated:NO];
        
        EFTabBarViewController *tabBarViewController = [self _detailViewControllerWithCross:cross];
        [self.navigationController pushViewController:tabBarViewController animated:NO];
        
        return YES;
    }
    
    return NO;
}

- (BOOL)pushToConversation:(int)cross_id {
    Cross *cross = [self crossWithId:cross_id];
    
    if (cross != nil) {
        [self.navigationController popToRootViewControllerAnimated:NO];
        
        Class toJumpClass = NSClassFromString(@"WidgetConvViewController");
        EFTabBarViewController *tabBarViewController = [self _detailViewControllerWithCross:cross];
        tabBarViewController.viewWillAppearHandler = ^{
            NSUInteger toJumpIndex = [tabBarViewController indexOfViewControllerForClass:toJumpClass];
            NSAssert(toJumpIndex != NSNotFound, @"应该必须可找到");
            
            [tabBarViewController.tabBar setSelectedIndex:toJumpIndex];
        };
        
        [self.navigationController pushViewController:tabBarViewController animated:NO];
        
        return YES;
    }
    
    return NO;
}

#pragma mark - CrossCardDelegate

- (void)onClickConversation:(UIView *)card {
    [Flurry logEvent:@"CLICK_CROSS_CARD_CONVERSATION"];
    CrossCard* c = (CrossCard*)card;
    int cross_id = [c.cross_id intValue];
    
    Cross *cross = [self crossWithId:cross_id];
    if (cross != nil) {
        Class toJumpClass = NSClassFromString(@"WidgetConvViewController");
        EFTabBarViewController *tabBarViewController = [self _detailViewControllerWithCross:cross];
        tabBarViewController.viewWillAppearHandler = ^{
            NSUInteger toJumpIndex = [tabBarViewController indexOfViewControllerForClass:toJumpClass];
            NSAssert(toJumpIndex != NSNotFound, @"应该必须可找到");
            
            [tabBarViewController.tabBar setSelectedIndex:toJumpIndex];
        };
        
        [self.navigationController pushViewController:tabBarViewController animated:YES];
    }
}

#pragma mark - Private

- (EFTabBarViewController *)_detailViewControllerWithCross:(Cross *)cross {
    // CrossGroupViewController
    CrossGroupViewController *crossGroupViewController = [[CrossGroupViewController alloc] initWithNibName:@"CrossGroupViewController" bundle:nil];
    crossGroupViewController.cross = cross;
    
    EFTabBarItem *tabBarItem1 = [EFTabBarItem tabBarItemWithImage:[UIImage imageNamed:@"widget_x_30.png"]];
    tabBarItem1.highlightImage = [UIImage imageNamed:@"widget_x_30shine.png"];
    
    crossGroupViewController.customTabBarItem = tabBarItem1;
    crossGroupViewController.tabBarStyle = kEFTabBarStyleDoubleHeight;
    crossGroupViewController.shadowImage = [UIImage imageNamed:@"tabshadow_x.png"];
    
    // ConvViewController
    WidgetConvViewController *conversationViewController =  [[WidgetConvViewController alloc] initWithNibName:@"WidgetConvViewController" bundle:nil] ;
    // prepare data for conversation
    conversationViewController.exfee_id = [cross.exfee.exfee_id intValue];
    Invitation* myInvitation = [cross.exfee getMyInvitation];
    if (myInvitation != nil) {
        conversationViewController.myIdentity = myInvitation.identity;
    }
    
    NSUInteger conversationCount = [cross.conversation_count unsignedIntegerValue];
    
    EFTabBarItem *tabBarItem2 = [EFTabBarItem tabBarItemWithImage:[UIImage imageNamed:@"widget_conv_30.png"]];
    tabBarItem2.highlightImage = [UIImage imageNamed:@"widget_conv_30shine.png"];
    tabBarItem2.titleEnable = YES;
    tabBarItem2.title = conversationCount > 0 ? [NSString stringWithFormat:@"%u", conversationCount] : nil;
    
    conversationViewController.customTabBarItem = tabBarItem2;
    conversationViewController.tabBarStyle = kEFTabBarStyleNormal;
    conversationViewController.shadowImage = [UIImage imageNamed:@"tabshadow_conv.png"];
    
    // ExfeeViewController
    WidgetExfeeViewController *exfeeViewController = [[WidgetExfeeViewController alloc] initWithNibName:@"WidgetExfeeViewController" bundle:nil];
    exfeeViewController.exfee = cross.exfee;
    exfeeViewController.onExitBlock = ^{
        [crossGroupViewController performSelector:@selector(fillExfee:)
                                       withObject:exfeeViewController.exfee];
    };
    
    EFTabBarItem *tabBarItem3 = [EFTabBarItem tabBarItemWithImage:[UIImage imageNamed:@"widget_exfee_30.png"]];
    tabBarItem3.highlightImage = [UIImage imageNamed:@"widget_exfee_30shine.png"];
    
    exfeeViewController.customTabBarItem = tabBarItem3;
    exfeeViewController.tabBarStyle = kEFTabBarStyleNormal;
    exfeeViewController.shadowImage = [UIImage imageNamed:@"tabshadow_x.png"];
    
    // Init TabBarViewController
    EFTabBarViewController *tabBarViewController = [[[EFTabBarViewController alloc] initWithViewControllers:@[crossGroupViewController, conversationViewController, exfeeViewController]] autorelease];
    
    [crossGroupViewController release];
    [conversationViewController release];
    [exfeeViewController release];
    
    tabBarViewController.titlePressedHandler = ^{
        if (crossGroupViewController == tabBarViewController.selectedViewController) {
            NSInteger arg = 0x0101;
            [crossGroupViewController showPopup:arg];
        }
    };
    
    tabBarViewController.backButtonActionHandler = ^{
        RKObjectManager* manager = [RKObjectManager sharedManager];
        [manager.operationQueue cancelAllOperations];
        [self.navigationController popToRootViewControllerAnimated:YES];
    };
    
    tabBarViewController.title = cross.title;
    
    // Fetch background image
    BOOL flag = NO;
    for(NSDictionary *widget in cross.widget) {
        if([[widget objectForKey:@"type"] isEqualToString:@"Background"]) {
            NSString* url = [widget objectForKey:@"image"];
            
            if (url && url.length > 0) {
                NSString *imgurl = [Util getBackgroundLink:[widget objectForKey:@"image"]];
                
                if (!imgurl) {
                    tabBarViewController.tabBar.backgroundImage = [UIImage imageNamed:@"x_titlebg_default.jpg"];
                } else {
                    if ([[EFDataManager imageManager] isImageCachedInMemoryForKey:imgurl]) {
                        tabBarViewController.tabBar.backgroundImage = [[EFDataManager imageManager] cachedImageInMemoryForKey:imgurl];
                    } else {
                        tabBarViewController.tabBar.backgroundImage = [UIImage imageNamed:@"x_titlebg_default.jpg"];
                        [[EFDataManager imageManager] cachedImageForKey:imgurl
                                                        completeHandler:^(UIImage *image){
                                                            if (image) {
                                                                tabBarViewController.tabBar.backgroundImage = image;
                                                            }
                                                        }];
                    }
                }
                
                flag = YES;
                break;
            }
        }
    }
    if (flag == NO) {
        // Missing Background widget
        tabBarViewController.tabBar.backgroundImage = [UIImage imageNamed:@"x_titlebg_default.jpg"];
    }
    
    return tabBarViewController;
}

@end
