//
//  SigninViewController.m
//  EXFE
//
//  Created by ju huo on 5/22/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SigninViewController.h"

@interface SigninViewController ()

@end

@implementation SigninViewController
@synthesize delegate;

- (IBAction) Signin:(id) sender{
    RKClient *client = [RKClient sharedClient];
    NSString *endpoint = [NSString stringWithFormat:@"/users/signin"];
    RKParams* rsvpParams = [RKParams params];
    NSString *provider=[Util findProvider:textUsername.text];
    [rsvpParams setValue:provider forParam:@"provider"];
    [rsvpParams setValue:textUsername.text forParam:@"external_username"];
    [rsvpParams setValue:textPassword.text forParam:@"password"];
    [client post:endpoint usingBlock:^(RKRequest *request){
        request.method=RKRequestMethodPOST;
        request.params=rsvpParams;
        request.onDidLoadResponse=^(RKResponse *response){
            if (response.statusCode == 200) {
                [self processResponse:[response.body objectFromJSONData]];
            }
        };
    }];
    
    
    
}
- (IBAction) TwitterLoginButtonPress:(id) sender{
    OAuthLoginViewController *oauth = [[OAuthLoginViewController alloc] initWithNibName:@"OAuthLoginViewController" bundle:nil];
    oauth.delegate=signindelegate;
    [self presentModalViewController:oauth animated:YES];
    

}
//#pragma Mark - OAuthlogin Delegate
//- (void)OAuthloginViewControllerDidCancel:(UIViewController *)oauthlogin {
//    [self dismissModalViewControllerAnimated:YES];        
//    [oauthlogin release]; 
//    oauthlogin = nil; 
//}
//-(void)OAuthloginViewControllerDidSuccess:(OAuthLoginViewController *)oauthloginViewController userid:(NSString*)userid username:(NSString*)username external_id:(NSString*)external_id token:(NSString*)token
//{
//    [self loginSuccessWith:token userid:userid username:username];
//}
#pragma Mark - RKRequestDelegate

- (void)request:(RKRequest*)request didLoadResponse:(RKResponse*)response {
    
    if ([request isGET]) {
        if ([response isOK]) {
//            NSLog(@"Data returned: %@", [response bodyAsString]);
        }
    } else if ([request isPOST]) {
        if ([response isJSON]) {
            NSError *error = nil;
            id jsonParser =[[RKParserRegistry sharedRegistry] parserForMIMEType:RKMIMETypeJSON];
            NSDictionary *parsedResponse = [jsonParser objectFromString:[response bodyAsString] error:&error];
            [self processResponse:parsedResponse];
        }
    } else if ([request isDELETE]) {
        if ([response isNotFound]) {
            NSLog(@"Resource '%@' not exists", [request resourcePath]);
        }
    }    //    NSLog(@"Response code=%@, token=[%@], userName=[%@]", [[result meta] code], [result token], [[result user] userName]);
}

//- (void)loginSuccessWith:(NSString *)token userid:(NSString *)userid username:(NSString *)username {
//    [[NSUserDefaults standardUserDefaults] setObject:token forKey:@"access_token"];
//    [[NSUserDefaults standardUserDefaults] setObject:userid forKey:@"userid"];
//    [[NSUserDefaults standardUserDefaults] synchronize];
//
//    AppDelegate *app=(AppDelegate *)[[UIApplication sharedApplication] delegate];
//
//    app.userid=[userid intValue];
//    app.accesstoken=token;
//    NSLog(@"loaduser with userid..");
//    [APIProfile LoadUsrWithUserId:app.userid delegate:self];
//}

- (void) processResponse:(id)obj{
    
    NSLog(@"processResponse..");
    if([obj isKindOfClass:[NSDictionary class]])
    {
        id meta=[obj objectForKey:@"meta"];
        if([meta isKindOfClass:[NSDictionary class]])
        {
            id code=[[obj objectForKey:@"meta"] objectForKey:@"code"];
            if([code isKindOfClass:[NSNumber class]])
            {
                id response=[obj objectForKey:@"response"];
                if([code intValue]==200)
                {
                    if([response isKindOfClass:[NSDictionary class]])
                    {
                        NSString *token=[response objectForKey:@"token"];
                        NSString *userid=[response objectForKey:@"user_id"];
                        NSString *username=[response objectForKey:@"username"];
                        NSLog(@"login success with ");
                        [signindelegate loginSuccessWith:token userid:userid username:username];
                    }
                }
                else{
                    NSLog(@"%@",obj);
                }
            }
        }
    }
//    NSLog(@"POST returned a JSON response:%@",obj);
}
- (void)request:(RKRequest *)request didFailLoadWithError:(NSError *)error{
    NSLog(@"error:%@",error);   
}

- (void)SigninDidFinish{
    [delegate SigninDidFinish];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    signindelegate=[[SigninDelegate alloc]init];
    signindelegate.parent=self;
    
    signintoolbar=[[SigninIconToolbarView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 50) style:@"signin" delegate:self];
    signintoolbar.backgroundColor=[UIColor colorWithPatternImage:[UIImage imageNamed:@"signinbar_bg.png"]];
    [self.view addSubview:signintoolbar];
    
    UIImage *textfieldback = [UIImage imageNamed:@"textfield_bg_rect.png"];
    identitybackimg=[[UIImageView alloc] initWithFrame:CGRectMake(20, 70, 230, 41)];
    identitybackimg.image=textfieldback;
    identitybackimg.contentMode=UIViewContentModeScaleToFill;
    identitybackimg.contentStretch = CGRectMake(0.5, 0.5, 0, 0);
    [self.view addSubview:identitybackimg];
    
    passwordbackimg=[[UIImageView alloc] initWithFrame:CGRectMake(20, 135, 230, 41)];
    passwordbackimg.image=textfieldback;
    passwordbackimg.contentMode=UIViewContentModeScaleToFill;
    passwordbackimg.contentStretch = CGRectMake(0.5, 0.5, 0, 0);
    [self.view addSubview:passwordbackimg];
    
    
    identityLeftIcon=[[UIImageView alloc] initWithFrame:CGRectMake(6, 12, 18, 18)];
    identityLeftIcon.image=nil;//[UIImage imageNamed:@"identity_email_18_grey.png"];
    [identitybackimg addSubview:identityLeftIcon];
    
    identityRightIcon=[[UIImageView alloc] initWithFrame:CGRectMake(206, 12, 18, 18)];
    identityRightIcon.image=nil;//[UIImage imageNamed:@"textfield_clear.png"];
    [identitybackimg addSubview:identityRightIcon];
    
    textUsername=[[UITextField alloc] initWithFrame:CGRectMake(identitybackimg.frame.origin.x+6+18+6, 70, 230-(6+18+6)*2, 41)];
    textUsername.placeholder=@"Enter your email";
    textUsername.contentVerticalAlignment=UIControlContentVerticalAlignmentCenter;
    textUsername.contentHorizontalAlignment=UIControlContentHorizontalAlignmentCenter;
    textUsername.textAlignment=UITextAlignmentCenter;
    textUsername.autocorrectionType=UITextAutocorrectionTypeNo;
    textUsername.autocapitalizationType=UITextAutocapitalizationTypeNone;
    [textUsername setFont:[UIFont fontWithName:@"HelveticaNeue-Italic" size:18]];
    [textUsername setTextColor:FONT_COLOR_25];
    [textUsername addTarget:self action:@selector(textDidChange:) forControlEvents:UIControlEventEditingChanged];
    [self.view addSubview:textUsername];
    [textUsername becomeFirstResponder];
    
    textPassword=[[UITextField alloc] initWithFrame:CGRectMake(20, 135, 230, 41)];
    textPassword.placeholder=@"Enter EXFE Password";
    textPassword.contentVerticalAlignment=UIControlContentVerticalAlignmentCenter;
    textPassword.contentHorizontalAlignment=UIControlContentHorizontalAlignmentCenter;
    textPassword.textAlignment=UITextAlignmentCenter;
    textPassword.autocorrectionType=UITextAutocorrectionTypeNo;
    textPassword.autocapitalizationType=UITextAutocapitalizationTypeNone;
    textPassword.secureTextEntry=YES;
    [textPassword setFont:[UIFont fontWithName:@"HelveticaNeue" size:18]];
    [textPassword setTextColor:FONT_COLOR_25];
    [self.view addSubview:textPassword];

    avatarview=[[UIImageView alloc] initWithFrame:CGRectMake(260, 70, 40, 40)];
    avatarview.image=nil;
    [self.view addSubview:avatarview];

    UIImage *btn_dark = [UIImage imageNamed:@"btn_dark.png"];
    UIImageView *startbackimg=[[UIImageView alloc] initWithFrame:CGRectMake(20, 200, 280, 44)];
    startbackimg.image=btn_dark;
    startbackimg.contentMode=UIViewContentModeScaleToFill;
    startbackimg.contentStretch = CGRectMake(0.5, 0.5, 0, 0);
    [self.view addSubview:startbackimg];
    [startbackimg release];

    loginbtn=[UIButton buttonWithType:UIButtonTypeCustom];
    [loginbtn setFrame:CGRectMake(20, 200, 280, 44)];
    [loginbtn setTitle:@"Start" forState:UIControlStateNormal];
    [loginbtn.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:18]];
    [loginbtn setTitleColor:[UIColor colorWithRed:204.0/255.0f green:229.0/255.0f blue:255.0/255.0f alpha:1] forState:UIControlStateNormal];
    [loginbtn addTarget:self action:@selector(Signin:) forControlEvents:UIControlEventTouchUpInside];
    [loginbtn setTitleShadowColor:[UIColor colorWithRed:21.0/255.0f green:52.0/255.0f blue:84.0/255.0f alpha:1] forState:UIControlStateNormal];
    loginbtn.titleLabel.shadowOffset=CGSizeMake(0, 1);
    [self.view addSubview:loginbtn];
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}
- (void)dealloc
{
    [identitybackimg release];
    [textUsername release];
    [signindelegate release];
    [identityLeftIcon release];
    [identityRightIcon release];
    [super dealloc];

}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)editingDidBegan:(UITextField*)textField{
    NSLog(@"editing did");
    
}
- (void) getUser{
    if(CFAbsoluteTimeGetCurrent()-editinginterval>1.2)
    {
        NSString *provider=[Util findProvider:textUsername.text];
        if(![provider isEqualToString:@""]){
            RKClient *client = [RKClient sharedClient];
            NSString *endpoint = [NSString stringWithFormat:@"/users/GetRegistrationFlag?external_username=%@&provider=%@",textUsername.text,provider];
            AppDelegate *app=(AppDelegate *)[[UIApplication sharedApplication] delegate];
            [client setValue:app.accesstoken forHTTPHeaderField:@"token"];
            [client get:endpoint usingBlock:^(RKRequest *request){
                request.method=RKRequestMethodGET;
                request.onDidLoadResponse=^(RKResponse *response){
                    if (response.statusCode == 200) {
                        NSLog(@"%@",response.bodyAsString);
                        NSDictionary *body=[response.body objectFromJSONData];
                        id code=[[body objectForKey:@"meta"] objectForKey:@"code"];
                        if(code)
                            if([code intValue]==200) {
                                NSDictionary* response = [body objectForKey:@"response"];
                                NSString *registration_flag=(NSString*)[response objectForKey:@"registration_flag"] ;
                                if([registration_flag isEqualToString:@"SIGN_IN"] )
                                {
                                    NSDictionary *identity = [response objectForKey:@"identity"];
                                    NSString *avatar_filename=[identity objectForKey:@"avatar_filename"];
                                    NSString *provider=[identity objectForKey:@"provider"];
                                    NSString *iconname=[NSString stringWithFormat:@"identity_%@_18_grey.png",provider];
                                    identityLeftIcon.image=[UIImage imageNamed:iconname];

                                    if(avatar_filename!=nil) {
                                        dispatch_queue_t imgQueue = dispatch_queue_create("fetchimg thread", NULL);
                                        dispatch_async(imgQueue, ^{
                                            UIImage *avatar = [[ImgCache sharedManager] getImgFrom:avatar_filename];
                                            dispatch_async(dispatch_get_main_queue(), ^{
                                                if(avatar!=nil && ![avatar isEqual:[NSNull null]]) {
                                                    avatarview.image=avatar;
                                                }
                                            });
                                        });
                                        dispatch_release(imgQueue);        
                                    }
                                }
                                if([registration_flag isEqualToString:@"VERIFY"] )
                                {
                                    [self setHintView:@"verification"];
                                }
                            }
                    }
                };
            }];
        }
    }
}


- (IBAction)textDidChange:(UITextField*)textField{
    if([textField.text length]>2) {
        identityRightIcon.image=[UIImage imageNamed:@"textfield_clear.png"];
        editinginterval=CFAbsoluteTimeGetCurrent();
        [NSObject cancelPreviousPerformRequestsWithTarget:self];
        [self performSelector:@selector(getUser) withObject:self afterDelay:1.2];
    } else {
        avatarview.image=nil;
        identityRightIcon.image=nil;
        identityLeftIcon.image=nil;
    }
}

- (IBAction)showForgetPwd:(id)sender{
    [self setHintView:@"forgetpassword"];
    NSLog(@"forget password");
}
- (void) setHintView:(NSString*)hintname{
    [textUsername resignFirstResponder];
    [textPassword resignFirstResponder];
    
    if([hintname isEqualToString:@"forgetpassword"]){
        hint_title.text=@"Forgot Password";
        NSMutableAttributedString * desc = [[NSMutableAttributedString alloc] initWithString:@"You can reset your EXFE password through this identity. Confirm sending reset token to your mailbox?"];
    
        [desc addAttribute:(NSString*)kCTForegroundColorAttributeName  value:(id)[UIColor blackColor].CGColor range:NSMakeRange(0,19)];

        [desc addAttribute:(NSString*)kCTForegroundColorAttributeName value:(id)FONT_COLOR_HL range:NSMakeRange(19,4)];
//        hint_desc.text=desc;

        [desc release];
        [hint_title setHidden:NO];
        [hint_desc setHidden:NO];
        [Send removeTarget:self action:@selector(sendVerify:) forControlEvents:UIControlEventTouchUpInside];
        [Send addTarget:self action:@selector(sendPwd:) forControlEvents:UIControlEventTouchUpInside];
        
        [Send setHidden:NO];
    }
    else if([hintname isEqualToString:@"verification"]){
        hint_title.text=@"Verification";
        NSMutableAttributedString * desc = [[NSMutableAttributedString alloc] initWithString:@"This identity requires verification before using.\nConfirm sending verification to your mailbox?"];
        [desc addAttribute:(NSString*)kCTForegroundColorAttributeName value:(id)[UIColor redColor] range:NSMakeRange(0,50)];
        hint_desc.text=desc;
        [desc release];
        [hint_title setHidden:NO];
        [hint_desc setHidden:NO];
        [Send removeTarget:self action:@selector(sendPwd:) forControlEvents:UIControlEventTouchUpInside];
        [Send addTarget:self action:@selector(sendVerify:) forControlEvents:UIControlEventTouchUpInside];
        [Send setHidden:NO];
        
    }
}
- (void)TwitterSigninButtonPress:(id)sender{
    OAuthLoginViewController *oauth = [[OAuthLoginViewController alloc] initWithNibName:@"OAuthLoginViewController" bundle:nil];
    oauth.delegate=signindelegate;
    [self presentModalViewController:oauth animated:YES];
}

- (IBAction)sendVerify:(id)sender{
    RKClient *client = [RKClient sharedClient];
    NSString *provider=[Util findProvider:textUsername.text];
    NSString *endpoint = [NSString stringWithFormat:@"/users/VerifyIdentity?provider=%@&external_username=%@",provider,textUsername.text];
    
    AppDelegate *app=(AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    [client setValue:app.accesstoken forHTTPHeaderField:@"token"];
    [client get:endpoint usingBlock:^(RKRequest *request){
        request.method=RKRequestMethodGET;
        request.onDidLoadResponse=^(RKResponse *response){
            if (response.statusCode == 200) {
                [hint_desc setText:@"Verification sent, it should arrive in minutes. Please check your mailbox and follow the instruction."];
                [Send setHidden:YES];
            }
        };
    }];}
- (IBAction)sendPwd:(id)sender{
    RKClient *client = [RKClient sharedClient];
    NSString *endpoint = [NSString stringWithFormat:@"/users/forgotpassword"];
    RKParams* rsvpParams = [RKParams params];
    NSString *provider=[Util findProvider:textUsername.text];
    [rsvpParams setValue:provider forParam:@"provider"];
    [rsvpParams setValue:textUsername.text forParam:@"external_username"];
    
    AppDelegate *app=(AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    [client setValue:app.accesstoken forHTTPHeaderField:@"token"];
    
    [client post:endpoint usingBlock:^(RKRequest *request){
        request.method=RKRequestMethodPOST;
        request.params=rsvpParams;
        request.onDidLoadResponse=^(RKResponse *response){
            if (response.statusCode == 200) {
                [hint_desc setText:@"Password sent, it should arrive in minutes. Please check your mailbox and follow the instruction."];
                [Send setHidden:YES];
            }
        };
    }];
}
//#pragma mark RKObjectLoaderDelegate methods

//- (void)objectLoader:(RKObjectLoader *)objectLoader didLoadObjects:(NSArray *)objects {
//    AppDelegate *app=(AppDelegate *)[[UIApplication sharedApplication] delegate];
//	NSFetchRequest* request = [User fetchRequest];
//    NSPredicate *predicate = [NSPredicate
//                              predicateWithFormat:@"user_id = %u", app.userid];    
//    [request setPredicate:predicate];
//	NSArray *users = [[User objectsWithFetchRequest:request] retain];
//    
//    if(users!=nil && [users count] >0)
//    {
//        User* user=[users objectAtIndex:0];
//        [[NSUserDefaults standardUserDefaults] setObject:user.name forKey:@"username"];
//        [[NSUserDefaults standardUserDefaults] synchronize];
//        app.username=user.name;
//    }
//    [delegate SigninDidFinish];
//}
//
//- (void)objectLoader:(RKObjectLoader *)objectLoader didFailWithError:(NSError *)error {
//    NSLog(@"Error!:%@",error);
//    //    [self stopLoading];
//}

@end
