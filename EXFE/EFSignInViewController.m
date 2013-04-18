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

typedef NS_ENUM(NSUInteger, EFStage){
    kStageStart,
    kStageSignIn,
    kStageSignUp,
    kStageVerificate
};

@interface EFSignInViewController (){

    EFStage _stage;
    
}
@end

@implementation EFSignInViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _stage = kStageStart;
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
    
    UITextField *textIdentity = [[UITextField alloc] initWithFrame:CGRectMake(15, 30, 290, 50)];
    textIdentity.placeholder = @"Enter email or phone";
    textIdentity.borderStyle = UITextBorderStyleRoundedRect;
    textIdentity.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    [textIdentity addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    self.inputIdentity = textIdentity;
    [self.view addSubview:self.inputIdentity];
    
    UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    [imgView.layer setCornerRadius:4.0];
    [imgView.layer setMasksToBounds:YES];
    imgView.image = [UIImage imageNamed:@"identity_email_18_grey.png"];
    imgView.contentMode = UIViewContentModeCenter;
    self.imageIdentity = imgView;
    self.inputIdentity.leftView = imgView;
    self.inputIdentity.leftViewMode = UITextFieldViewModeAlways;
    
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    btn.backgroundColor = [UIColor blueColor];
    [btn addTarget:self action:@selector(expandIdentity:) forControlEvents:UIControlEventTouchUpInside];
    self.extIdentity = btn;
    self.inputIdentity.rightView = btn;
    self.inputIdentity.rightViewMode = UITextFieldViewModeAlways;
    
    UITextField *textPwd = [[EFPasswordField alloc] initWithFrame:CGRectMake(15, 85, 290, 50)];
    textPwd.borderStyle = UITextBorderStyleRoundedRect;
    textPwd.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    textPwd.hidden = YES;
    self.inputPassword = textPwd;
    [self.view addSubview:self.inputPassword];
    
    
    UIButton *btnS = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    btnS.frame = CGRectMake(15, 140, 290, 48);
    [btnS setTitle:@"Start" forState:UIControlStateNormal];
    btnS.hidden = YES;
    [btnS addTarget:self action:@selector(signIn:) forControlEvents:UIControlEventTouchUpInside];
    self.btnStart = btnS;
    [self.view addSubview:self.btnStart];
    
    UIButton *btnF = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    btnF.frame = CGRectMake(45, 200, 50, 50);
    [btnF setTitle:@"Facebook" forState:UIControlStateNormal];
//    btnF.hidden = YES;
    [btnF addTarget:self action:@selector(facebookSignIn:) forControlEvents:UIControlEventTouchUpInside];
    self.btnFacebook = btnF;
    [self.view addSubview:self.btnFacebook];
    
    UIButton *btnT = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    btnT.frame = CGRectMake(205, 200, 50, 50);
    [btnT setTitle:@"Twitter" forState:UIControlStateNormal];
//    btnT.hidden = YES;
    [btnT addTarget:self action:@selector(twitterSignIn:) forControlEvents:UIControlEventTouchUpInside];
    self.btnTwitter = btnT;
    [self.view addSubview:self.btnTwitter];
    
    
    
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
    [super dealloc];
}

- (void)setStage:(EFStage)stage
{
    _stage = stage;
    switch (_stage){
        case kStageStart:
            break;
        case kStageSignIn:
            // show rest login form
            _inputPassword.hidden = NO;
            _btnStart.hidden = NO;
            break;
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

- (void)fillIdentityImage:(NSDictionary*)identityDict
{
    Provider provider =  [Identity getProviderCode: [identityDict valueForKeyPath:@"provider"]];
    
    //                                NSString *iconname=[NSString stringWithFormat:@"identity_%@_18_grey.png",provider];
    //                                identityLeftIcon.image=[UIImage imageNamed:iconname];
    
    switch (provider) {
        case kProviderEmail:{
            NSString *avatar_filename = [identityDict valueForKeyPath:@"avatar_filename"];
            if (avatar_filename.length > 0) {
                UIImage *def = [UIImage imageNamed:@"portrait_default.png"];
                _imageIdentity.contentMode = UIViewContentModeScaleAspectFill;
                [[ImgCache sharedManager] fillAvatar:_imageIdentity with:avatar_filename byDefault:def];
            } else {
                _imageIdentity.image = [UIImage imageNamed:@"identity_email_18_grey.png"];
                _imageIdentity.contentMode = UIViewContentModeCenter;
            }
        }   break;
        case kProviderPhone:
            _imageIdentity.image = [UIImage imageNamed:@"identity_phone_18_grey.png"];
            _imageIdentity.contentMode = UIViewContentModeCenter;
            break;
            
        default:
            // no identity info, fall back to default
            _imageIdentity.image = [UIImage imageNamed:@"identity_email_18_grey.png"];
            _imageIdentity.contentMode = UIViewContentModeCenter;
            break;
    }
}

#pragma mark Click handler
- (void)expandIdentity:(id)sender
{
    //if (_stage == 0){
        if([self.regFlag isEqualToString:@"SIGN_IN"] ) {
            [self setStage:kStageSignIn];
        } else if([self.regFlag isEqualToString:@"SIGN_UP"] ){
            [self setStage:kStageSignUp];
        } else if([self.regFlag isEqualToString:@"VERIFY"] ) {
            [self setStage:kStageVerificate];
        } else {
            [self setStage:kStageSignIn];
        }
    
    //}
    
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
                        
                        UIViewController *parent = self.parentViewController;
                        [parent.navigationController popToRootViewControllerAnimated:YES];
                        
                        // request for push
                        
                        // get cross list
                        
                        // get user  profile
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
}

- (void)twitterSignIn:(id)sender
{
    NSLog(@"twitter Sign In");
}

#pragma mark Textfiled Change
- (void)textFieldDidChange:(id)sender
{
    NSLog(@"TextChange");
    NSString *identity = _inputIdentity.text;
    Provider provider = [Util candidateProvider:identity];
    [self fillIdentityImage:@{@"provider": [Identity getProviderString:provider]}];
    if (identity.length > 2) {
        if(provider != kProviderUnknown) {
            [NSObject cancelPreviousPerformRequestsWithTarget:self];
            NSInteger start = MAX(identity.length, 3) - 3;
            NSString *domainext = [identity substringFromIndex:start];
            if([Util isCommonDomainName:domainext]){
                [self performSelector:@selector(checkIdentityFlag:) withObject:identity];
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
                            NSString *flag = [responseObject valueForKeyPath:@"response.registration_flag"];
                            NSDictionary *dic = [responseObject valueForKeyPath:@"response.identity"];
                            
                            if ([_inputIdentity.text isEqualToString:identity]) {
                                if (dic != nil) {
                                    self.identityDict = dic;
                                } else {
                                    self.identityDict = @{@"provider": [Identity getProviderString:provider]};
                                }
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
