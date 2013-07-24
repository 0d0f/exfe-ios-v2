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
#import <Social/Social.h>
#import <Twitter/Twitter.h>
#import <Accounts/Accounts.h>
#import <FacebookSDK/FacebookSDK.h>
#import "TWAPIManager.h"
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
#import "EFIdentityBar.h"
#import "EFPasswordField.h"
#import "OAuthLoginViewController.h"

#define kTagPassword        233
#define kTagBtnAuthPwd      234
#define kTagBtnAuthIdentity 235

#define kTagIdentityBar     238
#define kTagBtnAuthForSet   239
#define kViewTagErrorInline 240


typedef void(^TwitterAccountsHandler)(NSArray *accounts);

@interface EFAuthenticationViewController ()

@property (nonatomic, weak) EXFEModel *model;

@property (nonatomic, strong, readonly) NSArray *trustIdentities;
@property (nonatomic, copy) NSString *currentPwd;

@property (nonatomic, strong) CSLinearLayoutView *rootView;
@property (nonatomic, strong) CSLinearLayoutView *authView;
@property (nonatomic, strong) CSLinearLayoutView *setpwdView;


@property (nonatomic, strong) EFIdentityBar * identitybarSet;

@property (nonatomic, strong) UIButton *btnAuth;
@property (nonatomic, strong) UITextField *pwdTextField;
@property (nonatomic, strong) UILabel *whyTitle1;
@property (nonatomic, strong) UILabel *whyDesc1;
@property (nonatomic, strong) UILabel *forgotTitle;
@property (nonatomic, strong) UILabel *forgotDetail;
@property (nonatomic, strong) EFIdentityBar * identityBarFgt;
@property (nonatomic, strong) UIButton *btnAuthIdentity;

@property (nonatomic, strong) UIActionSheet *pickerViewPopup;
@property (nonatomic, strong) UIPickerView * categoryPickerView;
@property (nonatomic, strong) UILabel *hintError;
@property (nonatomic, strong) TTTAttributedLabel *inlineError;
@property (nonatomic, strong) UIActivityIndicatorView *indicator;
@property (nonatomic, strong) UIButton *btnBack;

@property (nonatomic, strong) Identity *identity;
@property (nonatomic, assign) NSInteger selectedIdentityIndex;

@property (nonatomic, strong) ACAccountStore *accountStore;
@property (nonatomic, strong) TWAPIManager *apiManager;
@property (nonatomic, strong) NSArray *accounts;

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
        
        self.accountStore = [[ACAccountStore alloc] init];
        self.apiManager = [[TWAPIManager alloc] init];
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
    
    CSLinearLayoutView * authLayout = [[CSLinearLayoutView alloc] initWithFrame:CGRectMake(0, 44, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds) - 44)];
    {
        UILabel * labelHead = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 290, 100)];
        labelHead.backgroundColor = [UIColor clearColor];
        labelHead.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:14];
        labelHead.textColor = [UIColor COLOR_BLACK_19];
        labelHead.numberOfLines = 0;
        labelHead.text = NSLocalizedString(@"You’re about to change important information of your account. For security concerns, please authenticate your account.", nil);
        [labelHead sizeToFit];
        CSLinearLayoutItem *item1 = [CSLinearLayoutItem layoutItemForView:labelHead];
        item1.horizontalAlignment = CSLinearLayoutItemHorizontalAlignmentCenter;
        item1.fillMode = CSLinearLayoutItemFillModeNormal;
        item1.padding = CSLinearLayoutMakePadding(10, 15, 5, 15);
        [authLayout addItem:item1];
        
        EFPasswordField *inputPassword = [[EFPasswordField alloc] initWithFrame:CGRectMake(0, 0, 290, 50)];
        inputPassword.leftViewMode = UITextFieldViewModeNever;
        inputPassword.returnKeyType = UIReturnKeyNext;
        inputPassword.tag = kTagPassword;
        inputPassword.placeholder = NSLocalizedString(@"Current password", nil);
        inputPassword.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:18];
        inputPassword.delegate = self;
        inputPassword.borderStyle = UITextBorderStyleNone;
        inputPassword.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        [inputPassword.btnForgot addTarget:self action:@selector(forgetPwd:) forControlEvents:UIControlEventTouchUpInside];
        CSLinearLayoutItem *item2 = [CSLinearLayoutItem layoutItemForView:inputPassword];
        item2.horizontalAlignment = CSLinearLayoutItemHorizontalAlignmentCenter;
        item2.fillMode = CSLinearLayoutItemFillModeNormal;
        item2.padding = CSLinearLayoutMakePadding(5, 20, 5, 20);
        [authLayout addItem:item2];
        self.pwdTextField = inputPassword;
        
        UIButton *btnChangePwd = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 290, 48)];
        [btnChangePwd setTitleShadowColor:[UIColor COLOR_WA(0x00, 0x7F)] forState:UIControlStateNormal];
        UIImage *btnImage = [UIImage imageNamed:@"btn_blue_44.png"];
        btnImage = [btnImage resizableImageWithCapInsets:(UIEdgeInsets){15, 10, 15, 10}];
        [btnChangePwd setBackgroundImage:btnImage forState:UIControlStateNormal];
        [btnChangePwd setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        btnChangePwd.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:18];
        btnChangePwd.titleLabel.shadowOffset = CGSizeMake(0, -1);
        [btnChangePwd setTitle:NSLocalizedString(@"Authenticate", nil) forState:UIControlStateNormal];
        [btnChangePwd addTarget:self action:@selector(authWithPwd:) forControlEvents:UIControlEventTouchUpInside];
        btnChangePwd.tag = kTagBtnAuthPwd;
        CSLinearLayoutItem *item3 = [CSLinearLayoutItem layoutItemForView:btnChangePwd];
        item3.horizontalAlignment = CSLinearLayoutItemHorizontalAlignmentCenter;
        item3.fillMode = CSLinearLayoutItemFillModeNormal;
        item3.padding = CSLinearLayoutMakePadding(5, 15, 5, 15);
        [authLayout addItem:item3];
        self.btnAuth = btnChangePwd;
        
        UILabel * whyTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 290, 40)];
        whyTitle.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:14];
        whyTitle.backgroundColor = [UIColor clearColor];
        whyTitle.textColor = [UIColor COLOR_BLACK_19];
        whyTitle.text = NSLocalizedString(@"Why I have to do this?", nil);
        [whyTitle sizeToFit];
        CSLinearLayoutItem *item4 = [CSLinearLayoutItem layoutItemForView:whyTitle];
        item4.fillMode = CSLinearLayoutItemFillModeNormal;
        item4.hiddenType = CSLinearLayoutItemGone;
        item4.padding = CSLinearLayoutMakePadding(0, 15, 5, 15);
        [authLayout addItem:item4];
        self.whyTitle1 = whyTitle;
        
        UILabel * whyDesc = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 290, MAXFLOAT)];
        whyDesc.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:10];
        whyDesc.backgroundColor = [UIColor clearColor];
        whyDesc.textColor = [UIColor COLOR_GRAY];
        whyDesc.numberOfLines = 0;
        whyDesc.text = NSLocalizedString(@"Sorry for the inconvenience. Sometimes, we have to compromise on experience for your account security. Re-authentication is to avoid modification by others who can possibly use your phone.", nil);
        [whyDesc sizeToFit];
        CSLinearLayoutItem *item5 = [CSLinearLayoutItem layoutItemForView:whyDesc];
        item5.fillMode = CSLinearLayoutItemFillModeNormal;
        item5.hiddenType = CSLinearLayoutItemGone;
        item5.padding = CSLinearLayoutMakePadding(0, 15, 5, 15);
        [authLayout addItem:item5];
        self.whyDesc1 = whyDesc;
        
        UILabel * forgotTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 290, 50)];
        forgotTitle.backgroundColor = [UIColor clearColor];
        forgotTitle.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:21];
        forgotTitle.textColor = [UIColor COLOR_BLACK_19];
        forgotTitle.text = NSLocalizedString(@"Forgot password?", nil);
        [forgotTitle sizeToFit];
//        forgotTitle.tag = kTagForgetTitle;
        CSLinearLayoutItem *item6 = [CSLinearLayoutItem layoutItemForView:forgotTitle];
        item6.fillMode = CSLinearLayoutItemFillModeNormal;
        item6.padding = CSLinearLayoutMakePadding(0, 15, 0, 15);
        [authLayout addItem:item6];
        self.forgotTitle = forgotTitle;
        
        TTTAttributedLabel * forgotDetail = [[TTTAttributedLabel alloc] initWithFrame:CGRectMake(0, 0, 290, 50)];
        forgotDetail.backgroundColor = [UIColor clearColor];
        forgotDetail.numberOfLines = 0;
        forgotDetail.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:14];
        forgotDetail.textColor = [UIColor COLOR_BLACK_19];
        NSString *full = NSLocalizedString(@"To reset EXFE password, please authenticate with your identity.", nil);
        NSString *part = NSLocalizedString(@"EXFE", nil);
        [forgotDetail setText:full afterInheritingLabelAttributesAndConfiguringWithBlock:^NSMutableAttributedString *(NSMutableAttributedString *mutableAttributedString) {
            NSRange titleRange = [[mutableAttributedString string] rangeOfString:part options:NSCaseInsensitiveSearch];
            [mutableAttributedString addAttribute:(NSString*)kCTForegroundColorAttributeName value:(id)[[UIColor COLOR_BLUE_EXFE] CGColor] range:titleRange];
            return mutableAttributedString;
        }];
        [forgotDetail sizeToFit];
//        forgotDetail.tag = kTagForgetDesc;
        CSLinearLayoutItem *item7 = [CSLinearLayoutItem layoutItemForView:forgotDetail];
        item7.fillMode = CSLinearLayoutItemFillModeNormal;
        item7.padding = CSLinearLayoutMakePadding(0, 15, 10, 15);
        [authLayout addItem:item7];
        self.forgotDetail = forgotDetail;
        
        EFIdentityBar *identityBar = [[EFIdentityBar alloc] initWithFrame:CGRectMake(0, 0, 290, 50)];
        UITapGestureRecognizer *gesture = [UITapGestureRecognizer recognizerWithHandler:^(UIGestureRecognizer *sender, UIGestureRecognizerState state, CGPoint location) {
            if (state == UIGestureRecognizerStateEnded) {
                [self changeIdentity:sender.view];
            }
        }];
        identityBar.tag = kTagIdentityBar;
        [identityBar addGestureRecognizer:gesture];
        CSLinearLayoutItem *item8 = [CSLinearLayoutItem layoutItemForView:identityBar];
        item8.horizontalAlignment = CSLinearLayoutItemHorizontalAlignmentCenter;
        item8.fillMode = CSLinearLayoutItemFillModeNormal;
        item8.padding = CSLinearLayoutMakePadding(5, 15, 10, 15);
        [authLayout addItem:item8];
        self.identityBarFgt = identityBar;
        
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
        btnAuth.tag = kTagBtnAuthIdentity;
        CSLinearLayoutItem *item9 = [CSLinearLayoutItem layoutItemForView:btnAuth];
        item9.fillMode = CSLinearLayoutItemFillModeNormal;
        item9.padding = CSLinearLayoutMakePadding(0, 15, 5, 15);
        [authLayout addItem:item9];
        self.btnAuthIdentity = btnAuth;
        
        self.forgotTitle.hidden = YES;
        self.forgotDetail.hidden = YES;
        self.identityBarFgt.hidden = YES;
        self.btnAuthIdentity.hidden = YES;
    }
    [self.view addSubview:authLayout];
    self.authView = authLayout;
    
    CSLinearLayoutView * setpwdLayout = [[CSLinearLayoutView alloc] initWithFrame:CGRectMake(0, 44, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds) - 44)];
    {
        TTTAttributedLabel * labelHead = [[TTTAttributedLabel alloc] initWithFrame:CGRectMake(0, 0, 290, 100)];
        labelHead.backgroundColor = [UIColor clearColor];
        labelHead.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:14];
        labelHead.textColor = [UIColor COLOR_BLACK_19];
        labelHead.numberOfLines = 0;
        NSString *text = NSLocalizedString(@"You’re about to change import information of your account. For security concerns, please authenticate first and set your EXFE password.", nil);
        [labelHead setText:text afterInheritingLabelAttributesAndConfiguringWithBlock:^NSMutableAttributedString *(NSMutableAttributedString *mutableAttributedString) {
            NSString *highlight = NSLocalizedString(@"EXFE", nil);
            NSRange range = [[mutableAttributedString string] rangeOfString:highlight options:NSCaseInsensitiveSearch];
            
            [mutableAttributedString addAttribute:(NSString *)kCTForegroundColorAttributeName value:(id)[UIColor COLOR_BLUE_EXFE].CGColor range:range];
            
            return  mutableAttributedString;
        }];
        [labelHead sizeToFit];
        CSLinearLayoutItem *item11 = [CSLinearLayoutItem layoutItemForView:labelHead];
        item11.horizontalAlignment = CSLinearLayoutItemHorizontalAlignmentCenter;
        item11.fillMode = CSLinearLayoutItemFillModeNormal;
        item11.padding = CSLinearLayoutMakePadding(20, 15, 5, 15);
        [setpwdLayout addItem:item11];
        
        EFIdentityBar *identityBar = [[EFIdentityBar alloc] initWithFrame:CGRectMake(0, 0, 290, 50)];
        //    identityBar.backgroundColor = [UIColor blackColor];
        UITapGestureRecognizer *gesture = [UITapGestureRecognizer recognizerWithHandler:^(UIGestureRecognizer *sender, UIGestureRecognizerState state, CGPoint location) {
            if (state == UIGestureRecognizerStateEnded) {
                [self changeIdentity:sender.view];
            }
        }];
        identityBar.tag = kTagIdentityBar;
        [identityBar addGestureRecognizer:gesture];
        CSLinearLayoutItem *item12 = [CSLinearLayoutItem layoutItemForView:identityBar];
        item12.horizontalAlignment = CSLinearLayoutItemHorizontalAlignmentCenter;
        item12.fillMode = CSLinearLayoutItemFillModeNormal;
        item12.padding = CSLinearLayoutMakePadding(5, 15, 10, 15);
        [setpwdLayout addItem:item12];
        self.identitybarSet = identityBar;
        
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
        btnAuth.tag = kTagBtnAuthForSet;
        CSLinearLayoutItem *item13 = [CSLinearLayoutItem layoutItemForView:btnAuth];
        item13.fillMode = CSLinearLayoutItemFillModeNormal;
        item13.padding = CSLinearLayoutMakePadding(0, 15, 5, 15);
        [setpwdLayout addItem:item13];
        self.btnAuth = btnAuth;
        
        UILabel * whyTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 290, 40)];
        whyTitle.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:14];
        whyTitle.backgroundColor = [UIColor clearColor];
        whyTitle.textColor = [UIColor COLOR_BLACK_19];
        whyTitle.text = NSLocalizedString(@"Why I have to do this?", nil);
        [whyTitle sizeToFit];
        CSLinearLayoutItem *item14 = [CSLinearLayoutItem layoutItemForView:whyTitle];
        item14.fillMode = CSLinearLayoutItemFillModeNormal;
        item14.padding = CSLinearLayoutMakePadding(0, 15, 5, 15);
        [setpwdLayout addItem:item14];
        
        UILabel * whyDesc = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 290, MAXFLOAT)];
        whyDesc.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:10];
        whyDesc.backgroundColor = [UIColor clearColor];
        whyDesc.textColor = [UIColor COLOR_GRAY];
        whyDesc.numberOfLines = 0;
        whyDesc.text = NSLocalizedString(@"Sorry for the inconvenience. Sometimes, we have to compromise on experience for your account security. Re-authentication is to avoid modification by others who can possibly use your phone.", nil);
        [whyDesc sizeToFit];
        CSLinearLayoutItem *item15 = [CSLinearLayoutItem layoutItemForView:whyDesc];
        item15.fillMode = CSLinearLayoutItemFillModeNormal;
        item15.padding = CSLinearLayoutMakePadding(0, 15, 5, 15);
        [setpwdLayout addItem:item15];
    }
    [self.view addSubview:setpwdLayout];
    self.setpwdView = setpwdLayout;
    
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
    
    if ([self.user.password boolValue]) {
        self.authView.hidden = NO;
        self.setpwdView.hidden = YES;
        self.rootView = self.authView;
    } else {
        self.authView.hidden = YES;
        self.setpwdView.hidden = NO;
        self.rootView = self.setpwdView;
    }
    
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
    
//    [[NSNotificationCenter defaultCenter] removeObserver:self];
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
    
    EFIdentityBar *bar = nil;
    if ([self.user.password boolValue]) {
        bar = self.identityBarFgt;
    } else {
        bar = self.identitybarSet;
    }
    
    bar.identity = identity;
    
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
    
    CSLinearLayoutItem *baseitem = [self.rootView findItemByTag:kTagBtnAuthIdentity];
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

#pragma mark - Logic Methods
- (void)loadUserAndDismiss:(NSInteger)user_id withToken:(NSString*)token
{
    NSAssert(user_id == [self.user.user_id integerValue], @"Should be same user");
    
    self.model.userToken = token;
    
    [self dismissViewControllerAnimated:YES completion:^{
        if (self.nextStep) {
            self.nextStep();
        }
    }];
    
}

#pragma mark - UI Events

#pragma mark UIButton action
- (void)goBack:(UIControl*)sender
{
    [self dismissModalViewControllerAnimated:YES];
}

- (void)forgetPwd:(id)view
{
    if ([self.pwdTextField isFirstResponder]) {
        [self.pwdTextField resignFirstResponder];
    }
    
    if (!self.whyTitle1.hidden && !self.whyDesc1.hidden) {
        
        self.whyTitle1.hidden = YES;
        self.whyDesc1.hidden = YES;
        [self.authView setNeedsLayout];
        [self.authView layoutIfNeeded];
        
        self.whyTitle1.alpha = 1;
        self.whyDesc1.alpha = 1;
        self.whyTitle1.hidden = NO;
        self.whyDesc1.hidden = NO;
        [UIView animateWithDuration:0.4 animations:^{
            self.whyTitle1.alpha = 0;
            self.whyDesc1.alpha = 0;
        } completion:^(BOOL finished) {
            self.whyTitle1.hidden = YES;
            self.whyDesc1.hidden = YES;
        }];
    }
    
    if (self.forgotTitle.hidden && self.forgotDetail.hidden && self.identityBarFgt.hidden && self.btnAuthIdentity.hidden) {
        
        self.forgotTitle.alpha = 0;
        self.forgotDetail.alpha = 0;
        self.identityBarFgt.alpha = 0;
        self.btnAuthIdentity.alpha = 0;
//        self.inlineError.alpha = 0;
        
        self.forgotTitle.hidden = NO;
        self.forgotDetail.hidden = NO;
        self.identityBarFgt.hidden = NO;
        self.btnAuthIdentity.hidden = NO;
        [UIView animateWithDuration:0.4
                         animations:^{
                             self.forgotTitle.alpha = 1;
                             self.forgotDetail.alpha = 1;
                             self.identityBarFgt.alpha = 1;
                             self.btnAuthIdentity.alpha = 1;
//                             self.inlineError.alpha = 1;
                         } completion:^(BOOL finished) {
                             ;
                         }];
    }
    
    
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

- (void)authWithPwd:(UIControl *)sender
{
    if (self.trustIdentities.count == 0) {
        return;
    }
    
    if ([self.pwdTextField isFirstResponder]) {
        [self.pwdTextField resignFirstResponder];
    }
    
    Identity *identity = [self.trustIdentities objectAtIndex:0];
    Provider provider = [Identity getProviderCode:identity.provider];
    
    [self.model.apiServer signIn:identity.external_username with:provider password:self.currentPwd success:^(AFHTTPRequestOperation *operation, id responseObject) {
        sender.enabled = YES;
        [self hideIndicator];
        
        if ([operation.response statusCode] == 200 && [responseObject isKindOfClass:[NSDictionary class]]){
            NSNumber *code = [responseObject valueForKeyPath:@"meta.code"];
            if (code) {
                NSInteger c = [code integerValue];
                NSInteger t = c / 100;
                
                switch (t) {
                    case 2:{
                        NSNumber *u = [responseObject valueForKeyPath:@"response.user_id"];
                        NSString *t = [responseObject valueForKeyPath:@"response.token"];
                        
                        if ([u integerValue] == [self.user.user_id integerValue]) {
                            // refresh token
                            [self loadUserAndDismiss:[u integerValue] withToken:t];
                        } else {
                            // Merge user?
                            
                        }
                        
                        
                    }   break;
                    case 4:{
                        // response.body={"meta":{"code":403,"errorType":"failed","errorDetail":{"registration_flag":"SIGN_UP"}},"response":{}}
                        NSString *errorType = [responseObject valueForKeyPath:@"meta.errorType"];
                        if ([@"failed" isEqualToString:errorType]) {
                            NSString *registration_flag = [responseObject valueForKeyPath:@"meta.errorDetail.registration_flag"];
                            if ([@"SIGN_UP" isEqualToString:registration_flag]) {
                            } else if ([@"SIGN_IN" isEqualToString:registration_flag]){
                                [self showErrorInfo:NSLocalizedString(@"Authentication failed.", nil) dockOn:self.pwdTextField];
                                break;
                            } else if ([@"AUTHENTICATE" isEqualToString:registration_flag]){
                                
                            } else if ([@"VERIFY" isEqualToString:registration_flag]){
                            }
                        }
                    }   break;
                    default:
                        break;
                }
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error){
        sender.enabled = YES;
        [self hideIndicator];
        
        if ([@"NSURLErrorDomain" isEqualToString:error.domain]) {
            switch (error.code) {
                case NSURLErrorTimedOut: //-1001
                case NSURLErrorCannotFindHost: //-1003
                case NSURLErrorCannotConnectToHost: //-1004
                case NSURLErrorNetworkConnectionLost: //-1005
                case NSURLErrorDNSLookupFailed: //-1006
                case NSURLErrorHTTPTooManyRedirects: //-1007
                case NSURLErrorResourceUnavailable: //-1008
                case NSURLErrorNotConnectedToInternet: //-1009
                case NSURLErrorRedirectToNonExistentLocation: //-1010
                case NSURLErrorServerCertificateUntrusted: //-1202
                    [Util showConnectError:error delegate:nil];
                    //                    [self showInlineError:@"Failed to connect server." with:@"Please retry or wait awhile."];
                    break;
                    
                default:
                    break;
            }
        }
    }];
}

- (void)authenticate:(UIControl*)sender
{
    _inlineError.hidden = YES;
    
    Provider provider = [Identity getProviderCode:self.identity.provider];
    if (provider == kProviderTwitter) {
        [self twitterAuth:self.identity success:^(NSNumber *user_id, NSString *token) {
            if ([user_id integerValue] == self.model.userId) {
                
                
            } else {
                // TODO: merge
//                    [self mergeUser:u with:t];
            };
        } failure:nil];
    }
    
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
                                                                     oauth.onSuccess = ^(NSDictionary * params){
                                                                         NSString *userid = [params valueForKey:@"userid"];
                                                                         
                                                                         if ([userid integerValue] == self.model.userId) {
                                                                             // use refresh token
                                                                             NSString *token = [params valueForKey:@"token"];
                                                                             self.model.userToken = token;
                                                                             [self.model saveUserData];
                                                                             
                                                                             [self setPasswordWithErrorMessage:nil];
                                                                         } else {
                                                                             // TODO: Merge User
                                                                         }
                                                                     };
                                                                     oauth.oAuthURL = url;
                                                                     oauth.external_username = [identity valueForKey:@"external_username"];
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

#pragma mark UITextFieldDelegate
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    switch (textField.tag) {
        case kTagPassword:{
            if (self.whyTitle1.hidden && self.whyDesc1.hidden) {
                self.whyTitle1.alpha = 0;
                self.whyDesc1.alpha = 0;
                self.whyTitle1.hidden = NO;
                self.whyDesc1.hidden = NO;
                [UIView animateWithDuration:0.4 animations:^{
                    self.whyTitle1.alpha = 1;
                    self.whyDesc1.alpha = 1;
                } completion:^(BOOL finished) {
                    [self.authView setNeedsLayout];
                    [self.authView layoutIfNeeded];
                }];
            }
            
            if (!self.forgotTitle.hidden && !self.forgotDetail.hidden && !self.identityBarFgt.hidden && !self.btnAuthIdentity.hidden) {
                self.forgotTitle.alpha = 1;
                self.forgotDetail.alpha = 1;
                self.identityBarFgt.alpha = 1;
                self.btnAuthIdentity.alpha = 1;
                
                [UIView animateWithDuration:0.4 animations:^{
                    self.forgotTitle.alpha = 0;
                    self.forgotDetail.alpha = 0;
                    self.identityBarFgt.alpha = 0;
                    self.btnAuthIdentity.alpha = 0;
                } completion:^(BOOL finished) {
                    self.forgotTitle.hidden = YES;
                    self.forgotDetail.hidden = YES;
                    self.identityBarFgt.hidden = YES;
                    self.btnAuthIdentity.hidden = YES;
                }];
            }
        }   break;
            
        default:
            break;
    }
    
    
    
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    switch (textField.tag) {
        case kTagPassword:
            self.currentPwd = textField.text;
            break;
            
        default:
            break;
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    return NO;
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



#pragma mark - temp

- (void)mergeUser:(NSNumber *)newUserId with:(NSString*)newToken
{
    // Load identities to merge from another user
    [self.model.apiServer loadUserBy:[newUserId integerValue]
             withToken:newToken
               success:^(AFHTTPRequestOperation *operation, id responseObject) {
                   NSDictionary *body = responseObject;
                   if([body isKindOfClass:[NSDictionary class]]) {
                       NSNumber *code = [responseObject valueForKeyPath:@"meta.code"];
                       if(code){
                           if([code integerValue] == 200) {
                               NSString *name = [responseObject valueForKeyPath:@"response.user.name"];
                               NSArray *ids = [responseObject valueForKeyPath:@"response.user.identities.@distinctUnionOfObjects.id"];
                               
                               [UIAlertView showAlertViewWithTitle:@"Merge accounts"
                                                           message:[NSString stringWithFormat:@"Merge account %@ into your current signed-in account?", name]
                                                 cancelButtonTitle:@"Cancel"
                                                 otherButtonTitles:@[@"Merge"]
                                                           handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
                                                               if (buttonIndex == alertView.firstOtherButtonIndex ) {
                                                                   
                                                                   [self.model.apiServer mergeIdentities:ids byToken:newToken success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                                                       if ([operation.response statusCode] == 200 && [responseObject isKindOfClass:[NSDictionary class]]){
                                                                           NSDictionary *body=responseObject;
                                                                           if ([body isKindOfClass:[NSDictionary class]]) {
                                                                               id code = [[body objectForKey:@"meta"] objectForKey:@"code"];
                                                                               if (code && [code intValue] == 200) {
                                                                                   [self.model loadMe];
                                                                                   // clean some timestamp
                                                                                   
                                                                                   // do following things
                                                                               }
                                                                           }
                                                                       }
                                                                   } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                                       
                                                                   }];
                                                               }
                                                           }];
                           }
                       }
                   }
                   
               }
               failure:nil];
    
}

- (void)reverseAuth:(Provider)provider WithToken:(NSString *)token withParams:(NSDictionary *)params success:(void (^)(NSNumber *user_id, NSString *token))success failure:(void (^)(void))failure
{
    [self.model.apiServer reverseAuth:kProviderTwitter withToken:token andParam:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        if ([operation.response statusCode] == 200 && [responseObject isKindOfClass:[NSDictionary class]]){
            
            NSNumber *code = [responseObject valueForKeyPath:@"meta.code"];
            if ([code integerValue] == 200) {
                NSNumber *u = [responseObject valueForKeyPath:@"response.user_id"];
                NSString *t = [responseObject valueForKeyPath:@"response.token"];
                
                if (success) {
                    success(u, t);
                }
                
            }
            //400: invalid_token
            //400: no_provider
            //400: unsupported_provider
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        if ([@"NSURLErrorDomain" isEqualToString:error.domain]) {
            switch (error.code) {
                case NSURLErrorTimedOut: // -1001
                case NSURLErrorCannotFindHost: //-1003
                case NSURLErrorCannotConnectToHost: //-1004
                case NSURLErrorNetworkConnectionLost: //-1005
                case NSURLErrorDNSLookupFailed: //-1006
                case NSURLErrorHTTPTooManyRedirects: //-1007
                case NSURLErrorResourceUnavailable: //-1008
                case NSURLErrorNotConnectedToInternet: //-1009
                case NSURLErrorRedirectToNonExistentLocation: //-1010
                case NSURLErrorServerCertificateUntrusted: //-1202
                    [Util showConnectError:error delegate:nil];
                    //                            [self showInlineError:@"Failed to connect server." with:@"Please retry or wait awhile."];
                    break;
                    
                default:
                    break;
            }
        }
    }];
}

// step 1 try to auth twtiter from phone
- (void)twitterAuth:(Identity *)identity success:(void (^)(NSNumber *user_id, NSString *token))success failure:(void (^)(void))failure
{
    Provider provider = [Identity getProviderCode:identity.provider];
    NSAssert(kProviderTwitter == provider, @"Entry for twitter only");
    
    [self syncTwitterAccounts:^(NSArray *accounts) {
        BOOL webauth = YES;
        
        if ([TWAPIManager isLocalTwitterAccountAvailable]) {
            ACAccount *account = nil;
            for (ACAccount *acct in _accounts) {
                if ([acct.username isEqualToString: identity.external_username]) {
                    account = acct;
                }
            }
            
            if (account) {
                // reverse auth
                webauth = NO;
                [_apiManager performReverseAuthForAccount:account withHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
                    if (!error) {
                        NSString *responseStr = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
                        NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:[Util splitQuery:responseStr]];
                        NSString *token = [params valueForKey:@"oauth_token"];
                        [params removeObjectForKey:@"oauth_token"];
                        [self reverseAuth:kProviderTwitter WithToken:token withParams:params success:success failure:failure];
                    } else {
                        [MBProgressHUD hideHUDForView:self.view animated:YES];
                        if ([@"NSURLErrorDomain" isEqualToString:error.domain]) {
                            switch (error.code) {
                                case NSURLErrorTimedOut: // -1001
                                case NSURLErrorCannotFindHost: //-1003
                                case NSURLErrorCannotConnectToHost: //-1004
                                case NSURLErrorNetworkConnectionLost: //-1005
                                case NSURLErrorDNSLookupFailed: //-1006
                                case NSURLErrorHTTPTooManyRedirects: //-1007
                                case NSURLErrorResourceUnavailable: //-1008
                                case NSURLErrorNotConnectedToInternet: //-1009
                                case NSURLErrorRedirectToNonExistentLocation: //-1010
                                case NSURLErrorServerCertificateUntrusted: //-1202
                                    [Util showConnectError:error delegate:nil];
                                    //                        [self showInlineError:@"Failed to connect twitter server." with:@"Please retry or wait awhile."];
                                    break;
                                case NSURLErrorUserCancelledAuthentication:
                                    [self showInlineError:NSLocalizedString(@"Authorization failed.", nil) with:NSLocalizedString(@"Please check your network connection and account setting in Settings app.", nil)];
                                    break;
                                default:
                                    break;
                            }
                        }
                        
                    }
                }];
            }
        }
     
        if (webauth) {
            // auth web
            OAuthLoginViewController *oauth = [[OAuthLoginViewController alloc] initWithNibName:@"OAuthLoginViewController" bundle:nil];
            oauth.provider = provider;
            oauth.onSuccess = ^(NSDictionary * params){
                NSString *user_id = [params valueForKey:@"userid"];
                NSNumber *userid = [NSNumber numberWithInteger:[user_id integerValue]];
                NSString *token = [params valueForKey:@"token"];
                if (success) {
                    success(userid, token);
                }
            };
            AppDelegate *app = (AppDelegate *)[UIApplication sharedApplication].delegate;
            // eg:  exfe://oauthcallback/
            NSString *callback = [NSString stringWithFormat: @"%@://oauthcallback/", app.defaultScheme];
            oauth.oAuthURL = [NSString stringWithFormat:@"%@/Authenticate?device=iOS&device_callback=%@&provider=%@", EXFE_OAUTH_LINK, [Util EFPercentEscapedQueryStringPairMemberFromString:callback], [Util EFPercentEscapedQueryStringPairMemberFromString:[Identity getProviderString:provider]]];
            oauth.external_username = [identity valueForKey:@"external_username"];
            [self presentModalViewController:oauth animated:YES];
        }
    }];
}

- (void)syncTwitterAccounts:(TwitterAccountsHandler)block
{
    ACAccountType *twitterType = [_accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    
    ACAccountStoreRequestAccessCompletionHandler handler = ^(BOOL granted, NSError *error) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (granted) {
                self.accounts = [_accountStore accountsWithAccountType:twitterType];
                if ([TWAPIManager isLocalTwitterAccountAvailable] && _accounts.count > 0) {
                    if (block) {
                        block(_accounts);
                    }
                } else {
                    
                    //http://stackoverflow.com/questions/13335795/login-user-with-twitter-in-ios-what-to-use
                    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"6.0")) {
                        // iOS 6 http://stackoverflow.com/questions/13946062/twitter-framework-for-ios6-how-to-login-through-settings-from-app
                        SLComposeViewController *tweetSheet = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
                        tweetSheet.view.hidden = TRUE;
                        
                        [self presentViewController:tweetSheet animated:NO completion:^{
                            [tweetSheet.view endEditing:YES];
                        }];
                    } else if(SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"5.1")){
                        // iOS 5 http://stackoverflow.com/questions/9667921/prompt-login-alert-with-twitter-framework-in-ios5
                        TWTweetComposeViewController *viewController = [[TWTweetComposeViewController alloc] init];
                        //hide the tweet screen
                        viewController.view.hidden = YES;
                        
                        //fire tweetComposeView to show "No Twitter Accounts" alert view on iOS5.1
                        viewController.completionHandler = ^(TWTweetComposeViewControllerResult result) {
                            if (result == TWTweetComposeViewControllerResultCancelled) {
                                [self dismissModalViewControllerAnimated:NO];
                            }
                        };
                        [self presentModalViewController:viewController animated:NO];
                        
                        //hide the keyboard
                        [viewController.view endEditing:YES];
                    } else {
                        return;
                    }
                    //                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No Accounts" message:@"Please configure a Twitter account in Settings.app" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    //                    [alert show];
                }
            } else {
                
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Set up Twitter account", nil) message:NSLocalizedString(@"Please allow EXFE to use your Twitter account. Go to the Settings app, select Twitter to set up.", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
                [alert show];
                
            }
        });
    };
    
    if(SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"5.1")){
        //  This method changed in iOS6. If the new version isn't available, fall back to the original (which means that we're running on iOS5+).
        if ([_accountStore respondsToSelector:@selector(requestAccessToAccountsWithType:options:completion:)]) {
            [_accountStore requestAccessToAccountsWithType:twitterType options:nil completion:handler];
        }
        else {
            [_accountStore requestAccessToAccountsWithType:twitterType withCompletionHandler:handler];
        }
    }
}
@end
