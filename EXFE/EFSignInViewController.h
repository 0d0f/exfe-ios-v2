//
//  EFSignInViewController.h
//  EXFE
//
//  Created by Stony Wang on 13-4-15.
//
//

#import <UIKit/UIKit.h>
#import "CSLinearLayoutView.h"

@interface EFSignInViewController : UIViewController

@property (nonatomic, retain) CSLinearLayoutView *rootView;
@property (nonatomic, retain) UITextField *inputIdentity;
@property (nonatomic, retain) UIImageView *imageIdentity;
@property (nonatomic, retain) UIButton *extIdentity;
@property (nonatomic, retain) UITextField *inputPassword;
@property (nonatomic, retain) UITextField *inputUsername;
@property (nonatomic, retain) UIButton *btnStart;
@property (nonatomic, retain) UIButton *btnStartNewUser;
@property (nonatomic, retain) UIButton *btnStartOver;

@property (nonatomic, retain) UIButton *btnFacebook;
@property (nonatomic, retain) UIButton *btnTwitter;

@property (nonatomic, retain) NSDictionary *identityDict;
@property (nonatomic, retain) NSString *regFlag;
@property (nonatomic, copy) id onExitBlock;

@end
