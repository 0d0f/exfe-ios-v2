//
//  EFSignInViewController.h
//  EXFE
//
//  Created by Stony Wang on 13-4-15.
//
//

#import <UIKit/UIKit.h>
#import "OAuthLoginViewController.h"
#import "CSLinearLayoutView.h"
#import "EFPasswordField.h"
#import "TTTAttributedLabel.h"

@interface EFSignInViewController : UIViewController<OAuthLoginViewControllerDelegate, UITextFieldDelegate, UIActionSheetDelegate>

@property (nonatomic, retain) CSLinearLayoutView *rootView;
@property (nonatomic, retain) UITextField *inputIdentity;
@property (nonatomic, retain) UIImageView *imageIdentity;
@property (nonatomic, retain) UIButton *extIdentity;
@property (nonatomic, retain) EFPasswordField *inputPassword;
@property (nonatomic, retain) UITextField *inputUsername;
@property (nonatomic, retain) UIButton *btnStart;
@property (nonatomic, retain) UIButton *btnStartNewUser;
@property (nonatomic, retain) UIButton *btnStartOver;

@property (nonatomic, retain) UILabel *labelVerifyTitle;
@property (nonatomic, retain) UILabel *labelVerifyDescription;

@property (nonatomic, retain) UILabel *hintError;
@property (nonatomic, retain) TTTAttributedLabel *inlineError;
@property (nonatomic, retain) UIActivityIndicatorView *indicator;
@property (nonatomic, retain) UIImageView *textFieldFrame;

@property (nonatomic, retain) UIButton *btnFacebook;
@property (nonatomic, retain) UIButton *btnTwitter;


@property (nonatomic, copy) id onExitBlock;
@property (nonatomic, retain) NSMutableDictionary *identityCache;

@end
