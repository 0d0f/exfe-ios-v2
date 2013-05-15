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
