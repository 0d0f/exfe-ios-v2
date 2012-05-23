//
//  SigninViewController.h
//  EXFE
//
//  Created by ju huo on 5/22/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RestKit.h"

@interface SigninViewController : UIViewController <RKRequestDelegate> {
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
@end
