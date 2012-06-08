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
#ifdef RESTKIT_GENERATE_SEED_DB
    NSString *seedDatabaseName = nil;
    NSString *databaseName = RKDefaultSeedDatabaseFileName;
#else
    NSString *seedDatabaseName = RKDefaultSeedDatabaseFileName;
    NSString *databaseName = @"CoreData.sqlite";
#endif
//    RKLogConfigureByName("RestKit/*", RKLogLevelTrace);
//    RKObjectManager* manager = [RKObjectManager objectManagerWithBaseURLString:API_V2_ROOT];
    RKObjectManager* manager = [RKObjectManager objectManagerWithBaseURL:[NSURL URLWithString:API_V2_ROOT]];

    
    manager.objectStore = [RKManagedObjectStore objectStoreWithStoreFilename:databaseName usingSeedDatabaseName:seedDatabaseName managedObjectModel:nil delegate:self];
    [APICrosses MappingCross];
    [APIConversation MappingConversation];
    [APIProfile MappingUsers];

    crossviewController = [[[CrossesViewController alloc] initWithNibName:@"CrossesViewController" bundle:nil] autorelease];
    
	self.navigationController = [[UINavigationController alloc] initWithRootViewController:crossviewController];
    
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];

    [self.window addSubview:self.navigationController.view];
    BOOL login=[self Checklogin];
    if(login==NO){
        LandingViewController *landingView=[[[LandingViewController alloc]initWithNibName:@"LandingViewController" bundle:nil]autorelease];
        landingView.delegate=self;
        double delayInSeconds = 0.1;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [self.navigationController presentModalViewController:landingView animated:YES];
        });        
    }
    [self.window makeKeyAndVisible];
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
        [(CrossesViewController*)crossviewController refreshCrosses];
        [self.navigationController dismissModalViewControllerAnimated:YES];
    }
}
-(BOOL) Checklogin{
    if (self.userid>0) {
        return YES;
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
    NSString *_access_token=[[NSUserDefaults standardUserDefaults] stringForKey:@"access_token"]; 
    NSString *_userid=[[NSUserDefaults standardUserDefaults] stringForKey:@"userid"]; 

    if(_access_token!=NULL && _userid!=NULL)
    {
        self.userid=[_userid intValue];
        self.accesstoken=_access_token;
        return YES;
    }
    return NO;
}
@end
