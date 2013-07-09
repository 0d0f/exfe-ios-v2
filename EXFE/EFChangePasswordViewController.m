//
//  EFChangePasswordViewController.m
//  EXFE
//
//  Created by Stony Wang on 13-7-8.
//
//

#import "EFChangePasswordViewController.h"
#import <BlocksKit/BlocksKit.h>
#import "EFPasswordField.h"
#import "WCAlertView.h"
#import "EFModel.h"
#import "CSLinearLayoutView.h"
#import "Util.h"
#import "TTTAttributedLabel.h"
#import "EFAPI.h"

#define kTagOldPassword 233
#define kTagFreshPassword 234

@interface EFChangePasswordViewController ()

@property (nonatomic, strong) EXFEModel *model;

@property (nonatomic, strong) UITextField *oldPwdTextField;
@property (nonatomic, strong) UITextField *freshPwdTextField;
@property (nonatomic, strong) UIButton *btnDone;

@property (nonatomic, strong) NSString *oldPassword;
@property (nonatomic, strong) NSString *freshPassword;

@end

@implementation EFChangePasswordViewController

- (id)initWithModel:(EXFEModel*)model
{
    self = [super init];
    if (self) {
        self.model = model;
    }
    return self;
}

- (void)loadView
{
    CGRect applicationFrame = [[UIScreen mainScreen] applicationFrame];
    UIView *contentView = [[UIView alloc] initWithFrame:applicationFrame];
    contentView.backgroundColor = [UIColor whiteColor];
    self.view = contentView;
    
    UIImageView *fullScreen = [[UIImageView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:fullScreen];
    
    UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), 44)];
    
    UILabel *title = [[UILabel alloc] initWithFrame:header.bounds];
    title.textAlignment = NSTextAlignmentCenter;
    title.text = NSLocalizedString(@"Change password", nil);
    [header addSubview:title];
    
    UIButton *btnBack = [UIButton buttonWithType:UIButtonTypeCustom];
    btnBack.frame = CGRectMake(0, 0, 24, CGRectGetHeight(header.bounds));
    btnBack.backgroundColor = [UIColor blackColor];
    [btnBack addTarget:self action:@selector(goBack:) forControlEvents:UIControlEventTouchUpInside];
    [header addSubview:btnBack];
    
    [self.view addSubview:header];
    
    CSLinearLayoutView *layout = [[CSLinearLayoutView alloc] initWithFrame:CGRectMake(0, 44, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds) - 44)];
    

    UITextField *inputOldPassword = [[EFPasswordField alloc] initWithFrame:CGRectMake(0, 0, 290, 50)];
    inputOldPassword.tag = kTagOldPassword;
    inputOldPassword.placeholder = NSLocalizedString(@"Current password", nil);
    inputOldPassword.secureTextEntry = YES;
    inputOldPassword.delegate = self;
    inputOldPassword.backgroundColor = [UIColor grayColor];
    inputOldPassword.borderStyle = UITextBorderStyleNone;
    inputOldPassword.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    CSLinearLayoutItem *item1 = [CSLinearLayoutItem layoutItemForView:inputOldPassword];
    item1.horizontalAlignment = CSLinearLayoutItemHorizontalAlignmentCenter;
    item1.fillMode = CSLinearLayoutItemFillModeNormal;
    item1.padding = CSLinearLayoutMakePadding(24, 20, 0, 20);
    [layout addItem:item1];
    self.oldPwdTextField = inputOldPassword;
    
    UITextField *inputFreshPassword = [[EFPasswordField alloc] initWithFrame:CGRectMake(0, 0, 290, 50)];
    inputFreshPassword.tag = kTagFreshPassword;
    inputFreshPassword.placeholder = NSLocalizedString(@"Set new password", nil);
    inputFreshPassword.secureTextEntry = YES;
    inputFreshPassword.delegate = self;
    inputFreshPassword.backgroundColor = [UIColor lightGrayColor];
    inputFreshPassword.borderStyle = UITextBorderStyleNone;
    inputFreshPassword.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    CSLinearLayoutItem *item2 = [CSLinearLayoutItem layoutItemForView:inputFreshPassword];
    item2.horizontalAlignment = CSLinearLayoutItemHorizontalAlignmentCenter;
    item2.fillMode = CSLinearLayoutItemFillModeNormal;
    item2.padding = CSLinearLayoutMakePadding(0, 20, 10, 20);
    [layout addItem:item2];
    self.freshPwdTextField = inputFreshPassword;
    
    UIButton *btnDone = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 290, 48)];
    [btnDone setTitleShadowColor:[UIColor blackColor] forState:UIControlStateNormal];
    UIImage *btnImage = [UIImage imageNamed:@"btn_blue_44.png"];
    btnImage = [btnImage resizableImageWithCapInsets:(UIEdgeInsets){15, 10, 15, 10}];
    [btnDone setBackgroundImage:btnImage forState:UIControlStateNormal];
    [btnDone setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    btnDone.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:18];
    btnDone.titleLabel.shadowOffset = CGSizeMake(0, -1);
    [btnDone setTitle:NSLocalizedString(@"Done", nil) forState:UIControlStateNormal];
    [btnDone addTarget:self action:@selector(done:) forControlEvents:UIControlEventTouchUpInside];
    CSLinearLayoutItem *item3 = [CSLinearLayoutItem layoutItemForView:btnDone];
    item3.horizontalAlignment = CSLinearLayoutItemHorizontalAlignmentCenter;
    item3.fillMode = CSLinearLayoutItemFillModeNormal;
    item3.padding = CSLinearLayoutMakePadding(0, 15, 24, 15);
    [layout addItem:item3];
    self.btnDone = btnDone;
    
    UILabel * forgotTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 290, 50)];
    forgotTitle.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:21];
    forgotTitle.textColor = [UIColor COLOR_BLACK_19];
    forgotTitle.text = NSLocalizedString(@"Forgot password?", nil);
    [forgotTitle sizeToFit];
    CSLinearLayoutItem *item4 = [CSLinearLayoutItem layoutItemForView:forgotTitle];
    item4.fillMode = CSLinearLayoutItemFillModeNormal;
    item4.padding = CSLinearLayoutMakePadding(0, 15, 0, 15);
    [layout addItem:item4];
    
    TTTAttributedLabel * forgotDetail = [[TTTAttributedLabel alloc] initWithFrame:CGRectMake(0, 0, 290, 50)];
    forgotDetail.numberOfLines = 0;
    forgotDetail.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:14];
    forgotDetail.textColor = [UIColor COLOR_BLACK_19];
    NSString *full = NSLocalizedString(@"To reset your EXFE password, please authenticate with following identity.", nil);
    NSString *part = NSLocalizedString(@"EXFE", nil);
    [forgotDetail setText:full afterInheritingLabelAttributesAndConfiguringWithBlock:^NSMutableAttributedString *(NSMutableAttributedString *mutableAttributedString) {
        NSRange titleRange = [[mutableAttributedString string] rangeOfString:part options:NSCaseInsensitiveSearch];
        [mutableAttributedString addAttribute:(NSString*)kCTForegroundColorAttributeName value:(id)[[UIColor COLOR_BLUE_EXFE] CGColor] range:titleRange];
        return mutableAttributedString;
    }];
    [forgotDetail sizeToFit];
    CSLinearLayoutItem *item5 = [CSLinearLayoutItem layoutItemForView:forgotDetail];
//    item5.horizontalAlignment = CSLinearLayoutItemHorizontalAlignmentCenter;
    item5.fillMode = CSLinearLayoutItemFillModeNormal;
    item5.padding = CSLinearLayoutMakePadding(0, 15, 10, 15);
    [layout addItem:item5];
    
    
    UIView *labelPlace = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 290, 50)];
    labelPlace.backgroundColor = [UIColor lightGrayColor];
    CSLinearLayoutItem *item6 = [CSLinearLayoutItem layoutItemForView:labelPlace];
    item6.horizontalAlignment = CSLinearLayoutItemHorizontalAlignmentCenter;
    item6.fillMode = CSLinearLayoutItemFillModeNormal;
    item6.padding = CSLinearLayoutMakePadding(0, 15, 10, 15);
    [layout addItem:item6];
    
    UIButton *btnAuth = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 290, 48)];
    [btnAuth setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    btnAuth.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:18];
    [btnAuth setTitle:NSLocalizedString(@"Authenticate", nil) forState:UIControlStateNormal];
    [btnAuth setTitleColor:[UIColor COLOR_BLACK_19] forState:UIControlStateNormal];
    btnAuth.titleLabel.shadowColor = [UIColor whiteColor];
    btnAuth.titleLabel.shadowOffset = CGSizeMake(0, 1);
    UIImage *btnImage2 = [UIImage imageNamed:@"btn_white_44.png"];
    btnImage2 = [btnImage2 resizableImageWithCapInsets:(UIEdgeInsets){15, 10, 15, 10}];
    [btnAuth setBackgroundImage:btnImage2 forState:UIControlStateNormal];
    CSLinearLayoutItem *item7 = [CSLinearLayoutItem layoutItemForView:btnAuth];
    item7.fillMode = CSLinearLayoutItemFillModeNormal;
    item7.padding = CSLinearLayoutMakePadding(0, 15, 5, 15);
    [layout addItem:item7];
    
    UIButton *btnVerify = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 290, 48)];
    [btnVerify setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    btnVerify.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:18];
    [btnVerify setTitle:NSLocalizedString(@"Verify", nil) forState:UIControlStateNormal];
    [btnVerify setTitleColor:[UIColor COLOR_BLACK_19] forState:UIControlStateNormal];
    btnVerify.titleLabel.shadowColor = [UIColor whiteColor];
    btnVerify.titleLabel.shadowOffset = CGSizeMake(0, 1);
    UIImage *btnImage3 = [UIImage imageNamed:@"btn_white_44.png"];
    btnImage3 = [btnImage3 resizableImageWithCapInsets:(UIEdgeInsets){15, 10, 15, 10}];
    [btnVerify setBackgroundImage:btnImage3 forState:UIControlStateNormal];
    CSLinearLayoutItem *item8 = [CSLinearLayoutItem layoutItemForView:btnVerify];
    item8.fillMode = CSLinearLayoutItemFillModeNormal;
    item8.padding = CSLinearLayoutMakePadding(0, 15, 5, 15);
    [layout addItem:item8];
    
    [self.view addSubview:layout];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
//    if ([textField.text isEqualToString:@""])
//        return;
    
    switch (textField.tag) {
        case kTagOldPassword:
            self.oldPassword = textField.text;
            break;
        case kTagFreshPassword:
            self.freshPassword = textField.text;
            break;
        default:
            break;
    }
}

- (void)goBack:(id)view
{
    [self dismissModalViewControllerAnimated:YES];
}

- (void)done:(id)view
{
    if ([self.oldPwdTextField isFirstResponder]) {
        [self textFieldDidEndEditing:self.oldPwdTextField];
    }
    if ([self.freshPwdTextField isFirstResponder]) {
        [self textFieldDidEndEditing:self.freshPwdTextField];
    }
    
    NSLog(@"conver %@ to %@", self.oldPassword, self.freshPassword);
    
    if (self.freshPassword.length <= 4) {
        // error: "Invalid password."
        return;
    }
    
    [WCAlertView showAlertWithTitle:NSLocalizedString(@"Set Password", nil)
                            message:nil
                 customizationBlock:^(WCAlertView *alertView) {
                     alertView.alertViewStyle = UIAlertViewStyleSecureTextInput;
                     UITextField *textField = [alertView textFieldAtIndex:0];
                     textField.placeholder = NSLocalizedString(@"Set EXFE password", nil);
                     textField.textAlignment = UITextAlignmentCenter;
                 }
                    completionBlock:^(NSUInteger buttonIndex, WCAlertView *alertView) {
                        if (buttonIndex == 0) {
                            UITextField *field = [alertView textFieldAtIndex:0];
                            NSString *password = [NSString stringWithString:field.text];
                            NSLog(@"newPassword: %@", password);
                            
                            if ([_freshPassword isEqualToString:password]) {
                                
                                [self.model.apiServer changePassword:_oldPassword
                                                                with:_freshPassword
                                                             success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                                                 if ([operation.response statusCode] == 200 && [responseObject isKindOfClass:[NSDictionary class]]) {
                                                                     id code = [responseObject valueForKeyPath:@"meta.code"];
                                                                     if (code) {
                                                                         NSUInteger c = [code integerValue];
                                                                         NSInteger type = [code integerValue] / 100;
                                                                         
                                                                         switch (type) {
                                                                             case 2:{
                                                                                 // [code integerValue] == 200
                                                                                 NSDictionary *resp = [responseObject valueForKeyPath:@"response"];
                                                                                 NSString *token = [resp valueForKey:@"token"];
                                                                                 if (token.length > 0) {
                                                                                     _model.userToken = token;
                                                                                     [_model saveUserData];
                                                                                     
                                                                                     [self goBack:_btnDone];
                                                                                 } else {
                                                                                     // error
                                                                                 }
                                                                             }   break;
                                                                             case 4:{
                                                                                 NSString *errorType = [responseObject valueForKeyPath:@"meta.errorType"];
                                                                                 if (c == 400) {
                                                                                     if ([@"weak_password" isEqualToString:errorType]) {
                                                                                        // error: "Weak password." 
                                                                                     }
                                                                                 } else if (c == 401){
                                                                                     if ([@"no_signin" isEqualToString:errorType]) {
                                                                                         // error: "Not sign in"
                                                                                     } else if ([@"authenticate_timeout" isEqualToString:errorType]) {
                                                                                         // error: "Authenticate timeout."
                                                                                     }
                                                                                 }
                                                                             }
                                                                                 break;
                                                                             case 5:{
                                                                                 // faild
                                                                             }
                                                                                 break;
                                                                             default:
                                                                                 break;
                                                                         }
                                                                     }
                                                                 }
                                                             }
                                                             failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                                 
                                                             }];
                            } else {
                                // error password not match
                            }
                        }
                        
                    }
                  cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
                  otherButtonTitles:NSLocalizedString(@"Done", nil), nil];

}

@end
