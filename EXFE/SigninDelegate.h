//
//  SigninDelegate.h
//  EXFE
//
//  Created by huoju on 8/24/12.
//
//

#import <Foundation/Foundation.h>
#import <RestKit/RestKit.h>
#import <RestKit/JSONKit.h>
#import "OAuthLoginViewController.h"
#import "AppDelegate.h"
#import "APIProfile.h"
#import "User.h"

@interface SigninDelegate : NSObject<RKRequestDelegate,OAuthLoginViewControllerDelegate,RKObjectLoaderDelegate>{
    UIViewController *modalview;
    UIViewController *parent;
}
@property(retain,nonatomic)UIViewController *modalview;
@property(retain,nonatomic)UIViewController *parent;

- (void)loginSuccessWith:(NSString *)token userid:(NSString *)userid username:(NSString *)username;

@end