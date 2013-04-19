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
#import "EFPasswordField.h"
#import "EFAPIServer.h"
#import "Util.h"
#import "Identity+EXFE.h"
#import "ImgCache.h"
#import "CSLinearLayoutView.h"
#import "OAuthLoginViewController.h"
#import "SigninDelegate.h"
#import "UILabel+EXFE.h"


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
    kViewTagErrorHint = 41
    
};

@interface EFSignInViewController (){

    EFStage _stage;
    SigninDelegate *_signindelegate;
   
}
@property  (nonatomic, copy) NSString *lastInputIdentity;
@end

@implementation EFSignInViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _stage = kStageStart;
        _signindelegate = [[SigninDelegate alloc] init];
        _signindelegate.parent = self;
        self.lastInputIdentity = @"";
        self.identityCache = [NSMutableDictionary dictionaryWithCapacity:30];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    CGRect appFrame = [[UIScreen mainScreen] applicationFrame];
    [self.view setFrame:CGRectMake(0, 36, appFrame.size.width, appFrame.size.height - 36)];
    
    self.view.backgroundColor = [UIColor grayColor];
    
    // create the linear layout view
    CSLinearLayoutView *linearLayoutView = [[[CSLinearLayoutView alloc] initWithFrame:self.view.bounds] autorelease];
    linearLayoutView.orientation = CSLinearLayoutViewOrientationVertical;
    self.rootView = linearLayoutView;
    [self.view addSubview:linearLayoutView];
    
    {// Input Identity Field
        UITextField *textfield = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 290, 50)];
        textfield.placeholder = @"Enter email or phone";
        textfield.borderStyle = UITextBorderStyleRoundedRect;
        textfield.autocapitalizationType = UITextAutocapitalizationTypeNone;
        textfield.keyboardType = UIKeyboardTypeEmailAddress;
        textfield.font = [UIFont fontWithName:@"HelveticaNeue-Italic" size:18];
        textfield.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        [textfield addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
        self.inputIdentity = textfield;
        self.inputIdentity.tag = kViewTagInputIdentity;
        //    [self.view addSubview:self.inputIdentity];
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
        imageView.layer.cornerRadius = 4.0;
        imageView.layer.masksToBounds = YES;
        imageView.image = [UIImage imageNamed:@"identity_email_18_grey.png"];
        imageView.contentMode = UIViewContentModeCenter;
        self.imageIdentity = imageView;
        self.inputIdentity.leftView = self.imageIdentity;
        self.inputIdentity.leftViewMode = UITextFieldViewModeAlways;
        
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
        button.backgroundColor = [UIColor blueColor];
        [button addTarget:self action:@selector(expandIdentity:) forControlEvents:UIControlEventTouchUpInside];
        self.extIdentity = button;
        self.inputIdentity.rightView = self.extIdentity;
        self.inputIdentity.rightViewMode = UITextFieldViewModeAlways;
        
        CSLinearLayoutItem *item = [CSLinearLayoutItem layoutItemForView:self.inputIdentity];
        item.padding = CSLinearLayoutMakePadding(10.0, 15, 5, 15);
        item.horizontalAlignment = CSLinearLayoutItemHorizontalAlignmentCenter;
        item.fillMode = CSLinearLayoutItemFillModeNormal;
        [linearLayoutView addItem:item];
    }
    
    {// Input Password Field
        UITextField *txtfield = [[EFPasswordField alloc] initWithFrame:CGRectMake(0, 0, 290, 50)];
        txtfield.borderStyle = UITextBorderStyleRoundedRect;
        txtfield.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        self.inputPassword = txtfield;
        self.inputPassword.tag = kViewTagInputPassword;
    }
    
    {// Input Username
        UITextField *txtfield = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 290, 50)];
        txtfield.borderStyle = UITextBorderStyleRoundedRect;
        txtfield.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        self.inputUsername = txtfield;
        self.inputUsername.tag = kViewTagInputUserName;
    }
    
    {// Start button
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(0, 0, 290, 48);
        [btn setTitle:@"Start" forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(signIn:) forControlEvents:UIControlEventTouchUpInside];
        UIImage *btnImage = [UIImage imageNamed:@"btn_blue_30inset.png"];
        btnImage = [btnImage resizableImageWithCapInsets:(UIEdgeInsets){15, 10, 15, 10}];
        [btn setBackgroundImage:btnImage forState:UIControlStateNormal];
        self.btnStart = btn;
        self.btnStart.tag = kViewTagButtonStart;
    }
    
    {// Start with new account
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(0, 0, 290, 48);
        [btn setTitle:@"Start with new account" forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(signUp:) forControlEvents:UIControlEventTouchUpInside];
        UIImage *btnImage = [UIImage imageNamed:@"btn_blue_30inset.png"];
        btnImage = [btnImage resizableImageWithCapInsets:(UIEdgeInsets){15, 10, 15, 10}];
        [btn setBackgroundImage:btnImage forState:UIControlStateNormal];
        self.btnStartNewUser = btn;
        self.btnStartNewUser.tag = kViewTagButtonNewUser;
    }
    
    {// Start over
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(0, 0, 290, 48);
        [btn setTitle:@"Start Over" forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(startOver:) forControlEvents:UIControlEventTouchUpInside];
        UIImage *btnImage = [UIImage imageNamed:@"btn_blue_30inset.png"];
        btnImage = [btnImage resizableImageWithCapInsets:(UIEdgeInsets){15, 10, 15, 10}];
        [btn setBackgroundImage:btnImage forState:UIControlStateNormal];
        self.btnStartOver = btn;
        self.btnStartOver.tag = kViewTagButtonNewUser;
    }
    
    {// Verification Title
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 290, 40)];
        label.text = @"Verification";
        label.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:21.0];
        [label wrapContent];
        self.labelVerifyTitle = label;
        self.labelVerifyTitle.tag = kViewTagVerificationTitle;
    }
    
    {// Verification Description
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 290, 80)];
        label.text = @"This number requires verification before proceeding. Verification request sent, please check your message for instructions.";
        label.numberOfLines = 0;
        label.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:14.0];
        [label wrapContent];
        label.lineBreakMode = UILineBreakModeWordWrap;
        self.labelVerifyDescription = label;
        self.labelVerifyDescription.tag = kViewTagVerificationDescription;
    }
    
    CSLinearLayoutView *snsLayoutView = [[[CSLinearLayoutView alloc] initWithFrame:CGRectMake(0, 0, 296, 106)] autorelease];
    snsLayoutView.backgroundColor = [UIColor whiteColor];
    snsLayoutView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    snsLayoutView.layer.borderWidth = 3.0;
    snsLayoutView.layer.masksToBounds = YES;
    snsLayoutView.layer.cornerRadius = 6;
    snsLayoutView.orientation = CSLinearLayoutViewOrientationHorizontal;
    
    CSLinearLayoutItem *snsItem = [CSLinearLayoutItem layoutItemForView:snsLayoutView];
    snsItem.padding = CSLinearLayoutMakePadding(5, 12, 5, 12);
    snsItem.horizontalAlignment = CSLinearLayoutItemHorizontalAlignmentCenter;
    snsItem.fillMode = CSLinearLayoutItemFillModeNormal;
    [linearLayoutView addItem:snsItem];
    
    {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        button.frame = CGRectMake(0, 0, 50, 50);
        [button setTitle:@"Facebook" forState:UIControlStateNormal];
        [button addTarget:self action:@selector(facebookSignIn:) forControlEvents:UIControlEventTouchUpInside];
        self.btnFacebook = button;
        self.btnFacebook.tag = 21;
        //    [self.view addSubview:self.btnFacebook];
        CSLinearLayoutItem *item = [CSLinearLayoutItem layoutItemForView:self.btnFacebook];
        item.padding = CSLinearLayoutMakePadding(23, 68, 0, 30);
        item.horizontalAlignment = CSLinearLayoutItemHorizontalAlignmentCenter;
        item.fillMode = CSLinearLayoutItemFillModeNormal;
        [snsLayoutView addItem:item];
        
    }
    
    {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        button.frame = CGRectMake(0, 0, 50, 50);
        [button setTitle:@"Twitter" forState:UIControlStateNormal];
        [button addTarget:self action:@selector(twitterSignIn:) forControlEvents:UIControlEventTouchUpInside];
        self.btnTwitter = button;
        self.btnTwitter.tag = 22;
        //    [self.view addSubview:self.btnTwitter];
        CSLinearLayoutItem *item = [CSLinearLayoutItem layoutItemForView:self.btnTwitter];
        item.padding = CSLinearLayoutMakePadding(23, 30, 0, 0);
        item.horizontalAlignment = CSLinearLayoutItemHorizontalAlignmentCenter;
        item.fillMode = CSLinearLayoutItemFillModeNormal;
        [snsLayoutView addItem:item];
    }
    
    [self setStage:kStageStart];

}

- (void)viewDidAppear:(BOOL)animated
{
    CGRect appFrame = [[UIScreen mainScreen] applicationFrame];

    
    
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
    self.btnFacebook = nil;
    self.btnTwitter = nil;
    self.identityCache = nil;
    [_signindelegate release];
    [super dealloc];
}

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
            
            break;
        case kStageSignIn:{
            // show rest login form
            [self.rootView removeItem:[self.rootView findItemByTag:kViewTagInputUserName]];
            [self.rootView removeItem:[self.rootView findItemByTag:kViewTagButtonNewUser]];
            [self.rootView removeItem:[self.rootView findItemByTag:kViewTagButtonStartOver]];
            [self.rootView removeItem:[self.rootView findItemByTag:kViewTagVerificationTitle]];
            [self.rootView removeItem:[self.rootView findItemByTag:kViewTagVerificationDescription]];
            [self.rootView removeItem:[self.rootView findItemByTag:kViewTagErrorHint]];
            
            CSLinearLayoutItem *baseItem = [self.rootView findItemByTag:self.inputIdentity.tag];
            
            CSLinearLayoutItem *item1 = [self.rootView findItemByTag:self.inputPassword.tag];
            if (item1 == nil) {
                item1 = [CSLinearLayoutItem layoutItemForView:self.inputPassword];
                item1.padding = CSLinearLayoutMakePadding(5, 15, 5, 15);
                item1.horizontalAlignment = CSLinearLayoutItemHorizontalAlignmentCenter;
                item1.fillMode = CSLinearLayoutItemFillModeNormal;
                [self.rootView insertItem:item1 afterItem:baseItem];
            }
            
            CSLinearLayoutItem *item2 = [self.rootView findItemByTag:self.btnStart.tag];
            if (item2 == nil){
                item2 = [CSLinearLayoutItem layoutItemForView:self.btnStart];
                item2.padding = CSLinearLayoutMakePadding(5, 15, 5, 15);
                item2.horizontalAlignment = CSLinearLayoutItemHorizontalAlignmentCenter;
                item2.fillMode = CSLinearLayoutItemFillModeNormal;
                [self.rootView insertItem:item2 afterItem:item1];
            }
            
        }    break;
        case kStageSignUp:{
            [self.rootView removeItem:[self.rootView findItemByTag:kViewTagButtonStart]];
            [self.rootView removeItem:[self.rootView findItemByTag:kViewTagButtonStartOver]];
            [self.rootView removeItem:[self.rootView findItemByTag:kViewTagVerificationTitle]];
            [self.rootView removeItem:[self.rootView findItemByTag:kViewTagVerificationDescription]];
            [self.rootView removeItem:[self.rootView findItemByTag:kViewTagErrorHint]];
           
            CSLinearLayoutItem *baseItem = [self.rootView findItemByTag:self.inputIdentity.tag];
            
            CSLinearLayoutItem *item1 = [self.rootView findItemByTag:self.inputPassword.tag];
            if (item1 == nil) {
                item1 = [CSLinearLayoutItem layoutItemForView:self.inputPassword];
                item1.padding = CSLinearLayoutMakePadding(5, 15, 5, 15);
                item1.horizontalAlignment = CSLinearLayoutItemHorizontalAlignmentCenter;
                item1.fillMode = CSLinearLayoutItemFillModeNormal;
                [self.rootView insertItem:item1 afterItem:baseItem];
            } else {
                [self.rootView moveItem:item1 afterItem:baseItem];
            }
            
            CSLinearLayoutItem *item2 = [self.rootView findItemByTag:self.inputUsername.tag];
            if (item2 == nil) {
                item2 = [CSLinearLayoutItem layoutItemForView:self.inputUsername];
                item2.padding = CSLinearLayoutMakePadding(5, 15, 5, 15);
                item2.horizontalAlignment = CSLinearLayoutItemHorizontalAlignmentCenter;
                item2.fillMode = CSLinearLayoutItemFillModeNormal;
                [self.rootView insertItem:item2 afterItem:item1];
            } else {
                [self.rootView moveItem:item2 afterItem:item1];
            }
            
            CSLinearLayoutItem *item3 = [self.rootView findItemByTag:self.btnStartNewUser.tag];
            if (item3 == nil){
                item3 = [CSLinearLayoutItem layoutItemForView:self.btnStartNewUser];
                item3.padding = CSLinearLayoutMakePadding(5, 15, 5, 15);
                item3.horizontalAlignment = CSLinearLayoutItemHorizontalAlignmentCenter;
                item3.fillMode = CSLinearLayoutItemFillModeNormal;
                [self.rootView insertItem:item3 afterItem:item2];
            } else {
                [self.rootView moveItem:item3 afterItem:item2];
            }
           
        }  break;
        case kStageVerificate:
            [self.rootView removeItem:[self.rootView findItemByTag:kViewTagInputPassword]];
            [self.rootView removeItem:[self.rootView findItemByTag:kViewTagInputUserName]];
            [self.rootView removeItem:[self.rootView findItemByTag:kViewTagButtonStart]];
            [self.rootView removeItem:[self.rootView findItemByTag:kViewTagButtonNewUser]];
//            [self.rootView removeItem:[self.rootView findItemByTag:kViewTagButtonStartOver]];
//            [self.rootView removeItem:[self.rootView findItemByTag:kViewTagVerificationTitle]];
//            [self.rootView removeItem:[self.rootView findItemByTag:kViewTagVerificationDescription]];
            [self.rootView removeItem:[self.rootView findItemByTag:kViewTagErrorHint]];
            
            CSLinearLayoutItem *baseItem = [self.rootView findItemByTag:self.inputIdentity.tag];
            
            CSLinearLayoutItem *item1 = [self.rootView findItemByTag:self.labelVerifyTitle.tag];
            if (item1 == nil) {
                item1 = [CSLinearLayoutItem layoutItemForView:self.labelVerifyTitle];
                item1.padding = CSLinearLayoutMakePadding(5, 15, 0, 15);
                item1.horizontalAlignment = CSLinearLayoutItemHorizontalAlignmentCenter;
                item1.fillMode = CSLinearLayoutItemFillModeNormal;
                [self.rootView insertItem:item1 afterItem:baseItem];
            } else {
                [self.rootView moveItem:item1 afterItem:baseItem];
            }
            
            CSLinearLayoutItem *item2 = [self.rootView findItemByTag:self.labelVerifyDescription.tag];
            if (item2 == nil) {
                item2 = [CSLinearLayoutItem layoutItemForView:self.labelVerifyDescription];
                item2.padding = CSLinearLayoutMakePadding(0, 15, 5, 15);
                item2.horizontalAlignment = CSLinearLayoutItemHorizontalAlignmentCenter;
                item2.fillMode = CSLinearLayoutItemFillModeNormal;
                [self.rootView insertItem:item2 afterItem:item1];
            } else {
                [self.rootView moveItem:item2 afterItem:item1];
            }
            
            CSLinearLayoutItem *item3 = [self.rootView findItemByTag:self.btnStartOver.tag];
            if (item3 == nil){
                item3 = [CSLinearLayoutItem layoutItemForView:self.btnStartOver];
                item3.padding = CSLinearLayoutMakePadding(5, 15, 5, 15);
                item3.horizontalAlignment = CSLinearLayoutItemHorizontalAlignmentCenter;
                item3.fillMode = CSLinearLayoutItemFillModeNormal;
                [self.rootView insertItem:item3 afterItem:item2];
            } else {
                [self.rootView moveItem:item3 afterItem:item2];
            }
            
            break;
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
            _imageIdentity.image = [UIImage imageNamed:@"identity_email_18_grey.png"];
            _imageIdentity.contentMode = UIViewContentModeCenter;
            break;
    }
}

- (void)swithStagebyFlag:(NSString*)flag
{
    if([flag isEqualToString:@"SIGN_UP"] ){
        [self setStage:kStageSignUp];
    } else if([flag isEqualToString:@"VERIFY"] ) {
        [self setStage:kStageVerificate];
    } else if([flag isEqualToString:@"AUTHENTICATE"]){
        
    } else { //(self.regFlag isEqualToString:@"SIGN_IN"])
        [self setStage:kStageSignIn];
    }
}

#pragma mark Click handler
- (void)expandIdentity:(id)sender
{
    NSString* identity = _inputIdentity.text;
    NSDictionary *resp = [self.identityCache objectForKey:identity];
    [self swithStagebyFlag:[resp valueForKey:@"registration_flag"]];
}

- (void)signIn:(id)sender
{
    NSLog(@"Start Sign In");
    if (_inputIdentity.text.length == 0 || _inputPassword.text.length == 0) {
        return;
    }
    NSLog(@"%@ %@", _inputIdentity.text, _inputPassword.text);
    Provider provider = [Util matchedProvider:_inputIdentity.text];
    [[EFAPIServer sharedInstance] signIn:_inputIdentity.text with:provider password:_inputPassword.text success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        if ([operation.response statusCode] == 200 && [responseObject isKindOfClass:[NSDictionary class]]){
            NSNumber *code = [responseObject valueForKeyPath:@"meta.code"];
            if (code) {
                NSInteger c = [code integerValue];
                switch (c) {
                    case 200:
                        NSLog(@"Signed In");
//                        UIViewController *parent = self.parentViewController;
//                        [parent dismissModalViewControllerAnimated:YES];
//
                        [[EFAPIServer sharedInstance] loadMeSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                            AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                            [app SigninDidFinish];
                        }
                                                            failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                                                ;
                                                            }];
                        
                       
                        
                        
                        
                        break;
                    case 403:
                        // login fail
                        break;
                    default:
                        break;
                }
            }
        }
    } failure:nil];
}

- (void)signUp:(id)sender
{
    NSLog(@"Start with new user");
}

- (void)startOver:(id)sender
{
    NSLog(@"Start over");
    [self setStage:kStageStart];
}

- (void)facebookSignIn:(id)sender
{
    NSLog(@"facebook Sign In");
    OAuthLoginViewController *oauth = [[OAuthLoginViewController alloc] initWithNibName:@"OAuthLoginViewController" bundle:nil];
    oauth.provider = @"facebook";
    oauth.delegate = _signindelegate;
    [self presentModalViewController:oauth animated:YES];
}

- (void)twitterSignIn:(id)sender
{
    NSLog(@"twitter Sign In");
    OAuthLoginViewController *oauth = [[OAuthLoginViewController alloc] initWithNibName:@"OAuthLoginViewController" bundle:nil];
    oauth.provider = @"twitter";
    oauth.delegate = _signindelegate;
    [self presentModalViewController:oauth animated:YES];
}

#pragma mark Textfiled Change
- (void)textFieldDidChange:(id)sender
{
    NSLog(@"TextChange notification");
    NSString *identity = _inputIdentity.text;
    
    if ([identity isEqualToString:self.lastInputIdentity]) {
        return;
    } else {
        self.lastInputIdentity = identity;
        [self identityDidChange:identity];
    }
}

- (void)identityDidChange:(NSString*)identity
{
    NSLog(@"Identity text did change");
    
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
            NSInteger start = MAX(identity.length, 3) - 3;
            NSString *domainext = [identity substringFromIndex:start];
            if([Util isCommonDomainName:domainext]){
                [self performSelector:@selector(checkIdentityFlag:) withObject:identity afterDelay:0.1];
            } else {
                [self performSelector:@selector(checkIdentityFlag:) withObject:identity afterDelay:0.8];
            }
        }
    }
   
}

- (void)checkIdentityFlag:(NSString*)identity
{
    if (identity.length > 0) {
        // start query
        Provider provider = [Util matchedProvider:identity];
        if (provider != kProviderUnknown) {
            EFAPIServer *server = [EFAPIServer sharedInstance];
            [server getRegFlagBy:identity with:provider success:^(AFHTTPRequestOperation *operation, id responseObject) {
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
                            NSLog(@"get flag fail");
                        }
                    }
                }
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                NSLog(@"get flag fail");
            }];
        }
    }
}
@end
