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


typedef NS_ENUM(NSUInteger, EFStage){
    kStageStart,
    kStageSignIn,
    kStageSignUp,
    kStageVerificate
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
        textfield.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        [textfield addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
        self.inputIdentity = textfield;
        self.inputIdentity.tag = 1;
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
        UITextField *textPwd = [[EFPasswordField alloc] initWithFrame:CGRectMake(0, 0, 290, 50)];
        textPwd.borderStyle = UITextBorderStyleRoundedRect;
        textPwd.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        self.inputPassword = textPwd;
        self.inputPassword.tag = 2;
    }
    
    {
        UIButton *btnS = [UIButton buttonWithType:UIButtonTypeCustom];
        btnS.frame = CGRectMake(0, 0, 290, 48);
        [btnS setTitle:@"Start" forState:UIControlStateNormal];
        [btnS addTarget:self action:@selector(signIn:) forControlEvents:UIControlEventTouchUpInside];
        UIImage *btnImage = [UIImage imageNamed:@"btn_blue_30inset.png"];
        btnImage = [btnImage resizableImageWithCapInsets:(UIEdgeInsets){15, 10, 15, 10}];
        [btnS setBackgroundImage:btnImage forState:UIControlStateNormal];
        self.btnStart = btnS;
        self.btnStart.tag = 3;
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
    self.btnFacebook = nil;
    self.btnTwitter = nil;
    
    [_signindelegate release];
    [super dealloc];
}

- (void)setStage:(EFStage)stage
{
    _stage = stage;
    switch (_stage){
        case kStageStart:
            
            
            break;
        case kStageSignIn:{
            // show rest login form
            
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
        case kStageSignUp:
            
            _inputPassword.hidden = NO;
            _inputUsername.hidden = NO;
            _btnStartNewUser.hidden = NO;
            break;
        case kStageVerificate:
            _inputPassword.hidden = NO;
            _btnStartOver.hidden = NO;
            break;
        default:
            break;
    }
}

- (void)fillIdentityImage:(NSDictionary*)identityDict{
    NSString *avatar_filename = [identityDict valueForKeyPath:@"avatar_filename"];
    if (avatar_filename.length > 0) {
        UIImage *def = [UIImage imageNamed:@"portrait_default.png"];
        _imageIdentity.contentMode = UIViewContentModeScaleAspectFill;
        [[ImgCache sharedManager] fillAvatar:_imageIdentity with:avatar_filename byDefault:def];
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
    [self swithStagebyFlag:self.regFlag];
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
    NSLog(@"TextChange");
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
    if (_stage == kStageStart) {
        Provider provider = [Util candidateProvider:identity];
        [self fillIdentityHint:provider];
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
    } else {
        [self setStage:kStageStart];
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
                            NSString *flag = [responseObject valueForKeyPath:@"response.registration_flag"];
                            NSDictionary *dic = [responseObject valueForKeyPath:@"response.identity"];
                            
                            if ([_inputIdentity.text isEqualToString:identity]) {
                                self.identityDict = dic;
                                self.regFlag = flag;
                                [self fillIdentityImage:self.identityDict];
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
