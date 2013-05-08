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
#import "ImgCache.h"
#import "CSLinearLayoutView.h"
#import "UILabel+EXFE.h"
#import "EFIdentityTextField.h"
#import "TWAPIManager.h"


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
@property (nonatomic, retain) UIImageView *line1;
@property (nonatomic, retain) UIImageView *line2;

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
    CSLinearLayoutView *linearLayoutView = [[[CSLinearLayoutView alloc] initWithFrame:self.view.bounds] autorelease];
    linearLayoutView.orientation = CSLinearLayoutViewOrientationVertical;
    linearLayoutView.alwaysBounceVertical = YES;
    self.rootView = linearLayoutView;
    [self.view addSubview:linearLayoutView];
    
    {// TextField Frame
        UIImage *img = [[UIImage imageNamed:@"textfield.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(6, 6, 6, 6)];
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
        textfield.placeholder = @"Enter email or phone";
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
        textfield.placeholder = @"Set display name";
        UIView *stub = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 55, 40)];
        textfield.leftView = stub;
        textfield.leftViewMode = UITextFieldViewModeAlways;
        [stub release];
        UIView *stub2 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
        textfield.rightView = stub2;
        textfield.rightViewMode = UITextFieldViewModeAlways;
        [stub2 release];
        self.inputUsername = textfield;
        self.inputUsername.tag = kViewTagInputUserName;
    }
    
    {// Start button
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(0, 0, 290, 48);
        [btn setTitle:@"Start" forState:UIControlStateNormal];
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
        [btn setTitle:@"Start with new account" forState:UIControlStateNormal];
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
        [btn setTitle:@"Start over" forState:UIControlStateNormal];
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
        label.text = @"Verification";
        label.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:21.0];
        label.backgroundColor = [UIColor clearColor];
        [label wrapContent];
        self.labelVerifyTitle = label;
        self.labelVerifyTitle.tag = kViewTagVerificationTitle;
    }
    
    {// Verification Description
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 280, 80)];
        label.text = @"This number requires verification before proceeding. Verification request sent, please check your message for instructions.";
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
    
    CSLinearLayoutView *snsLayoutView = [[[CSLinearLayoutView alloc] initWithFrame:CGRectMake(0, 0, 296, 106)] autorelease];
    snsLayoutView.tag = kViewTagSnsGroup;
    snsLayoutView.orientation = CSLinearLayoutViewOrientationHorizontal;
    
    UIEdgeInsets insets = UIEdgeInsetsMake(6, 6, 6, 6);
    UIImage *image = [UIImage imageNamed:@"table.png"];
    UIImageView *background = [[UIImageView alloc] initWithFrame:snsLayoutView.bounds];
    background.image = [image resizableImageWithCapInsets:insets];
    [snsLayoutView addSubview:background];
    [background release];
    
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
        [button setTitle:@"Facebook" forState:UIControlStateNormal];
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
        [button setTitle:@"Twitter" forState:UIControlStateNormal];
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
        UIActivityIndicatorView *aiView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
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
    self.inputIdentity = nil;
    self.imageIdentity = nil;
    self.extIdentity = nil;
    self.inputPassword = nil;
    self.inputUsername = nil;
    self.btnStart = nil;
    self.btnStartNewUser = nil;
    self.btnStartOver = nil;
    self.labelVerifyTitle = nil;
    self.labelVerifyDescription = nil;
    self.hintError = nil;
    self.inlineError = nil;
    self.indicator = nil;
    self.btnFacebook = nil;
    self.btnTwitter = nil;
    self.identityCache = nil;
    
    self.lastInputIdentity = nil;
    self.line1 = nil;
    self.line2 = nil;
    [super dealloc];
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
            _inputPassword.placeholder = @"Enter password";
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
            _inputPassword.placeholder = @"Set EXFE password";
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
            
            
            Provider p = [Util matchedProvider:_inputIdentity.text];
            switch (p) {
                case kProviderPhone:
                    _labelVerifyDescription.text = @"This number requires verification before proceeding. Verification request sent, please check your message for instructions.";
                    break;
                    
                default:
                    _labelVerifyDescription.text = @"This email requires verification before proceeding. Verification request sent, please check your email for instructions.";
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
            
            _line1.hidden = NO;
            _line2.hidden = NO;
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
        UIImage *def = [UIImage imageNamed:@"portrait_default.png"];
        _imageIdentity.contentMode = UIViewContentModeScaleAspectFill;
        [[ImgCache sharedManager] fillAvatar:_imageIdentity with:avatar_filename byDefault:def];
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
        
        
        Provider provider = [Util matchedProvider:_inputIdentity.text];
        NSDictionary *dict = [Util parseIdentityString:_inputIdentity.text byProvider:provider];
        NSString *username = [dict valueForKeyPath:@"external_username"];
        
        switch (provider) {
            case kProviderTwitter:
            {
                OAuthLoginViewController *oauth = [[OAuthLoginViewController alloc] initWithNibName:@"OAuthLoginViewController" bundle:nil];
                oauth.provider = kProviderTwitter;
                oauth.delegate = self;
                if (username) {
                    oauth.matchedURL = @"https://api.twitter.com/oauth/authorize?";
                    oauth.javaScriptString = [NSString stringWithFormat:@"document.getElementById('username_or_email').value='%@';", username];
                } else {
                    oauth.matchedURL = nil;
                    oauth.javaScriptString = nil;
                }
                
                [self presentModalViewController:oauth animated:YES];
            }
                return;
            case kProviderFacebook:
            {
                OAuthLoginViewController *oauth = [[OAuthLoginViewController alloc] initWithNibName:@"OAuthLoginViewController" bundle:nil];
                oauth.provider = kProviderFacebook;
                oauth.delegate = self;
                if (username) {
                    oauth.matchedURL = @"http://m.facebook.com/login.php?";
                    oauth.javaScriptString = [NSString stringWithFormat:@"document.getElementsByName('email')[0].value='%@';", username];
                } else {
                    oauth.matchedURL = nil;
                    oauth.javaScriptString = nil;
                }
                [self presentModalViewController:oauth animated:YES];
            }
                return;
            default:
                break;
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

- (void)showIndicatorAt:(CGPoint)center
{
    [_indicator removeFromSuperview];
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
        item.padding = CSLinearLayoutMakePadding(0, 20, 0, 20);
    }
}

- (void)hideInlineError
{
    
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
        Provider provider = [Util matchedProvider:identity];
        NSDictionary *dict = [Util parseIdentityString:identity byProvider:provider];
        NSString *external_username = [dict valueForKeyPath:@"external_username"];
        if (provider != kProviderUnknown) {
            EFAPIServer *server = [EFAPIServer sharedInstance];
            [server getRegFlagBy:external_username with:provider success:^(AFHTTPRequestOperation *operation, id responseObject) {
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
                            [self.identityCache setObject:resp forKey:identity];
                            
                            if ([_inputIdentity.text isEqualToString:identity]) {
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


- (void)loadUserAndExit
{
    [[EFAPIServer sharedInstance] loadMeSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        [self SigninDidFinish];
    }
                                        failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                            ;
                                        }];
}

- (void)SigninDidFinish
{
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [app SigninDidFinish];
}



#pragma mark -
#pragma mark Button / View Click Handler
- (void)expandIdentity:(id)sender
{
    NSString* identity = _inputIdentity.text;
    Provider provider = [Util candidateProvider:identity];
    
    if (provider == kProviderUnknown) {
        [self showErrorInfo:@"Invalid identity." dockOn:_inputIdentity];
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
            [[EFAPIServer sharedInstance] verifyIdentity:external_username with:provider success:^(AFHTTPRequestOperation *operation, id responseObject) {
                if ([operation.response statusCode] == 200 && [responseObject isKindOfClass:[NSDictionary class]]){
                    NSNumber *code = [responseObject valueForKeyPath:@"meta.code"];
                    if (code) {
                        NSInteger c = [code integerValue];
                        switch (c) {
                            case 200:{
                                NSString *action = [responseObject valueForKeyPath:@"response.action"];
                                if ([@"VERIFYING" isEqualToString:action]) {
                                    // contiue wait;
                                } else if ([@"REDIRECT" isEqualToString:action]){
                                    NSString *url = [responseObject valueForKeyPath:@"response.url"];
                                    if (url) {
                                        // start oAuth by provider
                                    }
                                }
                            }    break;
                            case 400:{
                                NSString *errorType = [responseObject valueForKeyPath:@"meta.code"];
                                if ([@"identity_does_not_exist" isEqualToString:errorType]) {
                                    [self setStage:kStageSignUp];
                                } else if ([@"no_need_to_verify" isEqualToString:errorType]) {
                                    [self setStage:kStageSignIn];
                                }
                            }  break;
                            default:
                                break;
                        }
                    }
                }
            } failure:^(AFHTTPRequestOperation *operation, NSError *error){
                //error.domain
                switch (error.code) {
                    case NSURLErrorCannotFindHost: //-1003
                    case NSURLErrorCannotConnectToHost: //-1004
                    case NSURLErrorNetworkConnectionLost: //-1005
                    case NSURLErrorDNSLookupFailed: //-1006
                    case NSURLErrorHTTPTooManyRedirects: //-1007
                    case NSURLErrorResourceUnavailable: //-1008
                    case NSURLErrorNotConnectedToInternet: //-1009
                    case NSURLErrorRedirectToNonExistentLocation: //-1010
                        [self showInlineError:@"Failed to connect server." with:@"Please retry or wait awhile."];
                        
                        //NSURLErrorCannotFindHost = -1003,
                        //NSURLErrorCannotConnectToHost = -1004,
                        //NSURLErrorNetworkConnectionLost = -1005,
                        //NSURLErrorDNSLookupFailed = -1006,
                        //NSURLErrorHTTPTooManyRedirects = -1007,
                        //NSURLErrorResourceUnavailable = -1008,
                        //NSURLErrorNotConnectedToInternet = -1009,
                        //NSURLErrorRedirectToNonExistentLocation = -1010,
                        //NSURLErrorInternationalRoamingOff = -1018,
                        //NSURLErrorCallIsActive = -1019,
                        //NSURLErrorDataNotAllowed = -1020,
                        //NSURLErrorSecureConnectionFailed = -1200,
                        //NSURLErrorCannotLoadFromNetwork = -2000,
                        break;
                        
                    default:
                        break;
                }
            }];
        } break;
            
        default:
            break;
    }
}

- (void)signIn:(UIControl *)sender
{
    if (_inputIdentity.text.length == 0) {
        return;
    }
    if (_inputPassword.text.length == 0) {
        [self showErrorInfo:@"Invalid password." dockOn:_inputPassword];
        return;
    }
    
    [self showIndicatorAt:CGPointMake(285, sender.center.y)];
    Provider provider = [Util matchedProvider:_inputIdentity.text];
    NSDictionary *dict = [Util parseIdentityString:_inputIdentity.text byProvider:provider];
    NSString *external_username = [dict valueForKeyPath:@"external_username"];
    [[EFAPIServer sharedInstance] signIn:external_username with:provider password:_inputPassword.text success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [self hideIndicator];
        if ([operation.response statusCode] == 200 && [responseObject isKindOfClass:[NSDictionary class]]){
            NSNumber *code = [responseObject valueForKeyPath:@"meta.code"];
            if (code) {
                NSInteger c = [code integerValue];
                switch (c) {
                    case 200:
                        
                        [self loadUserAndExit];
                        
                        break;
                    case 403:{
                        // response.body={"meta":{"code":403,"errorType":"failed","errorDetail":{"registration_flag":"SIGN_UP"}},"response":{}}
                        NSString *errorType = [responseObject valueForKeyPath:@"meta.errorType"];
                        if ([@"failed" isEqualToString:errorType]) {
                            NSString *registration_flag = [responseObject valueForKeyPath:@"meta.errorDetail.registration_flag"];
                            if ([@"SIGN_UP" isEqualToString:registration_flag]) {
                            } else if ([@"SIGN_IN" isEqualToString:registration_flag]){
                                [self showErrorInfo:@"Authentication failed." dockOn:_inputPassword];
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
        [self hideIndicator];
        //error.domain
        switch (error.code) {
            case NSURLErrorCannotFindHost: //-1003
            case NSURLErrorCannotConnectToHost: //-1004
            case NSURLErrorNetworkConnectionLost: //-1005
            case NSURLErrorDNSLookupFailed: //-1006
            case NSURLErrorHTTPTooManyRedirects: //-1007
            case NSURLErrorResourceUnavailable: //-1008
            case NSURLErrorNotConnectedToInternet: //-1009
            case NSURLErrorRedirectToNonExistentLocation: //-1010
                [self showInlineError:@"Failed to connect server." with:@"Please retry or wait awhile."];
                break;
                
            default:
                break;
        }
        
    }];
}

- (void)signUp:(UIControl *)sender
{
    if (_inputIdentity.text.length == 0) {
        return;
    }
    if (_inputPassword.text.length == 0) {
        [self showErrorInfo:@"Invalid password." dockOn:_inputPassword];
        return;
    }
    
    if (_inputUsername.text.length == 0) {
        // show "Invalid name."
        [self showErrorInfo:@"Invalid name." dockOn:_inputUsername];
        return;
    }
    
    Provider provider = [Util matchedProvider:_inputIdentity.text];
    NSDictionary *dict = [Util parseIdentityString:_inputIdentity.text byProvider:provider];
    NSString *external_username = [dict valueForKeyPath:@"external_username"];
    
    [self showIndicatorAt:CGPointMake(285, sender.center.y)];
    [[EFAPIServer sharedInstance] signUp:external_username with:provider name:_inputUsername.text password:_inputPassword.text success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [self hideIndicator];
        if ([operation.response statusCode] == 200 && [responseObject isKindOfClass:[NSDictionary class]]){
            NSNumber *code = [responseObject valueForKeyPath:@"meta.code"];
            if (code) {
                NSInteger c = [code integerValue];
                switch (c) {
                    case 200:
                        [self loadUserAndExit];
                        break;
                    case 400:{
                        NSString *errorType = [responseObject valueForKeyPath:@"meta.errorType"];
                        if ([@"weak_password" isEqualToString:errorType]) {
                            [self showErrorInfo:@"Invalid password." dockOn:_inputPassword];
                        } else if ([@"invalid_username" isEqualToString:errorType]) {
                            [self showErrorInfo:@"Invalid name." dockOn:_inputPassword];
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
        [self hideIndicator];
        //error.domain
        switch (error.code) {
            case NSURLErrorCannotFindHost: //-1003
            case NSURLErrorCannotConnectToHost: //-1004
            case NSURLErrorNetworkConnectionLost: //-1005
            case NSURLErrorDNSLookupFailed: //-1006
            case NSURLErrorHTTPTooManyRedirects: //-1007
            case NSURLErrorResourceUnavailable: //-1008
            case NSURLErrorNotConnectedToInternet: //-1009
            case NSURLErrorRedirectToNonExistentLocation: //-1010
                [self showInlineError:@"Failed to connect server." with:@"Please retry or wait awhile."];
                break;
                
            default:
                break;
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
                                              NSDictionary *params = @{@"oauth_expires": [NSString stringWithFormat:@"%.0f", session.accessTokenData.expirationDate.timeIntervalSince1970]};
                                              
                                              MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                                              hud.labelText = @"Signing in Facebook";
                                              hud.mode = MBProgressHUDModeCustomView;
                                              EXSpinView *bigspin = [[EXSpinView alloc] initWithPoint:CGPointMake(0, 0) size:40];
                                              [bigspin startAnimating];
                                              hud.customView = bigspin;
                                              [bigspin release];
                                              
                                              [[EFAPIServer sharedInstance] reverseAuth:kProviderFacebook withToken:session.accessTokenData.accessToken andParam:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                                  [MBProgressHUD hideHUDForView:self.view animated:YES];
                                                  if ([operation.response statusCode] == 200 && [responseObject isKindOfClass:[NSDictionary class]]){
                                                      
                                                      NSNumber *code = [responseObject valueForKeyPath:@"meta.code"];
                                                      switch ([code integerValue]) {
                                                          case 200:{
                                                              [self loadUserAndExit];
                                                              // ask for more permissions
                                                              //                            NSArray *permissions = @[@"user_photos", @"friends_photos"];
                                                              //                            [[FBSession activeSession] requestNewReadPermissions:permissions completionHandler:^(FBSession *session, NSError *error) {
                                                              //                                ;
                                                              //                            }];
                                                          }
                                                              break;
                                                          case 400:{
                                                              if ([@"invalid_token" isEqualToString:[responseObject valueForKeyPath:@"meta.errorType"]] ) {
                                                                  [self showInlineError:@"Invalid token" with:@"There is something wrong. Please try again later."];
                                                                  
                                                                  [self syncFBAccount];
                                                                  
                                                              }
                                                          }
                                                          default:
                                                              break;
                                                      }
                                                  }
                                              } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                  [MBProgressHUD hideHUDForView:self.view animated:YES];
                                                  //                    NSLog(@"login failure with %@", error);
                                                  // kCFURLErrorCannotDecodeContentData = -1016, unexpected error
                                              }];
                                          }
                                              break;
                                              
                                          case FBSessionStateClosedLoginFailed:
                                              [self showInlineError:@"Login Failed" with:@"There is something wrong. Please try again later."];
                                              
                                              [self syncFBAccount];
                                              break;
                                          default:
                                              break;
                                      }
                                      
                                      
                                  }];
    
}

- (void)twitterSignIn:(id)sender
{
    ACAccountType *twitterType = [_accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    
    ACAccountStoreRequestAccessCompletionHandler handler = ^(BOOL granted, NSError *error) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (granted) {
                self.accounts = [_accountStore accountsWithAccountType:twitterType];
                if ([TWAPIManager isLocalTwitterAccountAvailable] && _accounts.count > 0) {
                    if ([TWAPIManager isLocalTwitterAccountAvailable]) {
                        if (_accounts.count > 1) {
                            UIActionSheet *sheet = [UIActionSheet actionSheetWithTitle:@"Choose an Account"];
                            for (ACAccount *acct in _accounts) {
                                [sheet addButtonWithTitle:acct.username handler:^{
                                    [self performReverseAuthForAccount:acct];
                                }];
                            }
                            sheet.cancelButtonIndex = [sheet setCancelButtonWithTitle:@"Cancel" handler:^{
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
                        [viewController release];
                    } else {
                        return;
                    }
//                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No Accounts" message:@"Please configure a Twitter account in Settings.app" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
//                    [alert show];
                }
            } else {
                
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Set up Twitter account" message:@"Please allow EXFE to use your Twitter account. Go to the Settings app, select Twitter to set up." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
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
    Provider provider = [Util matchedProvider:_inputIdentity.text];
    NSDictionary *dict = [Util parseIdentityString:_inputIdentity.text byProvider:provider];
    NSString *external_username = [dict valueForKeyPath:@"external_username"];
    
    CGPoint p = [sender convertPoint:sender.center toView:self.rootView];
    [self showIndicatorAt:CGPointMake(285, p.y)];
    [[EFAPIServer sharedInstance] forgetPassword:external_username with:provider success:^(AFHTTPRequestOperation *operation, id responseObject) {
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
                                msg = @"Password reset request sent, please check your message for instructions.";
                                break;
                                
                            default:
                                msg = @"Password reset request sent, please check your email for instructions.";
                                break;
                        }
                        [UIAlertView showAlertViewWithTitle:@"Forget Password?" message:msg cancelButtonTitle:@"OK" otherButtonTitles:nil handler:nil];
                    } break;
                    case 400:{
                        NSString *errorType = [responseObject valueForKeyPath:@"meta.errorType"];
                        if ([@"identity_does_not_exist" isEqualToString:errorType]
                                  || [@"identity_is_being_verified" isEqualToString:errorType]){
                            [self showInlineError:@"Invalid account." with:@"Please check your input above."];
                        }
                    }  break;
                    case 429:{
                        NSString *msg = nil;
                        switch (provider) {
                            case kProviderPhone:
                                msg = @"Request should be responded usually in seconds, please wait for awhile.";
                                break;
                                
                            default:
                                msg = @"Request should be responded usually in seconds, please wait for awhile. Please also check your spam email folder, it might be mistakenly filtered by your mailbox.";
                                break;
                        }
                        [self showInlineError:@"Request too frequently." with:msg];
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
        [self hideIndicator];
        //error.domain
        switch (error.code) {
            case NSURLErrorCannotFindHost: //-1003
            case NSURLErrorCannotConnectToHost: //-1004
            case NSURLErrorNetworkConnectionLost: //-1005
            case NSURLErrorDNSLookupFailed: //-1006
            case NSURLErrorHTTPTooManyRedirects: //-1007
            case NSURLErrorResourceUnavailable: //-1008
            case NSURLErrorNotConnectedToInternet: //-1009
            case NSURLErrorRedirectToNonExistentLocation: //-1010
                [self showInlineError:@"Failed to connect server." with:@"Please retry or wait awhile."];
                break;
                
            default:
                break;
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
            textField.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:18];
        }
    }
    else
    {
        //Set textfield placeholder font (or so it appears)
        textField.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:18];
    }
    
    if (textField.tag == kViewTagInputIdentity) {
        NSString *identity = _inputIdentity.text;
        
        if ([identity isEqualToString:self.lastInputIdentity]) {
            return;
        } else {
            self.lastInputIdentity = identity;
            [self identityDidChange:identity];
        }
    }
}

#pragma mark OAuthlogin Delegate
- (void)OAuthloginViewControllerDidCancel:(UIViewController *)oauthlogin {
    [oauthlogin dismissModalViewControllerAnimated:YES];
    [oauthlogin release];
    oauthlogin = nil;
}

-(void)OAuthloginViewControllerDidSuccess:(OAuthLoginViewController *)oauthloginViewController userid:(NSString*)userid username:(NSString*)username external_id:(NSString*)external_id token:(NSString*)token
{
    [self.navigationController dismissModalViewControllerAnimated:YES];
    
    //save token/user id/ username
    if ([userid integerValue] > 0 && token.length > 0) {
        EFAPIServer *server = [EFAPIServer sharedInstance];
        server.user_id = [userid integerValue];
        server.user_token = token;
//        server.user_name = username;
        [server saveUserData];
    }
    
    [self loadUserAndExit];
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
    hud.labelText = @"Signing in Twitter";
    hud.mode = MBProgressHUDModeCustomView;
    EXSpinView *bigspin = [[EXSpinView alloc] initWithPoint:CGPointMake(0, 0) size:40];
    [bigspin startAnimating];
    hud.customView = bigspin;
    [bigspin release];
    
    [_apiManager performReverseAuthForAccount:acct withHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error){
        if (responseData) {
            NSString *responseStr = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
            NSDictionary *params = [Util splitQuery:responseStr];
            
            [[EFAPIServer sharedInstance] reverseAuth:kProviderTwitter withToken:[params valueForKey:@"oauth_token"] andParam:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
                [MBProgressHUD hideHUDForView:self.view animated:YES];
                if ([operation.response statusCode] == 200 && [responseObject isKindOfClass:[NSDictionary class]]){
                    
                    NSNumber *code = [responseObject valueForKeyPath:@"meta.code"];
                    if ([code integerValue] == 200) {
                        [self loadUserAndExit];
                    }
                    //400: invalid_token
                    //400: no_provider
                    //400: unsupported_provider
                }
                
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                [MBProgressHUD hideHUDForView:self.view animated:YES];
//                NSLog(@"login failure with %@", error);
                // kCFURLErrorCannotDecodeContentData = -1016, unexpected error
            }];
        } else {
            [MBProgressHUD hideHUDForView:self.view animated:YES];
//            NSLog(@"Reverse Auth process failed. Error returned was: %@\n", [error localizedDescription]);
        }
    }];
}

@end
