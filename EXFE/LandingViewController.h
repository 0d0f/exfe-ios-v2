//
//  LandingViewController.h
//  EXFE
//
//  Created by ju huo on 5/22/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LandingBackgroundView.h"
#import "EXIconToolBar.h"
#import "SigninDelegate.h"

@interface LandingViewController : UIViewController{
    id delegate;
    UIImageView *logo;
    UIView *backgroundview;
    UIView *signintoolbar;
    UIButton *signinbutton;
    UIButton *twitterbutton;
    SigninDelegate *signindelegate;


}

@property (nonatomic, assign) id delegate;

- (IBAction) SigninButtonPress:(id) sender;
- (void)TwitterSigninButtonPress:(id)sender;
- (void)SigninDidFinish;
@end
