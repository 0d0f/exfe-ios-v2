//
//  AppDelegate.m
//  EXFE
//
//  Created by ju huo on 5/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"
#import <BlocksKit/BlocksKit.h>
#import <FacebookSDK/FacebookSDK.h>
#import "UIApplication+EXFE.h"
#import "EXFEModel.h"
#import "CrossesViewController.h"
#import "EFAPIServer.h"
#import "EFLandingViewController.h"
#import "Util.h"
#import "EFKit.h"
#import "EFModel.h"

@interface AppDelegate ()
@property (nonatomic, copy) NSURL *url;
@end

@implementation AppDelegate
@synthesize window = _window;
@synthesize navigationController=_navigationController;


- (NSString *)defaultScheme
{
    NSArray * schemes = [[[NSBundle mainBundle] infoDictionary] valueForKeyPath:@"CFBundleURLTypes.@distinctUnionOfArrays.CFBundleURLSchemes"];
    NSAssert([schemes objectAtIndex:1] != nil, @"Missing url sheme in main bundle.");
    
    return [schemes objectAtIndex:1];
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
#ifdef DEBUG
    RKLogConfigureByName("RestKit/Network", RKLogLevelTrace);
    //    RKLogConfigureByName("RestKit/ObjectMapping", RKLogLevelDebug);
    RKLogConfigureByName("RestKit/CoreData", RKLogLevelOff);
    //    RKLogConfigureByName("RestKit/CoreData/Cache", RKLogLevelTrace);
#else
    RKLogConfigureByName("*", RKLogLevelOff);
#endif
    
#ifdef DEBUG
    NSLog(@"API ROOT: %@", API_ROOT);
#endif
    
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
        [self.crossesViewController refreshCrosses:@"crossupdateview"];
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
    
    if([[NSUserDefaults standardUserDefaults] objectForKey:@"udid"]!=nil &&  [[[NSUserDefaults standardUserDefaults] objectForKey:@"udid"] isEqualToString:tokenAsString])
        return;
    
    if (self.model.userId > 0 && self.model.isLoggedIn) {
        [self.model.apiServer regDevice:tokenAsString success:nil failure:nil];
    }
}

- (void)application:(UIApplication *)app didFailToRegisterForRemoteNotificationsWithError:(NSError *)err {
    //    NSLog(@"Error in registration. Error: %@", err);
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
        CrossesViewController *crossViewController = self.crossesViewController;
        
        if (userInfo != nil) {
            id arg = [userInfo objectForKey:@"args"];
            if([arg isKindOfClass:[NSDictionary class]]) {
                id cid = [arg objectForKey:@"cid"];
                id msg_type = [arg objectForKey:@"t"];
                
                if (cid != nil && [cid isKindOfClass:[NSNumber class]] && msg_type != nil && [msg_type isKindOfClass:[NSString class]]) {
                    if ([cid intValue] > 0 ) {
                        int cross_id = [cid intValue];
                        NSString *type = (NSString *)msg_type;
                        if ([type isEqualToString:@"i"]) {
                            if ([crossViewController pushToCross:cross_id] == NO) {
                                [crossViewController refreshCrosses:@"pushtocross" withCrossId:cross_id];
                            }
                        }
                        
                        if ([type isEqualToString:@"c"]) {
                            if ([crossViewController pushToConversation:cross_id] == NO) {
                                [crossViewController refreshCrosses:@"pushtoconversation" withCrossId:cross_id];
                            }
                        }
                    }
                }
            }
        }
    } else {
        CrossesViewController *crossViewController = self.crossesViewController;
        [crossViewController refreshCrosses:@"crossupdateview"];
    }
}

#pragma mark -

- (void)showLanding:(UIViewController*)parent {
    EFLandingViewController *viewController = [[EFLandingViewController alloc] initWithNibName:@"EFLandingViewController" bundle:nil];
    [parent presentModalViewController:viewController animated:NO];
}

- (void)signinDidFinish {
    if ([self.model isLoggedIn]) {
        [self requestForPush];
        
        [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
        self.navigationController.navigationBar.frame = CGRectOffset(self.navigationController.navigationBar.frame, 0.0, -20.0);
        
        CrossesViewController *crossViewController = self.crossesViewController;
        [crossViewController refreshCrosses:@"crossview_init"];
        [crossViewController loadObjectsFromDataStore];
        
        [self.navigationController dismissModalViewControllerAnimated:YES];
    }
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
//    NSLog(@"application:openURL:sourceApplication:annotation: called");
    
    BOOL fb = [FBAppCall handleOpenURL:url
                  sourceApplication:sourceApplication
                        withSession:[FBSession activeSession]];
    
    if (fb) {
        return YES;
    }
    
    [Flurry logEvent:@"HANDLE_OPEN_URL"];
    
    NSString *query = [url query];
    NSDictionary *params = [Util splitQuery:query];
    NSString *token = [params objectForKey:@"token"];
    NSString *user_id = [params objectForKey:@"user_id"];
    //NSString *identity_id = [params objectForKey:@"identity_id"];
    
    self.url = url;
    
    if (token.length > 0 && [user_id intValue] > 0){
        EFAPIServer *server = self.model.apiServer;
        if (![server isLoggedIn]) {
            // sign in
            
            [self switchContextByUserId:[user_id integerValue] withAbandon:NO];
            self.model.userToken = token;
            [self.model saveUserData];
            
            [self.model loadMe];
            
            [self signinDidFinish];
            [self processUrlHandler:url];
        } else {
            if ([user_id integerValue] == self.model.userId) {
                // refresh token
                self.model.userToken = token;
                [self.model saveUserData];
                [self processUrlHandler:url];
            } else {
                // merge identities
                
                // Load identities to merge from another user
                [server loadUserBy:[user_id integerValue]
                             withToken:token
                               success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                   NSDictionary *body = responseObject;
                                   if([body isKindOfClass:[NSDictionary class]]) {
                                       NSNumber *code = [responseObject valueForKeyPath:@"meta.code"];
                                       if(code){
                                           if([code integerValue] == 200) {
                                               NSString *name = [responseObject valueForKeyPath:@"response.user.name"];
                                               NSArray *ids = [responseObject valueForKeyPath:@"response.user.identities.@distinctUnionOfObjects.id"];
                                               
                                               [UIAlertView showAlertViewWithTitle:@"Merge accounts"
                                                                           message:[NSString stringWithFormat:@"Merge account %@ into your current signed-in account?", name]
                                                                 cancelButtonTitle:@"Cancel"
                                                                 otherButtonTitles:@[@"Merge"]
                                                                           handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
                                                                               if (buttonIndex == alertView.firstOtherButtonIndex ) {
                                                                                   
                                                                                   [server mergeIdentities:ids byToken:token success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                                                                       if ([operation.response statusCode] == 200 && [responseObject isKindOfClass:[NSDictionary class]]){
                                                                                           NSDictionary *body=responseObject;
                                                                                           if ([body isKindOfClass:[NSDictionary class]]) {
                                                                                               id code = [[body objectForKey:@"meta"] objectForKey:@"code"];
                                                                                               if (code && [code intValue] == 200) {
                                                                                                   [self.model loadMe];
                                                                                                   
                                                                                                   [self processUrlHandler:url];
                                                                                               }
                                                                                           }
                                                                                       }
                                                                                   } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                                                       
                                                                                   }];
                                                                               }
                                                                           }];
                                           }
                                       }
                                   }
                                   
                               }
                               failure:nil];
            }
        }
        
    }else{
        [self processUrlHandler:url];
    }
    
    
    return YES;
}

- (void)processUrlHandler:(NSURL*)url {
    
    NSString *host = [url host];
    NSArray *pathComps = [url pathComponents];
    CrossesViewController *crossViewController = self.crossesViewController;
    
    
    if ([host isEqualToString:@"crosses"]) {
        if (self.navigationController.viewControllers.count > 1) {
            [self.navigationController popToRootViewControllerAnimated:NO];
        }
        
        if (pathComps.count  == 2) {
            int cross_id = [[pathComps objectAtIndex:1] intValue];
            if ( cross_id > 0) {
                if ([self.model isLoggedIn]) {
                    if ([crossViewController pushToCross:cross_id] == NO) {
                        [crossViewController refreshCrosses:@"pushtocross" withCrossId:cross_id];
                    }
                }
                return ;
            }
        }
    } else if ([host isEqualToString:@"conversation"]) {
        if (self.navigationController.viewControllers.count > 1) {
            [self.navigationController popToRootViewControllerAnimated:NO];
        }
        if (pathComps.count  == 2) {
            int cross_id = [[pathComps objectAtIndex:1] intValue];
            if (cross_id > 0){
                if ([self.model isLoggedIn]) {
                    if ([crossViewController pushToConversation:cross_id] == NO) {
                        [crossViewController refreshCrosses:@"pushtoconversation" withCrossId:cross_id];
                    }
                }
            }
        }
    } else if([host isEqualToString:@"profile"]) {
        if (self.navigationController.viewControllers.count > 1) {
            [self.navigationController popToRootViewControllerAnimated:NO];
        }
        if ([self.model isLoggedIn]) {
            [crossViewController ShowProfileView];
        }
    }
}

- (void)gatherCrossDidFinish {
    CrossesViewController *crossViewController = self.crossesViewController;
    [crossViewController refreshCrosses:@"gatherview"];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)crossUpdateDidFinish:(int)cross_id {
    CrossesViewController *crossViewController = self.crossesViewController;
    [crossViewController refreshCrosses:@"crossupdateview" withCrossId:cross_id];
}

- (void)signoutDidFinish {
    [Flurry logEvent:@"ACTION_DID_SIGN_OUT"];
    
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [ud removeObjectForKey:@"devicetoken"];
    [ud removeObjectForKey:@"exfee_updated_at"];
    [ud removeObjectForKey:@"ifdevicetokenSave"];
    [ud removeObjectForKey:@"localaddressbook_read_at"];
    [ud removeObjectForKey:@"udid"];
    [ud removeObjectForKey:@"push_token"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self switchContextByUserId:0 withAbandon:YES];
    
    CrossesViewController *rootViewController = self.crossesViewController;
    [rootViewController emptyView];
    
    [self.navigationController popToRootViewControllerAnimated:YES];
    
    EFLandingViewController *viewController = [[EFLandingViewController alloc] initWithNibName:@"EFLandingViewController" bundle:nil];
    [self.navigationController presentModalViewController:viewController animated:NO];
}

- (void)switchContextByUserId:(NSInteger)user_id withAbandon:(BOOL)flag
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
    }
}

//- (void) observeContextSave:(NSNotification*) notification {
//    RKManagedObjectStore *objectStore = [[RKObjectManager sharedManager] objectStore];
//    [[objectStore managedObjectContextForCurrentThread] mergeChangesFromContextDidSaveNotification:notification];
//}


@end
