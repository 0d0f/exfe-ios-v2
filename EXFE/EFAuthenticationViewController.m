//
//  EFAuthenticationViewController.m
//  EXFE
//
//  Created by Stony Wang on 13-7-22.
//
//

#import "EFAuthenticationViewController.h"
#import <BlocksKit/BlocksKit.h>
#import <QuartzCore/QuartzCore.h>
#import "WCAlertView.h"
#import "EFModel.h"
#import "CSLinearLayoutView.h"
#import "Util.h"
#import "TTTAttributedLabel.h"
#import "EFAPI.h"
#import "User+EXFE.h"
#import "Identity+EXFE.h"
#import "EFKit.h"
#import "EXGradientToolbarView.h"
#import "UILabel+EXFE.h"

#define kTagIdentityBar     238
#define kTagBtnAuth         239
#define kViewTagErrorInline 240

@interface EFAuthenticationViewController ()

@property (nonatomic, weak) EXFEModel *model;

@property (nonatomic, strong, readonly) NSArray *trustIdentities;

@property (nonatomic, strong) CSLinearLayoutView *rootView;
@property (nonatomic, strong) UIView * identitybar;
@property (nonatomic, strong) UIButton *btnAuth;

@property (nonatomic, strong) UIImageView *avatar;
@property (nonatomic, strong) UILabel *name;
@property (nonatomic, strong) UIActionSheet *pickerViewPopup;
@property (nonatomic, strong) UIPickerView * categoryPickerView;
@property (nonatomic, strong) UILabel *hintError;
@property (nonatomic, strong) TTTAttributedLabel *inlineError;
@property (nonatomic, strong) UIActivityIndicatorView *indicator;
@property (nonatomic, strong) UIButton *btnBack;

@property (nonatomic, strong) Identity *identity;
@property (nonatomic, assign) NSInteger selectedIdentityIndex;

@end

@implementation EFAuthenticationViewController

#pragma mark - Getter/Setter
- (void)setSelectedIdentityIndex:(NSInteger)index
{
    _selectedIdentityIndex = index;
    self.identity = [self.trustIdentities objectAtIndex:_selectedIdentityIndex];
}

- (void)setUser:(User *)user
{
    _user = user;
    
    NSArray* array = [self.user sortedIdentiesById];
    NSMutableArray *ma = [[NSMutableArray alloc] initWithCapacity:array.count];
    for (Identity *ident in array) {
        NSString* s = ident.status;
        if ([@"VERIFYING" isEqualToString:s] || [@"CONNECTED" isEqualToString:s] || [@"REVOKED" isEqualToString:s]) {
            [ma addObject:ident];
        }
    }
    _trustIdentities = ma;
}

#pragma mark - View Controller Life cycle
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
    contentView.backgroundColor = [UIColor COLOR_SNOW];
    self.view = contentView;
    
    UIImageView *fullScreen = [[UIImageView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:fullScreen];
    
    UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), 44)];
    
    
    EXGradientToolbarView *toolbar = [[EXGradientToolbarView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];
    [toolbar.layer setShadowColor:[UIColor blackColor].CGColor];
    [toolbar.layer setShadowOpacity:0.8];
    [toolbar.layer setShadowRadius:3.0];
    [toolbar.layer setShadowOffset:CGSizeMake(0, 0)];
    
    [self.view addSubview:toolbar];
    
    UILabel *title = [[UILabel alloc] initWithFrame:header.bounds];
    title.backgroundColor = [UIColor clearColor];
    title.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:20];
    title.textColor = [UIColor COLOR_CARBON];
    title.textAlignment = NSTextAlignmentCenter;
    title.shadowColor = [UIColor COLOR_WA(0xFF, 0xBF)];
    title.shadowOffset = CGSizeMake(0, 1);
    title.text = NSLocalizedString(@"Authentication", nil);
    [header addSubview:title];
    
    UIButton *btnBack = [UIButton buttonWithType:UIButtonTypeCustom ];
    [btnBack setFrame:CGRectMake(0, 0, 20,  CGRectGetHeight(header.bounds))];
    btnBack.backgroundColor = [UIColor COLOR_WA(0x33, 0xAA)];
    [btnBack setImage:[UIImage imageNamed:@"back.png"] forState:UIControlStateNormal];
    [btnBack setImage:[UIImage imageNamed:@"back_pressed.png"] forState:UIControlStateHighlighted];
    [btnBack addTarget:self action:@selector(goBack:) forControlEvents:UIControlEventTouchUpInside];
    [header addSubview:btnBack];
    self.btnBack = btnBack;
    
    UISwipeGestureRecognizer *swipe = [UISwipeGestureRecognizer recognizerWithHandler:^(UIGestureRecognizer *sender, UIGestureRecognizerState state, CGPoint location) {
        if (state == UIGestureRecognizerStateEnded) {
            [btnBack sendActionsForControlEvents:UIControlEventTouchUpInside];
        }
    }];
    swipe.direction = UISwipeGestureRecognizerDirectionRight;
    [header addGestureRecognizer:swipe];
    [self.view addSubview:header];
    
    CSLinearLayoutView *layout = [[CSLinearLayoutView alloc] initWithFrame:CGRectMake(0, 44, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds) - 44)];
    
    UIView * identityBar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 290, 50)];
    identityBar.layer.backgroundColor = [UIColor COLOR_WA(0xE6, 0xFF)].CGColor;
    identityBar.layer.cornerRadius = 4;
    identityBar.layer.borderColor = [UIColor COLOR_WA(0xCC, 0xFF)].CGColor;
    identityBar.layer.borderWidth = 1;
    identityBar.layer.masksToBounds = NO;
    
    UIImageView *avatar = [[UIImageView alloc] initWithFrame:CGRectMake(5, 5, 40, 40)];
    avatar.layer.cornerRadius = 2;
    avatar.clipsToBounds = YES;
    self.avatar = avatar;
    [identityBar addSubview:avatar];
    
    UILabel *name = [[UILabel alloc] initWithFrame:CGRectMake(50, 5, 200, 40)];
    name.backgroundColor = [UIColor clearColor];
    name.font = [UIFont fontWithName:@"HelveticaNeue-Italic" size:18];
    name.textColor = [UIColor COLOR_BLACK_19];;
    self.name = name;
    [identityBar addSubview:name];
    // listarrow
    UIImageView *down = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"chevron_d20g5.png"]];
    down.frame = CGRectMake(260, 15, 20, 20);
    [identityBar addSubview:down];
    
    UITapGestureRecognizer *gesture = [UITapGestureRecognizer recognizerWithHandler:^(UIGestureRecognizer *sender, UIGestureRecognizerState state, CGPoint location) {
        if (state == UIGestureRecognizerStateEnded) {
            [self changeIdentity:sender.view];
        }
    }];
    identityBar.tag = kTagIdentityBar;
    [identityBar addGestureRecognizer:gesture];
    
    CSLinearLayoutItem *item6 = [CSLinearLayoutItem layoutItemForView:identityBar];
    item6.horizontalAlignment = CSLinearLayoutItemHorizontalAlignmentCenter;
    item6.fillMode = CSLinearLayoutItemFillModeNormal;
    item6.padding = CSLinearLayoutMakePadding(0, 15, 10, 15);
    [layout addItem:item6];
    self.identitybar = identityBar;
    
    UIButton *btnAuth = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 290, 48)];
    btnAuth.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:18];
    [btnAuth setTitle:NSLocalizedString(@"Authenticate", nil) forState:UIControlStateNormal];
    [btnAuth setTitleColor:[UIColor COLOR_BLACK_19] forState:UIControlStateNormal];
    [btnAuth setTitleShadowColor:[UIColor whiteColor] forState:UIControlStateNormal];
    btnAuth.titleLabel.shadowOffset = CGSizeMake(0, 1);
    UIImage *btnImage2 = [UIImage imageNamed:@"btn_white_44.png"];
    btnImage2 = [btnImage2 resizableImageWithCapInsets:(UIEdgeInsets){15, 10, 15, 10}];
    [btnAuth setBackgroundImage:btnImage2 forState:UIControlStateNormal];
    [btnAuth addTarget:self action:@selector(authenticate:) forControlEvents:UIControlEventTouchUpInside];
    btnAuth.tag = kTagBtnAuth;
    CSLinearLayoutItem *item7 = [CSLinearLayoutItem layoutItemForView:btnAuth];
    item7.fillMode = CSLinearLayoutItemFillModeNormal;
    item7.padding = CSLinearLayoutMakePadding(0, 15, 5, 15);
    [layout addItem:item7];
    self.btnAuth = btnAuth;
    
    [self.view addSubview:layout];
    self.rootView = layout;
    
    {// Inline error hint
        TTTAttributedLabel *label = [[TTTAttributedLabel alloc] initWithFrame:CGRectMake(0, 0, 280, 80)];
        label.backgroundColor = [UIColor clearColor];
        label.font = [UIFont fontWithName:@"HelveticaNeue" size:14.0];
        label.textColor = [UIColor COLOR_WA(25, 0xFF)];
        label.lineBreakMode = UILineBreakModeWordWrap;
        label.numberOfLines = 0;
        label.tag = kViewTagErrorInline;
        self.inlineError = label;
    }
    
    {
        UIActivityIndicatorView *aiView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        aiView.frame = (CGRect){{0, 0}, {20, 20}};
        self.indicator = aiView;
    }

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
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShown:)
                                                 name:UIKeyboardWillShowNotification object:nil];
}

- (void)unregisterForChangeNotification {
    [self removeObserver:self forKeyPath:@"identity"];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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
            self.avatar.image = [[EFDataManager imageManager] cachedImageInMemoryForKey:avatar_filename];
            
        } else {
            self.avatar.image = defaultImage;
            
            [[EFDataManager imageManager] cachedImageForKey:avatar_filename
                                            completeHandler:^(UIImage *image){
                                                if (image) {
                                                    self.avatar.image = image;
                                                }
                                            }];
        }
    }
    self.name.text = [identity getDisplayIdentity];
    
}

- (void)showInlineError:(NSString *)title with:(NSString *)description
{
    // TODO: show error
    BOOL layoutFlag = NO;
    NSString* full = [NSString stringWithFormat:@"%@ %@", title, description];
    
    [_inlineError setText:full afterInheritingLabelAttributesAndConfiguringWithBlock:^NSMutableAttributedString *(NSMutableAttributedString *mutableAttributedString) {
        NSRange titleRange = [[mutableAttributedString string] rangeOfString:title options:NSCaseInsensitiveSearch];
        [mutableAttributedString addAttribute:(NSString*)kCTForegroundColorAttributeName value:(id)[[UIColor COLOR_RED_EXFE] CGColor] range:titleRange];
        return mutableAttributedString;
    }];
    _inlineError.hidden = NO;
    
    CSLinearLayoutItem *baseitem = [self.rootView findItemByTag:kTagBtnAuth];
    if (baseitem) {
        [_inlineError wrapContent];
        CSLinearLayoutItem *item = [self.rootView findItemByTag:_inlineError.tag];
        if (item == nil){
            item = [CSLinearLayoutItem layoutItemForView:_inlineError];
            item.horizontalAlignment = CSLinearLayoutItemHorizontalAlignmentCenter;
            item.fillMode = CSLinearLayoutItemFillModeNormal;
            [self.rootView insertItem:item afterItem:baseitem];
        } else {
            [self.rootView moveItem:item afterItem:baseitem];
        }
        CGFloat top = layoutFlag ? 27 : 0;
        item.padding = CSLinearLayoutMakePadding(top, 20, 0, 20);
    }
}

- (void)showErrorInfo:(NSString*)error dockOn:(UIView*)view
{
    [_hintError removeFromSuperview];
    _hintError.text = error;
    _hintError.backgroundColor = [UIColor COLOR_WA(250, 217)];
    CGRect frame = _hintError.bounds;
    frame.size.height = 44;
    frame.size.width = 245;
    frame.origin.x = CGRectGetMinX(view.frame) + 5;
    frame.origin.y = CGRectGetMidY(view.frame) - CGRectGetMidY(frame);
    _hintError.frame = frame;
    _hintError.alpha = 1.0;
    [self.rootView addSubview:_hintError];
    _hintError.hidden = NO;
    [self performBlock:^(id sender) {
        if (_hintError.hidden == NO) {
            [self hide:_hintError withAnmated:YES];
        }
    }
            afterDelay:5];
}

- (void)showErrorInfo:(NSString*)error over:(UIView*)view on:(UIView*)parent
{
    [_hintError removeFromSuperview];
    _hintError.text = error;
    _hintError.backgroundColor = [UIColor COLOR_WA(250, 217)];
    _hintError.frame = (CGRect){{16, 58}, {252, 35}};
    _hintError.alpha = 1.0;
    [parent addSubview:_hintError];
    _hintError.hidden = NO;
    [self performBlock:^(id sender) {
        if (_hintError.hidden == NO) {
            [self hide:_hintError withAnmated:YES];
        }
    }
            afterDelay:5];
}

- (void)hide:(UIView *)view withAnmated:(BOOL)animated
{
    if (animated) {
        [UIView animateWithDuration:0.5 animations:^{
            _hintError.alpha = 0.0;
        } completion:^(BOOL finished) {
            _hintError.hidden = YES;
            _hintError.alpha = 1.0;
        }];
    } else {
        _hintError.hidden = YES;
        _hintError.alpha = 1.0;
    }
}

- (void)showIndicatorAt:(CGPoint)center style:(UIActivityIndicatorViewStyle)style
{
    [_indicator removeFromSuperview];
    _indicator.activityIndicatorViewStyle = style;
    _indicator.center = center;
    [self.rootView addSubview:_indicator];
    [_indicator startAnimating];
}

- (void)hideIndicator
{
    [_indicator stopAnimating];
    [_indicator removeFromSuperview];
}

#pragma mark - UI Events

#pragma mark UIButton action
- (void)goBack:(UIControl*)sender
{
    [self dismissModalViewControllerAnimated:YES];
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
    _inlineError.hidden = YES;
    
    if (self.model.apiServer) {
        sender.enabled = NO;
        [self showIndicatorAt:CGPointMake(285, sender.center.y) style:UIActivityIndicatorViewStyleWhite];
    }
    
    [self.model.apiServer forgetPassword:self.identity.external_username
                                    with:[Identity getProviderCode:self.identity.provider]
                                 success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                     //                                     sender.enabled = YES;
                                     //                                     [self hideIndicator];
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
                                                                             oauth.javaScriptString = [NSString stringWithFormat:@"document.getElementById('username_or_email').value='%@';", [identity valueForKey:@"external_username"]];
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
                                                                                   otherButtonTitles:nil
                                                                                             handler:nil];
                                                             }
                                                         }
                                                     }  break;
                                                     case 3:{
                                                         
                                                     }  break;
                                                     case 4:{
                                                         NSString *errorType = [responseObject valueForKeyPath:@"meta.errorType"];
                                                         
                                                         if (c == 401) {
                                                             if ([@"no_signin" isEqualToString:errorType]) {
                                                                 // error: "Not sign in"
                                                             } else if ([@"token_staled" isEqualToString:errorType]) {
                                                                 // error: "Token expired"
                                                             }
                                                         } else if (c == 429){
                                                             
                                                             NSString *msg = nil;
                                                             Provider provider = [Identity getProviderCode:self.identity.provider];
                                                             switch (provider) {
                                                                 case kProviderPhone:
                                                                     msg = NSLocalizedString(@"Request should be responded usually in seconds, please wait for awhile.", nil);
                                                                     break;
                                                                     
                                                                 default:
                                                                     msg = NSLocalizedString(@"Request should be responded usually in seconds, please wait for awhile. Please also check your spam email folder, it might be mistakenly filtered by your mailbox.", nil);
                                                                     break;
                                                             }
                                                             [self showInlineError:NSLocalizedString(@"Request too frequently.", nil) with:msg];
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
                                     
                                     sender.enabled = YES;
                                     [self hideIndicator];
                                 } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                     sender.enabled = YES;
                                     [self hideIndicator];
                                 }];
    
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
    Identity *identity = [self.trustIdentities objectAtIndex:row];
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
        
        [self setPasswordWithErrorMessage:nil];
    } else {
        // TODO: Merge User
    }
    
}

#pragma mark - Helper Methods


#pragma mark - Private
- (void) setPasswordWithErrorMessage:(NSString*)msg
{
    [WCAlertView showAlertWithTitle:NSLocalizedString(@"Set Password", nil)
                            message:nil
                 customizationBlock:^(WCAlertView *alertView) {
                     alertView.alertViewStyle = UIAlertViewStyleSecureTextInput;
                     UITextField *textField = [alertView textFieldAtIndex:0];
                     textField.placeholder = NSLocalizedString(@"Set EXFE password", nil);
                     textField.textAlignment = UITextAlignmentCenter;
                     //                     textField.delegate = self;
                     if (msg) {
                         [self showErrorInfo:msg over:textField on:[textField superview]];
                     }
                 }
                    completionBlock:^(NSUInteger buttonIndex, WCAlertView *alertView) {
                        if (buttonIndex == 0) {
                            UITextField *textField = [alertView textFieldAtIndex:0];
                            NSString *password = [NSString stringWithString:textField.text];
                            
                            if (password.length < 4) {
                                [self setPasswordWithErrorMessage:@"Invalid password."];
                                return;
                            }
                            
                            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                            hud.mode = MBProgressHUDModeIndeterminate;
                            
                            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                                UITapGestureRecognizer *tap = [UITapGestureRecognizer recognizerWithHandler:^(UIGestureRecognizer *sender, UIGestureRecognizerState state, CGPoint location) {
                                    [hud hide:YES];
                                }];
                                [hud addGestureRecognizer:tap];
                            });
                            
                            [self.model.apiServer changePassword:nil
                                                            with:password
                                                         success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                                             [MBProgressHUD hideHUDForView:self.view animated:YES];
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
                                                                                     
                                                                                     [self goBack:self.btnBack];
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
                                                                                         [self setPasswordWithErrorMessage:@"Invalid password."];
                                                                                         
                                                                                     }
                                                                                 } else if (c == 401){
                                                                                     if ([@"no_signin" isEqualToString:errorType]) {
                                                                                         // error: "Not sign in"
                                                                                     } else if ([@"authenticate_timeout" isEqualToString:errorType]) {
                                                                                         // error: "Authenticate timeout."
                                                                                         [self showInlineError:NSLocalizedString(@"Set password failed.", nil) with:NSLocalizedString(@"The time is too long after the autentication. Please try authenticate identity above again.", nil)];
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
                                                             [MBProgressHUD hideHUDForView:self.view animated:YES];
                                                         }];
                        }
                        
                    }
                  cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
                  otherButtonTitles:NSLocalizedString(@"Done", nil), nil];
}

@end
