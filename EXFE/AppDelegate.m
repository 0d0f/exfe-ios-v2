//
//  AppDelegate.m
//  EXFE
//
//  Created by ju huo on 5/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"
#import "APICrosses.h"
#import "APIConversation.h"
#import "APIProfile.h"
#import "CrossesViewController.h"
#import "LandingViewController.h"

@implementation AppDelegate
@synthesize userid;
@synthesize username;
@synthesize accesstoken;
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
    [Flurry startSession:@"8R2R8KZG35DK6S6MDHGS"];
    
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(observeContextSave:)
//                                                 name:NSManagedObjectContextDidSaveNotification
//                                               object:nil];
    NSNumber* db_version=[[NSUserDefaults standardUserDefaults] objectForKey:@"db_version"];
    
    if(db_version==nil || [db_version intValue]<APP_DB_VERSION){
        
        [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"exfee_updated_at"];
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:APP_DB_VERSION] forKey:@"db_version"];
    }
    
  NSURL *baseURL = [NSURL URLWithString:API_ROOT];
  RKLogConfigureByName("RestKit/Network", RKLogLevelTrace);
//  RKLogConfigureByName("*", RKLogLevelOff);
  
  [AFNetworkActivityIndicatorManager sharedManager].enabled = YES;
  [self createdb];
  RKObjectManager *objectManager = [RKObjectManager sharedManager];

//  RKObjectManager *objectManager = [RKObjectManager managerWithBaseURL:baseURL];
//  NSManagedObjectModel *managedObjectModel = [NSManagedObjectModel mergedModelFromBundles:nil];
//  RKManagedObjectStore *managedObjectStore = [[RKManagedObjectStore alloc] initWithManagedObjectModel:managedObjectModel];
//  objectManager.managedObjectStore = managedObjectStore;
//  [ModelMapping buildMapping];
//  
//  [managedObjectStore createPersistentStoreCoordinator];
//  NSString *storePath = [RKApplicationDataDirectory() stringByAppendingPathComponent:DBNAME];
////  NSString *seedPath = [[NSBundle mainBundle] pathForResource:@"RKSeedDatabase" ofType:@"sqlite"];
//  NSError *error;
//  NSPersistentStore *persistentStore = [managedObjectStore addSQLitePersistentStoreAtPath:storePath fromSeedDatabaseAtPath:nil withConfiguration:nil options:nil error:&error];
//  NSAssert(persistentStore, @"Failed to add persistent store with error: %@", error);
//  
//  // Create the managed object contexts
//  [managedObjectStore createManagedObjectContexts];
//  
//  // Configure a managed object cache to ensure we do not create duplicate objects
//  managedObjectStore.managedObjectCache = [[RKInMemoryManagedObjectCache alloc] initWithManagedObjectContext:managedObjectStore.persistentStoreManagedObjectContext];
  
  
  AppDelegate *app=(AppDelegate *)[[UIApplication sharedApplication] delegate];
  if(app.accesstoken!=nil)
    [objectManager.HTTPClient setDefaultHeader:app.accesstoken value:@"token"];
  
   [AFNetworkActivityIndicatorManager sharedManager].enabled = YES;
    BOOL login=[self Checklogin];
    if(login==NO){
        [self ShowLanding];
    }
  
//    NSString* ifdevicetokenSave=[[NSUserDefaults standardUserDefaults] stringForKey:@"ifdevicetokenSave"];
  
    if(login==YES)
    {
      [[UIApplication sharedApplication] registerForRemoteNotificationTypes: UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeBadge ];
    }
    crossviewController = [[[CrossesViewController alloc] initWithNibName:@"CrossesViewController" bundle:nil] autorelease];
    self.navigationController = [[UINavigationController alloc] initWithRootViewController:crossviewController];

    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    self.window.rootViewController=self.navigationController;
    [self.window addSubview:self.navigationController.view];
    [self.window makeKeyAndVisible];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque animated:NO];
    if(login==YES)
        [APIProfile LoadUsrWithUserId:userid success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
          NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"User"];
          NSPredicate *predicate = [NSPredicate predicateWithFormat:@"user_id = %u", userid];
          [request setPredicate:predicate];
          RKObjectManager *objectManager = [RKObjectManager sharedManager];
          NSArray *users = [objectManager.managedObjectStore.mainQueueManagedObjectContext executeFetchRequest:request error:nil];
          if(users!=nil && [users count] >0)
          {
              User* user=[users objectAtIndex:0];
              NSMutableArray *identities=[[NSMutableArray alloc] initWithCapacity:4];
              for(Identity *identity in user.identities){
                  [identities addObject:identity.identity_id];
              }
              [[NSUserDefaults standardUserDefaults] setObject:identities forKey:@"default_user_identities"];
              [identities release];
              [[NSUserDefaults standardUserDefaults] synchronize];
          }
        } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        }];
  
  NSString *endpoint = [NSString stringWithFormat:@"%@/Backgrounds/GetAvailableBackgrounds?token=%@",API_ROOT,self.accesstoken];
  [objectManager.HTTPClient getPath:endpoint parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
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
  } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
    
  }];

    return YES;
}

- (void) createdb{
  NSURL *baseURL = [NSURL URLWithString:API_ROOT];
  
  RKObjectManager *objectManager = [RKObjectManager sharedManager];
  if(objectManager==nil)
    objectManager = [RKObjectManager managerWithBaseURL:baseURL];
  
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
  managedObjectStore.managedObjectCache = [[RKInMemoryManagedObjectCache alloc] initWithManagedObjectContext:managedObjectStore.persistentStoreManagedObjectContext];
  NSArray *descriptors=objectManager.requestDescriptors;
  if(descriptors==nil || [descriptors count]==0)
    [ModelMapping buildMapping];

}

-(void)ShowLanding{
    LandingViewController *landingView=[[[LandingViewController alloc]initWithNibName:@"LandingViewController" bundle:nil]autorelease];
    landingView.delegate=self;
    double delayInSeconds = 0.1;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self.navigationController presentModalViewController:landingView animated:NO];
    });        
    
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
    if(self.userid>0){
        [(CrossesViewController*)crossviewController refreshCrosses:@"crossupdateview"];
    }
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

-(void)SigninDidFinish{
    if([self Checklogin]==YES)
    {
        NSString* devicetoken=[[NSUserDefaults standardUserDefaults] stringForKey:@"devicetoken"];
        NSString* ifdevicetokenSave=[[NSUserDefaults standardUserDefaults] stringForKey:@"ifdevicetokenSave"];
        if( ifdevicetokenSave==nil)
        {
            [[UIApplication sharedApplication] registerForRemoteNotificationTypes: UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeBadge ];
        }
        [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
        self.navigationController.navigationBar.frame = CGRectOffset(self.navigationController.navigationBar.frame, 0.0, -20.0);

        [(CrossesViewController*)crossviewController initUI];
        [(CrossesViewController*)crossviewController refreshCrosses:@"crossview_init"];
        [(CrossesViewController*)crossviewController loadObjectsFromDataStore];
        [self.navigationController dismissModalViewControllerAnimated:YES];
    }
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    
    NSString * tokenAsString = [[[deviceToken description]
                                 stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]]
                                stringByReplacingOccurrencesOfString:@" " withString:@""];
  
    if([[NSUserDefaults standardUserDefaults] objectForKey:@"udid"]!=nil &&  [[[NSUserDefaults standardUserDefaults] objectForKey:@"udid"] isEqualToString:tokenAsString])
        return;
  
    NSString *endpoint = [NSString stringWithFormat:@"%@/users/%u/regdevice?token=%@",API_ROOT,self.userid,self.accesstoken];
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
  
  

  
//RESTKIT0.2
//    RKParams* rsvpParams = [RKParams params];
//    [rsvpParams setValue:tokenAsString forParam:@"udid"];
//    [rsvpParams setValue:tokenAsString forParam:@"push_token"];
//    [rsvpParams setValue:@"iOS" forParam:@"os_name"];
//    [rsvpParams setValue:@"apple" forParam:@"brand"];
//    [rsvpParams setValue:@"" forParam:@"model"];
//    [rsvpParams setValue:@"6" forParam:@"os_version"];
//    
//    RKClient *client = [RKClient sharedClient];
//    [client setBaseURL:[RKURL URLWithBaseURLString:API_V2_ROOT]];
//  
//  
//    NSString *endpoint = [NSString stringWithFormat:@"/users/%u/regdevice?token=%@",self.userid,self.accesstoken];
//    [client post:endpoint usingBlock:^(RKRequest *request){
//        request.method=RKRequestMethodPOST;
//        request.params=rsvpParams;
//        request.onDidLoadResponse=^(RKResponse *response){
//            if (response.statusCode == 200) {
//                NSDictionary *body=[response.body objectFromJSONData];
//                if([body isKindOfClass:[NSDictionary class]]) {
//                    id code=[[body objectForKey:@"meta"] objectForKey:@"code"];
//                    if(code)
//                        if([code intValue]==200) {
//                            //TODO: make sure the api response is ok.
//                            [[NSUserDefaults standardUserDefaults] setObject:@"YES" forKey:@"ifdevicetokenSave"];
//                            [[NSUserDefaults standardUserDefaults] setObject:tokenAsString forKey:@"udid"];
//                        }
//                }
//            }else {
//                //Check Response Body to get Data!
//            }
//            
//        };
//        request.onDidFailLoadWithError=^(NSError *error){
//        };
//    }];
}

- (void)application:(UIApplication *)app didFailToRegisterForRemoteNotificationsWithError:(NSError *)err {
    NSLog(@"Error in registration. Error: %@", err);
}
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    BOOL isForeground=TRUE;
    if(application.applicationState != UIApplicationStateActive)
        isForeground=FALSE;
    [self ReceivePushData:userInfo RunOnForeground:isForeground];
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    NSArray *url_components=[url.absoluteString componentsSeparatedByString:@"?"];
    if([url_components count] ==2){
        
        for (NSString *param in [[url_components objectAtIndex:1] componentsSeparatedByString:@"&"]) {
            NSArray *elts = [param componentsSeparatedByString:@"="];
            if([elts count] < 2) continue;
            [params setObject:[elts objectAtIndex:1] forKey:[elts objectAtIndex:0]];
        }
    }
    NSString *token=[params objectForKey:@"token"];
    NSString *user_id=[params objectForKey:@"user_id"];
    NSString *identity_id=[params objectForKey:@"identity_id"];
    
    token_formerge=@"";
    if([params objectForKey:@"token"] !=nil)
        token_formerge=[token_formerge stringByAppendingString:[params objectForKey:@"token"]];
    
    [params release];
    if(![token isEqualToString:@""]&& [user_id intValue]>0){
      [APIProfile LoadUsrWithUserId:[user_id intValue] withToken:token success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
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
                            if([self Checklogin]==NO){
                              AppDelegate *app=(AppDelegate *)[[UIApplication sharedApplication] delegate];
                              app.userid=[user_id intValue];
                              app.accesstoken=token;
                              
                              [SigninDelegate saveSigninData:user];
                              [self SigninDidFinish];
                              [self processUrlHandler:url];
                            }else{
                              if([identity_id intValue] >0  && [user_id intValue] != self.userid) {
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
      } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        
      }];
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
        [(CrossesViewController*)crossviewController refreshCrosses:@"crossupdateview"];
    }
}

-(void)GatherCrossDidFinish{
    [(CrossesViewController*)crossviewController refreshCrosses:@"gatherview"];
    [self.navigationController dismissModalViewControllerAnimated:YES];
}
-(void)CrossUpdateDidFinish:(int)cross_id{
//    [(CrossesViewController*)crossviewController refreshCrosses:@"crossupdateview"];
    [(CrossesViewController*)crossviewController refreshCrosses:@"crossupdateview" withCrossId:cross_id];
    
}
-(void)SignoutDidFinish{
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"access_token"];
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"userid"];
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"default_user_identities"];
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"devicetoken"];
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"exfee_updated_at"];
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"ifdevicetokenSave"];
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"localaddressbook_read_at"];
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"udid"];
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"push_token"];
  
    
    
    [[NSUserDefaults standardUserDefaults] synchronize];
    AppDelegate* app=(AppDelegate*)[[UIApplication sharedApplication] delegate];  
    
    app.userid=0;
    app.accesstoken=@"";
    [self cleandb];

    
    NSArray *viewControllers = app.navigationController.viewControllers;
    CrossesViewController *rootViewController = [viewControllers objectAtIndex:0];
    [rootViewController emptyView];
        
    [self.navigationController popToRootViewControllerAnimated:YES];
}
- (void) cleandb{
  
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
//    RKManagedObjectStore *objectStore = [[RKObjectManager sharedManager] objectStore];

//#ifdef RESTKIT_GENERATE_SEED_DB
//    NSString *seedDatabaseName = nil;
//    NSString *databaseName = DBNAME;
//#else
//    NSString *seedDatabaseName = RKDefaultSeedDatabaseFileName;
//    NSString *databaseName = DBNAME;
//#endif
//    
//    [objectStore deletePersistentStore];
//    [objectStore save:nil];
//    objectStore = [RKManagedObjectStore objectStoreWithStoreFilename:databaseName usingSeedDatabaseName:seedDatabaseName managedObjectModel:nil delegate:self];

//    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSManagedObjectContextDidSaveNotification object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(observeContextSave:)
//                                                 name:NSManagedObjectContextDidSaveNotification
//                                               object:nil];
//    
//    RKObjectManager* manager = [RKObjectManager objectManagerWithBaseURL:[NSURL URLWithString:API_V2_ROOT]];
//    manager.objectStore = [RKManagedObjectStore objectStoreWithStoreFilename:databaseName usingSeedDatabaseName:seedDatabaseName managedObjectModel:nil delegate:self];
}
-(BOOL) Checklogin{

    if (self.userid>0) {
        return YES;
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
    NSString *_access_token=[[NSUserDefaults standardUserDefaults] stringForKey:@"access_token"]; 
    NSString *_userid=[[NSUserDefaults standardUserDefaults] stringForKey:@"userid"]; 
    NSString *_username=[[NSUserDefaults standardUserDefaults] stringForKey:@"username"];

    if(_access_token!=NULL && _userid!=NULL)
    {
        self.userid=[_userid intValue];
        self.username=_username;
        self.accesstoken=_access_token;
        return YES;
    }
    return NO;
}
//- (void) observeContextSave:(NSNotification*) notification {
//    RKManagedObjectStore *objectStore = [[RKObjectManager sharedManager] objectStore];
//    [[objectStore managedObjectContextForCurrentThread] mergeChangesFromContextDidSaveNotification:notification];
//}

//- (void)objectLoader:(RKObjectLoader *)objectLoader didLoadObjects:(NSArray *)objects {
//	NSFetchRequest* request = [User fetchRequest];
//    NSPredicate *predicate = [NSPredicate
//                              predicateWithFormat:@"user_id = %u", userid];
//    [request setPredicate:predicate];
//	NSArray *users = [[User objectsWithFetchRequest:request] retain];
//    
//    if(users!=nil && [users count] >0)
//    {
//        User* user=[users objectAtIndex:0];
//        NSMutableArray *identities=[[NSMutableArray alloc] initWithCapacity:4];
//        for(Identity *identity in user.identities){
//            [identities addObject:identity.identity_id];
//        }
//        [[NSUserDefaults standardUserDefaults] setObject:identities forKey:@"default_user_identities"];
//        [identities release];
//        [[NSUserDefaults standardUserDefaults] synchronize];
//    }
//    [users release];
//}
//- (void)objectLoader:(RKObjectLoader *)objectLoader didFailWithError:(NSError *)error {
////    NSLog(@"Error!:%@",error);
//}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    AppDelegate *app=(AppDelegate *)[[UIApplication sharedApplication] delegate];
    
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
                    [APIProfile LoadUsrWithUserId:app.userid success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                            if(operation.HTTPRequestOperation.response.statusCode==200){
                                NSURL *url = (NSURL *)objc_getAssociatedObject(alertView, &handleurlobject);
                                [self processUrlHandler:url];
                          }
                    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
                      
                    }];
              }
          }
        }
      } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
      }];
    }
}




@end
