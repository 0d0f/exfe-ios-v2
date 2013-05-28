//
//  AddIdentityViewController.m
//  EXFE
//
//  Created by huoju on 11/12/12.
//
//

#import "AddIdentityViewController.h"
#import <BlocksKit/BlocksKit.h>
#import <Social/Social.h>
#import <Twitter/Twitter.h>
#import <Accounts/Accounts.h>
#import <FacebookSDK/FacebookSDK.h>
#import "EFAPIServer.h"
#import "TWAPIManager.h"

@interface AddIdentityViewController ()

@property (nonatomic, strong) ACAccountStore *accountStore;
@property (nonatomic, strong) TWAPIManager *apiManager;
@property (nonatomic, strong) NSArray *accounts;

@end

@implementation AddIdentityViewController
@synthesize profileview;

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
    [Flurry logEvent:@"ADD_IDENTITY"];
    CGRect a = [UIScreen mainScreen].applicationFrame;
    
    UIView *contentLayer = [[UIView alloc] initWithFrame:CGRectMake(0, 44, CGRectGetWidth(a), CGRectGetHeight(a) - 44)];
    [self.view addSubview:contentLayer];
    [contentLayer release];
    
    toolbar = [[EXGradientToolbarView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];
    [toolbar.layer setShadowColor:[UIColor blackColor].CGColor];
    [toolbar.layer setShadowOpacity:0.8];
    [toolbar.layer setShadowRadius:3.0];
    [toolbar.layer setShadowOffset:CGSizeMake(0, 0)];
    
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, CGRectGetWidth(toolbar.bounds) - 20, CGRectGetHeight(toolbar.bounds))];
    title.text = @"Add identity";
    title.textAlignment = NSTextAlignmentCenter;
    title.textColor = [UIColor COLOR_CARBON];
    title.shadowColor = [UIColor COLOR_WHITE];
    title.shadowOffset = CGSizeMake(0, 1);
    title.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:20];
    [toolbar addSubview:title];
    [title release];
    [self.view addSubview:toolbar];
    
    UIImage *textfieldback = [UIImage imageNamed:@"textfield_bg_rect.png"];
    identitybackimg=[[UIImageView alloc] initWithFrame:CGRectMake(20, 18, 280, 41)];
    identitybackimg.image=textfieldback;
    identitybackimg.contentMode=UIViewContentModeScaleToFill;
    identitybackimg.contentStretch = CGRectMake(0.5, 0.5, 0, 0);
    [contentLayer addSubview:identitybackimg];
    
    UIImage *dividerback = [UIImage imageNamed:@"textfield_divider.png"];
    divider=[[UIImageView alloc] initWithFrame:CGRectMake(21, 120+40, 230-2, 2)];
    divider.image=dividerback;
    divider.contentMode=UIViewContentModeScaleToFill;
    divider.contentStretch = CGRectMake(0.5, 0.5, 0, 0);
    [divider setHidden:YES];
    
    identityLeftIcon=[[UIImageView alloc] initWithFrame:CGRectMake(6, 12, 18, 18)];
    identityLeftIcon.image=nil;//[UIImage imageNamed:@"identity_email_18_grey.png"];
    [identitybackimg addSubview:identityLeftIcon];
    
    identityRightButton=[UIButton buttonWithType:UIButtonTypeCustom];
    [identityRightButton setFrame:CGRectMake(identitybackimg.frame.origin.x+230-18-6+50, 18+11.5, 18, 18)];
    [identityRightButton addTarget:self action:@selector(clearIdentity) forControlEvents:UIControlEventTouchUpInside];
    [contentLayer addSubview:identityRightButton];
    
    textUsername=[[UITextField alloc] initWithFrame:CGRectMake(identitybackimg.frame.origin.x+6+18+6, 18, 230-(6+18+6)*2+50, 40)];
    textUsername.keyboardType = UIKeyboardTypeEmailAddress;
    textUsername.placeholder=@"Enter email or phone";
    textUsername.contentVerticalAlignment=UIControlContentVerticalAlignmentCenter;
    textUsername.contentHorizontalAlignment=UIControlContentHorizontalAlignmentCenter;
    textUsername.textAlignment=UITextAlignmentCenter;
    textUsername.autocorrectionType=UITextAutocorrectionTypeNo;
    textUsername.autocapitalizationType=UITextAutocapitalizationTypeNone;
    [textUsername setFont:[UIFont fontWithName:@"HelveticaNeue-Italic" size:18]];
    [textUsername setTextColor:FONT_COLOR_25];
    [textUsername addTarget:self action:@selector(textDidChange:) forControlEvents:UIControlEventEditingChanged];
    [contentLayer addSubview:textUsername];
    [textUsername becomeFirstResponder];
    
    avatarview=[[UIImageView alloc] initWithFrame:CGRectMake(20, 18, 40, 40)];
    avatarview.image=nil;
    [contentLayer addSubview:avatarview];
    avatarframeview=[[UIImageView alloc] initWithFrame:CGRectMake(20, 18, 40, 41)];
    avatarframeview.image=nil;
    [contentLayer addSubview:avatarframeview];
    
    
    addbtn=[UIButton buttonWithType:UIButtonTypeCustom];
    [addbtn setFrame:CGRectMake(20, 18+50, 280, 44)];
    [addbtn setTitle:@"Add to verify" forState:UIControlStateNormal];
    [addbtn.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:18]];
    
    [addbtn setTitleColor:FONT_COLOR_51 forState:UIControlStateNormal];
    [addbtn addTarget:self action:@selector(addIdentity:) forControlEvents:UIControlEventTouchUpInside];
//    [addbtn setTitleShadowColor:[UIColor colorWithRed:21.0/255.0f green:52.0/255.0f blue:84.0/255.0f alpha:1] forState:UIControlStateNormal];
//    addbtn.titleLabel.shadowOffset=CGSizeMake(0, 1);
    [addbtn setBackgroundImage:[[UIImage imageNamed:@"btn_light_44.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 12, 0, 12)] forState:UIControlStateNormal];
    [contentLayer addSubview:addbtn];
    
    UIView *signinbgview=[[UIView alloc] initWithFrame:CGRectMake(0, 18+50+65, self.view.bounds.size.width, 76)];
    signinbgview.backgroundColor=[UIColor colorWithPatternImage:[UIImage imageNamed:@"gather_describe_area.png"]];
    [contentLayer addSubview:signinbgview];
    [signinbgview release];
    
    signintoolbar=[[SigninIconToolbarView alloc] initWithFrame:CGRectMake(0, 18+50+65, self.view.bounds.size.width, 75  ) style:@"addidentity" delegate:self];
    signintoolbar.backgroundColor=[UIColor clearColor];//[UIColor colorWithPatternImage:[UIImage imageNamed:@"cross_bg.png"]];
    [contentLayer addSubview:signintoolbar];
    
    
    identityhint.text=@"More identity providers\nsupport coming…";
    identityhint.numberOfLines=0;
    [identityhint sizeToFit];
    
    

//gather_describe_area.png
    
    labelSignError=[[UILabel alloc] initWithFrame:CGRectMake(20, 135+40+4, 280, 18)];
    labelSignError.backgroundColor=[UIColor clearColor];
    labelSignError.text=@"";
    labelSignError.textColor=[UIColor colorWithRed:204/255.f green:81/255.f blue:71/255.f alpha:1.0];
    labelSignError.shadowColor=[UIColor whiteColor];
    labelSignError.shadowOffset=CGSizeMake(0, 1);
    [contentLayer addSubview:labelSignError];
    
    [contentLayer setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"cross_bg.png"]]];

    
    spin=[[EXSpinView alloc] initWithPoint:CGPointMake([addbtn frame].size.width-18-10, ([addbtn frame].size.height-18)/2) size:18];
    [addbtn addSubview:spin];
    [setupnewbtn addSubview:spin];
    [spin startAnimating];
    [spin setHidden:YES];
    
    
    UIButton *btnBack = [UIButton buttonWithType:UIButtonTypeCustom ];
    [btnBack setFrame:CGRectMake(0, 0, 20, 44)];
    btnBack.backgroundColor = [UIColor COLOR_WA(0x33, 0xAA)];
    [btnBack setImage:[UIImage imageNamed:@"back.png"] forState:UIControlStateNormal];
    [btnBack setImage:[UIImage imageNamed:@"back_pressed.png"] forState:UIControlStateHighlighted];
    [btnBack addTarget:self action:@selector(gotoBack:) forControlEvents:UIControlEventTouchUpInside];
    [self.view  addSubview:btnBack];
}

- (void)dealloc
{
    self.accountStore = nil;
    self.apiManager = nil;
}

- (void)gotoBack:(UIButton*)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)textDidChange:(UITextField*)textField{
    if([textField.text length]>2) {
        [identityRightButton setImage:[UIImage imageNamed:@"textfield_clear.png"] forState:UIControlStateNormal];
        
        NSString *provider=[Util findProvider:textField.text];
        if(![provider isEqualToString:@""]) {
            [NSObject cancelPreviousPerformRequestsWithTarget:self];
            NSString *domainext=[textField.text substringFromIndex:textField.text.length-3];
            if([Util isCommonDomainName:domainext])
                [self performSelector:@selector(getUser) withObject:self];
            else
                [self performSelector:@selector(getUser) withObject:self afterDelay:0.8];
        }
    } else {
        avatarview.image=nil;
        avatarframeview.image=nil;
        [identityRightButton setImage:nil forState:UIControlStateNormal];
        identityLeftIcon.image=nil;
    }
}

- (void) clearIdentity{
    [textUsername setText:@""];
    identityLeftIcon.image=nil;
    avatarview.image=nil;
    avatarframeview.image=nil;
    
}

- (void) getUser{
    //    if(CFAbsoluteTimeGetCurrent()-editinginterval>1.2)
    //    {
    NSString *provider=[Util findProvider:textUsername.text];
    if ([provider isEqualToString:@"phone"] && ![[textUsername.text substringToIndex:1] isEqualToString:@"+"])
    textUsername.text=[Util formatPhoneNumber:textUsername.text];
  
    if(![provider isEqualToString:@""]){
        [[EFAPIServer sharedInstance] getIdentitiesWithParams:@[@{@"provider": provider, @"external_username": textUsername.text}]
                                                      success:^(NSArray *identities){
                                                          if (identities && [identities count]) {
                                                              Identity *identity = [identities objectAtIndex:0];
                                                              NSString *avatarFilename = identity.avatar_filename;
                                                              NSString *provider = identity.provider;
                                                              NSString *iconName = [NSString stringWithFormat:@"identity_%@_18_grey.png", provider];
                                                              identityLeftIcon.image = [UIImage imageNamed:iconName];
                                                              
                                                              if (avatarFilename != nil) {
                                                                  dispatch_queue_t imgQueue = dispatch_queue_create("fetchimg thread", NULL);
                                                                  dispatch_async(imgQueue, ^{
                                                                      UIImage *avatar = [[ImgCache sharedManager] getImgFrom:avatarFilename];
                                                                      dispatch_async(dispatch_get_main_queue(), ^{
                                                                          if (avatar != nil && ![avatar isEqual:[NSNull null]]) {
                                                                              avatarview.image = avatar;
                                                                              avatarframeview.image = [UIImage imageNamed:@"signin_portrait_frame.png"];
                                                                          }
                                                                      });
                                                                  });
                                                                  dispatch_release(imgQueue);
                                                              }
                                                          }
                                                      }
                                                      failure:^(NSError *error){
                                                          [MBProgressHUD hideHUDForView:self.view animated:YES];
                                                      }];
    }
}

- (void) addIdentity:(id) sender{
    [spin setHidden:NO];
    
    Provider p = [Util matchedProvider:textUsername.text];
    NSDictionary *idDict = [Util parseIdentityString:textUsername.text];

    NSDictionary *param = nil;
    if (p == kProviderTwitter || p == kProviderFacebook) {
        NSArray * schemes = [[[NSBundle mainBundle] infoDictionary] valueForKeyPath:@"CFBundleURLTypes.@distinctUnionOfArrays.CFBundleURLSchemes"];
        NSAssert([schemes objectAtIndex:0] != nil, @"Missing url sheme in main bundle.");
        
        // eg:  exfe://oauthcallback/
        NSString *callback = [NSString stringWithFormat: @"%@://oauthcallback/", [schemes objectAtIndex:0]];
        
        param = @{@"device_callback": callback, @"device": @"iOS"};
    }
    
    [[EFAPIServer sharedInstance] addIdentityBy:[idDict valueForKeyPath:@"external_username"] withProvider:p param:param success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ([operation.response statusCode] == 200 && [responseObject isKindOfClass:[NSDictionary class]]){
            NSDictionary *body=responseObject;
            if([body isKindOfClass:[NSDictionary class]]) {
                id code=[[body objectForKey:@"meta"] objectForKey:@"code"];
                if(code){
                    if([code intValue]==200) {
                        NSDictionary *responseobj=[body objectForKey:@"response"];
                        if([responseobj isKindOfClass:[NSDictionary class]]){
                            if([responseobj objectForKey:@"url"]!=nil){
                                OAuthAddIdentityViewController *oauth=[[OAuthAddIdentityViewController alloc] initWithNibName:@"OAuthAddIdentityViewController" bundle:nil];
                                oauth.parentView=self;
                                oauth.oauth_url=[responseobj objectForKey:@"url"];
                                [self presentModalViewController:oauth animated:YES];
                                [oauth release];
                            }else{
                                ProfileViewController *vc = (ProfileViewController*)profileview;
                                [vc syncUser];
                                [self.navigationController popViewControllerAnimated:YES];
                            }
                        }
                    }
                    else{
                        if([[body objectForKey:@"meta"] objectForKey:@"errorType"]!=nil && [[[body objectForKey:@"meta"] objectForKey:@"errorType"] isEqualToString:@"no_connected_identity"] ){
                            //                                NSLog(@"error:%@",[[body objectForKey:@"meta"] objectForKey:@"errorType"]);
                        }
                    }
                }
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [spin setHidden:YES];
    }];
}

- (void) oauthSuccess{
    ProfileViewController *vc = (ProfileViewController*)profileview;
    [vc syncUser];
    [self.navigationController popViewControllerAnimated:YES];
}
- (void) doOAuth:(Provider)provider{
    [textUsername resignFirstResponder];
    MBProgressHUD *hud=[MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode=MBProgressHUDModeCustomView;
    EXSpinView *bigspin = [[EXSpinView alloc] initWithPoint:CGPointMake(0, 0) size:40];
    [bigspin startAnimating];
    hud.customView=bigspin;
    [bigspin release];
    hud.labelText = @"Loading";

    NSArray * schemes = [[[NSBundle mainBundle] infoDictionary] valueForKeyPath:@"CFBundleURLTypes.@distinctUnionOfArrays.CFBundleURLSchemes"];
    NSAssert([schemes objectAtIndex:0] != nil, @"Missing url sheme in main bundle.");
    
    // eg:  exfe://oauthcallback/
    NSString *callback = [NSString stringWithFormat: @"%@://oauthcallback/", [schemes objectAtIndex:0]];
    
    [[EFAPIServer sharedInstance] addIdentityBy:@"" withProvider:provider param:@{@"device_callback": callback, @"device": @"iOS" }
                                        success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        if (operation.response.statusCode == 200 && [responseObject isKindOfClass:[NSDictionary class]]) {
            NSDictionary *body = responseObject;
            if([body isKindOfClass:[NSDictionary class]]) {
                id code=[[body objectForKey:@"meta"] objectForKey:@"code"];
                if(code){
                    if([code intValue]==200) {
                        NSDictionary *responseobj=[body objectForKey:@"response"];
                        if([responseobj isKindOfClass:[NSDictionary class]]){
                            if([responseobj objectForKey:@"url"]!=nil){
                                OAuthAddIdentityViewController *oauth=[[OAuthAddIdentityViewController alloc] initWithNibName:@"OAuthAddIdentityViewController" bundle:nil];
                                oauth.parentView=self;
                                oauth.oauth_url=[responseobj objectForKey:@"url"];
                                [self presentModalViewController:oauth animated:YES];
                                [oauth release];
                            }
                        }
                    }
                    else{
                        if([[body objectForKey:@"meta"] objectForKey:@"errorType"]!=nil && [[[body objectForKey:@"meta"] objectForKey:@"errorType"] isEqualToString:@"no_connected_identity"] ){
                        }
                    }
                }
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    }];
  
}
//- (void) FacebookSigninButtonPress:(id)sender{
//    [self doOAuth:kProviderFacebook];
//}
//
//- (void) TwitterSigninButtonPress:(id)sender{
//    [self doOAuth:kProviderTwitter];
//
//}
- (void) MoreButtonPress:(id)sender{
    [textUsername resignFirstResponder];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)FacebookSigninButtonPress:(id)sender
{
//    [self hideInlineError];
    
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
                                              [bigspin release];
                                              
                                              [[EFAPIServer sharedInstance] addReverseAuthIdentity:kProviderFacebook withToken:session.accessTokenData.accessToken andParam:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
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
//                                                                  [self showInlineError:@"Invalid token." with:@"There is something wrong. Please try again later."];
                                                                  
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
                                              
                                              [self syncFBAccount];
                                              break;
                                          default:
                                              break;
                                      }
                                      
                                      
                                  }];
    
}

- (void)TwitterSigninButtonPress:(id)sender
{
//    [self hideInlineError];
    
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
    [bigspin release];
    
    [_apiManager performReverseAuthForAccount:acct withHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error){
        if (responseData) {
            NSString *responseStr = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
            NSDictionary *params = [Util splitQuery:responseStr];
            
            [[EFAPIServer sharedInstance] addReverseAuthIdentity:kProviderTwitter withToken:[params valueForKey:@"oauth_token"] andParam:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
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
                        
                    default:
                        break;
                }
            }
            
        }
    }];
}

- (void)loadUserAndExit
{
    ProfileViewController *vc = (ProfileViewController*)profileview;
    [vc syncUser];
    
    
    [[EFAPIServer sharedInstance] loadMeSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        [self SigninDidFinish];
    }
                                        failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                            [self SigninDidFinish];
                                        }];
}

- (void)SigninDidFinish
{
//    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
//    [app SigninDidFinish];
//    
    [self.navigationController popViewControllerAnimated:YES];
}


@end
