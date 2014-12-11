//
//  AppDelegate.h
//  EXFE
//
//  Created by ju huo on 5/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "WXApi.h"

// https://gist.github.com/953657
// http://stackoverflow.com/questions/3339722/check-iphone-ios-version
#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)

@class CrossesViewController;
@class EXFEModel;

@interface AppDelegate : UIResponder
<
UIApplicationDelegate,
UIAlertViewDelegate,
WXApiDelegate
>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, strong, readwrite) EXFEModel *model;
@property (nonatomic, strong, readwrite) UINavigationController *navigationController;
@property (nonatomic, strong, readwrite) CrossesViewController *crossesViewController;

- (void)switchContextByUserId:(NSUInteger)user_id withAbandon:(BOOL)flag;
-(void)signinDidFinish;
-(void)signoutDidFinish;
-(void)showLanding:(UIViewController*)parent;
@end
