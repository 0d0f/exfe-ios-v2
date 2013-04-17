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

@interface EFSignInViewController (){

    NSUInteger stage;
    
}
@end

@implementation EFSignInViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        stage = 0;
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
    self.inputIdentity = textIdentity;
    [self.view addSubview:self.inputIdentity];
    
    UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    [imgView.layer setCornerRadius:4.0];
    [imgView.layer setMasksToBounds:YES];
    imgView.hidden = YES;
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
    btnS.frame = CGRectMake(15, 130, 290, 48);
    btnS.titleLabel.text = @"Start";
    btnS.hidden = YES;
    [btnS addTarget:self action:@selector(signIn:) forControlEvents:UIControlEventTouchUpInside];
    self.btnStart = btnS;
    [self.view addSubview:self.btnStart];
    
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


#pragma mark Click handler
- (void)expandIdentity:(id)sender
{
    if (stage == 0){
        if (_inputIdentity.text.length > 0) {
            
            NSString *identity = _inputIdentity.text;
            // start query
            Provider provider = [Util matchedProvider:identity];
            EFAPIServer *server = [EFAPIServer sharedInstance];
            [server getRegFlagBy:identity and:provider success:^(AFHTTPRequestOperation *operation, id responseObject) {
                if ([operation.response statusCode] == 200 && [responseObject isKindOfClass:[NSDictionary class]]) {
                    id code = [responseObject valueForKeyPath:@"meta.code"];
                    if(code)
                        if([code intValue] == 200) {
                            NSString *registration_flag = [responseObject valueForKeyPath:@"response.registration_flag"];
                            if([registration_flag isEqualToString:@"SIGN_IN"] ) {
//                                [self setSigninView];
                                NSDictionary *identity = [responseObject valueForKeyPath:@"response.identity"];
                                NSString *avatar_filename = [identity valueForKeyPath:@"avatar_filename"];
                                NSString *provider = [identity valueForKeyPath:@"provider"];
                                
//                                NSString *iconname=[NSString stringWithFormat:@"identity_%@_18_grey.png",provider];
//                                identityLeftIcon.image=[UIImage imageNamed:iconname];
//                                
//                                if(avatar_filename!=nil) {
//                                    dispatch_queue_t imgQueue = dispatch_queue_create("fetchimg thread", NULL);
//                                    dispatch_async(imgQueue, ^{
//                                        UIImage *avatar = [[ImgCache sharedManager] getImgFrom:avatar_filename];
//                                        dispatch_async(dispatch_get_main_queue(), ^{
//                                            if(avatar!=nil && ![avatar isEqual:[NSNull null]]) {
//                                                avatarview.image=avatar;
//                                                avatarframeview.image=[UIImage imageNamed:@"signin_portrait_frame.png"];
//                                            }
//                                        });
//                                    });
//                                    dispatch_release(imgQueue);
//                                }
                            }
                            else if([registration_flag isEqualToString:@"SIGN_UP"] ){
//                                [self setSignupView];
                            }
                            else if([registration_flag isEqualToString:@"VERIFY"] ) {
//                                [self setSigninView];
                            }
                        }
                }
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                NSLog(@"get flag fail");
            }];
            
            // show rest login form
            _imageIdentity.hidden = NO;
            _inputPassword.hidden = NO;
            _btnStart.hidden = NO;
            switch (provider) {
                case kProviderEmail:
                    _imageIdentity.image = [UIImage imageNamed:@"portrait_default.png"];
                    break;
                case kProviderPhone:
                    _imageIdentity.image = [UIImage imageNamed:@"identity_phone_18_grey.png"];
                    break;
                    
                default:
                    _imageIdentity.image = nil;
                    break;
            }
        }
    
    }
    
}

- (void)signIn:(id)sender
{
    NSLog(@"Start Sign In");
}

@end
