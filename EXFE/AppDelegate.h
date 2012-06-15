//
//  AppDelegate.h
//  EXFE
//
//  Created by ju huo on 5/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#define API_V2_ROOT @"http://api.local.exfe.com/v2"
//#define API_V2_ROOT @"https://www.exfe.com/v2"

@interface AppDelegate : UIResponder <UIApplicationDelegate>{
    int userid;
    NSString *accesstoken;
    UIViewController* crossviewController;
}
//@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
//@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
//@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, retain) UINavigationController *navigationController;
@property (nonatomic) int userid;
@property (nonatomic, retain) NSString *accesstoken;

-(void)SigninDidFinish;
-(void)SignoutDidFinish;
-(void)ShowLanding;
-(BOOL) Checklogin;
@end
