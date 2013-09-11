//
//  EFSignInViewController.h
//  EXFE
//
//  Created by Stony Wang on 13-4-15.
//
//

#import <UIKit/UIKit.h>
#import "CSLinearLayoutView.h"
#import "EFPasswordField.h"
#import "TTTAttributedLabel.h"

@interface EFSignInViewController : UIViewController<UITextFieldDelegate, UIScrollViewDelegate>

@property (nonatomic, strong) CSLinearLayoutView *rootView;
@property (nonatomic, strong) UITextField *inputIdentity;
@property (nonatomic, strong) UIImageView *imageIdentity;
@property (nonatomic, strong) UIButton *extIdentity;
@property (nonatomic, strong) EFPasswordField *inputPassword;
@property (nonatomic, strong) UITextField *inputUsername;
@property (nonatomic, strong) UIButton *btnStart;
@property (nonatomic, strong) UIButton *btnStartNewUser;
@property (nonatomic, strong) UIButton *btnStartOver;

@property (nonatomic, strong) UILabel *labelVerifyTitle;
@property (nonatomic, strong) UILabel *labelVerifyDescription;

@property (nonatomic, strong) UILabel *hintError;
@property (nonatomic, strong) TTTAttributedLabel *inlineError;
@property (nonatomic, strong) UIActivityIndicatorView *indicator;
@property (nonatomic, strong) UIImageView *textFieldFrame;

@property (nonatomic, strong) UIButton *btnFacebook;
@property (nonatomic, strong) UIButton *btnTwitter;

@property (nonatomic, strong) TTTAttributedLabel *labelRegion;

@property (nonatomic, copy) id onExitBlock;
@property (nonatomic, strong) NSMutableDictionary *identityCache;

@end
