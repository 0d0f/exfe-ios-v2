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
  
  RKObjectManager *objectManager = [RKObjectManager managerWithBaseURL:baseURL];
  // Enable Activity Indicator Spinner
  [AFNetworkActivityIndicatorManager sharedManager].enabled = YES;
  
  // Initialize managed object store
  NSManagedObjectModel *managedObjectModel = [NSManagedObjectModel mergedModelFromBundles:nil];
  RKManagedObjectStore *managedObjectStore = [[RKManagedObjectStore alloc] initWithManagedObjectModel:managedObjectModel];
  objectManager.managedObjectStore = managedObjectStore;
  [ModelMapping buildMapping];
  
  [managedObjectStore createPersistentStoreCoordinator];
  NSString *storePath = [RKApplicationDataDirectory() stringByAppendingPathComponent:DBNAME];
  NSString *seedPath = [[NSBundle mainBundle] pathForResource:@"RKSeedDatabase" ofType:@"sqlite"];
  NSLog(@"%@",storePath);
  NSError *error;
  NSPersistentStore *persistentStore = [managedObjectStore addSQLitePersistentStoreAtPath:storePath fromSeedDatabaseAtPath:seedPath withConfiguration:nil options:nil error:&error];
  NSAssert(persistentStore, @"Failed to add persistent store with error: %@", error);
  
  // Create the managed object contexts
  [managedObjectStore createManagedObjectContexts];
  
  // Configure a managed object cache to ensure we do not create duplicate objects
  managedObjectStore.managedObjectCache = [[RKInMemoryManagedObjectCache alloc] initWithManagedObjectContext:managedObjectStore.persistentStoreManagedObjectContext];
  
  
//  NSString *endpoint = [NSString stringWithFormat:@"%@/users/%u?token=%@",API_ROOT,user_id, app.accesstoken];
  
//  NSURL *url = [NSURL URLWithString:@"http://api.0d0f.com/v2/users/29?token=7d0a978b674529fe1c66120beaad804eae0bcf6fc8e03cd4106d8f773835ebdd"];
//  NSURLRequest *request = [NSURLRequest requestWithURL:url];
//  
//      RKManagedObjectRequestOperation *operation = [[RKManagedObjectRequestOperation alloc] initWithRequest:request responseDescriptors:@[responseDescriptor]];
//      NSManagedObjectContext *context=[RKObjectManager sharedManager].managedObjectStore.mainQueueManagedObjectContext;
//      operation.managedObjectContext = context;
//      //  operation.managedObjectCache = managedObjectStore.managedObjectCache;
//      [operation setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
//        User * user=(User*)[[mappingResult array] objectAtIndex:0];
//        NSSet *identities=user.identities;
//        for (Identity *identity in identities){
//          NSLog(@"login result: %@", identity.name);
//          
//        }
//       
//        
//      } failure:^(RKObjectRequestOperation *operation, NSError *error) {
//        RKLogError(@"Load failed with error: %@", error);
//      }];
//      [operation start];
//      [operation release];

//  [APIProfile LoadUsrWithUserId:385 delegate:self];
//
//  
//  NSManagedObjectModel *managedObjectModel = [NSManagedObjectModel mergedModelFromBundles:nil];
//  RKManagedObjectStore *managedObjectStore = [[RKManagedObjectStore alloc] initWithManagedObjectModel:managedObjectModel];
//  NSError *error = nil;
//  BOOL success = RKEnsureDirectoryExistsAtPath(RKApplicationDataDirectory(), &error);
//  if (! success) {
//    RKLogError(@"Failed to create Application Data Directory at path '%@': %@", RKApplicationDataDirectory(), error);
//  }
//  NSString *path = [RKApplicationDataDirectory() stringByAppendingPathComponent:databaseName];
//  NSPersistentStore *persistentStore = [managedObjectStore addSQLitePersistentStoreAtPath:path fromSeedDatabaseAtPath:nil withConfiguration:nil options:nil error:&error];
//  if (! persistentStore) {
//    RKLogError(@"Failed adding persistent store at path '%@': %@", path, error);
//  }
//  
//  [managedObjectStore createManagedObjectContexts];
//
//
  AppDelegate *app=(AppDelegate *)[[UIApplication sharedApplication] delegate];
//  RKObjectManager* manager =[RKObjectManager managerWithBaseURL:[NSURL URLWithString:API_ROOT]];
//  manager.managedObjectStore=managedObjectStore;
  if(app.accesstoken!=nil)
    [objectManager.HTTPClient setDefaultHeader:app.accesstoken value:@"token"];
  
//  NSManagedObjectContext *context=[RKObjectManager sharedManager].managedObjectStore.mainQueueManagedObjectContext;

  //    RKObjectManager* manager =[RKObjectManager managerWithBaseURL:[NSURL URLWithString:API_V2_ROOT]];

  
  
//RESTKIT0.2  
//    RKObjectManager* manager = [RKObjectManager objectManagerWithBaseURL:[NSURL URLWithString:API_V2_ROOT]];
//    RKObjectManager* manager =[RKObjectManager managerWithBaseURL:[NSURL URLWithString:API_V2_ROOT]];
//  
//    manager.objectStore = [RKManagedObjectStore objectStoreWithStoreFilename:databaseName usingSeedDatabaseName:seedDatabaseName managedObjectModel:nil delegate:self];
//
//    [[[RKClient sharedClient] requestQueue] setShowsNetworkActivityIndicatorWhenBusy:YES];
//    [[[RKObjectManager sharedManager] requestQueue] setShowsNetworkActivityIndicatorWhenBusy:YES];
  
//    [APICrosses MappingCross];
//    [APIConversation MappingConversation];
//    [APIProfile MappingUsers];
//    [APIProfile MappingSuggest];
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
  
      
//RESTKIT0.2
//    RKClient *client = [RKClient sharedClient];
//    [client setBaseURL:[RKURL URLWithBaseURLString:API_V2_ROOT]];
//    
//    NSString *endpoint = [NSString stringWithFormat:@"/Backgrounds/GetAvailableBackgrounds?token=%@",self.accesstoken];
//    [client get:endpoint usingBlock:^(RKRequest *request){
//        request.method=RKRequestMethodPOST;
//        request.onDidLoadResponse=^(RKResponse *response){
//            if (response.statusCode == 200) {
//                NSDictionary *body=[response.body objectFromJSONData];
//                if([body isKindOfClass:[NSDictionary class]]) {
//                    id code=[[body objectForKey:@"meta"] objectForKey:@"code"];
//                    if(code)
//                        if([code intValue]==200) {
//                            NSArray *backgrounds=[[body objectForKey:@"response"] objectForKey:@"backgrounds"];
//                            [[NSUserDefaults standardUserDefaults] setObject:backgrounds forKey:@"cross_default_backgrounds"];
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
    return YES;
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
//        [APICrosses MappingRoute];
        NSString* devicetoken=[[NSUserDefaults standardUserDefaults] stringForKey:@"devicetoken"];
        NSString* ifdevicetokenSave=[[NSUserDefaults standardUserDefaults] stringForKey:@"ifdevicetokenSave"];
        if( ifdevicetokenSave==nil)
        {
            [[UIApplication sharedApplication] registerForRemoteNotificationTypes: UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeBadge ];
        }
        [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
        self.navigationController.navigationBar.frame = CGRectOffset(self.navigationController.navigationBar.frame, 0.0, -20.0);

//        [(CrossesViewController*)crossviewController initUI];
//        [(CrossesViewController*)crossviewController refreshCrosses:@"crossview_init"];
//        [(CrossesViewController*)crossviewController loadObjectsFromDataStore];
        [self.navigationController dismissModalViewControllerAnimated:YES];
    }
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    
    NSString * tokenAsString = [[[deviceToken description]
                                 stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]]
                                stringByReplacingOccurrencesOfString:@" " withString:@""];
  
    if([[NSUserDefaults standardUserDefaults] objectForKey:@"udid"]!=nil &&  [[[NSUserDefaults standardUserDefaults] objectForKey:@"udid"] isEqualToString:tokenAsString])
        return;
    
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
//RESTKIT0.2
//    if(![token isEqualToString:@""]&& [user_id intValue]>0){
//        [APIProfile LoadUsrWithUserId:[user_id intValue] token:token usingBlock:^(RKRequest *request) {
//            request.method=RKRequestMethodGET;
//            request.onDidLoadResponse=^(RKResponse *response){
//                if (response.statusCode == 200) {
//                    NSDictionary *body=[response.body objectFromJSONData];
//                    if([body isKindOfClass:[NSDictionary class]]) {
//                        id code=[[body objectForKey:@"meta"] objectForKey:@"code"];
//                        if(code)
//                            if([code intValue]==200) {
//                                NSString *ids_formerge=@"";
//                                RKObjectMapper* mapper;
//                                mapper = [RKObjectMapper mapperWithObject:body mappingProvider:[RKObjectManager sharedManager].mappingProvider];
//                                RKObjectMappingResult* result = [mapper performMapping];
//                                NSDictionary *obj=[result asDictionary];
//                                User *user=[obj objectForKey:@"response.user"];
//                                for (Identity *_identity in user.identities){
//                                    if([ids_formerge isEqualToString:@""])
//                                        ids_formerge = [ids_formerge stringByAppendingFormat:@"%u",
//                                                        [_identity.identity_id intValue]];
//                                    else
//                                        ids_formerge = [ids_formerge stringByAppendingFormat:@",%u",
//                                                    [_identity.identity_id intValue]];
//                                }
//                                ids_formerge=[NSString stringWithFormat:@"[%@]",ids_formerge];
//
//                                if([self Checklogin]==NO){
//                                    AppDelegate *app=(AppDelegate *)[[UIApplication sharedApplication] delegate];
//                                    app.userid=[user_id intValue];
//                                    app.accesstoken=token;
//
//                                    [SigninDelegate saveSigninData:user];
//                                    [self SigninDidFinish];
//                                    [self processUrlHandler:url];
//                                }else{
//                                    if([identity_id intValue] >0  && [user_id intValue] != self.userid)
//                                    {
////                                        
//                                        
//                                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Merge accounts" message:[NSString stringWithFormat:@"Merge account %@ into your current signed-in account?",user.name] delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Merge",nil];
//                                        alert.tag=400;
//                                        objc_setAssociatedObject (alert, &alertobject, ids_formerge,OBJC_ASSOCIATION_RETAIN);
//                                        objc_setAssociatedObject (alert, &handleurlobject, url,OBJC_ASSOCIATION_RETAIN);
//                                        
//
//                                        [alert show];
//                                        [alert release];
//                                    }else{
//                                        [self processUrlHandler:url];
//                                    }
//                                }
//                                
//                            }
//
//                    }
//                }
//            };
//        }];
//    }else{
//        [self processUrlHandler:url];
//    }

    
    
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
        
        NSString *merge_identity = (NSString *)objc_getAssociatedObject(alertView, &alertobject);
//RESTKIT0.2      
//        [APIProfile MergeIdentities:token_formerge Identities_ids:merge_identity usingBlock:^(RKRequest *request){
//            request.method=RKRequestMethodPOST;
//            request.onDidLoadResponse=^(RKResponse *response){
//                if (response.statusCode == 200) {
//                    NSDictionary *body=[response.body objectFromJSONData];
//                    if([body isKindOfClass:[NSDictionary class]]){
//                        NSDictionary *meta=[body objectForKey:@"meta"];
//                        if([meta isKindOfClass:[NSDictionary class]]){
//                            if([[meta objectForKey:@"code"] isKindOfClass:[NSNumber class]]){
//                                if([[meta objectForKey:@"code"] intValue]==200){
//                                    [APIProfile LoadUsrWithUserId:app.userid token:app.accesstoken usingBlock:^(RKRequest *drequest) {
//                                        request.method=RKRequestMethodGET;
//                                        request.onDidLoadResponse=^(RKResponse *response){
//                                            if (response.statusCode == 200) {
//                                                NSURL *url = (NSURL *)objc_getAssociatedObject(alertView, &handleurlobject);
//                                                [self processUrlHandler:url];
//                                            }
//                                        };
//                                    }];
//                                }
//                            }
//                        }
//                    }
//                }
//            };
//            request.onDidFailLoadWithError=^(NSError *error){
////                [spin setHidden:YES];
////                NSLog(@"error %@",error);
//            };
//        }];
    }
}




@end
