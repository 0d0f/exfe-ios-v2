//
//  AppDelegate.m
//  EXFE
//
//  Created by ju huo on 5/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"

#import <RestKit/RestKit.h>
#import <objc/runtime.h>
#import <BlocksKit/BlocksKit.h>
#import <FacebookSDK/FacebookSDK.h>


#import "Flurry.h"

#import "EFEntity.h"
#import "EFKit.h"
#import "EFModel.h"
#import "EFAPI.h"
#import "Util.h"
#import "UIApplication+EXFE.h"

#import "CrossesViewController.h"
#import "EFLandingViewController.h"
#import "XQueryComponents.h"

@interface AppDelegate ()
@property (nonatomic, copy) NSURL *url;
@end

@implementation AppDelegate
@synthesize window = _window;
@synthesize navigationController=_navigationController;

- (void)registerWeixin {
    [WXApi registerApp:kWeixinAppID];
}

- (void)handleLocationNotificaiton:(UILocalNotification *)localNotificaiton {
    NSString *key = [localNotificaiton.userInfo valueForKey:@"key"];
    if ([key isEqualToString:@"backgroudLocationUpdate"]) {
        [[EFLocationManager defaultManager] handleNotificaiton:localNotificaiton];
    }
}

#pragma mark UIApplicationDelegate
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Setup Flurry
    [Flurry setAppVersion:[UIApplication appVersion]];
    [Flurry startSession:kFlurryKey];
#ifdef DEBUG
    [Flurry logEvent:@"START_DEBUG_VERSION"];
#else
    [Flurry logEvent:@"START_ONLINE_VERSION"];
#endif
    
    // Setup RKLog
    RKLogSetAppLoggingLevel(RKLogLevelDefault);
#ifdef DEBUG
    RKLogConfigureByName("RestKit/Network", RKLogLevelTrace);
    //    RKLogConfigureByName("RestKit/ObjectMapping", RKLogLevelDebug);
    RKLogConfigureByName("RestKit/CoreData", RKLogLevelOff);
    //    RKLogConfigureByName("RestKit/CoreData/Cache", RKLogLevelTrace);
#else
    RKLogConfigureByName("RestKit", RKLogLevelDefault);
#endif
    
    RKLogInfo(@"API ROOT: %@", [EFConfig sharedInstance].API_ROOT);
    
    [self registerWeixin];
    
    NSUserDefaults *    userDefaults;
    
    // Clean some on-distk garbage.
    [EXFEModel applicationStartup];
    
    // Monitor network usage
    // [[NetworkManager sharedManager] addObserver:self forKeyPath:@"networkInUse" options:NSKeyValueObservingOptionInitial context:NULL];
    
    // If the "applicationClearSetup" user default is set, clear our preferences.
    // This provides an easy way to get back to the initial state while debugging.
    userDefaults = [NSUserDefaults standardUserDefaults];
    if ( [userDefaults boolForKey:@"applicationClearSetup"] ) {
        [userDefaults removeObjectForKey:@"applicationClearSetup"];
        // remove other keys
        [userDefaults removeObjectForKey:@"userid"];
    }
    
    NSInteger user_id = 0;
    user_id = [[userDefaults stringForKey:@"userid"] integerValue];
    [self switchContextByUserId:user_id withAbandon:NO];
    if (user_id > 0) {
        if (self.model.isLoggedIn) {
            NSString *token = [[NSUserDefaults standardUserDefaults] valueForKey:@"udid"];
            if (token.length > 0) {
                [self.model.apiServer regDevice:token success:nil failure:nil];
            }
        }
    }
    
    //    [[NSNotificationCenter defaultCenter] addObserver:self
    //                                             selector:@selector(observeContextSave:)
    //                                                 name:NSManagedObjectContextDidSaveNotification
    //                                               object:nil];

    
    // Setup AFNetwork
    [AFNetworkActivityIndicatorManager sharedManager].enabled = YES;
    
    
    // Setup APN Push
    [self requestForPush];
    
    NSDictionary *userinfo = [launchOptions valueForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
    
    // Setup root UIViewController
    CrossesViewController *crossviewController = [[CrossesViewController alloc] initWithStyle:UITableViewStylePlain];
    crossviewController.needHeaderAnimation = userinfo ? NO : YES;
    self.navigationController = [[UINavigationController alloc] initWithRootViewController:crossviewController];
    self.crossesViewController = crossviewController;
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.rootViewController = self.navigationController;
    CGRect appFrame = [UIScreen mainScreen].applicationFrame;
    self.window.frame = appFrame;
//    [self.window addSubview:self.navigationController.view];
    [self.window makeKeyAndVisible];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque animated:NO];
    
    // Handle Remote notification
    if (userinfo) {
        [self receivePushData:userinfo isOnForeground:NO];
    }

    
    // Version info
#ifdef DEBUG
    CGRect windowBounds = [UIScreen mainScreen].bounds;
    CGFloat width = 100.0f;
    
    UIWindow *versionWindow = [[UIWindow alloc] initWithFrame:(CGRect){{(CGRectGetWidth(windowBounds) - width) * 0.5f, 0.0f}, width, 12.0f}];
    versionWindow.layer.cornerRadius = 2.0f;
    versionWindow.layer.shouldRasterize = YES;
    versionWindow.layer.rasterizationScale = [UIScreen mainScreen].scale;
    versionWindow.layer.contentsScale = [UIScreen mainScreen].scale;
    versionWindow.layer.masksToBounds = YES;
    
    versionWindow.windowLevel = UIWindowLevelStatusBar;
    versionWindow.alpha = 0.9f;
    UIColor *backgroundColor = [UIColor COLOR_BLUE_EXFE];
    NSString *serverName = @"EXFE";
    NSString *version = [[[NSBundle mainBundle] infoDictionary] valueForKey:@"EXFE-build"];
    
    #ifdef PILOT
        backgroundColor = [UIColor purpleColor];
        serverName = @"Panda";
    #elif DEV
        backgroundColor = [UIColor purpleColor];
        serverName = @"Black";
    #endif
    
    versionWindow.backgroundColor = backgroundColor;
    
    UILabel *label = [[UILabel alloc] initWithFrame:versionWindow.bounds];
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor lightTextColor];
    label.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:10];
    label.textAlignment = NSTextAlignmentCenter;
    label.text = [NSString stringWithFormat:@"%@ @ %@", version, serverName];
    [versionWindow addSubview:label];
    
    [versionWindow makeKeyAndVisible];
    
    [self.window makeKeyAndVisible];
#endif
    
    EFAPIServer *server = self.model.apiServer;
    // Load User
    if (self.model.isLoggedIn == YES){
        [self.model loadMe];
    }
    // Load Background List
    [server getAvailableBackgroundsWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ([operation.response statusCode] == 200 && [responseObject isKindOfClass:[NSDictionary class]]) {
            NSDictionary *body = responseObject;
            if ([body isKindOfClass:[NSDictionary class]]) {
                id code = [[body objectForKey:@"meta"] objectForKey:@"code"];
                if(code && 200 == [code intValue]) {
                    NSArray *backgrounds = [[body objectForKey:@"response"] objectForKey:@"backgrounds"];
                    [[NSUserDefaults standardUserDefaults] setObject:backgrounds forKey:@"cross_default_backgrounds"];
                }
            }
        }
    }
                                       failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                       }];
    
    if (![[EFLocationManager defaultManager] isFirstTimeToPostUserLocation] &&
        [[EFLocationManager defaultManager] canPostUserLocationInBackground]) {
        [[EFLocationManager defaultManager] startUpdatingLocation];
        [[EFLocationManager defaultManager] startUpdatingHeading];
    }
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    
    if (self.model.apiServer && self.model.userId > 0) {
        [self.model loadCrossListAfter:self.model.latestModify];
    }
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [FBAppCall handleDidBecomeActiveWithSession:[FBSession activeSession]];
    [Util checkUpdate];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    [[FBSession activeSession] close];
}

- (void)application:(UIApplication *)application didChangeStatusBarFrame:(CGRect)oldStatusBarFrame
{
    CGRect appFrame = [UIScreen mainScreen].applicationFrame;
    self.window.rootViewController.view.frame = appFrame;
}

#pragma mark - WXApiDelegate

/*! @brief 收到一个来自微信的请求，处理完后调用sendResp
 *
 * 收到一个来自微信的请求，异步处理完成后必须调用sendResp发送处理结果给微信。
 * 可能收到的请求有GetMessageFromWXReq、ShowMessageFromWXReq等。
 * @param req 具体请求内容，是自动释放的
 */
- (void)onReq:(BaseReq*)req {
}

/*! @brief 发送一个sendReq后，收到微信的回应
 *
 * 收到一个来自微信的处理结果。调用一次sendReq后会收到onResp。
 * 可能收到的处理结果有SendMessageToWXResp、SendAuthResp等。
 * @param resp具体的回应内容，是自动释放的
 */
- (void)onResp:(BaseResp*)resp {
    
}

#pragma mark - Loation Notification

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
    [self handleLocationNotificaiton:notification];
}

#pragma mark - Push Notification
// request for APN
- (void)requestForPush
{
    if ([self.model isLoggedIn] == YES) {
        NSString* ifdevicetokenSave = [[NSUserDefaults standardUserDefaults] stringForKey:@"ifdevicetokenSave"];
        if( ifdevicetokenSave == nil)
        {
            [[UIApplication sharedApplication] registerForRemoteNotificationTypes: UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeBadge ];
        }
    }
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    NSString * tokenAsString = [[[deviceToken description]
                                 stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]]
                                stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    NSString * savedToken = [[NSUserDefaults standardUserDefaults] objectForKey:@"push_token"];
    if (savedToken == nil || ![savedToken isEqualToString:tokenAsString]){
        [[NSUserDefaults standardUserDefaults] setValue:tokenAsString forKey:@"push_token"];
    }
    
    NSString *savedUdid = [[NSUserDefaults standardUserDefaults] valueForKey:@"udid"];
    if (savedUdid == nil || ![savedUdid isEqualToString:tokenAsString]) {
        [[NSUserDefaults standardUserDefaults] setValue:tokenAsString forKey:@"udid"];
    }
    
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    if (self.model.userId > 0 && self.model.isLoggedIn) {
        [self.model.apiServer regDevice:tokenAsString success:nil failure:nil];
    }
}

- (void)application:(UIApplication *)app didFailToRegisterForRemoteNotificationsWithError:(NSError *)err {
    RKLogError(@"Error in registration. Error: %@", err);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    [Flurry logEvent:@"RECEIVE_REMOTE_NOTIFICATION"];
    
    BOOL isForeground = YES;
    if (UIApplicationStateActive != application.applicationState) {
        isForeground = NO;
    }
    
    [self receivePushData:userInfo isOnForeground:isForeground];
}

- (void)receivePushData:(NSDictionary *)userInfo isOnForeground:(BOOL)isForeground {
    
    if (isForeground == NO) {
        if (userInfo != nil) {
            id arg = [userInfo valueForKeyPath:@"args"];
            if(arg && [arg isKindOfClass:[NSDictionary class]]) {
                RKLogInfo(@"receive old push");
            } else  {
                NSURL *url = nil;
                NSString * u = [userInfo valueForKeyPath:@"url"];
                if (u && [u isKindOfClass:[NSString class]]) {
                    RKLogDebug(@"receive url: %@", u);
                    // some filter for safety?
                    url = [NSURL URLWithString:u];
                } else {
                    NSString * path = [userInfo valueForKeyPath:@"path"];
                    if (path && [path isKindOfClass:[NSString class]]) {
                        RKLogDebug(@"receive path: %@", path);
                        if (path.length > 0) {
                            url = [[NSURL alloc] initWithScheme:[UIApplication sharedApplication].defaultScheme host:[EFConfig sharedInstance].scope path:path];
                        } else {
                            url = [[NSURL alloc] initWithScheme:[UIApplication sharedApplication].defaultScheme host:[EFConfig sharedInstance].scope path:@"/"];
                        }
                        RKLogDebug(@"combined url %@", url);
                    }
                }
                
                if (url) {
                    NSString *scope = [[[url.host componentsSeparatedByString:@"."] lastObject] uppercaseString];
                    if ([[EFConfig sharedInstance] sameServerScope:scope]) {
                        [self jumpTo:url];
                    } else {
                        RKLogWarning(@"Not same server");
                    }
                } else {
                    RKLogWarning(@"Invalid url or path field");
                }
            }
        }
    } else {
        [self.model loadCrossList];
    }
}

#pragma mark -

- (void)showLanding:(UIViewController*)parent {
    EFLandingViewController *viewController = [[EFLandingViewController alloc] initWithNibName:@"EFLandingViewController" bundle:nil];
    [parent presentViewController:viewController animated:NO completion:nil];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    // Facebook
    BOOL fb = [FBAppCall handleOpenURL:url
                  sourceApplication:sourceApplication
                        withSession:[FBSession activeSession]];
    
    if (fb) {
        return YES;
    }
    
    // Weixin
    BOOL wx = [WXApi handleOpenURL:url delegate:self];
    
    if (wx) {
        return YES;
    }
    
    [Flurry logEvent:@"HANDLE_OPEN_URL"];
    
    NSString *schema __attribute__((unused)) = url.scheme;
    NSString *host = url.host;
    NSString *scope = [[[host componentsSeparatedByString:@"."] lastObject] uppercaseString];
    NSString *query __attribute__((unused)) = [url query];
    NSDictionary *params = [url queryComponents];
    NSString *token = [[params objectForKey:@"token"] lastObject];
    NSString *user_id = [[params objectForKey:@"user_id"] lastObject];
    NSString *username = [[params objectForKey:@"username"] lastObject];
    if (!username) {
        username = @"";
    }
    NSString *identity_id __attribute__((unused)) = [[params objectForKey:@"identity_id"] lastObject];
    
    self.url = url;
    
    if (token.length > 0 && [user_id integerValue] > 0){
        

        if (![self.model isLoggedIn]) {
            RKLogInfo(@"Sign In by url");
            if (![[EFConfig sharedInstance] sameServerScope:scope]) {
                [[EFConfig sharedInstance] saveScope:scope];
            }
            
            // TODO check token is valid: query for profile with the time in future; HTTP 200 with API 304 is valid.
            [self switchContextByUserId:[user_id integerValue] withAbandon:NO];
            self.model.userToken = token;
            [self.model saveUserData];
            
            [self.model loadMe];
            
            [self signinDidFinish];
            [self jumpTo:url];
        } else {
            if (![[EFConfig sharedInstance] sameServerScope:scope]) {
                // TODO
                // [[EFConfig sharedInstance] saveScope:scope];
                // 1 sign out
                // 2 login
                RKLogWarning(@"Not same server.");
                
                [Util handleDefaultBannerTitle:NSLocalizedString(@"Failed to merge accounts.", nil) andMessage:NSLocalizedString(@"Authentication token expired.", nil)];
                
            }else {
                NSUInteger uid = [user_id integerValue];
                if (uid == self.model.userId) {
                    RKLogInfo(@"Jump in by url");
                    // refresh token
                    // self.model.userToken = token; // We want the token maps to a single client.
                    // [self.model saveUserData];
                    [self jumpTo:url];
                } else {
                    // merge identities
                    RKLogDebug(@"Merge (%@/%u) to %u by url", username, uid, self.model.userId);
                    [UIAlertView showAlertViewWithTitle:NSLocalizedString(@"Merge accounts", nil)
                                                message:[NSString stringWithFormat:NSLocalizedString(@"Merge account %@ into your current signed-in account?", nil), username]
                                      cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
                                      otherButtonTitles:@[NSLocalizedString(@"Merge", nil)]
                                                handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
                                                    if (buttonIndex == alertView.firstOtherButtonIndex ) {
                                                        RKLogInfo(@"Start merge");
                                                        [self.model.apiServer mergeAllByToken:token
                                                                        success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                                                            if ([responseObject isKindOfClass:[NSDictionary class]]) {
                                                                                NSDictionary *body = responseObject;
                                                                                Meta * meta = [body valueForKey:@"meta"];
                                                                                NSInteger c = [[meta valueForKey:@"code"] integerValue];
                                                                                NSInteger t = c / 100;
                                                                                switch (t) {
                                                                                    case 2:
                                                                                        RKLogInfo(@"finish merge. Jump!");
                                                                                        [self jumpTo:url];
                                                                                        
                                                                                        if ([url.path hasPrefix:@"/!"]) {
                                                                                            [self performBlock:^(id sender) {
                                                                                                [self.model loadMe];
                                                                                            } afterDelay:3];
                                                                                        } else {
                                                                                            [self.model loadMe];
                                                                                        }
                                                                                        break;
                                                                                        
                                                                                    default:
                                                                                        // 400: error_browsing_identity_token
                                                                                        // 400: error_invitation_token
                                                                                        // 400: no_identity_ids
                                                                                        // 400: error_user_status
                                                                                        // 401: no_signin
                                                                                        // 500: server_error
                                                                                        
                                                                                        // [self jumpTo:url];
                                                                                        RKLogError(@"Merge fail for %i %@. NO Jump!", c, [meta valueForKey:@"errorType"]);
                                                                                        [Util handleDefaultBannerTitle:NSLocalizedString(@"Failed to merge accounts.", nil) andMessage:NSLocalizedString(@"Authentication token expired.", nil)];
                                                                                        break;
                                                                                }
                                                                            }
                                                                        }
                                                                        failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                                            RKLogError(@"Merge fail for error %@. NO Jump!", error);
                                                                            // [self jumpTo:url];
                                                                            // HTTP 500 NSURLErrorBadServerResponse AFNetworkingErrorDomain
                                                                            // HTTP 4xx
                                                                            [Util handleDefaultBannerTitle:NSLocalizedString(@"Failed to merge accounts.", nil) andMessage:NSLocalizedString(@"Failed to connect to server.", nil)];
                                                                        }];
                                                    } else {
                                                        RKLogInfo(@"Not merge. Jump!");
                                                        [self jumpTo:url];
                                                    }
                                                }];
                }
            }
        }
    }else{
        [self jumpTo:url];
    }
    return YES;
}

- (void)jumpTo:(NSURL *)url
{
    RKLogDebug(@"Jump to: %@", url.path);
    
    NSString *host = url.host;
    NSString *scope = [[host componentsSeparatedByString:@"."] lastObject];
    
    if (![self.model isLoggedIn]) {
        RKLogInfo(@"Not Logged In. Ignore");
        return;
    }
    if (![[EFConfig sharedInstance] sameServerScope:scope]) {
        RKLogInfo(@"Logged in with another server. Ignore");
        return;
    }
    
    NSArray *pathComps = [url pathComponents];
    NSDictionary * params = [url queryComponents];
    NSArray *anim = [params objectForKey:@"animated"];
    BOOL animated = NO;
    if (anim) {
        animated = [[anim objectAtIndex:0] boolValue];
    }

    if (pathComps.count > 0 ) {
        NSString *root = [pathComps objectAtIndex:0];
        if ([@"/" isEqualToString:root]) {
            NSMutableArray *array = [NSMutableArray arrayWithArray:pathComps];
            [array removeObjectAtIndex:0];
            if ([self.crossesViewController pushTo:array animated:animated]){
                return;
            } else {
                if (self.navigationController.viewControllers.count > 1 && self.model.isLoggedIn) {
                    [self.navigationController popToRootViewControllerAnimated:animated];
                }
                return;
            }
        }
    }
    // default keep current
    return;
}


- (void)signinDidFinish {
    if ([self.model isLoggedIn]) {
        [self requestForPush];
        
        NSString *token = [[NSUserDefaults standardUserDefaults] valueForKey:@"udid"];
        if (token.length > 0) {
            [self.model.apiServer regDevice:token success:nil failure:nil];
        }
        
        [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
        self.navigationController.navigationBar.frame = CGRectOffset(self.navigationController.navigationBar.frame, 0.0, -20.0);
        
//        [self.model loadCrossList];
        
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)signoutDidFinish {
    [Flurry logEvent:@"ACTION_DID_SIGN_OUT"];
    
    [[EFLocationManager defaultManager] stopUpdatingHeading];
    [[EFLocationManager defaultManager] stopUpdatingLocation];
    
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [ud removeObjectForKey:@"devicetoken"];
    [ud removeObjectForKey:@"exfee_updated_at"];
    [ud removeObjectForKey:@"ifdevicetokenSave"];
    [ud removeObjectForKey:@"localaddressbook_read_at"];
    [ud removeObjectForKey:@"udid"];
    [ud removeObjectForKey:@"push_token"];
    [ud removeObjectForKey:EFKeyBackgroundUpdatingLocationEnabled];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self switchContextByUserId:0 withAbandon:YES];
    
    [NSNotificationCenter.defaultCenter postNotificationName:EXCrossListDidChangeNotification object:self];
    
    [self.navigationController popToRootViewControllerAnimated:YES];
    
    EFLandingViewController *viewController = [[EFLandingViewController alloc] initWithNibName:@"EFLandingViewController" bundle:nil];
    [self.navigationController presentViewController:viewController animated:NO completion:nil];
}

- (void)switchContextByUserId:(NSUInteger)user_id withAbandon:(BOOL)flag
{
    if (self.model == nil || self.model.userId != user_id) {
        [self.model stop];
        if (flag && self.model.userId > 0) {
            [self.model abandonCachePath];
            [self.model clearUserData];
        }
        EXFEModel * model = [[EXFEModel alloc] initWithUser:user_id];
        self.model = model;
        [self.model start];
    } else if (self.model != nil && self.model.userId == 0 && self.model.userId == user_id){
        [self.model stop];
        if (flag) {
            [self.model abandonCachePath];
            [self.model clearUserData];
        }
        EXFEModel * model = [[EXFEModel alloc] initWithUser:user_id];
        self.model = model;
        [self.model start];
    }
}

//- (void) observeContextSave:(NSNotification*) notification {
//    RKManagedObjectStore *objectStore = [[RKObjectManager sharedManager] objectStore];
//    [[objectStore managedObjectContextForCurrentThread] mergeChangesFromContextDidSaveNotification:notification];
//}


@end
