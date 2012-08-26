//
//  SigninViewController.h
//  EXFE
//
//  Created by ju huo on 5/22/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <RestKit/RestKit.h>
#import <RestKit/JSONKit.h>
#import <CoreText/CoreText.h>
#import "OAuthLoginViewController.h"
#import "APIProfile.h"
#import "User.h"
#import "ImgCache.h"
#import "SigninDelegate.h"
#import "SigninIconToolbarView.h"

@interface SigninViewController : UIViewController <RKRequestDelegate> {
    id delegate;
    SigninDelegate *signindelegate;

    IBOutlet UILabel *hint;
    IBOutlet UIActivityIndicatorView* activityIndicatorview;
    IBOutlet UILabel *hint_title;
    IBOutlet UITextView *hint_desc;
    IBOutlet UIButton *Send;
    double editinginterval;
    IBOutlet UIView *hintpannel;
    
    SigninIconToolbarView *signintoolbar;
    
    UIImageView *identitybackimg;
    UIImageView *passwordbackimg;
    
    UIImageView *identityLeftIcon;
    UIButton *identityRightButton;
    UIImageView *divider;
    UIImageView *avatarview;
    
    UITextField *textUsername;
    UITextField *textPassword;
    UITextField *textDisplayname;
    
    UIButton *loginbtn;
    UIButton *setupnewbtn;
}
@property (nonatomic, assign) id delegate;

- (void) getUser;
- (IBAction) Signin:(id) sender;
- (void)SigninDidFinish;
- (void)SigninCancel;
- (void) processResponse:(id)obj;
- (IBAction) TwitterLoginButtonPress:(id) sender;
- (IBAction)showForgetPwd:(id)sender;
- (IBAction)sendPwd:(id)sender;
- (IBAction)sendVerify:(id)sender;
- (void) setHintView:(NSString*)hintname;
- (void) TwitterSigninButtonPress:(id)sender;
- (void) setSignupView;
- (void) setSigninView;
- (void) clearIdentity;

@end
