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
#import "User+EXFE.h"
#import "Identity+EXFE.h"
#import "EFKit.h"

#define kTagOldPassword 233
#define kTagFreshPassword 234

@interface EFChangePasswordViewController ()

@property (nonatomic, strong) EXFEModel *model;

@property (nonatomic, strong) UITextField *oldPwdTextField;
@property (nonatomic, strong) UITextField *freshPwdTextField;
@property (nonatomic, strong) UIButton *btnDone;
@property (nonatomic, strong) UIButton *btnIdentity;
@property (nonatomic, strong) UIActionSheet *pickerViewPopup;
@property (nonatomic, strong) UIPickerView * categoryPickerView;

@property (nonatomic, strong) NSString *oldPassword;
@property (nonatomic, strong) NSString *freshPassword;
@property (nonatomic, strong) Identity *identity;
@property (nonatomic, assign) NSInteger selectedIdentityIndex;

@end

@implementation EFChangePasswordViewController

#pragma mark - Getter/Setter
- (void)setSelectedIdentityIndex:(NSInteger)index
{
    _selectedIdentityIndex = index;
    self.identity = [[self.user.identities allObjects] objectAtIndex:_selectedIdentityIndex];
}

#pragma mark - View Controller Live cycle
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
    [btnBack setImage:[UIImage imageNamed:@"back.png"] forState:UIControlStateNormal];
    [btnBack setImage:[UIImage imageNamed:@"back_pressed.png"] forState:UIControlStateHighlighted];
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
    
    
    UIButton *btnIdentity = [UIButton buttonWithType:UIButtonTypeCustom];
    btnIdentity.frame = CGRectMake(0, 0, 290, 50);
    btnIdentity.imageView.contentMode = UIViewContentModeScaleAspectFill;
    btnIdentity.imageEdgeInsets = UIEdgeInsetsMake(5.0, 5, 5.0, 245);
    btnIdentity.titleEdgeInsets = UIEdgeInsetsMake(5, -100, 5.0, 0);
    btnIdentity.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    btnIdentity.backgroundColor = [UIColor brownColor];
    // listarrow
    [btnIdentity addTarget:self action:@selector(changeIdentity:) forControlEvents:UIControlEventTouchUpInside];
    self.btnIdentity = btnIdentity;
    
    CSLinearLayoutItem *item6 = [CSLinearLayoutItem layoutItemForView:btnIdentity];
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
    [btnAuth addTarget:self action:@selector(authenticate:) forControlEvents:UIControlEventTouchUpInside];
    CSLinearLayoutItem *item7 = [CSLinearLayoutItem layoutItemForView:btnAuth];
    item7.fillMode = CSLinearLayoutItemFillModeNormal;
    item7.padding = CSLinearLayoutMakePadding(0, 15, 5, 15);
    [layout addItem:item7];
    
    [self.view addSubview:layout];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    [self registerAsObserver];
    
    self.selectedIdentityIndex = 0;
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [self unregisterForChangeNotification];
}

#pragma mark KVO methods
- (void)registerAsObserver {
    /*
     Register 'inspector' to receive change notifications for the "openingBalance" property of
     the 'account' object and specify that both the old and new values of "openingBalance"
     should be provided in the observe… method.
     */
    [self addObserver:self
              forKeyPath:@"identity"
                 options:(NSKeyValueObservingOptionNew |
                          NSKeyValueObservingOptionOld)
                 context:NULL];
}

- (void)unregisterForChangeNotification {
    [self removeObserver:self forKeyPath:@"identity"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    
    if ([keyPath isEqual:@"identity"]) {
        Identity * identity = [change objectForKey:NSKeyValueChangeNewKey];
        [self refreshIdentity:identity];
    } else {
        /*
         Be sure to call the superclass's implementation *if it implements it*.
         NSObject does not implement the method.
         */
        [super observeValueForKeyPath:keyPath
                             ofObject:object
                               change:change
                              context:context];
    }
}

#pragma mark - UI Refresh
- (void) refreshIdentity:(Identity*)identity
{
 
    NSString *avatar_filename = identity.avatar_filename;
    if (avatar_filename.length > 0) {
        UIImage *defaultImage = [UIImage imageNamed:@"portrait_default.png"];
        
        if ([[EFDataManager imageManager] isImageCachedInMemoryForKey:avatar_filename]) {
            [self.btnIdentity setImage: [[EFDataManager imageManager] cachedImageInMemoryForKey:avatar_filename] forState:UIControlStateNormal];
        } else {
            [self.btnIdentity setImage: defaultImage forState:UIControlStateNormal];
            
            [[EFDataManager imageManager] cachedImageForKey:avatar_filename
                                            completeHandler:^(UIImage *image){
                                                if (image) {
                                                    [self.btnIdentity setImage: image forState:UIControlStateNormal];
                                                }
                                            }];
        }
    }
    [self.btnIdentity setTitle: [identity getDisplayIdentity]  forState:UIControlStateNormal];

}

- (void)showInlineError:(NSString *)error with:(NSString*)msg
{
    // TODO: show error
}

#pragma mark - UI Events

#pragma mark UIButton action
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
    
    [self.model.apiServer changePassword:_oldPassword
                                    with:_freshPassword
                                 success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                     if ([operation.response statusCode] == 200 && [responseObject isKindOfClass:[NSDictionary class]]) {
                                         id code = [responseObject valueForKeyPath:@"meta.code"];
                                         if (code) {
                                             NSUInteger c = [code integerValue];
                                             NSInteger type = c / 100;
                                             
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
                                                 case 3: {
                                                     
                                                 } break;
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

}

- (void)changeIdentity:(id)view
{
    
    if (!_pickerViewPopup) {
        UIPickerView * categoryPickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 44, 320, 160)];
        [categoryPickerView setDataSource: self];
        [categoryPickerView setDelegate: self];
        categoryPickerView.showsSelectionIndicator = YES;
        
        UIToolbar *pickerToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
        pickerToolbar.barStyle = UIBarStyleBlackOpaque;
        [pickerToolbar sizeToFit];
        
        NSMutableArray *barItems = [[NSMutableArray alloc] init];
        
        UIBarButtonItem *flexSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
        [barItems addObject:flexSpace];
        
        UIBarButtonItem *doneBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneButtonPressed:)];
        [barItems addObject:doneBtn];
        
        [pickerToolbar setItems:barItems animated:YES];
        
        UIActionSheet *pickerViewPopup = [[UIActionSheet alloc] initWithTitle:nil delegate:nil cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
        [pickerViewPopup addSubview:pickerToolbar];
        [pickerViewPopup addSubview:categoryPickerView];
        self.pickerViewPopup = pickerViewPopup;
        self.categoryPickerView = categoryPickerView;
    }

//    [self.categoryPickerView reloadAllComponents];
    
    
    
    
    [self.pickerViewPopup showInView:self.view];
    [self.pickerViewPopup setBounds:CGRectMake(0, 0, 320, 400)];
    
    [self.categoryPickerView selectRow:self.selectedIdentityIndex inComponent:0 animated:NO];
    
}

- (void)authenticate:(UIControl*)sender
{
    
    sender.enabled = NO;
    
    [self.model.apiServer forgetPassword:self.identity.external_username
                                    with:[Identity getProviderCode:self.identity.provider]
                                 success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                     sender.enabled = YES;
                                     if ([operation.response statusCode] == 200){
                                         if([responseObject isKindOfClass:[NSDictionary class]]) {
                                             NSDictionary *body = responseObject;
                                             NSNumber *code = [body valueForKeyPath:@"meta.code"];
                                             if (code) {
                                                 NSInteger c = [code integerValue];
                                                 NSInteger t = c / 100;
                                                 switch (t) {
                                                     case 2:{
                                                         if (c == 200) {
                                                             NSString *action = [body valueForKeyPath:@"response.action"];
                                                             
                                                             if ([@"REDIRECT" isEqualToString:action]) {
                                                                 NSString * url = [body valueForKeyPath:@"response.url"];
                                                                 if (url.length > 0) {
                                                                     NSDictionary *identity = [body valueForKeyPath:@"response.identity"];
                                                                     Provider provider = [Identity getProviderCode:[identity valueForKey:@"provider"]];
                                                                     
                                                                     OAuthLoginViewController *oauth = [[OAuthLoginViewController alloc] initWithNibName:@"OAuthLoginViewController" bundle:nil];
                                                                     oauth.provider = provider;
                                                                     oauth.delegate = self;
                                                                     oauth.oAuthURL = url;
                                                                     switch (provider) {
                                                                         case kProviderTwitter:
                                                                             oauth.matchedURL = @"https://api.twitter.com/oauth/auth";
                                                                             oauth.javaScriptString = [NSString stringWithFormat:@"document.getElementById('username_or_email').value='%@';", [identity valueForKey:@"external_id"]];
                                                                             break;
                                                                         case kProviderFacebook:
                                                                             oauth.matchedURL = @"http://m.facebook.com/login.php?";
                                                                             oauth.javaScriptString = [NSString stringWithFormat:@"document.getElementsByName('email')[0].value='%@';", [identity valueForKey:@"external_username"]];
                                                                             break;
                                                                         default:
                                                                             oauth.matchedURL = nil;
                                                                             oauth.javaScriptString = nil;
                                                                             break;
                                                                     }
                                                                     
                                                                     [self presentModalViewController:oauth animated:YES];
                                                                 }
                                                             } else if ([@"VERIFYING" isEqualToString:action]) {
                                                                 // show verifying message
                                                                 NSString *message = NSLocalizedString(@"Verification is sent. Please check your email for instructions.", nil);
                                                                 if (kProviderPhone == [Identity getProviderCode:self.identity.provider]) {
                                                                     message = NSLocalizedString(@"Verification is sent. Please check your message for instructions.", nil);
                                                                 }
                                                                 
                                                                 [UIAlertView showAlertViewWithTitle:NSLocalizedString(@"Verification", nil)
                                                                                             message:message
                                                                                   cancelButtonTitle:nil
                                                                                   otherButtonTitles:@[NSLocalizedString(@"OK", nil)]
                                                                                             handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
                                                                                                 ;
                                                                                             }];
                                                             }
                                                         }
                                                     }  break;
                                                     case 3:{
                                                         
                                                     }  break;
                                                     case 4:{
                                                         
                                                     }  break;
                                                     case 5:{
                                                         
                                                     }  break;
                                                     default:
                                                         break;
                                                 }
                                             }
                                         }
                                     }
                                 } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                     sender.enabled = YES;
                                 }];
    
}

#pragma mark UITextFieldDelegate
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

#pragma mark UIPickerViewDataSource
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return self.user.identities.count;
}

#pragma mark UIPickerViewDelegate
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    Identity *identity = [self.user.identities.allObjects objectAtIndex:row];
    return  [identity getDisplayIdentity];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    self.selectedIdentityIndex = row;
}

- (void)doneButtonPressed:(id)sender{
    //Do something here here with the value selected using [pickerView date] to get that value
    [self.pickerViewPopup dismissWithClickedButtonIndex:1 animated:YES];
}

#pragma mark OAuthLoginViewControllerDelegate
- (void)OAuthloginViewControllerDidCancel:(UIViewController *)oauthlogin {
    [oauthlogin dismissModalViewControllerAnimated:YES];
}

- (void)OAuthloginViewControllerDidSuccess:(OAuthLoginViewController *)oauthloginViewController userid:(NSString*)userid username:(NSString*)username external_id:(NSString*)external_id token:(NSString*)token
{
    [oauthloginViewController dismissModalViewControllerAnimated:YES];
    
    if ([userid integerValue] == self.model.userId) {
        // use refresh token
        self.model.userToken = token;
        [self.model saveUserData];
        
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
                                
                                [self.model.apiServer changePassword:nil
                                                                with:password
                                                             success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                                                 
                                                                 if ([operation.response statusCode] == 200 && [responseObject isKindOfClass:[NSDictionary class]]){
                                                                     NSDictionary *body = responseObject;
                                                                     if([body isKindOfClass:[NSDictionary class]]) {
                                                                         NSNumber *code = [body valueForKeyPath:@"meta.code"];
                                                                         if (code) {
                                                                             NSInteger c = [code integerValue];
                                                                             NSInteger t = c / 100;
                                                                             switch (t) {
                                                                                 case 2:{
                                                                                     // c == 200
                                                                                     NSDictionary *resp = [responseObject valueForKeyPath:@"response"];
                                                                                     NSString *token = [resp valueForKey:@"token"];
                                                                                     if (token.length > 0) {
                                                                                         _model.userToken = token;
                                                                                         [_model saveUserData];
                                                                                         
                                                                                         [self goBack:_btnDone];
                                                                                     } else {
                                                                                         // error
                                                                                     }
                                                                                 }
                                                                                     break;
                                                                                 case 3:{
                                                                                     
                                                                                 }  break;
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
                                                                                     
                                                                                 }  break;
                                                                                 case 5:{
                                                                                     
                                                                                 }  break;
                                                                                 default:
                                                                                     break;
                                                                             }
                                                                         }
                                                                     }
                                                                 }
                                                             }
                                                             failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                                 ;
                                                             }];
                            }
                            
                        }
                      cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
                      otherButtonTitles:NSLocalizedString(@"Done", nil), nil];
    } else {
        // TODO: Merge to User
    }
  
}

#pragma mark - Helper Methods


#pragma mark - Private
@end
