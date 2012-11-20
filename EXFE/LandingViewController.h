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
#import "SigninIconToolbarView.h"
#import "EXSpinView.h"

@interface LandingViewController : UIViewController{
    id delegate;
    UIImageView *logo;
    UIView *backgroundview;
    SigninIconToolbarView *signintoolbar;
//    UIButton *signinbutton;
//    UIButton *twitterbutton;
    SigninDelegate *signindelegate;


}

@property (nonatomic, assign) id delegate;

- (IBAction) SigninButtonPress:(id) sender;
- (void)TwitterSigninButtonPress:(id)sender;
- (void)FacebookSigninButtonPress:(id)sender;
- (void)SigninDidFinish;
- (void)dismissSigninView;
@end
