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
#import "OAuthLoginViewController.h"
#import "APIProfile.h"
#import "User.h"
#import "ImgCache.h"

@interface SigninViewController : UIViewController <RKRequestDelegate,OAuthLoginViewControllerDelegate,RKObjectLoaderDelegate> {
    id delegate;
    
    IBOutlet UITextField *textUsername;
    IBOutlet UITextField *textPassword;    
    IBOutlet UILabel *hint;
    IBOutlet UIActivityIndicatorView* activityIndicatorview;
    IBOutlet UIButton *loginbtn;
    IBOutlet UIImageView *avatarview;
    IBOutlet UILabel *hint_title;
    IBOutlet UITextView *hint_desc;
    IBOutlet UIButton *Send;
    double editinginterval;
    IBOutlet UIView *hintpannel;
}
@property (nonatomic, assign) id delegate;

- (void) getUser;
- (IBAction) Signin:(id) sender;
- (void)SigninDidFinish;
- (void) processResponse:(id)obj;
- (IBAction) TwitterLoginButtonPress:(id) sender;
- (IBAction)showForgetPwd:(id)sender;
- (IBAction)sendPwd:(id)sender;
- (IBAction)sendVerify:(id)sender;
- (void) setHintView:(NSString*)hintname;


@end
