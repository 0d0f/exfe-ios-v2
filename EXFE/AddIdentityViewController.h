//
//  AddIdentityViewController.h
//  EXFE
//
//  Created by huoju on 11/12/12.
//
//

#import <UIKit/UIKit.h>
#import <RestKit/RestKit.h>
#import <RestKit/JSONKit.h>
#import <CoreText/CoreText.h>
#import "ProfileViewController.h"
#import "SigninIconToolbarView.h"
#import "OAuthAddIdentityViewController.h"
#import "EXSpinView.h"
#import "MBProgressHUD.h"
#import "ImgCache.h"

@interface AddIdentityViewController : UIViewController{
    SigninIconToolbarView *signintoolbar;
    UIImageView *identitybackimg;
    UIImageView *passwordbackimg;
    UIImageView *identityLeftIcon;
    UIButton *identityRightButton;
    UIImageView *divider;
    UIImageView *avatarview;
    UIImageView *avatarframeview;
    
    UITextField *textUsername;
    UITextField *textPassword;
//    UITextField *textDisplayname;
    
    UIButton *addbtn;
    UIButton *setupnewbtn;
    
    UILabel *labelSignError;
    EXSpinView *spin;
    
    UIViewController *profileview;
    IBOutlet UILabel *identityhint;
}
@property (nonatomic,retain) UIViewController* profileview;

- (void) getUser;
- (void) addIdentity:(id) sender;
- (void) TwitterSigninButtonPress:(id)sender;
- (void) FacebookSigninButtonPress:(id)sender;
- (void) oauthSuccess;
- (void) clearIdentity;
- (void) doOAuth:(NSString*)provider;
- (void) MoreButtonPress:(id)sender;

@end
