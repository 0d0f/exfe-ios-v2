//
//  AppDelegate.h
//  EXFE
//
//  Created by ju huo on 5/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


#define WWW

#ifdef DEV
#define API_V2_ROOT @"http://api.0d0f.com/v2"
#define IMG_ROOT @"http://dev.0d0f.com/static/img"
#define EXFE_OAUTH_LINK @"http://dev.0d0f.com/oauth"
#define GOOGLE_API_KEY @"AIzaSyCO_MQfEQI-p0r4tlQ3lj0WKLwbMtR5f3A"
#endif


#ifdef LOCAL
#define API_V2_ROOT @"http://api.local.exfe.com/v2"
#define IMG_ROOT @"http://local.exfe.com/static/img"
#define EXFE_OAUTH_LINK @"http://local.exfe.com/oauth"
#define GOOGLE_API_KEY @"AIzaSyCO_MQfEQI-p0r4tlQ3lj0WKLwbMtR5f3A"
#endif

#ifdef WWW
#define API_V2_ROOT @"https://www.exfe.com/v2"
#define IMG_ROOT @"https://img.exfe.com"
#define EXFE_OAUTH_LINK @"https://exfe.com/oAuth"
#define GOOGLE_API_KEY @"AIzaSyCO_MQfEQI-p0r4tlQ3lj0WKLwbMtR5f3A"
#endif


//#define API_V2_ROOT @"http://api.local.exfe.com/v2"
//#define IMG_ROOT @"http://local.exfe.com/static/img"

//#define API_V2_ROOT @"http://api.0d0f.com/v2"
//#define IMG_ROOT @"http://dev.0d0f.com/static/img"

//#define API_V2_ROOT @"https://www.exfe.com/v2"
//#define IMG_ROOT @"https://img.exfe.com"
//#define EXFE_OAUTH_LINK @"https://exfe.com/oAuth"

//#define EXFE_OAUTH_LINK @"http://local.exfe.com/oauth"


@interface AppDelegate : UIResponder <UIApplicationDelegate>{
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
-(void)CrossUpdateDidFinish;
-(void)ShowLanding;
-(BOOL) Checklogin;
-(void) deviceReg;
- (void) cleandb;
@end
