//
//  SigninViewController.h
//  EXFE
//
//  Created by ju huo on 5/22/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <RestKit/RestKit.h>
#import "OAuthLoginViewController.h"
#import "APIProfile.h"
#import "User.h"

@interface SigninViewController : UIViewController <RKRequestDelegate,OAuthLoginViewControllerDelegate,RKObjectLoaderDelegate> {
    id delegate;
    
    IBOutlet UITextField *textUsername;
    IBOutlet UITextField *textPassword;    
    IBOutlet UILabel *hint;
    IBOutlet UIActivityIndicatorView* activityIndicatorview;
    IBOutlet UIButton *loginbtn;
}
@property (nonatomic, assign) id delegate;

- (IBAction) Signin:(id) sender;
- (void)SigninDidFinish;
- (void) processResponse:(id)obj;
- (IBAction) TwitterLoginButtonPress:(id) sender;
@end
