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

#define WWW

#ifdef DEV
#define API_V2_ROOT @"http://api.0d0f.com/v2"
#define IMG_ROOT @"http://dev.0d0f.com/static/img"
#define EXFE_OAUTH_LINK @"http://dev.0d0f.com/oauth"
#define GOOGLE_API_KEY @"AIzaSyDTc7JJomGg5SW7Zn7lTN0N6mqAI9T3tFg"
#endif


#ifdef LOCAL
#define API_V2_ROOT @"http://api.local.exfe.com/v2"
#define IMG_ROOT @"http://local.exfe.com/static/img"
#define EXFE_OAUTH_LINK @"http://local.exfe.com/oauth"
#define GOOGLE_API_KEY @"AIzaSyDTc7JJomGg5SW7Zn7lTN0N6mqAI9T3tFg"
#endif

#ifdef WWW
#define API_V2_ROOT @"https://www.exfe.com/v2"
#define IMG_ROOT @"https://exfe.com/static/img"
#define EXFE_OAUTH_LINK @"https://exfe.com/oAuth"
#define GOOGLE_API_KEY @"AIzaSyDTc7JJomGg5SW7Zn7lTN0N6mqAI9T3tFg"
#endif

@interface AppDelegate : UIResponder <UIApplicationDelegate,RKObjectLoaderDelegate>{
    int userid;
    NSString *accesstoken;
    NSString *username;
    UIViewController* crossviewController;
}
@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, retain) UINavigationController *navigationController;
@property (nonatomic) int userid;
@property (nonatomic, retain) NSString *accesstoken;
@property (nonatomic, retain) NSString *username;

-(void)SigninDidFinish;
-(void)SignoutDidFinish;
-(void)GatherCrossDidFinish;
-(void)CrossUpdateDidFinish:(int)cross_id;
-(void)ShowLanding;
-(BOOL) Checklogin;
- (void) cleandb;
@end
