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

@class CrossesViewController;
@class EXFEModel;

@interface AppDelegate : UIResponder <UIApplicationDelegate,UIAlertViewDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, retain, readwrite) EXFEModel *model;
@property (nonatomic, retain, readwrite) UINavigationController *navigationController;
@property (nonatomic, retain, readwrite) CrossesViewController *crossesViewController;

@property (nonatomic, assign, readwrite) NSInteger user_id;
@property (nonatomic, copy, readwrite) NSString *user_token;

- (void)switchContextByUserId:(NSInteger)user_id;
-(void)signinDidFinish;
-(void)signoutDidFinish;
-(void)gatherCrossDidFinish;
-(void)crossUpdateDidFinish:(int)cross_id;
-(void)showLanding:(UIViewController*)parent;
@end
