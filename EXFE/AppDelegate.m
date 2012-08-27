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
#define DBNAME @"exfe_v2_0.sqlite"

@implementation AppDelegate
@synthesize userid;
@synthesize username;
@synthesize accesstoken;
@synthesize window = _window;
@synthesize navigationController=_navigationController;

- (void)dealloc
{
    [_window release];
    [_navigationController release];
    [super dealloc];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(observeContextSave:)
                                                 name:NSManagedObjectContextDidSaveNotification
                                               object:nil];
#ifdef RESTKIT_GENERATE_SEED_DB
    NSString *seedDatabaseName = nil;
    NSString *databaseName = DBNAME;
#else
    NSString *seedDatabaseName = RKDefaultSeedDatabaseFileName;
    NSString *databaseName = DBNAME;
#endif
    RKLogConfigureByName("RestKit/Network", RKLogLevelTrace);
    RKObjectManager* manager = [RKObjectManager objectManagerWithBaseURL:[NSURL URLWithString:API_V2_ROOT]];
    manager.objectStore = [RKManagedObjectStore objectStoreWithStoreFilename:databaseName usingSeedDatabaseName:seedDatabaseName managedObjectModel:nil delegate:self];
    [APICrosses MappingCross];
    [APIConversation MappingConversation];
    [APIProfile MappingUsers];
    [APIProfile MappingSuggest];
    BOOL login=[self Checklogin];
    if(login==NO){
        [self ShowLanding];
    }
    crossviewController = [[[CrossesViewController alloc] initWithNibName:@"CrossesViewController" bundle:nil] autorelease];
	self.navigationController = [[UINavigationController alloc] initWithRootViewController:crossviewController];
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    [self.window addSubview:self.navigationController.view];
    [self.window makeKeyAndVisible];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque animated:NO];
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
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

-(void)SigninDidFinish{
    if([self Checklogin]==YES)
    {
        [APICrosses MappingRoute];
        NSString* devicetoken=[[NSUserDefaults standardUserDefaults] stringForKey:@"devicetoken"];
        if(!devicetoken)
        {
            [[UIApplication sharedApplication] registerForRemoteNotificationTypes: UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeBadge ];
        }
        NSLog(@"SigninDidFinish");

        [(CrossesViewController*)crossviewController refreshCrosses:@"crossview"];
        [(CrossesViewController*)crossviewController initUI];
        [self.navigationController dismissModalViewControllerAnimated:YES];
    }
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    
//    NSString * tokenAsString = [[[deviceToken description] 
//                                 stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]] 
//                                stringByReplacingOccurrencesOfString:@" " withString:@""];
    
//    BOOL reg=[api regDeviceToken:tokenAsString];
//    if(reg==YES)
//    {
//        [[NSUserDefaults standardUserDefaults] setObject:@"YES"  forKey:@"devicetokenreg"];
//        [[NSUserDefaults standardUserDefaults] setObject:tokenAsString  forKey:@"devicetoken"];
//    }
}

- (void)application:(UIApplication *)app didFailToRegisterForRemoteNotificationsWithError:(NSError *)err {
    NSLog(@"Error in registration. Error: %@", err);
}


-(void)GatherCrossDidFinish{
    [(CrossesViewController*)crossviewController refreshCrosses:@"gatherview"];
    [self.navigationController dismissModalViewControllerAnimated:YES];
}

-(void)SignoutDidFinish{
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"access_token"];
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"userid"];
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"devicetoken"];
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"exfee_updated_at"];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
    AppDelegate* app=(AppDelegate*)[[UIApplication sharedApplication] delegate];  
    
    app.userid=0;
    app.accesstoken=@"";
    RKManagedObjectStore *objectStore = [[RKObjectManager sharedManager] objectStore];
//#ifdef RESTKIT_GENERATE_SEED_DB
//    NSString *seedDatabaseName = nil;
//    NSString *databaseName = DBNAME;
//#else
//    NSString *seedDatabaseName = RKDefaultSeedDatabaseFileName;
//    NSString *databaseName = DBNAME;
//#endif

//    [objectStore deletePersistentStoreUsingSeedDatabaseName:seedDatabaseName];
    [objectStore deletePersistentStore];
    [objectStore save:nil];
    
    NSArray *viewControllers = app.navigationController.viewControllers;
    CrossesViewController *rootViewController = [viewControllers objectAtIndex:0];
    [rootViewController emptyView];
    
    
//    RKObjectManager* manager = [RKObjectManager objectManagerWithBaseURL:[NSURL URLWithString:API_V2_ROOT]];
//    manager.objectStore = [RKManagedObjectStore objectStoreWithStoreFilename:databaseName usingSeedDatabaseName:seedDatabaseName managedObjectModel:nil delegate:self];
    
    [self.navigationController popToRootViewControllerAnimated:YES];
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
- (void) observeContextSave:(NSNotification*) notification {
    RKManagedObjectStore *objectStore = [[RKObjectManager sharedManager] objectStore];
    [[objectStore managedObjectContextForCurrentThread] mergeChangesFromContextDidSaveNotification:notification];
}
@end
