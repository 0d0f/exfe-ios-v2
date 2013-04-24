//
//  AppDelegate.h
//  EXFE
//
//  Created by ju huo on 5/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <RestKit/RestKit.h>
#import "Flurry.h"
#import <objc/runtime.h>
#import "User.h"
#import "ModelMapping.h"

#define APP_DB_VERSION 208
#define DBNAME @"exfe_v2_8.sqlite"


#ifdef DEBUG
    #ifdef WWW
        #define API_ROOT @"https://www.exfe.com/v2/"
        #define IMG_ROOT @"https://exfe.com/static/img"
        #define EXFE_OAUTH_LINK @"https://exfe.com/OAuth"
    #elif defined LOCAL
        #define API_ROOT @"http://api.local.exfe.com/v2/"
        #define IMG_ROOT @"http://local.exfe.com/static/img"
        #define EXFE_OAUTH_LINK @"http://local.exfe.com/OAuth"
    #elif (defined PANDA) || (defined PILOT)
        #define API_ROOT @"http://api.panda.0d0f.com/v2/"
        #define IMG_ROOT @"http://panda.0d0f.com/static/img"
        #define EXFE_OAUTH_LINK @"http://panda.0d0f.com/oAuth"
    #else
        // DEV
        #define API_ROOT @"http://api.0d0f.com/v2/"
        #define IMG_ROOT @"http://0d0f.com/static/img"
        #define EXFE_OAUTH_LINK @"http://0d0f.com/OAuth"
    #endif
    #define GOOGLE_API_KEY @"AIzaSyDTc7JJomGg5SW7Zn7lTN0N6mqAI9T3tFg"
#else
    // WWW
    #define API_ROOT @"https://www.exfe.com/v2/"
    #define IMG_ROOT @"https://exfe.com/static/img"
    #define EXFE_OAUTH_LINK @"https://exfe.com/OAuth"
    #define GOOGLE_API_KEY @"AIzaSyDTc7JJomGg5SW7Zn7lTN0N6mqAI9T3tFg"
#endif



// https://gist.github.com/953657
// http://stackoverflow.com/questions/3339722/check-iphone-ios-version
#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)


@interface AppDelegate : UIResponder <UIApplicationDelegate,UIAlertViewDelegate>
@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, retain) UINavigationController *navigationController;

-(void)SigninDidFinish;
-(void)SignoutDidFinish;
-(void)GatherCrossDidFinish;
-(void)CrossUpdateDidFinish:(int)cross_id;
-(void)ShowLanding:(UIViewController*)parent;
- (void) cleandb;
- (void) createdb;
- (void) processUrlHandler:(NSURL*)url;
@end
