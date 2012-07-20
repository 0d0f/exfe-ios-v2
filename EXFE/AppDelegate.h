//
//  AppDelegate.h
//  EXFE
//
//  Created by ju huo on 5/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#define API_V2_ROOT @"http://api.local.exfe.com/v2"
#define GOOGLE_API_KEY @"AIzaSyCO_MQfEQI-p0r4tlQ3lj0WKLwbMtR5f3A"
//#define API_V2_ROOT @"https://www.exfe.com/v2"

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
-(void)ShowLanding;
-(BOOL) Checklogin;
@end
