//
//  EFAddIdentityViewController.m
//  EXFE
//
//  Created by Stony Wang on 13-6-3.
//
//

#import "EFAddIdentityViewController.h"
#import <QuartzCore/QuartzCore.h>
#import <BlocksKit/BlocksKit.h>
#import <Social/Social.h>
#import <Twitter/Twitter.h>
#import <Accounts/Accounts.h>
#import <FacebookSDK/FacebookSDK.h>
#import "EFAPIServer.h"
#import "TWAPIManager.h"
#import "CCTemplate.h"
#import "EXGradientToolbarView.h"
#import "CSLinearLayoutView.h"
#import "EFIdentityTextField.h"
#import "Util.h"
#import "UILabel+EXFE.h"
#import "TTTAttributedLabel.h"
#import "MBProgressHUD.h"
#import "EXSpinView.h"
#import "EFAPI.h"
#import "OAuthLoginViewController.h"
#import "EFKit.h"

typedef NS_ENUM(NSUInteger, EFViewTag) {
    kViewTagNone,
    kViewTagInputIdentity = 11,
    kViewTagButtonStart = 21,
    kViewTagVerificationTitle = 31,
    kViewTagVerificationDescription = 32,
    kViewTagErrorHint = 41,
    kViewTagErrorInline = 42,
    kViewTagSnsGroup = 51,
    kViewTagSnsFacebook = 52,
    kViewTagSnsTwitter = 53
};

@interface EFAddIdentityViewController ()

@property (nonatomic, strong) EXGradientToolbarView *toolbar;
@property (nonatomic, strong) CSLinearLayoutView *rootView;
@property (nonatomic, strong) UITextField *inputIdentity;
@property (nonatomic, strong) UIImageView *imageIdentity;
@property (nonatomic, strong) UIButton *btnStart;

@property (nonatomic, strong) UILabel *labelVerifyTitle;
@property (nonatomic, strong) UILabel *labelVerifyDescription;

@property (nonatomic, strong) UILabel *hintError;
@property (nonatomic, strong) TTTAttributedLabel *inlineError;
@property (nonatomic, strong) UIActivityIndicatorView *indicator;
@property (nonatomic, strong) UIImageView *textFieldFrame;

@property (nonatomic, strong) UIButton *btnFacebook;
@property (nonatomic, strong) UIButton *btnTwitter;

@property (nonatomic, strong) NSMutableDictionary *identityCache;


@property (nonatomic, copy) NSString *lastInputIdentity;
@property (nonatomic, strong) ACAccountStore *accountStore;
@property (nonatomic, strong) TWAPIManager *apiManager;
@property (nonatomic, strong) NSArray *accounts;

@end

@implementation EFAddIdentityViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _accountStore = [[ACAccountStore alloc] init];
        _apiManager = [[TWAPIManager alloc] init];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [Flurry logEvent:@"ADD_IDENTITY"];
    CGRect a = [UIScreen mainScreen].applicationFrame;
    
    self.toolbar = [[EXGradientToolbarView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];
    [self.toolbar.layer setShadowColor:[UIColor blackColor].CGColor];
    [self.toolbar.layer setShadowOpacity:0.8];
    [self.toolbar.layer setShadowRadius:3.0];
    [self.toolbar.layer setShadowOffset:CGSizeMake(0, 0)];
    
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, CGRectGetWidth(self.toolbar.bounds) - 20, CGRectGetHeight(self.toolbar.bounds))];
    title.text = NSLocalizedString(@"Add identity", nil);
    title.textAlignment = NSTextAlignmentCenter;
    title.textColor = [UIColor COLOR_CARBON];
    title.shadowColor = [UIColor COLOR_WHITE];
    title.shadowOffset = CGSizeMake(0, 1);
    title.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:20];
    [self.toolbar addSubview:title];
    [self.view addSubview:self.toolbar];
    
    UIButton *btnBack = [UIButton buttonWithType:UIButtonTypeCustom ];
    [btnBack setFrame:CGRectMake(0, 0, 20, 44)];
    btnBack.backgroundColor = [UIColor COLOR_WA(0x33, 0xAA)];
    [btnBack setImage:[UIImage imageNamed:@"back.png"] forState:UIControlStateNormal];
    [btnBack setImage:[UIImage imageNamed:@"back_pressed.png"] forState:UIControlStateHighlighted];
    [btnBack addTarget:self action:@selector(gotoBack:) forControlEvents:UIControlEventTouchUpInside];
    [self.view  addSubview:btnBack];
    
    // create the linear layout view
    CSLinearLayoutView *linearLayoutView = [[CSLinearLayoutView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.toolbar.frame), CGRectGetWidth(a), CGRectGetHeight(a) - CGRectGetHeight(self.toolbar.frame))];
    linearLayoutView.orientation = CSLinearLayoutViewOrientationVertical;
    linearLayoutView.alwaysBounceVertical = YES;
    self.rootView = linearLayoutView;
    [self.view addSubview:linearLayoutView];
    
    {// TextField Frame
        UIImage *img = [[UIImage imageNamed:@"textfield.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(15, 9, 15, 9)];
        UIImageView *imageView = [[UIImageView alloc] initWithImage:img];
        imageView.frame = CGRectMake(15, 20, 290, 50);
        self.textFieldFrame = imageView;
        [self.rootView addSubview:self.textFieldFrame];
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
        
//        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
//        button.backgroundColor = [UIColor clearColor];
//        [button addTarget:self action:@selector(expandIdentity:) forControlEvents:UIControlEventTouchUpInside];
//        [button setImage:[UIImage imageNamed:@"start_tri-00.png"] forState:UIControlStateNormal];
//        NSMutableArray *imgs = [NSMutableArray arrayWithCapacity:30];
//        for (NSUInteger i = 0; i < 30; i++) {
//            NSString *name = [NSString stringWithFormat:@"start_tri-%02u.png", i];
//            [imgs addObject:[UIImage imageNamed:name]];
//        }
//        button.imageView.animationImages = imgs;
//        button.imageView.animationRepeatCount = 0;
//        button.imageView.animationDuration = 1.5;
//        [button.imageView startAnimating];
//        button.contentMode = UIViewContentModeScaleAspectFill;
//        self.extIdentity = button;
//        self.inputIdentity.rightView = self.extIdentity;
//        self.inputIdentity.rightViewMode = UITextFieldViewModeAlways;
        
        CSLinearLayoutItem *item = [CSLinearLayoutItem layoutItemForView:self.inputIdentity];
        item.padding = CSLinearLayoutMakePadding(20.0, 15, 0, 15);
        item.horizontalAlignment = CSLinearLayoutItemHorizontalAlignmentCenter;
        item.fillMode = CSLinearLayoutItemFillModeNormal;
        [linearLayoutView addItem:item];
    }
    
    {// Start button
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(0, 0, 290, 48);
        [btn setTitle:NSLocalizedString(@"Add and verify", nil) forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [btn setTitleShadowColor:[UIColor COLOR_WA(0x00, 0x7F)] forState:UIControlStateNormal];
        btn.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:18];
        btn.titleLabel.shadowOffset = CGSizeMake(0, -1);
        [btn addTarget:self action:@selector(addIdentity:) forControlEvents:UIControlEventTouchUpInside];
        UIImage *btnImage = [UIImage imageNamed:@"btn_blue_44.png"];
        btnImage = [btnImage resizableImageWithCapInsets:(UIEdgeInsets){15, 10, 15, 10}];
        [btn setBackgroundImage:btnImage forState:UIControlStateNormal];
        self.btnStart = btn;
        self.btnStart.tag = kViewTagButtonStart;
        
        CSLinearLayoutItem *item = [CSLinearLayoutItem layoutItemForView:self.btnStart];
        item.padding = CSLinearLayoutMakePadding(10.0, 15, 6, 15);
        item.horizontalAlignment = CSLinearLayoutItemHorizontalAlignmentCenter;
        item.fillMode = CSLinearLayoutItemFillModeNormal;
        [linearLayoutView addItem:item];
    }
    
//    {// Verification Title
//        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 280, 40)];
//        label.text = @"Verification";
//        label.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:21.0];
//        label.backgroundColor = [UIColor clearColor];
//        [label wrapContent];
//        self.labelVerifyTitle = label;
//        self.labelVerifyTitle.tag = kViewTagVerificationTitle;
//    }
//    
//    {// Verification Description
//        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 280, 80)];
//        label.text = @"This number requires verification before proceeding. Verification request is sent, please check your message for instructions.";
//        label.numberOfLines = 0;
//        label.backgroundColor = [UIColor clearColor];
//        label.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:14.0];
//        [label wrapContent];
//        label.lineBreakMode = UILineBreakModeWordWrap;
//        self.labelVerifyDescription = label;
//        self.labelVerifyDescription.tag = kViewTagVerificationDescription;
//    }
    
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
    snsItem.padding = CSLinearLayoutMakePadding(21, 12, 240, 12);
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


#pragma mark - UI Methods

- (void)fillIdentityResp:(NSDictionary*)respDict
{
    NSString *avatar_filename = [respDict valueForKeyPath:@"identity.avatar_filename"];
    if (avatar_filename.length > 0) {
        UIImage *defaultImage = [UIImage imageNamed:@"portrait_default.png"];
        _imageIdentity.contentMode = UIViewContentModeScaleAspectFill;
        
        if (!avatar_filename) {
            _imageIdentity.image = defaultImage;
        } else {
            [[EFDataManager imageManager] loadImageForView:_imageIdentity
                                          setImageSelector:@selector(setImage:)
                                               placeHolder:defaultImage
                                                       key:avatar_filename
                                           completeHandler:nil];
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
    
    NSString* full = [NSString stringWithFormat:@"%@ %@", title, description];
    
    [_inlineError setText:full afterInheritingLabelAttributesAndConfiguringWithBlock:^NSMutableAttributedString *(NSMutableAttributedString *mutableAttributedString) {
        NSRange titleRange = [[mutableAttributedString string] rangeOfString:title options:NSCaseInsensitiveSearch];
        [mutableAttributedString addAttribute:(NSString*)kCTForegroundColorAttributeName value:(id)[[UIColor COLOR_RED_EXFE] CGColor] range:titleRange];
        return mutableAttributedString;
    }];
    
    CSLinearLayoutItem *baseitem = [self.rootView findItemByTag:kViewTagButtonStart];
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
        item.padding = CSLinearLayoutMakePadding(0, 20, 0, 20);
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
    
//    if (_stage != kStageStart) {
//        [self setStage:kStageStart];
//    }
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
            AppDelegate * app = (AppDelegate*)[UIApplication sharedApplication].delegate;
            EFAPIServer *server = app.model.apiServer;
            [server getRegFlagBy:external_username with:provider success:^(AFHTTPRequestOperation *operation, id responseObject) {
                if ([operation.response statusCode] == 200 && [responseObject isKindOfClass:[NSDictionary class]]) {
                    id code = [responseObject valueForKeyPath:@"meta.code"];
                    if (code) {
                        NSInteger type = [code integerValue] / 100;
                        
                        switch (type) {
                            case 2:{
                                // [code integerValue] == 200
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
                            }   break;
                            case 4:{
                            }
                                break;
                            default:
                                break;
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
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [ud removeObjectForKey:@"exfee_updated_at"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:NotificationRefreshUserSelf object:self];
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark -
#pragma mark Button / View Click Handler
- (void)gotoBack:(UIButton*)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)addIdentity:(UIControl *)sender
{
    if (_inputIdentity.text.length == 0) {
        return;
    }
    sender.enabled = NO;
    [self hideInlineError];

    NSString* identity = [_inputIdentity.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    Provider provider = [Util candidateProvider:identity];
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
            sender.enabled = YES;
            return;
        }
    }
    
    provider = [Util matchedProvider:identity];
    if (provider == kProviderUnknown) {
        [self showErrorInfo:NSLocalizedString(@"Invalid identity.", nil) dockOn:_inputIdentity];
        sender.enabled = YES;
        return;
    }
    
    [self showIndicatorAt:CGPointMake(285, sender.center.y) style:UIActivityIndicatorViewStyleWhite];
    NSDictionary *dict = [Util parseIdentityString:_inputIdentity.text byProvider:provider];
    NSString *username = [dict valueForKeyPath:@"external_username"];
    
    AppDelegate * app = (AppDelegate*)[UIApplication sharedApplication].delegate;    
    [app.model.apiServer addIdentityBy:[dict valueForKeyPath:@"external_username"] withProvider:provider success:^(AFHTTPRequestOperation *operation, id responseObject) {
        sender.enabled = YES;
        [self hideIndicator];
        
        if ([operation.response statusCode] == 200 && [responseObject isKindOfClass:[NSDictionary class]]){
            NSNumber *code = [responseObject valueForKeyPath:@"meta.code"];
            if (code) {
                NSInteger type = [code integerValue] / 100;
                
                switch (type) {
                    case 2:{
                        // [code integerValue] == 200
                        NSDictionary *responseobj = [responseObject objectForKey:@"response"];
                        if([responseobj isKindOfClass:[NSDictionary class]]){
                            if([[responseobj objectForKey:@"action"] isEqualToString:@"REDIRECT"] && [responseobj objectForKey:@"url"] != nil){
                                OAuthLoginViewController *oauth = [[OAuthLoginViewController alloc] initWithNibName:@"OAuthLoginViewController" bundle:nil provider:provider];
                                oauth.oAuthURL = [responseobj objectForKey:@"url"];
                                oauth.external_username = username;
                                oauth.onSuccess = ^(NSDictionary *param) {
                                    [self loadUserAndExit];
                                };
                                [self presentModalViewController:oauth animated:YES];
                                
                            }else{
                                NSString * message = NSLocalizedString(@"Verification is sent. Please check your email for instructions.", nil);
                                if (provider == kProviderPhone) {
                                    message = NSLocalizedString(@"Verification is sent. Please check your message for instructions.", nil);
                                }
                                
                                UIAlertView *alertView = [UIAlertView alertViewWithTitle:@"Verification" message:message];
                                [alertView addButtonWithTitle:NSLocalizedString(@"OK", nil) handler:^{
                                    [self loadUserAndExit];
                                }];
                                [alertView show];
                            }
                        }
                    }   break;
                    case 4:{
                        // [code integerValue] == 403
                        NSString *errorType = [responseObject valueForKeyPath:@"meta.errorType"];
                        if ([@"failed" isEqualToString:errorType]) {
                            [self showInlineError:NSLocalizedString(@"Adding invitation failed.", nil) with:NSLocalizedString(@"Please check spell and retry.", nil)];
                        }
                    }
                        break;
                    default:
                        break;
                }
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        sender.enabled = YES;
        [self hideIndicator];
        
        if ([NSURLErrorDomain isEqualToString:error.domain] || [AFNetworkingErrorDomain isEqualToString:error.domain]) {
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
                case NSURLErrorBadServerResponse: // -1011
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
                                              [app.model.apiServer addReverseAuthIdentity:kProviderFacebook
                                                                                withToken:session.accessTokenData.accessToken
                                                                                 andParam:params
                                                                                  success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                                                                      [MBProgressHUD hideHUDForView:self.view animated:YES];
                                                                                      if ([operation.response statusCode] == 200){
                                                                                          if ([responseObject isKindOfClass:[NSDictionary class]]) {
                                                                                              NSDictionary *body = responseObject;
                                                                                              NSNumber *code = [body valueForKeyPath:@"meta.code"];
                                                                                              if (code) {
                                                                                                  NSInteger c = [code integerValue];
                                                                                                  NSInteger type =  c / 100;
                                                                                                  switch (type) {
                                                                                                      case 2:{
                                                                                                          // [code integerValue] == 200
                                                                                                          [self loadUserAndExit];
                                                                                                          // ask for more permissions
                                                                                                          //                            NSArray *permissions = @[@"user_photos", @"friends_photos"];
                                                                                                          //                            [[FBSession activeSession] requestNewReadPermissions:permissions completionHandler:^(FBSession *session, NSError *error) {
                                                                                                          //                                ;
                                                                                                          //
                                                                                                      }   break;
                                                                                                      case 4:{
                                                                                                          NSString *errorType = [body valueForKeyPath:@"meta.errorType"];
                                                                                                          if ([@"invalid_token" isEqualToString:errorType] ) { // 403
                                                                                                              [self showInlineError:NSLocalizedString(@"Invalid token.", nil) with:NSLocalizedString(@"There is something wrong. Please try again later.", nil)];
                                                                                                              
                                                                                                              [self syncFBAccount];
                                                                                                              
                                                                                                          } if ([@"invalid_oauth_token" isEqualToString:errorType]) { // 400
                                                                                                              // TODO: ask user to login fb on phone setting
                                                                                                          }
                                                                                                      }
                                                                                                          break;
                                                                                                      default:
                                                                                                          break;
                                                                                                  }
                                                                                              }
                                                                                          }
                                                                                      }
                                                                                  }
                                               
                                                                                  failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                                                      if ([NSURLErrorDomain isEqualToString:error.domain] || [AFNetworkingErrorDomain isEqualToString:error.domain]) {
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
                                                                                              case NSURLErrorBadServerResponse: //-1011
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
                
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Set up Twitter account", nil) message:[NSLocalizedString(@"Please allow {{PRODUCT_APP_NAME}} to use your Twitter account. Go to the Settings app, select Twitter to set up.", nil)  templateFromDict:[Util keywordDict]] delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
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

#pragma mark Textfield Change Notification
- (void)textFieldDidChange:(id)sender
{
    UITextField *textField = sender;
    //If there is text in the text field
    if (textField.text.length > 0)
    {
        //Set textfield font
        textField.font = [UIFont fontWithName:@"HelveticaNeue-Italic" size:18];
    }
    else
    {
        //Set textfield placeholder font (or so it appears)
        textField.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:18];
    }
    
    
    NSString *identity = _inputIdentity.text;
    
    if ([identity isEqualToString:self.lastInputIdentity]) {
        return;
    } else {
        self.lastInputIdentity = identity;
        [self identityDidChange:identity];
    }
    
}

#pragma mark UITextFieldDelegate
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [self hide:_hintError withAnmated:NO];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.btnStart sendActionsForControlEvents: UIControlEventTouchUpInside];
    return NO;
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
            [app.model.apiServer addReverseAuthIdentity:kProviderTwitter withToken:[params valueForKey:@"oauth_token"] andParam:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
                [MBProgressHUD hideHUDForView:self.view animated:YES];
                if ([operation.response statusCode] == 200 && [responseObject isKindOfClass:[NSDictionary class]]){
                    
                    NSNumber *code = [responseObject valueForKeyPath:@"meta.code"];
                    NSInteger type = [code integerValue] / 100;
                    
                    switch (type) {
                        case 2:
                            // [code integerValue] == 200 
                            [self loadUserAndExit];
                            break;
                        case 4:{
                            //400: invalid_token
                            //400: no_provider
                            //400: unsupported_provider
                        }   break;
                        default:
                            break;
                    }
                }
                
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                [MBProgressHUD hideHUDForView:self.view animated:YES];
                if ([NSURLErrorDomain isEqualToString:error.domain] || [AFNetworkingErrorDomain isEqualToString:error.domain]) {
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
                        case NSURLErrorBadServerResponse: //-1011
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
            if ([NSURLErrorDomain isEqualToString:error.domain] || [AFNetworkingErrorDomain isEqualToString:error.domain]) {
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
                    case NSURLErrorBadServerResponse: //-1011
                    case NSURLErrorServerCertificateUntrusted: //-1202
                        [Util showConnectError:error delegate:nil];
                        //                        [self showInlineError:@"Failed to connect twitter server." with:@"Please retry or wait awhile."];
                        break;
                    case NSURLErrorUserCancelledAuthentication:
                        [self showInlineError:NSLocalizedString(@"Authorization failed.", nil) with:NSLocalizedString(@"Please check your network connection and account setting in Settings app.", nil)];
                    default:
                        break;
                }
            }
            
        }
    }];
}


@end
