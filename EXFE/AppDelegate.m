//
//  AppDelegate.m
//  EXFE
//
//  Created by ju huo on 5/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"
#import <BlocksKit/BlocksKit.h>
#import "UIApplication+EXFE.h"
#import "APICrosses.h"
#import "APIConversation.h"
#import "APIProfile.h"
#import "CrossesViewController.h"
#import "LandingViewController.h"
#import "EFAPIServer.h"
#import "EFLandingViewController.h"

@implementation AppDelegate
@synthesize window = _window;
@synthesize navigationController=_navigationController;

static char alertobject;
static char handleurlobject;
static char mergetoken;

- (void)dealloc
{
    [_window release];
    [_navigationController release];
    [super dealloc];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Setup Flurry
    [Flurry setAppVersion:[UIApplication appVersion]];
    [Flurry startSession:@"8R2R8KZG35DK6S6MDHGS"];
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
    
    
    
    //    [[NSNotificationCenter defaultCenter] addObserver:self
    //                                             selector:@selector(observeContextSave:)
    //                                                 name:NSManagedObjectContextDidSaveNotification
    //                                               object:nil];
    // Setup DB version data
    NSNumber* db_version=[[NSUserDefaults standardUserDefaults] objectForKey:@"db_version"];
    
    if(db_version==nil || [db_version intValue]<APP_DB_VERSION){
        
        [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"exfee_updated_at"];
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:APP_DB_VERSION] forKey:@"db_version"];
    }
    

    // Setup AFNetwork
    [AFNetworkActivityIndicatorManager sharedManager].enabled = YES;
    [self createdb];
    
    // Setup APN Push
    [self requestForPush];
    
    // Setup root UIViewController
    CrossesViewController *crossviewController = [[[CrossesViewController alloc] initWithNibName:@"CrossesViewController" bundle:nil] autorelease];
    self.navigationController = [[UINavigationController alloc] initWithRootViewController:crossviewController];
    
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    self.window.rootViewController = self.navigationController;
    [self.window addSubview:self.navigationController.view];
    [self.window makeKeyAndVisible];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque animated:NO];
    
    //    UILogSetWindow(self.window);
    
    EFAPIServer *server = [EFAPIServer sharedInstance];
    // Load User
    if ([server isLoggedIn] == YES){
        [server loadMeSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                       User *user = [User getDefaultUser];
                       NSParameterAssert(user != nil);
                   }
                   failure:^(RKObjectRequestOperation *operation, NSError *error) {
                   }];
    }
    
    // Load Background List
    [server getAvailableBackgroundsWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ([operation.response statusCode] == 200 && [responseObject isKindOfClass:[NSDictionary class]]){
            NSDictionary *body=responseObject;
            if([body isKindOfClass:[NSDictionary class]]) {
                id code=[[body objectForKey:@"meta"] objectForKey:@"code"];
                if(code)
                    if([code intValue]==200) {
                        NSArray *backgrounds=[[body objectForKey:@"response"] objectForKey:@"backgrounds"];
                        [[NSUserDefaults standardUserDefaults] setObject:backgrounds forKey:@"cross_default_backgrounds"];
                    }
            }
        }else {
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

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    if([EFAPIServer sharedInstance].user_id > 0){
        NSArray *viewControllers = self.navigationController.viewControllers;
        CrossesViewController *crossViewController = [viewControllers objectAtIndex:0];
        [crossViewController refreshCrosses:@"crossupdateview"];
    }
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    [Util checkUpdate];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

// request for APN
- (void)requestForPush
{
    if ([[EFAPIServer sharedInstance] isLoggedIn] == YES) {
        NSString* ifdevicetokenSave = [[NSUserDefaults standardUserDefaults] stringForKey:@"ifdevicetokenSave"];
        if( ifdevicetokenSave == nil)
        {
            [[UIApplication sharedApplication] registerForRemoteNotificationTypes: UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeBadge ];
        }
    }
}

- (void) createdb{
    [Flurry logEvent:@"CREATE_DB"];
    NSURL *baseURL = [NSURL URLWithString:API_ROOT];
    NSLog(@"API Server: %@", baseURL);
    
    RKObjectManager *objectManager = [RKObjectManager sharedManager];
    if(objectManager == nil){
        objectManager = [RKObjectManager managerWithBaseURL:baseURL];
        [RKObjectManager setSharedManager:objectManager];
    }
    
    NSManagedObjectModel *managedObjectModel = [NSManagedObjectModel mergedModelFromBundles:nil];
    RKManagedObjectStore *managedObjectStore = [[RKManagedObjectStore alloc] initWithManagedObjectModel:managedObjectModel];
    objectManager.managedObjectStore = managedObjectStore;
    
    [managedObjectStore createPersistentStoreCoordinator];
    
    NSString *storePath = [RKApplicationDataDirectory() stringByAppendingPathComponent:DBNAME];
    //  NSString *seedPath = [[NSBundle mainBundle] pathForResource:@"RKSeedDatabase" ofType:@"sqlite"];
    NSError *error;
    NSPersistentStore *persistentStore = [managedObjectStore addSQLitePersistentStoreAtPath:storePath fromSeedDatabaseAtPath:nil withConfiguration:nil options:nil error:&error];
    NSAssert(persistentStore, @"Failed to add persistent store with error: %@", error);
    
    // Create the managed object contexts
    [managedObjectStore createManagedObjectContexts];
    
    // Configure a managed object cache to ensure we do not create duplicate objects
    managedObjectStore.managedObjectCache = [[[RKInMemoryManagedObjectCache alloc] initWithManagedObjectContext:managedObjectStore.persistentStoreManagedObjectContext] autorelease];
    NSArray *descriptors=objectManager.requestDescriptors;
    if(descriptors==nil || [descriptors count]==0)
        [ModelMapping buildMapping];
    
}

-(void)ShowLanding:(UIViewController*)parent{
    
    EFLandingViewController *viewController = [[[EFLandingViewController alloc] initWithNibName:@"EFLandingViewController" bundle:nil] autorelease];
    [parent presentModalViewController:viewController animated:NO];
}

-(void)SigninDidFinish{
    if([[EFAPIServer sharedInstance] isLoggedIn] == YES)
    {
        [self requestForPush];
        
        [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
        self.navigationController.navigationBar.frame = CGRectOffset(self.navigationController.navigationBar.frame, 0.0, -20.0);
        
        NSArray *viewControllers = self.navigationController.viewControllers;
        CrossesViewController *crossViewController = [viewControllers objectAtIndex:0];
        [crossViewController refreshCrosses:@"crossview_init"];
        [crossViewController loadObjectsFromDataStore];
        [crossViewController dismissModalViewControllerAnimated:YES];
        
        
    }
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    
    NSString * tokenAsString = [[[deviceToken description]
                                 stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]]
                                stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    if([[NSUserDefaults standardUserDefaults] objectForKey:@"udid"]!=nil &&  [[[NSUserDefaults standardUserDefaults] objectForKey:@"udid"] isEqualToString:tokenAsString])
        return;
    
    NSString *endpoint = [NSString stringWithFormat:@"%@users/%u/regdevice?token=%@",API_ROOT,[EFAPIServer sharedInstance].user_id,[EFAPIServer sharedInstance].user_token];
    RKObjectManager *manager=[RKObjectManager sharedManager] ;
    manager.HTTPClient.parameterEncoding=AFFormURLParameterEncoding;
    [manager.HTTPClient postPath:endpoint parameters:@{@"udid":tokenAsString,@"push_token":tokenAsString,@"os_name":@"iOS",@"brand":@"apple",@"model":@"",@"os_version":@"6"} success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ([operation.response statusCode] == 200 && [responseObject isKindOfClass:[NSDictionary class]]){
            NSDictionary *body=responseObject;
            if([body isKindOfClass:[NSDictionary class]]) {
                id code=[[body objectForKey:@"meta"] objectForKey:@"code"];
                if(code)
                    if([code intValue]==200) {
                        [[NSUserDefaults standardUserDefaults] setObject:@"YES" forKey:@"ifdevicetokenSave"];
                        [[NSUserDefaults standardUserDefaults] setObject:tokenAsString forKey:@"udid"];
                    }
            }
        }else {
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
    }];
    
}

- (void)application:(UIApplication *)app didFailToRegisterForRemoteNotificationsWithError:(NSError *)err {
    NSLog(@"Error in registration. Error: %@", err);
}
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    [Flurry logEvent:@"RECEIVE_REMOTE_NOTIFICATION"];
    BOOL isForeground=TRUE;
    if(application.applicationState != UIApplicationStateActive)
        isForeground=FALSE;
    [self ReceivePushData:userInfo RunOnForeground:isForeground];
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url{
    [Flurry logEvent:@"HANDLE_OPEN_URL"];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    NSString *query = [url query];
    if(query.length > 0){
        for (NSString *param in [query componentsSeparatedByString:@"&"]) {
            NSArray *elts = [param componentsSeparatedByString:@"="];
            if([elts count] < 2) continue;
            [params setObject:[elts objectAtIndex:1] forKey:[elts objectAtIndex:0]];
        }
    }
    NSString *token=[params objectForKey:@"token"];
    NSString *user_id=[params objectForKey:@"user_id"];
    NSString *identity_id=[params objectForKey:@"identity_id"];
    
    token_formerge=@"";
    if ([params objectForKey:@"token"] !=nil ){
        token_formerge=[token_formerge stringByAppendingString:[params objectForKey:@"token"]];
    }
    [params release];
    if (token.length > 0 && [user_id intValue]>0){
        EFAPIServer *server = [EFAPIServer sharedInstance];
        [server clearUserData];
        server.user_token = token;
        server.user_id = [user_id integerValue];
        [server saveUserData];
        [server loadMeSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
            if(operation.HTTPRequestOperation.response.statusCode==200){
                NSDictionary *body=[mappingResult dictionary];
                if([body isKindOfClass:[NSDictionary class]]) {
                    Meta *meta=(Meta*)[body objectForKey:@"meta"];
                    if(meta)
                        if([meta.code intValue]==200) {
                            NSString *ids_formerge=@"";
                            User *user=(User*)[body objectForKey:@"response.user"];
                            for (Identity *_identity in user.identities){
                                if([ids_formerge isEqualToString:@""])
                                    ids_formerge = [ids_formerge stringByAppendingFormat:@"%u",
                                                    [_identity.identity_id intValue]];
                                else
                                    ids_formerge = [ids_formerge stringByAppendingFormat:@",%u",
                                                    [_identity.identity_id intValue]];
                            }
                            ids_formerge=[NSString stringWithFormat:@"[%@]",ids_formerge];
                            if([[EFAPIServer sharedInstance] isLoggedIn]==NO){
                                [EFAPIServer sharedInstance].user_id = [user_id integerValue];
                                [EFAPIServer sharedInstance].user_token = token;
                                [[EFAPIServer sharedInstance] saveUserData];
                                [self SigninDidFinish];
                                [self processUrlHandler:url];
                            }else{
                                if([identity_id intValue] >0  && [user_id intValue] != [EFAPIServer sharedInstance].user_id) {
                                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Merge accounts" message:[NSString stringWithFormat:@"Merge account %@ into your current signed-in account?",user.name] delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Merge",nil];
                                    alert.tag=400;
                                    objc_setAssociatedObject (alert, &alertobject, ids_formerge,OBJC_ASSOCIATION_RETAIN);
                                    objc_setAssociatedObject (alert, &handleurlobject, url,OBJC_ASSOCIATION_RETAIN);
                                    objc_setAssociatedObject (alert, &mergetoken, token_formerge,OBJC_ASSOCIATION_RETAIN);
                                    
                                    
                                    
                                    [alert show];
                                    [alert release];
                                }else{
                                    [self processUrlHandler:url];
                                }
                            }
                            
                        }
                }
            }
        } failure:nil];
    }else{
        [self processUrlHandler:url];
    }
    
    
    
    return YES;
}

- (void) processUrlHandler:(NSURL*)url{
    NSString *host=[url host];
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    NSArray *url_components=[url.absoluteString componentsSeparatedByString:@"?"];
    if([url_components count] ==2){
        
        for (NSString *param in [[url_components objectAtIndex:1] componentsSeparatedByString:@"&"]) {
            NSArray *elts = [param componentsSeparatedByString:@"="];
            if([elts count] < 2) continue;
            [params setObject:[elts objectAtIndex:1] forKey:[elts objectAtIndex:0]];
        }
    }
    
    NSArray *viewControllers = self.navigationController.viewControllers;
    CrossesViewController *crossViewController = [viewControllers objectAtIndex:0];
    
    if([host isEqualToString:@"crosses"]){
        if([params objectForKey:@"cross_id"]){
            int cross_id=[[params objectForKey:@"cross_id"] intValue] ;
            if(cross_id>0)
            {
                if([crossViewController PushToCross:cross_id]==NO)
                    [crossViewController refreshCrosses:@"pushtocross" withCrossId:cross_id];
            }
        }
    }
    else if([host isEqualToString:@"conversation"]){
        if([params objectForKey:@"cross_id"]){
            int cross_id=[[params objectForKey:@"cross_id"] intValue] ;
            if(cross_id>0)
            {
                //                if([crossViewController PushToConversation:cross_id]==NO)
                //                    [crossViewController refreshCrosses:@"pushtoconversation" withCrossId:cross_id];
            }
        }
    }
    else if([host isEqualToString:@"profile"]){
        [crossViewController ShowProfileView];
    }
    [params release];
}

- (void)ReceivePushData:(NSDictionary*)userInfo RunOnForeground:(BOOL)isForeground
{
    if(isForeground==NO){
        NSArray *viewControllers = self.navigationController.viewControllers;
        CrossesViewController *crossViewController = [viewControllers objectAtIndex:0];
        if(userInfo!=nil)
        {
            id arg=[userInfo objectForKey:@"args"];
            if([arg isKindOfClass:[NSDictionary class]])
            {
                id cid=[arg objectForKey:@"cid"];
                id msg_type=[arg objectForKey:@"t"];
                if(cid !=nil && [cid isKindOfClass:[NSNumber class]] && msg_type!=nil && [msg_type isKindOfClass:[NSString class]])
                {
                    if([cid intValue]>0 )
                    {
                        int cross_id=[cid intValue];
                        NSString *type=(NSString*)msg_type;
                        if([type isEqualToString:@"i"])
                            [crossViewController refreshCrosses:@"pushtocross" withCrossId:cross_id];
                        if([type isEqualToString:@"c"])
                            [crossViewController refreshCrosses:@"pushtoconversation" withCrossId:cross_id];
                    }
                }
            }
        }
    }
    else{
        NSArray *viewControllers = self.navigationController.viewControllers;
        CrossesViewController *crossViewController = [viewControllers objectAtIndex:0];
        [crossViewController refreshCrosses:@"crossupdateview"];
    }
}

-(void)GatherCrossDidFinish{
    NSArray *viewControllers = self.navigationController.viewControllers;
    CrossesViewController *crossViewController = [viewControllers objectAtIndex:0];
    [crossViewController refreshCrosses:@"gatherview"];
    [self.navigationController dismissModalViewControllerAnimated:YES];
}
-(void)CrossUpdateDidFinish:(int)cross_id{
    //    [(CrossesViewController*)crossviewController refreshCrosses:@"crossupdateview"];
    NSArray *viewControllers = self.navigationController.viewControllers;
    CrossesViewController *crossViewController = [viewControllers objectAtIndex:0];
    [crossViewController refreshCrosses:@"crossupdateview" withCrossId:cross_id];
    
}
-(void)SignoutDidFinish{
    [Flurry logEvent:@"ACTION_DID_SIGN_OUT"];
    
    [[EFAPIServer sharedInstance] clearUserData];
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [ud removeObjectForKey:@"access_token"];
    [ud removeObjectForKey:@"userid"];
//    [ud removeObjectForKey:@"default_user_identities"];
    [ud removeObjectForKey:@"devicetoken"];
    [ud removeObjectForKey:@"exfee_updated_at"];
    [ud removeObjectForKey:@"ifdevicetokenSave"];
    [ud removeObjectForKey:@"localaddressbook_read_at"];
    [ud removeObjectForKey:@"udid"];
    [ud removeObjectForKey:@"push_token"];
    [[NSUserDefaults standardUserDefaults] synchronize];

    [self cleandb];
    
    NSArray *viewControllers = self.navigationController.viewControllers;
    CrossesViewController *rootViewController = [viewControllers objectAtIndex:0];
    [rootViewController emptyView];
    [self ShowLanding:rootViewController];
    
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void) cleandb{
    [Flurry logEvent:@"CLEAN_DB"];
    NSString *storePath = [RKApplicationDataDirectory() stringByAppendingPathComponent:DBNAME];
    //  NSString *seedPath = [[NSBundle mainBundle] pathForResource:@"RKSeedDatabase" ofType:@"sqlite"];
    //  NSLog(@"%@",storePath);
    
    NSURL *storeURL = [NSURL fileURLWithPath:storePath];
    NSError *error = nil;
    if ([[NSFileManager defaultManager] fileExistsAtPath:storeURL.path]) {
        if ([[NSFileManager defaultManager] removeItemAtPath:storeURL.path error:&error]) {
            
            RKObjectManager *objectManager = [RKObjectManager sharedManager];
            [ [NSURLCache sharedURLCache] removeAllCachedResponses];
            
            objectManager.managedObjectStore.managedObjectCache=nil;
            objectManager.managedObjectStore = nil;
            //      objectManager removeRequestDescriptor:(RKRequestDescriptor *)
            for ( RKRequestDescriptor * requestdesc in objectManager.requestDescriptors){
                [objectManager removeRequestDescriptor:requestdesc];
            }
            for ( RKResponseDescriptor * responsedesc in objectManager.responseDescriptors){
                [objectManager removeResponseDescriptor:responsedesc];
            }
            
            
            [self createdb];
        }
    }
}

//- (void) observeContextSave:(NSNotification*) notification {
//    RKManagedObjectStore *objectStore = [[RKObjectManager sharedManager] objectStore];
//    [[objectStore managedObjectContextForCurrentThread] mergeChangesFromContextDidSaveNotification:notification];
//}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
    if(buttonIndex==1 && alertView.tag==400){
        
        NSString *token = (NSString *)objc_getAssociatedObject(alertView, &mergetoken);
        
        NSString *merge_identity = (NSString *)objc_getAssociatedObject(alertView, &alertobject);
        
        [APIProfile MergeIdentities:token Identities_ids:merge_identity success:^(AFHTTPRequestOperation *operation, id responseObject) {
            if ([operation.response statusCode] == 200 && [responseObject isKindOfClass:[NSDictionary class]]){
                NSDictionary *body=responseObject;
                if([body isKindOfClass:[NSDictionary class]]) {
                    id code=[[body objectForKey:@"meta"] objectForKey:@"code"];
                    if(code)
                        if([code intValue]==200) {
                            [[EFAPIServer sharedInstance] loadMeSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                if(operation.HTTPRequestOperation.response.statusCode==200){
                                    NSURL *url = (NSURL *)objc_getAssociatedObject(alertView, &handleurlobject);
                                    [self processUrlHandler:url];
                                }
                            } failure:nil];
                        }
                }
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            
        }];
    }
}

@end
