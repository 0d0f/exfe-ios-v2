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
    [textIdentity release];
    
    UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    [imgView.layer setCornerRadius:4.0];
    [imgView.layer setMasksToBounds:YES];
    imgView.hidden = YES;
    self.imageIdentity = imgView;
    self.inputIdentity.leftView = imgView;
    self.inputIdentity.leftViewMode = UITextFieldViewModeAlways;
    [imgView release];
    
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    btn.backgroundColor = [UIColor blueColor];
    [btn addTarget:self action:@selector(expandIdentity:) forControlEvents:UIControlEventTouchUpInside];
    self.extIdentity = btn;
    self.inputIdentity.rightView = btn;
    self.inputIdentity.rightViewMode = UITextFieldViewModeAlways;
    [btn release];
    
    UITextField *textPwd = [[EFPasswordField alloc] initWithFrame:CGRectMake(15, 85, 290, 50)];
    textPwd.borderStyle = UITextBorderStyleRoundedRect;
    textPwd.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    textPwd.hidden = YES;
    self.inputPassword = textPwd;
    [self.view addSubview:self.inputPassword];
    [textPwd release];
    
    
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

- (void)expandIdentity:(id)sender
{
    if (stage == 0){
        if (_inputIdentity) {
            // start query
            
            
            // show rest login form
            _imageIdentity.hidden = NO;
            _imageIdentity.image = [UIImage imageNamed:@"portrait_default.png"];
            _inputPassword.hidden = NO;
        }
    
    }
    
}

@end
