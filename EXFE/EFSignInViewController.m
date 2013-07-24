//
//  EFSignInViewController.m
//  EXFE
//
//  Created by Stony Wang on 13-4-15.
//
//

#import "EFSignInViewController.h"
#import <BlocksKit/BlocksKit.h>
#import <QuartzCore/QuartzCore.h>
#import <CoreText/CoreText.h>
#import <Social/Social.h>
#import <Twitter/Twitter.h>
#import <Accounts/Accounts.h>
#import <FacebookSDK/FacebookSDK.h>
#import "EFAPIServer.h"
#import "Util.h"
#import "Identity+EXFE.h"
#import "CSLinearLayoutView.h"
#import "UILabel+EXFE.h"
#import "EFIdentityTextField.h"
#import "TWAPIManager.h"
#import "EFKit.h"
#import "EFModel.h"
#import "OAuthLoginViewController.h"

typedef NS_ENUM(NSUInteger, EFStage){
    kStageStart,
    kStageSignIn,
    kStageSignUp,
    kStageVerificate
};

typedef NS_ENUM(NSUInteger, EFViewTag) {
    kViewTagNone,
    kViewTagInputIdentity = 11,
    kViewTagInputPassword = 12,
    kViewTagInputUserName = 13,
    kViewTagButtonStart = 21,
    kViewTagButtonNewUser = 22,
    kViewTagButtonStartOver = 23,
    kViewTagVerificationTitle = 31,
    kViewTagVerificationDescription = 32,
    kViewTagErrorHint = 41,
    kViewTagErrorInline = 42,
    kViewTagSnsGroup = 51,
    kViewTagSnsFacebook = 52,
    kViewTagSnsTwitter = 53
};

@interface EFSignInViewController (){

    EFStage _stage;
   
}
@property (nonatomic, copy) NSString *lastInputIdentity;
@property (nonatomic, strong) UIImageView *line1;
@property (nonatomic, strong) UIImageView *line2;

@property (nonatomic, strong) ACAccountStore *accountStore;
@property (nonatomic, strong) TWAPIManager *apiManager;
@property (nonatomic, strong) NSArray *accounts;

@end

@implementation EFSignInViewController


#pragma mark -
#pragma mark UIViewController lifecycle
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _stage = kStageStart;
        self.lastInputIdentity = @"";
        self.identityCache = [NSMutableDictionary dictionaryWithCapacity:30];
        
        _accountStore = [[ACAccountStore alloc] init];
        _apiManager = [[TWAPIManager alloc] init];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    CGRect appFrame = [[UIScreen mainScreen] applicationFrame];
    [self.view setFrame:CGRectMake(0, 50, appFrame.size.width, appFrame.size.height - 50)];
    
    self.view.backgroundColor = [UIColor COLOR_SNOW];
    
    // create the linear layout view
    CSLinearLayoutView *linearLayoutView = [[CSLinearLayoutView alloc] initWithFrame:self.view.bounds];
    linearLayoutView.orientation = CSLinearLayoutViewOrientationVertical;
//    linearLayoutView.alwaysBounceVertical = YES;
    linearLayoutView.bounces = NO;
    linearLayoutView.delegate = self;
    self.rootView = linearLayoutView;
    [self.view addSubview:linearLayoutView];
    
    UISwipeGestureRecognizer * swipeRightRecognizer = [UISwipeGestureRecognizer recognizerWithHandler:^(UIGestureRecognizer *sender, UIGestureRecognizerState state, CGPoint location) {
            if ([sender.view isKindOfClass:[UIScrollView class]]){
//                UIScrollView * scrollView = (UIScrollView *)sender.view;
                    if ([self.parentViewController respondsToSelector:@selector(hideStart)]) {
                        [self.parentViewController performSelector:@selector(hideStart)];
                    }
            }
    }];
    swipeRightRecognizer.direction = UISwipeGestureRecognizerDirectionDown;
    [linearLayoutView addGestureRecognizer:swipeRightRecognizer];
    
    {// TextField Frame
        UIImage *img = [[UIImage imageNamed:@"textfield.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(15, 9, 15, 9)];
        UIImageView *imageView = [[UIImageView alloc] initWithImage:img];
        imageView.frame = CGRectMake(15, 20, 290, 50);
        self.textFieldFrame = imageView;
        [self.rootView addSubview:self.textFieldFrame];
    }
    
    {
        UIImage *img = [UIImage imageNamed:@"list_divider.png"];
        self.line1 = [[UIImageView alloc] initWithFrame:CGRectMake(15, 70, 290, 1)];
        self.line2 = [[UIImageView alloc] initWithFrame:CGRectMake(15, 120, 290, 1)];
        self.line1.image = img;
        self.line2.image = img;
        [self.rootView addSubview:self.line1];
        [self.rootView addSubview:self.line2];
    }
    
    {// Input Identity Field
        UITextField *textfield = [[EFIdentityTextField alloc] initWithFrame:CGRectMake(0, 0, 290, 50)];
        textfield.placeholder = NSLocalizedString(@"Enter email or phone", nil);
        textfield.borderStyle = UITextBorderStyleNone;
        textfield.autocapitalizationType = UITextAutocapitalizationTypeNone;
        textfield.keyboardType = UIKeyboardTypeEmailAddress;
        textfield.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:18];
        textfield.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        textfield.delegate = self;
        [textfield addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
        self.inputIdentity = textfield;
        self.inputIdentity.tag = kViewTagInputIdentity;
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
        imageView.layer.cornerRadius = 1.0;
        imageView.layer.masksToBounds = YES;
        imageView.image = nil;
        imageView.contentMode = UIViewContentModeCenter;
        self.imageIdentity = imageView;
        self.inputIdentity.leftView = self.imageIdentity;
        self.inputIdentity.leftViewMode = UITextFieldViewModeAlways;
        
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
        button.backgroundColor = [UIColor clearColor];
        [button addTarget:self action:@selector(expandIdentity:) forControlEvents:UIControlEventTouchUpInside];
        [button setImage:[UIImage imageNamed:@"start_tri-00.png"] forState:UIControlStateNormal];
        NSMutableArray *imgs = [NSMutableArray arrayWithCapacity:30];
        for (NSUInteger i = 0; i < 30; i++) {
            NSString *name = [NSString stringWithFormat:@"start_tri-%02u.png", i];
            [imgs addObject:[UIImage imageNamed:name]];
        }
        button.imageView.animationImages = imgs;
        button.imageView.animationRepeatCount = 0;
        button.imageView.animationDuration = 1.5;
        [button.imageView startAnimating];
        button.contentMode = UIViewContentModeScaleAspectFill;
        self.extIdentity = button;
        self.inputIdentity.rightView = self.extIdentity;
        self.inputIdentity.rightViewMode = UITextFieldViewModeAlways;
        
        CSLinearLayoutItem *item = [CSLinearLayoutItem layoutItemForView:self.inputIdentity];
        item.padding = CSLinearLayoutMakePadding(20.0, 15, 0, 15);
        item.horizontalAlignment = CSLinearLayoutItemHorizontalAlignmentCenter;
        item.fillMode = CSLinearLayoutItemFillModeNormal;
        [linearLayoutView addItem:item];
    }
    
    {// Input Password Field
        EFPasswordField *textfield = [[EFPasswordField alloc] initWithFrame:CGRectMake(0, 0, 290, 50)];
        textfield.borderStyle = UITextBorderStyleNone;
        textfield.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        textfield.font = [UIFont fontWithName:@"HelveticaNeue-Lignt" size:18];
        textfield.delegate = self;
        [textfield addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
        [textfield.btnForgot addTarget:self action:@selector(forgetPwd:) forControlEvents:UIControlEventTouchUpInside];
        
        self.inputPassword = textfield;
        self.inputPassword.tag = kViewTagInputPassword;
    }
    
    {// Input Username
        UITextField *textfield = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 290, 50)];
        textfield.borderStyle = UITextBorderStyleNone;
        textfield.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        textfield.font = [UIFont fontWithName:@"HelveticaNeue-Lignt" size:18];
        textfield.delegate = self;
        [textfield addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
        textfield.placeholder = NSLocalizedString(@"Set display name", nil);
        UIView *stub = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 55, 40)];
        textfield.leftView = stub;
        textfield.leftViewMode = UITextFieldViewModeAlways;
        UIView *stub2 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
        textfield.rightView = stub2;
        textfield.rightViewMode = UITextFieldViewModeAlways;
        self.inputUsername = textfield;
        self.inputUsername.tag = kViewTagInputUserName;
    }
    
    {// Start button
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(0, 0, 290, 48);
        [btn setTitle:NSLocalizedString(@"Start", nil) forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [btn setTitleShadowColor:[UIColor COLOR_WA(0x00, 0x7F)] forState:UIControlStateNormal];
        btn.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:18];
        btn.titleLabel.shadowOffset = CGSizeMake(0, -1);
        [btn addTarget:self action:@selector(signIn:) forControlEvents:UIControlEventTouchUpInside];
        UIImage *btnImage = [UIImage imageNamed:@"btn_blue_44.png"];
        btnImage = [btnImage resizableImageWithCapInsets:(UIEdgeInsets){15, 10, 15, 10}];
        [btn setBackgroundImage:btnImage forState:UIControlStateNormal];
        self.btnStart = btn;
        self.btnStart.tag = kViewTagButtonStart;
    }
    
    {// Start with new account
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(0, 0, 290, 48);
        [btn setTitle:NSLocalizedString(@"Start with new account", nil) forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [btn setTitleShadowColor:[UIColor COLOR_WA(0x00, 0x7F)] forState:UIControlStateNormal];
        btn.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:18];
        btn.titleLabel.shadowOffset = CGSizeMake(0, -1);
        [btn addTarget:self action:@selector(signUp:) forControlEvents:UIControlEventTouchUpInside];
        UIImage *btnImage = [UIImage imageNamed:@"btn_blue_44.png"];
        btnImage = [btnImage resizableImageWithCapInsets:(UIEdgeInsets){15, 10, 15, 10}];
        [btn setBackgroundImage:btnImage forState:UIControlStateNormal];
        self.btnStartNewUser = btn;
        self.btnStartNewUser.tag = kViewTagButtonNewUser;
    }
    
    {// Start over
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(0, 0, 290, 48);
        [btn setTitle:NSLocalizedString(@"Start over", nil) forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [btn setTitleShadowColor:[UIColor whiteColor] forState:UIControlStateNormal];
        btn.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:18];
        btn.titleLabel.shadowOffset = CGSizeMake(0, 1);
        [btn addTarget:self action:@selector(startOver:) forControlEvents:UIControlEventTouchUpInside];
        UIImage *btnImage = [UIImage imageNamed:@"btn_white_44.png"];
        btnImage = [btnImage resizableImageWithCapInsets:(UIEdgeInsets){15, 10, 15, 10}];
        [btn setBackgroundImage:btnImage forState:UIControlStateNormal];
        self.btnStartOver = btn;
        self.btnStartOver.tag = kViewTagButtonNewUser;
    }
    
    {// Verification Title
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 280, 40)];
        label.text = NSLocalizedString(@"Verification", nil);
        label.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:21.0];
        label.backgroundColor = [UIColor clearColor];
        [label wrapContent];
        self.labelVerifyTitle = label;
        self.labelVerifyTitle.tag = kViewTagVerificationTitle;
    }
    
    {// Verification Description
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 280, 80)];
        label.text = NSLocalizedString(@"This number requires verification before proceeding. Verification request is sent, please check your message for instructions.", nil);
        label.numberOfLines = 0;
        label.backgroundColor = [UIColor clearColor];
        label.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:14.0];
        [label wrapContent];
        label.lineBreakMode = UILineBreakModeWordWrap;
        self.labelVerifyDescription = label;
        self.labelVerifyDescription.tag = kViewTagVerificationDescription;
    }
    
    {// Overlay error hint
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 46)];
        label.textColor = [UIColor COLOR_RED_EXFE];
        label.font = [UIFont fontWithName:@"HelveticaNeue" size:18.0];
        label.backgroundColor = [UIColor clearColor];
        label.numberOfLines = 1;
        label.backgroundColor = [UIColor whiteColor];
        label.hidden = YES;
        label.textAlignment = UITextAlignmentRight;
        UITapGestureRecognizer *tap = [UITapGestureRecognizer recognizerWithHandler:^(UIGestureRecognizer *sender, UIGestureRecognizerState state, CGPoint location) {
            
            [self hide:sender.view withAnmated:NO];
            CGPoint p = [sender.view convertPoint:location toView:self.inputIdentity.superview];
            if (CGRectContainsPoint(self.inputIdentity.frame, p)) {
                [self.inputIdentity becomeFirstResponder];
                return;
            }
            if (CGRectContainsPoint(self.inputPassword.frame, p)) {
                [self.inputPassword becomeFirstResponder];
                return;
            }
            if (CGRectContainsPoint(self.inputUsername.frame, p)) {
                [self.inputUsername becomeFirstResponder];
                return;
            }
        }];
        [label addGestureRecognizer:tap];
        label.userInteractionEnabled = true;
        self.hintError = label;
    }
    
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
    
    CSLinearLayoutView *snsLayoutView = [[CSLinearLayoutView alloc] initWithFrame:CGRectMake(0, 0, 296, 106)];
    snsLayoutView.tag = kViewTagSnsGroup;
    snsLayoutView.orientation = CSLinearLayoutViewOrientationHorizontal;
    
    UIEdgeInsets insets = UIEdgeInsetsMake(6, 6, 6, 6);
    UIImage *image = [UIImage imageNamed:@"table.png"];
    UIImageView *background = [[UIImageView alloc] initWithFrame:snsLayoutView.bounds];
    background.image = [image resizableImageWithCapInsets:insets];
    [snsLayoutView addSubview:background];
    
    CSLinearLayoutItem *snsItem = [CSLinearLayoutItem layoutItemForView:snsLayoutView];
    snsItem.padding = CSLinearLayoutMakePadding(27, 12, 240, 12);
    snsItem.horizontalAlignment = CSLinearLayoutItemHorizontalAlignmentCenter;
    snsItem.fillMode = CSLinearLayoutItemFillModeNormal;
    [linearLayoutView addItem:snsItem];
    
    {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(0, 0, 70, 70);
        button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
        [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [button setTitle:NSLocalizedString(@"Facebook", nil) forState:UIControlStateNormal];
        button.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:14.0];
        UIImage *image = [UIImage imageNamed:@"identity_facebook_50btn.png"];
        [button setImage:image forState:UIControlStateNormal];
        
        //http://stackoverflow.com/questions/2451223/uibutton-how-to-center-an-image-and-a-text-using-imageedgeinsets-and-titleedgei
        CGFloat spacing = 4.0;
        CGSize imageSize = button.imageView.frame.size;
        CGSize titleSize = button.titleLabel.frame.size;
        button.titleEdgeInsets = UIEdgeInsetsMake(0.0, - imageSize.width, - (imageSize.height + spacing), 0.0);
        titleSize = button.titleLabel.frame.size;
        button.imageEdgeInsets = UIEdgeInsetsMake(- (titleSize.height + spacing), 0.0, 0.0, - titleSize.width);
        [button addTarget:self action:@selector(facebookSignIn:) forControlEvents:UIControlEventTouchUpInside];
        self.btnFacebook = button;
        self.btnFacebook.tag = kViewTagSnsFacebook;
        
        CSLinearLayoutItem *item = [CSLinearLayoutItem layoutItemForView:self.btnFacebook];
        item.padding = CSLinearLayoutMakePadding(21, 58, 0, 20);
        item.horizontalAlignment = CSLinearLayoutItemHorizontalAlignmentCenter;
        item.fillMode = CSLinearLayoutItemFillModeNormal;
        [snsLayoutView addItem:item];
        
    }
    
    {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(0, 0, 70, 70);
        button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
        [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [button setTitle:NSLocalizedString(@"Twitter", nil) forState:UIControlStateNormal];
        button.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:14.0];
        UIImage *image = [UIImage imageNamed:@"identity_twitter_50btn.png"];
        [button setImage:image forState:UIControlStateNormal];
        
        CGFloat spacing = 4.0;
        CGSize imageSize = button.imageView.frame.size;
        CGSize titleSize = button.titleLabel.frame.size;
        button.titleEdgeInsets = UIEdgeInsetsMake(0.0, - imageSize.width, - (imageSize.height + spacing), 0.0);
        titleSize = button.titleLabel.frame.size;
        button.imageEdgeInsets = UIEdgeInsetsMake(- (titleSize.height + spacing), 0.0, 0.0, - titleSize.width);
        [button addTarget:self action:@selector(twitterSignIn:) forControlEvents:UIControlEventTouchUpInside];
        self.btnTwitter = button;
        self.btnTwitter.tag = kViewTagSnsTwitter;
        
        CSLinearLayoutItem *item = [CSLinearLayoutItem layoutItemForView:self.btnTwitter];
        item.padding = CSLinearLayoutMakePadding(21, 20, 0, 0);
        item.horizontalAlignment = CSLinearLayoutItemHorizontalAlignmentCenter;
        item.fillMode = CSLinearLayoutItemFillModeNormal;
        [snsLayoutView addItem:item];
    }
    
    {
        UIActivityIndicatorView *aiView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        aiView.frame = (CGRect){{0, 0}, {20, 20}};
        self.indicator = aiView;
    }
    
    [self setStage:kStageStart];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
//    CGRect appFrame = [[UIScreen mainScreen] applicationFrame];

    [self performBlock:^(id sender) {
        [_inputIdentity becomeFirstResponder];
    } afterDelay:0.233];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
}

#pragma mark - UI Methods
- (void)setStage:(EFStage)stage
{
    _stage = stage;
    switch (_stage){
        case kStageStart:
            [self.rootView removeItem:[self.rootView findItemByTag:kViewTagInputPassword]];
            [self.rootView removeItem:[self.rootView findItemByTag:kViewTagInputUserName]];
            [self.rootView removeItem:[self.rootView findItemByTag:kViewTagButtonStart]];
            [self.rootView removeItem:[self.rootView findItemByTag:kViewTagButtonNewUser]];
            [self.rootView removeItem:[self.rootView findItemByTag:kViewTagButtonStartOver]];
            [self.rootView removeItem:[self.rootView findItemByTag:kViewTagVerificationTitle]];
            [self.rootView removeItem:[self.rootView findItemByTag:kViewTagVerificationDescription]];
            [self.rootView removeItem:[self.rootView findItemByTag:kViewTagErrorHint]];
            [self.rootView removeItem:[self.rootView findItemByTag:_inlineError.tag]];
            _line1.hidden = YES;
            _line2.hidden = YES;
            _textFieldFrame.frame = CGRectMake(15, 20, 290, 50);
            _inputIdentity.rightView = _extIdentity;
            _inputIdentity.returnKeyType = UIReturnKeyNext;
            _inputPassword.text = @"";
            [self textFieldDidChange:_inputPassword];
            _inputUsername.text = @"";
            [self textFieldDidChange:_inputUsername];
            [_inputIdentity becomeFirstResponder];
            break;
        case kStageSignIn:{
            // show rest login form
            [self.rootView removeItem:[self.rootView findItemByTag:kViewTagInputUserName]];
            [self.rootView removeItem:[self.rootView findItemByTag:kViewTagButtonNewUser]];
            [self.rootView removeItem:[self.rootView findItemByTag:kViewTagButtonStartOver]];
            [self.rootView removeItem:[self.rootView findItemByTag:kViewTagVerificationTitle]];
            [self.rootView removeItem:[self.rootView findItemByTag:kViewTagVerificationDescription]];
            [self.rootView removeItem:[self.rootView findItemByTag:kViewTagErrorHint]];
            [self.rootView removeItem:[self.rootView findItemByTag:_inlineError.tag]];
            
            CSLinearLayoutItem *baseItem = [self.rootView findItemByTag:_inputIdentity.tag];
            
            CSLinearLayoutItem *item1 = [self.rootView findItemByTag:_inputPassword.tag];
            if (item1 == nil) {
                item1 = [CSLinearLayoutItem layoutItemForView:self.inputPassword];
                item1.horizontalAlignment = CSLinearLayoutItemHorizontalAlignmentCenter;
                item1.fillMode = CSLinearLayoutItemFillModeNormal;
                [self.rootView insertItem:item1 afterItem:baseItem];
            } else {
                [self.rootView moveItem:item1 afterItem:baseItem];
            }
            item1.padding = CSLinearLayoutMakePadding(0, 15, 4, 15);
            
            CSLinearLayoutItem *item2 = [self.rootView findItemByTag:_btnStart.tag];
            if (item2 == nil){
                item2 = [CSLinearLayoutItem layoutItemForView:self.btnStart];
                item2.horizontalAlignment = CSLinearLayoutItemHorizontalAlignmentCenter;
                item2.fillMode = CSLinearLayoutItemFillModeNormal;
                [self.rootView insertItem:item2 afterItem:item1];
            } else {
                [self.rootView moveItem:item2 afterItem:item1];
            }
            item2.padding = CSLinearLayoutMakePadding(6, 15, 0, 15);
            
            _line1.hidden = NO;
            _line2.hidden = YES;
            _textFieldFrame.frame = CGRectMake(15, 20, 290, 100);
            _inputIdentity.returnKeyType = UIReturnKeyNext;
            _inputPassword.placeholder = NSLocalizedString(@"Enter password", nil);
            _inputPassword.returnKeyType = UIReturnKeyDone;
            _inputPassword.btnForgot.hidden = NO;
            [_inputPassword becomeFirstResponder];
            _inputUsername.text = @"";
            [self textFieldDidChange:_inputUsername];
            _inputIdentity.rightView = nil;
            _inputIdentity.clearButtonMode = UITextFieldViewModeAlways;
        }    break;
        case kStageSignUp:{
            [self.rootView removeItem:[self.rootView findItemByTag:kViewTagButtonStart]];
            [self.rootView removeItem:[self.rootView findItemByTag:kViewTagButtonStartOver]];
            [self.rootView removeItem:[self.rootView findItemByTag:kViewTagVerificationTitle]];
            [self.rootView removeItem:[self.rootView findItemByTag:kViewTagVerificationDescription]];
            [self.rootView removeItem:[self.rootView findItemByTag:kViewTagErrorHint]];
            [self.rootView removeItem:[self.rootView findItemByTag:_inlineError.tag]];
           
            CSLinearLayoutItem *baseItem = [self.rootView findItemByTag:_inputIdentity.tag];
            
            CSLinearLayoutItem *item1 = [self.rootView findItemByTag:_inputPassword.tag];
            if (item1 == nil) {
                item1 = [CSLinearLayoutItem layoutItemForView:_inputPassword];
                item1.horizontalAlignment = CSLinearLayoutItemHorizontalAlignmentCenter;
                item1.fillMode = CSLinearLayoutItemFillModeNormal;
                [self.rootView insertItem:item1 afterItem:baseItem];
            } else {
                [self.rootView moveItem:item1 afterItem:baseItem];
            }
            item1.padding = CSLinearLayoutMakePadding(0, 15, 0, 15);
            
            CSLinearLayoutItem *item2 = [self.rootView findItemByTag:_inputUsername.tag];
            if (item2 == nil) {
                item2 = [CSLinearLayoutItem layoutItemForView:_inputUsername];
                item2.horizontalAlignment = CSLinearLayoutItemHorizontalAlignmentCenter;
                item2.fillMode = CSLinearLayoutItemFillModeNormal;
                [self.rootView insertItem:item2 afterItem:item1];
            } else {
                [self.rootView moveItem:item2 afterItem:item1];
            }
            item2.padding = CSLinearLayoutMakePadding(0, 15, 4, 15);
            
            CSLinearLayoutItem *item3 = [self.rootView findItemByTag:_btnStartNewUser.tag];
            if (item3 == nil){
                item3 = [CSLinearLayoutItem layoutItemForView:_btnStartNewUser];
                item3.horizontalAlignment = CSLinearLayoutItemHorizontalAlignmentCenter;
                item3.fillMode = CSLinearLayoutItemFillModeNormal;
                [self.rootView insertItem:item3 afterItem:item2];
            } else {
                [self.rootView moveItem:item3 afterItem:item2];
            }
            item3.padding = CSLinearLayoutMakePadding(6, 15, 0, 15);
            
            _line1.hidden = NO;
            _line2.hidden = NO;
            _textFieldFrame.frame = CGRectMake(15, 20, 290, 150);
            _inputIdentity.returnKeyType = UIReturnKeyNext;
            _inputPassword.placeholder = NSLocalizedString(@"Set EXFE password", nil);
            _inputPassword.returnKeyType = UIReturnKeyNext;
            _inputPassword.btnForgot.hidden = YES;
            [_inputPassword becomeFirstResponder];
            _inputUsername.returnKeyType = UIReturnKeyDone;
            _inputIdentity.rightView = nil;
            _inputIdentity.clearButtonMode = UITextFieldViewModeAlways;
        }  break;
        case kStageVerificate:{
            [self.rootView removeItem:[self.rootView findItemByTag:kViewTagInputPassword]];
            [self.rootView removeItem:[self.rootView findItemByTag:kViewTagInputUserName]];
            [self.rootView removeItem:[self.rootView findItemByTag:kViewTagButtonStart]];
            [self.rootView removeItem:[self.rootView findItemByTag:kViewTagButtonNewUser]];
            [self.rootView removeItem:[self.rootView findItemByTag:kViewTagErrorHint]];
            [self.rootView removeItem:[self.rootView findItemByTag:_inlineError.tag]];
            
            CSLinearLayoutItem *baseItem = [self.rootView findItemByTag:_inputIdentity.tag];
            
            CSLinearLayoutItem *item1 = [self.rootView findItemByTag:_labelVerifyTitle.tag];
            if (item1 == nil) {
                item1 = [CSLinearLayoutItem layoutItemForView:_labelVerifyTitle];
                item1.horizontalAlignment = CSLinearLayoutItemHorizontalAlignmentCenter;
                item1.fillMode = CSLinearLayoutItemFillModeNormal;
                [self.rootView insertItem:item1 afterItem:baseItem];
            } else {
                [self.rootView moveItem:item1 afterItem:baseItem];
            }
            item1.padding = CSLinearLayoutMakePadding(5, 20, 0, 20);
            
            
            Provider p = [Util matchedProvider:[_inputIdentity.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
            switch (p) {
                case kProviderPhone:
                    _labelVerifyDescription.text = NSLocalizedString(@"This number requires verification before proceeding. Verification request is sent, please check your message for instructions.", nil);
                    break;
                    
                default:
                    _labelVerifyDescription.text = NSLocalizedString(@"This email requires verification before proceeding. Verification request is sent, please check your email for instructions.", nil);
                    break;
            }
            
            CSLinearLayoutItem *item2 = [self.rootView findItemByTag:_labelVerifyDescription.tag];
            if (item2 == nil) {
                item2 = [CSLinearLayoutItem layoutItemForView:_labelVerifyDescription];
                item2.horizontalAlignment = CSLinearLayoutItemHorizontalAlignmentCenter;
                item2.fillMode = CSLinearLayoutItemFillModeNormal;
                [self.rootView insertItem:item2 afterItem:item1];
            } else {
                [self.rootView moveItem:item2 afterItem:item1];
            }
            item2.padding = CSLinearLayoutMakePadding(0, 20, 0, 20);
            
            CSLinearLayoutItem *item3 = [self.rootView findItemByTag:_btnStartOver.tag];
            if (item3 == nil){
                item3 = [CSLinearLayoutItem layoutItemForView:_btnStartOver];
                item3.horizontalAlignment = CSLinearLayoutItemHorizontalAlignmentCenter;
                item3.fillMode = CSLinearLayoutItemFillModeNormal;
                [self.rootView insertItem:item3 afterItem:item2];
            } else {
                [self.rootView moveItem:item3 afterItem:item2];
            }
            item3.padding = CSLinearLayoutMakePadding(10, 15, 0, 15);
            
            _line1.hidden = YES;
            _line2.hidden = YES;
            _textFieldFrame.frame = CGRectMake(15, 20, 290, 50);
            _inputIdentity.rightView = nil;
            _inputIdentity.clearButtonMode = UITextFieldViewModeAlways;
        }   break;
        default:
            break;
    }
}

- (void)fillIdentityResp:(NSDictionary*)respDict
{
    NSString *avatar_filename = [respDict valueForKeyPath:@"identity.avatar_filename"];
    if (avatar_filename.length > 0) {
        UIImage *defaultImage = [UIImage imageNamed:@"portrait_default.png"];
        _imageIdentity.contentMode = UIViewContentModeScaleAspectFill;
        
        if ([[EFDataManager imageManager] isImageCachedInMemoryForKey:avatar_filename]) {
            _imageIdentity.image = [[EFDataManager imageManager] cachedImageInMemoryForKey:avatar_filename];
        } else {
            _imageIdentity.image = defaultImage;
            [[EFDataManager imageManager] cachedImageForKey:avatar_filename
                                            completeHandler:^(UIImage *image){
                                                if (image) {
                                                    _imageIdentity.image = image;
                                                }
                                            }];
        }
    } else {
        NSString *provider = [respDict valueForKeyPath:@"identity.provider"];
        [self fillIdentityHint:[Identity getProviderCode:provider]];
    }
}

- (void)fillIdentityHint:(Provider)provider;
{
    switch (provider) {
        case kProviderEmail:{
            _imageIdentity.image = [UIImage imageNamed:@"identity_email_18_grey.png"];
            _imageIdentity.contentMode = UIViewContentModeCenter;
        }   break;
        case kProviderPhone:
            _imageIdentity.image = [UIImage imageNamed:@"identity_phone_18_grey.png"];
            _imageIdentity.contentMode = UIViewContentModeCenter;
            break;
        case kProviderFacebook:
            _imageIdentity.image = [UIImage imageNamed:@"identity_facebook_18_grey.png"];
            _imageIdentity.contentMode = UIViewContentModeCenter;
            break;
        case kProviderTwitter:
            _imageIdentity.image = [UIImage imageNamed:@"identity_twitter_18_grey.png"];
            _imageIdentity.contentMode = UIViewContentModeCenter;
            break;
            
        default:
            // no identity info, fall back to default
            _imageIdentity.image = nil;
            _imageIdentity.contentMode = UIViewContentModeCenter;
            break;
    }
}

- (void)swithStagebyFlag:(NSString*)flag and:(Provider)provider
{
    if([flag isEqualToString:@"SIGN_UP"] ){
        [self setStage:kStageSignUp];
    } else if([flag isEqualToString:@"VERIFY"] ) {
        [self setStage:kStageVerificate];
    } else if([flag isEqualToString:@"AUTHENTICATE"]){
        
        NSString * identityText = [_inputIdentity.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        Provider provider = [Util matchedProvider:identityText];
        NSDictionary *dict = [Util parseIdentityString:identityText byProvider:provider];
        NSString *username = [dict valueForKeyPath:@"external_username"];
        
        AppDelegate *app = (AppDelegate *)[UIApplication sharedApplication].delegate;
        // eg:  exfe://oauthcallback/
        NSString *callback = [NSString stringWithFormat: @"%@://oauthcallback/", app.defaultScheme];
        
        NSString *oAuthURL = nil;
        switch (provider) {
            case kProviderTwitter:
            case kProviderFacebook:
            {
                oAuthURL = [NSString stringWithFormat:@"%@/Authenticate?device=iOS&device_callback=%@&provider=%@", EXFE_OAUTH_LINK, [Util EFPercentEscapedQueryStringPairMemberFromString:callback], [Util EFPercentEscapedQueryStringPairMemberFromString:[Identity getProviderString:provider]]];
            }   break;
            default:
                break;
        }
        
        if (oAuthURL) {
            OAuthLoginViewController *oauth = [[OAuthLoginViewController alloc] initWithNibName:@"OAuthLoginViewController" bundle:nil];
            oauth.provider = kProviderTwitter;
            oauth.onSuccess = ^(NSDictionary * params){
                NSString * userid = [params valueForKey:@"userid"];
                NSString * token = [params valueForKey:@"token"];
                
                if ([userid integerValue] > 0 && token.length > 0) {
                    [self loadUserAndExit:[userid integerValue] withToken:token];
                } else {
                    // Error?
                }
            };
            oauth.oAuthURL = oAuthURL;
            oauth.external_username = username;
            [self presentModalViewController:oauth animated:YES];
            return;
        } else {
            // unsupported provider
        }
        
    } else if([flag isEqualToString:@"SIGN_IN"]){
        [self setStage:kStageSignIn];
    }else {
        [self setStage:kStageSignIn];
    }
}

- (void)showErrorInfo:(NSString*)error dockOn:(UIView*)view
{
    [_hintError removeFromSuperview];
    _hintError.text = error;
    _hintError.backgroundColor = [UIColor COLOR_WA(250, 217)];
    CGRect frame = _hintError.bounds;
    frame.size.height = 44;
    frame.size.width = 200;
    frame.origin.x = CGRectGetMinX(view.frame) + 5 + 40 + 5;
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

- (void)showInlineError:(NSString *)title with:(NSString *)description
{
    
    BOOL layoutFlag = NO;
    NSString* full = [NSString stringWithFormat:@"%@ %@", title, description];
    
    [_inlineError setText:full afterInheritingLabelAttributesAndConfiguringWithBlock:^NSMutableAttributedString *(NSMutableAttributedString *mutableAttributedString) {
        NSRange titleRange = [[mutableAttributedString string] rangeOfString:title options:NSCaseInsensitiveSearch];
        [mutableAttributedString addAttribute:(NSString*)kCTForegroundColorAttributeName value:(id)[[UIColor COLOR_RED_EXFE] CGColor] range:titleRange];
        return mutableAttributedString;
    }];
    
    CSLinearLayoutItem *baseitem = [self.rootView findItemByTag:kViewTagButtonStart];
    if (baseitem == nil) {
        baseitem = [self.rootView findItemByTag:kViewTagButtonNewUser];
    }
    if (baseitem == nil) {
        baseitem = [self.rootView findItemByTag:kViewTagButtonStartOver];
    }
    if (baseitem == nil) {
        layoutFlag = YES;
        baseitem = [self.rootView findItemByTag:kViewTagSnsGroup];
    }
    
    if (baseitem) {
        [_inlineError wrapContent];
        CSLinearLayoutItem *item = [self.rootView findItemByTag:_inlineError.tag];
        if (item == nil){
            item = [CSLinearLayoutItem layoutItemForView:_inlineError];
            item.horizontalAlignment = CSLinearLayoutItemHorizontalAlignmentCenter;
            item.fillMode = CSLinearLayoutItemFillModeNormal;
            [self.rootView insertItem:item beforeItem:baseitem];
        } else {
            [self.rootView moveItem:item beforeItem:baseitem];
        }
        CGFloat top = layoutFlag ? 27 : 0;
        item.padding = CSLinearLayoutMakePadding(top, 20, 0, 20);
    }
}

- (void)hideInlineError
{
    CSLinearLayoutItem *item = [self.rootView findItemByTag:_inlineError.tag];
    if (item){
        [self.rootView removeItem:item];
    }
}

#pragma mark Logic Methods
- (void)identityDidChange:(NSString*)identity
{
    Provider provider = [Util candidateProvider:identity];
    NSDictionary *resp = [self.identityCache objectForKey:identity];
    if (!resp){
        resp = @{@"registration_flag":@"",
                 @"identity":@{ @"external_username":identity,
                                @"provider":[Identity getProviderString:provider]
                                }
                 };
        [self.identityCache setObject:resp forKey:identity];
    }
    [self fillIdentityResp:resp];
    
    if (_stage != kStageStart) {
        [self setStage:kStageStart];
    }
    if (identity.length > 2) {
        if(provider != kProviderUnknown) {
            [NSObject cancelPreviousPerformRequestsWithTarget:self];
            [self performSelector:@selector(checkIdentityFlag:) withObject:identity afterDelay:0.233];
        }
    }
    
}

- (void)checkIdentityFlag:(NSString*)identity
{
    if (identity.length > 0) {
        // start query
        NSString *identityText = [identity stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

        Provider provider = [Util matchedProvider:identityText];
        NSDictionary *dict = [Util parseIdentityString:identityText byProvider:provider];
        NSString *external_username = [dict valueForKeyPath:@"external_username"];
        if (provider != kProviderUnknown) {
            AppDelegate * app = (AppDelegate*)[UIApplication sharedApplication].delegate;
            [app.model.apiServer getRegFlagBy:external_username with:provider success:^(AFHTTPRequestOperation *operation, id responseObject) {
                if ([operation.response statusCode] == 200 && [responseObject isKindOfClass:[NSDictionary class]]) {
                    id code = [responseObject valueForKeyPath:@"meta.code"];
                    if (code) {
                        if([code intValue] == 200) {
                            NSDictionary *resp = [responseObject valueForKeyPath:@"response"];
                            if (![resp valueForKey:@"identity"]) {
                                resp = @{@"registration_flag":[resp valueForKey:@"registration_flag"],
                                         @"identity":@{ @"external_username":identity,
                                                        @"provider":[Identity getProviderString:[Util candidateProvider:identity]]
                                                        }
                                         };
                            }
                            [self.identityCache setObject:resp forKey:identityText];
                            
                            NSString *identityText2 = [_inputIdentity.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                            
                            if ([identityText2 isEqualToString:identityText]) {
                                [self fillIdentityResp:resp];
                            }
                        } else {
                        }
                    }
                }
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            }];
        }
    }
}

- (void)loadUserAndExit:(NSInteger)user_id withToken:(NSString*)token
{
    AppDelegate * app = (AppDelegate*)[UIApplication sharedApplication].delegate;
    
    [app switchContextByUserId:user_id withAbandon:NO];
    app.model.userToken = token;
    [app.model saveUserData];
    
    [app.model loadMe];
    
    [app signinDidFinish];
}

#pragma mark -
#pragma mark Button / View Click Handler
- (void)expandIdentity:(id)sender
{
    NSString* identity = [_inputIdentity.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    Provider provider = [Util candidateProvider:identity];
    
    if (provider == kProviderUnknown) {
        [self showErrorInfo:NSLocalizedString(@"Invalid identity.", nil) dockOn:_inputIdentity];
        return;
    }
    
    if (provider == kProviderPhone) {
        if (![identity hasPrefix:@"+"]) {
            NSString *cc = [Util getTelephoneCountryCode];
            _inputIdentity.text = [NSString stringWithFormat:@"+%@%@", cc, identity];
            int start = 1;
            int end = start + cc.length;
            UITextPosition *startPosition = [_inputIdentity positionFromPosition:_inputIdentity.beginningOfDocument offset:start];
            UITextPosition *endPosition = [_inputIdentity positionFromPosition:_inputIdentity.beginningOfDocument offset:end];
            UITextRange *selection = [_inputIdentity textRangeFromPosition:startPosition toPosition:endPosition];
            _inputIdentity.selectedTextRange = selection;
            [self textFieldDidChange:_inputIdentity];
            return;
        }
    }
    
    NSDictionary *resp = [self.identityCache objectForKey:identity];
    NSString *flag = [resp valueForKey:@"registration_flag"];
    
    [self swithStagebyFlag:flag and:provider];
    
    switch (_stage) {
        case kStageVerificate:{
            
            NSDictionary *dict = [Util parseIdentityString:identity byProvider:provider];
            NSString *external_username = [dict valueForKeyPath:@"external_username"];
            AppDelegate * app = (AppDelegate*)[UIApplication sharedApplication].delegate;
            [app.model.apiServer verifyIdentity:external_username with:provider success:^(AFHTTPRequestOperation *operation, id responseObject) {
                if ([operation.response statusCode] == 200 ){
                    if( [responseObject isKindOfClass:[NSDictionary class]]){
                        NSDictionary *body = responseObject;
                        NSNumber *code = [responseObject valueForKeyPath:@"meta.code"];
                        if (code) {
                            NSInteger c = [code integerValue];
                            NSInteger t = c / 100;
                            switch (t) {
                                case 2:{
                                    NSString *action = [responseObject valueForKeyPath:@"response.action"];
                                    if ([@"VERIFYING" isEqualToString:action]) {
                                        // contiue wait;
                                    } else if ([@"REDIRECT" isEqualToString:action]){
                                        // start oAuth by provider
                                        NSString * url = [body valueForKeyPath:@"response.url"];
                                        if (url.length > 0) {
                                            NSDictionary *identity = [body valueForKeyPath:@"response.identity"];
                                            Provider provider = [Identity getProviderCode:[identity valueForKey:@"provider"]];
                                            
                                            OAuthLoginViewController *oauth = [[OAuthLoginViewController alloc] initWithNibName:@"OAuthLoginViewController" bundle:nil];
                                            oauth.provider = provider;
                                            oauth.onSuccess = ^(NSDictionary * params){
                                                NSString * userid = [params valueForKey:@"userid"];
                                                NSString * token = [params valueForKey:@"token"];
                                                
                                                if ([userid integerValue] > 0 && token.length > 0) {
                                                    [self loadUserAndExit:[userid integerValue] withToken:token];
                                                } else {
                                                    // Error?
                                                }
                                            };
                                            oauth.oAuthURL = url;
                                            oauth.external_username = [identity valueForKey:@"external_username"];
                                            [self presentModalViewController:oauth animated:YES];

                                        }
                                    }
                                }    break;
                                case 4:{
                                    if (c == 401) {
                                        NSString *errorType = [responseObject valueForKeyPath:@"meta.errorType"];
                                        if ([@"identity_does_not_exist" isEqualToString:errorType]) {
                                            [self setStage:kStageSignUp];
                                        } else if ([@"no_need_to_verify" isEqualToString:errorType]) {
                                            [self setStage:kStageSignIn];
                                        }
                                    }
                                    
                                }  break;
                                default:
                                    break;
                            }
                        }
                    }
                }
            } failure:^(AFHTTPRequestOperation *operation, NSError *error){
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
//                            [self showInlineError:@"Failed to connect server." with:@"Please retry or wait awhile."];
                            
                            //NSURLErrorInternationalRoamingOff = -1018,
                            //NSURLErrorCallIsActive = -1019,
                            //NSURLErrorDataNotAllowed = -1020,
                            //NSURLErrorSecureConnectionFailed = -1200,
                            //NSURLErrorCannotLoadFromNetwork = -2000,
                            break;
                            
                        default:
                            break;
                    }
                }
            }];
        } break;
            
        default:
            break;
    }
}

- (void)signIn:(UIControl *)sender
{
    NSString *identityText = [_inputIdentity.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (identityText.length == 0) {
        return;
    }
    if (_inputPassword.text.length == 0) {
        [self showErrorInfo:NSLocalizedString(@"Invalid password.", nil) dockOn:_inputPassword];
        return;
    }
    sender.enabled = NO;
    [self hideInlineError];
    
    [self showIndicatorAt:CGPointMake(285, sender.center.y) style:UIActivityIndicatorViewStyleWhite];
    Provider provider = [Util matchedProvider:identityText];
    NSDictionary *dict = [Util parseIdentityString:identityText byProvider:provider];
    NSString *external_username = [dict valueForKeyPath:@"external_username"];
    AppDelegate * app = (AppDelegate*)[UIApplication sharedApplication].delegate;
    [app.model.apiServer signIn:external_username with:provider password:_inputPassword.text success:^(AFHTTPRequestOperation *operation, id responseObject) {
        sender.enabled = YES;
        [self hideIndicator];
        
        if ([operation.response statusCode] == 200 && [responseObject isKindOfClass:[NSDictionary class]]){
            NSNumber *code = [responseObject valueForKeyPath:@"meta.code"];
            if (code) {
                NSInteger c = [code integerValue];
                switch (c) {
                    case 200:{
                        NSNumber *u = [responseObject valueForKeyPath:@"response.user_id"];
                        NSString *t = [responseObject valueForKeyPath:@"response.token"];
                        [self loadUserAndExit:[u integerValue] withToken:t];
                    }   break;
                    case 403:{
                        // response.body={"meta":{"code":403,"errorType":"failed","errorDetail":{"registration_flag":"SIGN_UP"}},"response":{}}
                        NSString *errorType = [responseObject valueForKeyPath:@"meta.errorType"];
                        if ([@"failed" isEqualToString:errorType]) {
                            NSString *registration_flag = [responseObject valueForKeyPath:@"meta.errorDetail.registration_flag"];
                            if ([@"SIGN_UP" isEqualToString:registration_flag]) {
                            } else if ([@"SIGN_IN" isEqualToString:registration_flag]){
                                [self showErrorInfo:NSLocalizedString(@"Authentication failed.", nil) dockOn:_inputPassword];
                                break;
                            } else if ([@"AUTHENTICATE" isEqualToString:registration_flag]){
                                
                            } else if ([@"VERIFY" isEqualToString:registration_flag]){
                            }
                            [self swithStagebyFlag:registration_flag and:provider];
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

- (void)signUp:(UIControl *)sender
{
    sender.enabled = NO;
    NSString *identityText = [_inputIdentity.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if (identityText.length == 0) {
        return;
    }
    if (_inputPassword.text.length == 0) {
        [self showErrorInfo:NSLocalizedString(@"Invalid password.", nil) dockOn:_inputPassword];
        sender.enabled = YES;
        return;
    }
    
    if (_inputUsername.text.length == 0) {
        // show "Invalid name."
        [self showErrorInfo:NSLocalizedString(@"Invalid name.", nil) dockOn:_inputUsername];
        sender.enabled = YES;
        return;
    }
    
    [self hideInlineError];
    
    Provider provider = [Util matchedProvider:identityText];
    NSDictionary *dict = [Util parseIdentityString:identityText byProvider:provider];
    NSString *external_username = [dict valueForKeyPath:@"external_username"];
    
    [self showIndicatorAt:CGPointMake(285, sender.center.y) style:UIActivityIndicatorViewStyleWhite];
    AppDelegate * app = (AppDelegate*)[UIApplication sharedApplication].delegate;
    [app.model.apiServer signUp:external_username with:provider name:_inputUsername.text password:_inputPassword.text success:^(AFHTTPRequestOperation *operation, id responseObject) {
        sender.enabled = YES;
        [self hideIndicator];
        
        if ([operation.response statusCode] == 200 && [responseObject isKindOfClass:[NSDictionary class]]){
            NSNumber *code = [responseObject valueForKeyPath:@"meta.code"];
            if (code) {
                NSInteger c = [code integerValue];
                switch (c) {
                    case 200:{
                        NSNumber *u = [responseObject valueForKeyPath:@"response.user_id"];
                        NSString *t = [responseObject valueForKeyPath:@"response.token"];
                        [self loadUserAndExit:[u integerValue] withToken:t];
                    }  break;
                    case 400:{
                        NSString *errorType = [responseObject valueForKeyPath:@"meta.errorType"];
                        if ([@"weak_password" isEqualToString:errorType]) {
                            [self showErrorInfo:NSLocalizedString(@"Invalid password.", nil) dockOn:_inputPassword];
                        } else if ([@"invalid_username" isEqualToString:errorType]) {
                            [self showErrorInfo:NSLocalizedString(@"Invalid name.", nil) dockOn:_inputPassword];
                        }
                    }  break;
                    case 403:
                        // login fail
                        break;
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

- (void)startOver:(id)sender
{
    _inputIdentity.text = @"";
    [self textFieldDidChange:_inputIdentity];
    [self setStage:kStageStart];
}

- (void)syncFBAccount
{
    ACAccountStore *accountStore;
    ACAccountType *accountTypeFB;
    if ((accountStore = [[ACAccountStore alloc] init]) &&
        (accountTypeFB = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierFacebook] ) ){
        
        NSArray *fbAccounts = [accountStore accountsWithAccountType:accountTypeFB];
        id account;
        if (fbAccounts && [fbAccounts count] > 0 &&
            (account = [fbAccounts objectAtIndex:0])){
            
            [accountStore renewCredentialsForAccount:account completion:^(ACAccountCredentialRenewResult renewResult, NSError *error) {
                //we don't actually need to inspect renewResult or error.
                if (error){
                    
                }
            }];
        }
    }
}

- (void)facebookSignIn:(id)sender
{
    [self hideInlineError];
    
    [FBSession.activeSession closeAndClearTokenInformation];
    // If a user has *never* logged into your app, request one of
    // "email", "user_location", or "user_birthday". If you do not
    // pass in any permissions, "email" permissions will be automatically
    // requested for you. Other read permissions can also be included here.
    NSArray *permissions = @[@"email"];
    
    [FBSession openActiveSessionWithReadPermissions:permissions
                                       allowLoginUI:YES
                                  completionHandler:^(FBSession *session, FBSessionState status, NSError *error) {
                                      /* handle success + failure in block */
                                      
                                      switch (session.state) {
                                          case FBSessionStateOpen:{
                                              [self.view endEditing:YES];
                                              
                                              NSDictionary *params = @{@"oauth_expires": [NSString stringWithFormat:@"%.0f", session.accessTokenData.expirationDate.timeIntervalSince1970]};
                                              
                                              MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                                              hud.labelText = @"Authenticating...";
                                              hud.mode = MBProgressHUDModeCustomView;
                                              EXSpinView *bigspin = [[EXSpinView alloc] initWithPoint:CGPointMake(0, 0) size:40];
                                              [bigspin startAnimating];
                                              hud.customView = bigspin;
                                              
                                              AppDelegate * app = (AppDelegate*)[UIApplication sharedApplication].delegate;
                                              [app.model.apiServer reverseAuth:kProviderFacebook withToken:session.accessTokenData.accessToken andParam:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                                  [MBProgressHUD hideHUDForView:self.view animated:YES];
                                                  if ([operation.response statusCode] == 200 && [responseObject isKindOfClass:[NSDictionary class]]){
                                                      
                                                      NSNumber *code = [responseObject valueForKeyPath:@"meta.code"];
                                                      switch ([code integerValue]) {
                                                          case 200:{
                                                              NSNumber *u = [responseObject valueForKeyPath:@"response.user_id"];
                                                              NSString *t = [responseObject valueForKeyPath:@"response.token"];
                                                              [self loadUserAndExit:[u integerValue] withToken:t];
                                                              // ask for more permissions
                                                              //                            NSArray *permissions = @[@"user_photos", @"friends_photos"];
                                                              //                            [[FBSession activeSession] requestNewReadPermissions:permissions completionHandler:^(FBSession *session, NSError *error) {
                                                              //                                ;
                                                              //                            }];
                                                          }
                                                              break;
                                                          case 400:{
                                                              if ([@"invalid_token" isEqualToString:[responseObject valueForKeyPath:@"meta.errorType"]] ) {
                                                                  [self showInlineError:NSLocalizedString(@"Invalid token.", nil) with:NSLocalizedString(@"There is something wrong. Please try again later.", nil)];
                                                                  
                                                                  [self syncFBAccount];
                                                                  
                                                              }
                                                          }
                                                          default:
                                                              break;
                                                      }
                                                  }
                                              } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
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
//                                                              [self showInlineError:@"Failed to connect server." with:@"Please retry or wait awhile."];
                                                              break;
                                                              
                                                          default:
                                                              break;
                                                      }
                                                  }
                                                  
                                                  [MBProgressHUD hideHUDForView:self.view animated:YES];
                                              }];
                                          }
                                              break;
                                              
                                          case FBSessionStateClosedLoginFailed:
//                                              [self showInlineError:@"Login Failed." with:@"There is something wrong. Please try again later."];
                                              [self showInlineError:NSLocalizedString(@"Authorization failed.", nil) with:NSLocalizedString(@"Please check your network connection and account setting in Settings app.", nil)];
                                              [self syncFBAccount];
                                              break;
                                          default:
                                              break;
                                      }
                                      
                                      
                                  }];
    
}

- (void)twitterSignIn:(id)sender
{
    [self hideInlineError];
    
    ACAccountType *twitterType = [_accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    
    ACAccountStoreRequestAccessCompletionHandler handler = ^(BOOL granted, NSError *error) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (granted) {
                self.accounts = [_accountStore accountsWithAccountType:twitterType];
                if ([TWAPIManager isLocalTwitterAccountAvailable] && _accounts.count > 0) {
                    if ([TWAPIManager isLocalTwitterAccountAvailable]) {
                        if (_accounts.count > 1) {
                            UIActionSheet *sheet = [UIActionSheet actionSheetWithTitle:NSLocalizedString(@"Choose an Account", nil)];
                            for (ACAccount *acct in _accounts) {
                                [sheet addButtonWithTitle:acct.username handler:^{
                                    [self performReverseAuthForAccount:acct];
                                }];
                            }
                            sheet.cancelButtonIndex = [sheet setCancelButtonWithTitle:NSLocalizedString(@"Cancel", nil) handler:^{
                                // cancel
                            }];
                            [sheet showInView:self.view];
                        } else {
                            [self performReverseAuthForAccount:_accounts[0]];
                        }
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

- (void)forgetPwd:(UIControl *)sender
{
    NSString *identityText = [_inputIdentity.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    sender.enabled = NO;
    Provider provider = [Util matchedProvider:identityText];
    NSDictionary *dict = [Util parseIdentityString:identityText byProvider:provider];
    NSString *external_username = [dict valueForKeyPath:@"external_username"];
    
    CGPoint p = [sender.superview convertPoint:sender.center toView:self.rootView];
    [self showIndicatorAt:CGPointMake(285, p.y) style:UIActivityIndicatorViewStyleGray];
    
    CATransform3D scaleTransform = CATransform3DMakeScale(0.0f, 0.0f, 0.0f);
    CABasicAnimation *scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform"];
    scaleAnimation.duration = 0.1f;
    scaleAnimation.fromValue = [NSValue valueWithCATransform3D:sender.layer.transform];
    scaleAnimation.toValue = [NSValue valueWithCATransform3D:scaleTransform];
    scaleAnimation.fillMode = kCAFillModeForwards;
    scaleAnimation.removedOnCompletion = NO;
    [sender.layer addAnimation:scaleAnimation forKey:@"scale"];
    
    AppDelegate * app = (AppDelegate*)[UIApplication sharedApplication].delegate;
    [app.model.apiServer forgetPassword:external_username with:provider success:^(AFHTTPRequestOperation *operation, id responseObject) {
        sender.enabled = YES;
        [sender.layer removeAllAnimations];
        sender.layer.transform = CATransform3DIdentity;
        [self hideIndicator];
        if ([operation.response statusCode] == 200 && [responseObject isKindOfClass:[NSDictionary class]]){
            NSNumber *code = [responseObject valueForKeyPath:@"meta.code"];
            if (code) {
                NSInteger c = [code integerValue];
                switch (c) {
                    case 200:{
                        NSString *msg = nil;
                        switch (provider) {
                            case kProviderPhone:
                                msg = NSLocalizedString(@"Password reset request is sent, please check your message for instructions.", nil);
                                break;
                                
                            default:
                                msg = NSLocalizedString(@"Password reset request is sent, please check your email for instructions.", nil);
                                break;
                        }
                        [UIAlertView showAlertViewWithTitle:NSLocalizedString(@"Forget Password?", nil) message:msg cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil handler:nil];
                    } break;
                    case 400:{
                        NSString *errorType = [responseObject valueForKeyPath:@"meta.errorType"];
                        if ([@"identity_does_not_exist" isEqualToString:errorType]
                                  || [@"identity_is_being_verified" isEqualToString:errorType]){
                            [self showInlineError:NSLocalizedString(@"Invalid account.", nil) with:NSLocalizedString(@"Please check your input above.", nil)];
                        }
                    }  break;
                    case 429:{
                        NSString *msg = nil;
                        switch (provider) {
                            case kProviderPhone:
                                msg = NSLocalizedString(@"Request should be responded usually in seconds, please wait for awhile.", nil);
                                break;
                                
                            default:
                                msg = NSLocalizedString(@"Request should be responded usually in seconds, please wait for awhile. Please also check your spam email folder, it might be mistakenly filtered by your mailbox.", nil);
                                break;
                        }
                        [self showInlineError:NSLocalizedString(@"Request too frequently.", nil) with:msg];
                    }  break;
                    case 500:{
                        // 500 - failed
                    }  break;
                    default:
                        break;
                }
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        sender.enabled = YES;
        [sender.layer removeAllAnimations];
        sender.layer.transform = CATransform3DIdentity;
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

#pragma mark Textfield Change Notification
- (void)textFieldDidChange:(id)sender
{
    UITextField *textField = sender;
    //If there is text in the text field
    if (textField.text.length > 0)
    {
        //Set textfield font
        if (textField.tag == kViewTagInputIdentity) {
            textField.font = [UIFont fontWithName:@"HelveticaNeue-Italic" size:18];
        } else {
            textField.font = [UIFont fontWithName:@"HelveticaNeue" size:18];
        }
    }
    else
    {
        //Set textfield placeholder font (or so it appears)
        textField.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:18];
    }
    
    if (textField.tag == kViewTagInputIdentity) {
        NSString *identity = [textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        if ([identity isEqualToString:self.lastInputIdentity]) {
            return;
        } else {
            self.lastInputIdentity = identity;
            [self identityDidChange:identity];
        }
    }
}

#pragma mark UITextFieldDelegate
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [self hide:_hintError withAnmated:NO];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
  
        switch (textField.tag) {
            case kViewTagInputIdentity:
                switch (_stage) {
                    case kStageStart:
                        [_extIdentity sendActionsForControlEvents: UIControlEventTouchUpInside];
                        return NO;
                        break;
                    case kStageSignIn:
                    case kStageSignUp:
                        [_inputPassword becomeFirstResponder];
                        return NO;
                        break;
                    case kStageVerificate:
                        return NO;
                        break;
                    default:
                        break;
                }
                break;
            case kViewTagInputPassword:
                switch (_stage) {
                    case kStageSignIn:
                        [_btnStart sendActionsForControlEvents: UIControlEventTouchUpInside];
                        return NO;
                        break;
                    case kStageSignUp:
                        [_inputUsername becomeFirstResponder];
                        return NO;
                        break;
                    default:
                        break;
                }
            case kViewTagInputUserName:
                switch (_stage) {
                    case kStageSignUp:
                        [_btnStartNewUser sendActionsForControlEvents: UIControlEventTouchUpInside];
                        return NO;
                        break;
                    default:
                        break;
                }
            
            default:
                break;
        }
    
    
    
    return YES;
}

#pragma mark - Private

- (void)performReverseAuthForAccount:(ACAccount*)acct
{
    [self.view endEditing:YES];
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Authenticating...";
    hud.mode = MBProgressHUDModeCustomView;
    EXSpinView *bigspin = [[EXSpinView alloc] initWithPoint:CGPointMake(0, 0) size:40];
    [bigspin startAnimating];
    hud.customView = bigspin;
    
    [_apiManager performReverseAuthForAccount:acct withHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error){
        if (!error) {
            NSString *responseStr = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
            NSDictionary *params = [Util splitQuery:responseStr];
            
            AppDelegate * app = (AppDelegate*)[UIApplication sharedApplication].delegate;
            [app.model.apiServer reverseAuth:kProviderTwitter withToken:[params valueForKey:@"oauth_token"] andParam:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
                [MBProgressHUD hideHUDForView:self.view animated:YES];
                if ([operation.response statusCode] == 200 && [responseObject isKindOfClass:[NSDictionary class]]){
                    
                    NSNumber *code = [responseObject valueForKeyPath:@"meta.code"];
                    if ([code integerValue] == 200) {
                        NSNumber *u = [responseObject valueForKeyPath:@"response.user_id"];
                        NSString *t = [responseObject valueForKeyPath:@"response.token"];
                        [self loadUserAndExit:[u integerValue] withToken:t];
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

@end
