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
    NSLog(@"signin");
    [self showSignError:@""];
  NSString *provider=[Util findProvider:textUsername.text];
  NSString *username=[Util cleanInputName:textUsername.text provider:provider];
  
  NSString *endpoint = [NSString stringWithFormat:@"%@/users/signin",API_ROOT];
  RKObjectManager *manager=[RKObjectManager sharedManager] ;
  NSDictionary *params=@{
    @"provider": provider,
    @"external_username": username,
    @"password": textPassword.text,
    };

  manager.HTTPClient.parameterEncoding=AFFormURLParameterEncoding;
  [manager.HTTPClient postPath:endpoint parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
    if ([operation.response statusCode] == 200 && [responseObject isKindOfClass:[NSDictionary class]]){
        [self processResponse:responseObject status:@"signin"];
        [delegate SigninDidFinish];
    }
    [spin setHidden:YES];

  } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
    [spin setHidden:YES];
    NSString *errormsg;
    if(error.code==2)
        errormsg=@"A connection failure has occurred.";
    else
        errormsg=@"Could not connect to the server.";
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:errormsg delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
    [alert release];
    
  }];


    [spin removeFromSuperview];
    [loginbtn addSubview:spin];
    [spin setHidden:NO];
}

- (void) Signupnew:(id) sender{
    [self showSignError:@""];
//RESTKIT0.2  
//    RKClient *client = [RKClient sharedClient];
//    [client setBaseURL:[RKURL URLWithBaseURLString:API_V2_ROOT]];
//    NSString *endpoint = [NSString stringWithFormat:@"/users/signin"];
//    RKParams* rsvpParams = [RKParams params];
//    NSString *provider=[Util findProvider:textUsername.text];
//    [rsvpParams setValue:provider forParam:@"provider"];
//    [rsvpParams setValue:textUsername.text forParam:@"external_username"];
//    [rsvpParams setValue:textDisplayname.text forParam:@"name"];
//    [rsvpParams setValue:textPassword.text forParam:@"password"];
  
    [spin removeFromSuperview];
    [setupnewbtn addSubview:spin];
    [spin setHidden:NO];
//RESTKIT0.2  
//    [client post:endpoint usingBlock:^(RKRequest *request){
//        request.method=RKRequestMethodPOST;
//        request.params=rsvpParams;
//        request.onDidLoadResponse=^(RKResponse *response){
//            if (response.statusCode == 200) {
//                [self processResponse:[response.body objectFromJSONData] status:@"signup"];
//            }
//            [spin setHidden:YES];
//        };
//        request.onDidFailLoadWithError=^(NSError *error){
//            [spin setHidden:YES];
//            NSString *errormsg;
//            if(error.code==2)
//                errormsg=@"A connection failure has occurred.";
//            else
//                errormsg=@"Could not connect to the server.";
//            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:errormsg delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
//            [alert show];
//            [alert release];
//        };
//    }];
  
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
//RESTKIT0.2
//- (void)request:(RKRequest*)request didLoadResponse:(RKResponse*)response {
//    
//    if ([request isGET]) {
//        if ([response isOK]) {
//        }
//    } else if ([request isPOST]) {
//        if ([response isJSON]) {
//            NSError *error = nil;
//            id jsonParser =[[RKParserRegistry sharedRegistry] parserForMIMEType:RKMIMETypeJSON];
//            NSDictionary *parsedResponse = [jsonParser objectFromString:[response bodyAsString] error:&error];
//            [self processResponse:parsedResponse status:@""];
//        }
//    } else if ([request isDELETE]) {
//        if ([response isNotFound]) {
//        }
//    }
//}

- (void) processResponse:(id)obj status:(NSString*)status{
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
                        [signindelegate loginSuccessWith:token userid:userid username:username];
                        if([status isEqualToString:@"signup"])
                        {
                            [[NSUserDefaults standardUserDefaults] setObject:@"YES" forKey:@"NEWUSER"];
                            [[NSUserDefaults standardUserDefaults] synchronize];
                        }
                    }
                }
                else{
                    id meta=[obj objectForKey:@"meta"];
                    if([meta isKindOfClass:[NSDictionary class]])
                    {
                        
                        NSNumber *code=[meta objectForKey:@"code"];
                        if([code intValue]==403)
                            [self showSignError:@"Password incorrect."];
                    }
                }
            }
        }
    }
}

//- (void)request:(RKRequest *)request didFailLoadWithError:(NSError *)error{
//    NSLog(@"error:%@",error);   
//}

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
    
    UIImage *dividerback = [UIImage imageNamed:@"textfield_divider.png"];
    divider=[[UIImageView alloc] initWithFrame:CGRectMake(21, 120+40, 230-2, 2)];
    divider.image=dividerback;
    divider.contentMode=UIViewContentModeScaleToFill;
    divider.contentStretch = CGRectMake(0.5, 0.5, 0, 0);
    [divider setHidden:YES];
    [self.view addSubview:divider];
    
    
    identityLeftIcon=[[UIImageView alloc] initWithFrame:CGRectMake(6, 12, 18, 18)];
    identityLeftIcon.image=nil;//[UIImage imageNamed:@"identity_email_18_grey.png"];
    [identitybackimg addSubview:identityLeftIcon];
    
    identityRightButton=[UIButton buttonWithType:UIButtonTypeCustom];
    [identityRightButton setFrame:CGRectMake(identitybackimg.frame.origin.x+230-18-6, 81, 18, 18)];
    [identityRightButton addTarget:self action:@selector(clearIdentity) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:identityRightButton];
    
    
    textUsername=[[UITextField alloc] initWithFrame:CGRectMake(identitybackimg.frame.origin.x+6+18+6, 70, 230-(6+18+6)*2, 40)];
    textUsername.placeholder=@"Enter email or phone";
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
    
    textPassword=[[UITextField alloc] initWithFrame:CGRectMake(20, 135, 230, 40)];
    textPassword.placeholder=@"Enter EXFE Password";
    textPassword.contentVerticalAlignment=UIControlContentVerticalAlignmentCenter;
    textPassword.contentHorizontalAlignment=UIControlContentHorizontalAlignmentCenter;
    textPassword.textAlignment=UITextAlignmentCenter;
    textPassword.autocorrectionType=UITextAutocorrectionTypeNo;
    textPassword.autocapitalizationType=UITextAutocapitalizationTypeNone;
    textPassword.secureTextEntry=YES;
    [textPassword setFont:[UIFont fontWithName:@"HelveticaNeue" size:18]];
    [textPassword setTextColor:FONT_COLOR_25];
    [textPassword addTarget:self action:@selector(textDidChange:) forControlEvents:UIControlEventEditingChanged];

    [self.view addSubview:textPassword];

    textDisplayname=[[UITextField alloc] initWithFrame:CGRectMake(20, 120, 230, 40)];
    textDisplayname.placeholder=@"Set a recognizable name";
    textDisplayname.contentVerticalAlignment=UIControlContentVerticalAlignmentCenter;
    textDisplayname.contentHorizontalAlignment=UIControlContentHorizontalAlignmentCenter;
    textDisplayname.textAlignment=UITextAlignmentCenter;
    textDisplayname.autocorrectionType=UITextAutocorrectionTypeNo;
    textDisplayname.autocapitalizationType=UITextAutocapitalizationTypeNone;
    [textDisplayname setFont:[UIFont fontWithName:@"HelveticaNeue" size:18]];
    [textDisplayname setTextColor:FONT_COLOR_25];
    [textDisplayname setHidden:YES];
    [textDisplayname addTarget:self action:@selector(textDidChange:) forControlEvents:UIControlEventEditingChanged];

    [self.view addSubview:textDisplayname];

    
    avatarview=[[UIImageView alloc] initWithFrame:CGRectMake(260, 70, 40, 40)];
    avatarview.image=nil;
    [self.view addSubview:avatarview];
    avatarframeview=[[UIImageView alloc] initWithFrame:CGRectMake(260, 70, 40, 41)];
    avatarframeview.image=nil;
    [self.view addSubview:avatarframeview];
    

    loginbtn=[UIButton buttonWithType:UIButtonTypeCustom];
    [loginbtn setFrame:CGRectMake(20, 200, 280, 44)];
    [loginbtn setTitle:@"Start" forState:UIControlStateNormal];
    [loginbtn.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:18]];
    [loginbtn setTitleColor:[UIColor colorWithRed:204.0/255.0f green:229.0/255.0f blue:255.0/255.0f alpha:1] forState:UIControlStateNormal];
    [loginbtn addTarget:self action:@selector(Signin:) forControlEvents:UIControlEventTouchUpInside];
    [loginbtn setTitleShadowColor:[UIColor colorWithRed:21.0/255.0f green:52.0/255.0f blue:84.0/255.0f alpha:1] forState:UIControlStateNormal];
    loginbtn.titleLabel.shadowOffset=CGSizeMake(0, 1);
    [loginbtn setBackgroundImage:[[UIImage imageNamed:@"btn_light_44.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 12, 0, 12)] forState:UIControlStateNormal];

    [self.view addSubview:loginbtn];
    
    setupnewbtn=[UIButton buttonWithType:UIButtonTypeCustom];
    [setupnewbtn setFrame:CGRectMake(20, 210, 280, 44)];
    [setupnewbtn setTitle:@"Set up new account" forState:UIControlStateNormal];
    [setupnewbtn.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:18]];
    [setupnewbtn setTitleColor:[UIColor colorWithRed:204.0/255.0f green:229.0/255.0f blue:255.0/255.0f alpha:1] forState:UIControlStateNormal];
    [setupnewbtn addTarget:self action:@selector(Signupnew:) forControlEvents:UIControlEventTouchUpInside];
    [setupnewbtn setTitleShadowColor:[UIColor colorWithRed:21.0/255.0f green:52.0/255.0f blue:84.0/255.0f alpha:1] forState:UIControlStateNormal];
    setupnewbtn.titleLabel.shadowOffset=CGSizeMake(0, 1);
    [setupnewbtn setBackgroundImage:[[UIImage imageNamed:@"btn_dark_44.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 6, 0, 6)] forState:UIControlStateNormal];

    [setupnewbtn setHidden:YES];
    [self.view addSubview:setupnewbtn];
    
    labelSignError=[[UILabel alloc] initWithFrame:CGRectMake(20, 135+40+4, 280, 18)];
    labelSignError.backgroundColor=[UIColor clearColor];
    labelSignError.text=@"";
    labelSignError.textColor=[UIColor colorWithRed:204/255.f green:81/255.f blue:71/255.f alpha:1.0];
    labelSignError.shadowColor=[UIColor whiteColor];
    labelSignError.shadowOffset=CGSizeMake(0, 1);
    [self.view addSubview:labelSignError];
    
    spin=[[EXSpinView alloc] initWithPoint:CGPointMake([loginbtn frame].size.width-18-10, ([loginbtn frame].size.height-18)/2) size:18];
    [spin removeFromSuperview];
    [loginbtn addSubview:spin];
    [spin startAnimating];
    [spin setHidden:YES];
    
}

- (void) showSignError:(NSString*)error{
    labelSignError.text=error;
}

- (void) setSigninView{
    [passwordbackimg setFrame:CGRectMake(20, 135, 230, 41)];
    [textPassword setFrame:CGRectMake(20, 135, 230, 40)];
    [textDisplayname setHidden:YES];
    [divider setHidden:YES];
    [setupnewbtn setHidden:YES];
    [loginbtn setHidden:NO];
    
}
- (void) setSignupView{
    [passwordbackimg setFrame:CGRectMake(20, 120, 230, 81)];
    [textPassword setFrame:CGRectMake(20, 120+41, 230, 40)];
    [textDisplayname setHidden:NO];
    [divider setHidden:NO];
    [setupnewbtn setHidden:NO];
  
  if((textUsername.text != nil && textDisplayname.text.length >0) && (textDisplayname.text != nil && textDisplayname.text.length >0) && (textPassword.text != nil && textPassword.text.length >0)){
    [setupnewbtn setEnabled:YES];
    [setupnewbtn addTarget:self action:@selector(Signupnew:) forControlEvents:UIControlEventTouchUpInside];
  }else{
    [setupnewbtn removeTarget:self action:@selector(Signupnew:) forControlEvents:UIControlEventTouchUpInside];
    [setupnewbtn setEnabled:NO];
  }

    [loginbtn setHidden:YES];
}
- (void) welcomeButtonPress:(id) sender{
    [(LandingViewController*)delegate dismissSigninView];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}
- (void)dealloc
{
    [avatarframeview release];
    [avatarview release];
    [identitybackimg release];
    [textUsername release];
    [textPassword release];
    [textDisplayname release];
    [signindelegate release];
    [identityLeftIcon release];
    [labelSignError release];
    [spin release];
    if(hint_title!=nil)
      [hint_title release];
    [super dealloc];

}
- (void) clearIdentity{
    [textUsername setText:@""];
    identityLeftIcon.image=nil;

}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)TwitterSigninButtonPress:(id)sender{
    OAuthLoginViewController *oauth = [[OAuthLoginViewController alloc] initWithNibName:@"OAuthLoginViewController" bundle:nil];
    oauth.provider=@"twitter";
    oauth.delegate=signindelegate;
    [self presentModalViewController:oauth animated:YES];
}

- (void)FacebookSigninButtonPress:(id)sender{
    OAuthLoginViewController *oauth = [[OAuthLoginViewController alloc] initWithNibName:@"OAuthLoginViewController" bundle:nil];
    oauth.provider=@"facebook";
    oauth.delegate=signindelegate;
    [self presentModalViewController:oauth animated:YES];
}


- (IBAction)editingDidBegan:(UITextField*)textField{
}
- (void) getUser{
  
    NSString *provider=[Util findProvider:textUsername.text];
    if ([provider isEqualToString:@"phone"] && ![[textUsername.text substringToIndex:1] isEqualToString:@"+"])
      textUsername.text=[Util formatPhoneNumber:textUsername.text];

    if(![provider isEqualToString:@""]){
      NSString *endpoint = [NSString stringWithFormat:@"%@/users/GetRegistrationFlag?external_username=%@&provider=%@",API_ROOT,textUsername.text,provider];
      RKObjectManager *manager=[RKObjectManager sharedManager] ;
      
      [manager.HTTPClient getPath:endpoint parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ([operation.response statusCode] == 200 && [responseObject isKindOfClass:[NSDictionary class]]) {
          NSDictionary *body=responseObject;
          id code=[[body objectForKey:@"meta"] objectForKey:@"code"];
          if(code)
            if([code intValue]==200) {
              NSDictionary* response = [body objectForKey:@"response"];
                NSString *registration_flag=(NSString*)[response objectForKey:@"registration_flag"] ;
                  if([registration_flag isEqualToString:@"SIGN_IN"] ) {
                    [self setSigninView];
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
                                   avatarframeview.image=[UIImage imageNamed:@"signin_portrait_frame.png"];
                               }
                           });
                       });
                       dispatch_release(imgQueue);
                      }
                    }
                    else if([registration_flag isEqualToString:@"SIGN_UP"] ){
                        NSString *iconname=[NSString stringWithFormat:@"identity_%@_18_grey.png",provider];
                        identityLeftIcon.image=[UIImage imageNamed:iconname];

                        [self setSignupView];
                    }
                    else if([registration_flag isEqualToString:@"VERIFY"] ) {
                        NSString *iconname=[NSString stringWithFormat:@"identity_%@_18_grey.png",provider];
                        identityLeftIcon.image=[UIImage imageNamed:iconname];
                        [self setSigninView];
                        [self setHintView:@"verification" provider:provider];
                    }
            }
        }
      } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//         NSLog(@"It Failed: %@", error);
      }];
      
    }
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
      if(textUsername.text == nil || [textUsername.text length]==0){
        avatarview.image=nil;
        avatarframeview.image=nil;
        [identityRightButton setImage:nil forState:UIControlStateNormal];
        identityLeftIcon.image=nil;
      }
    }
  
  if((textUsername.text != nil && textDisplayname.text.length >0) && (textDisplayname.text != nil && textDisplayname.text.length >0) && (textPassword.text != nil && textPassword.text.length >0)){
    [setupnewbtn setEnabled:YES];
    [setupnewbtn addTarget:self action:@selector(Signupnew:) forControlEvents:UIControlEventTouchUpInside];
  }else{
    [setupnewbtn removeTarget:self action:@selector(Signupnew:) forControlEvents:UIControlEventTouchUpInside];
    [setupnewbtn setEnabled:NO];
  }

}

- (IBAction)showForgetPwd:(id)sender{
//    [self setHintView:@"forgetpassword"];
}
- (void) setHintView:(NSString*)hintname provider:(NSString*)provider{
    [textUsername resignFirstResponder];
    [textPassword resignFirstResponder];
    if(hint_title==nil){
        hint_title=[[UILabel alloc] initWithFrame:CGRectMake(20, 200+44+21, 280, 21)];
        [hint_title setBackgroundColor:[UIColor clearColor]];
        [hint_title setFont:[UIFont fontWithName:@"HelveticaNeue" size:18]];
        [hint_title setTextColor:[UIColor whiteColor]];
        [hint_title setShadowColor:[UIColor blackColor]];
        [hint_title setShadowOffset:CGSizeMake(0, 1)];
        [self.view addSubview:hint_title];
    }
    if(hint_desc==nil){
//        hint_desc=[[UITextView alloc] initWithFrame:CGRectMake(18, 200+44+21+36, 280, 55)];
//        [hint_desc setBackgroundColor:[UIColor clearColor]];
//        [hint_desc setFont:[UIFont fontWithName:@"HelveticaNeue" size:16]];
        hint_desc = [[CustomAttributedTextView alloc] initWithFrame:CGRectMake(20, 200+44+21+21
                                                                               +15, 280, 60)];
        [hint_desc setBackgroundColor:[UIColor clearColor]];
        [self.view addSubview:hint_desc];
    }
    if(sendbtn==nil){
        sendbtn=[UIButton buttonWithType:UIButtonTypeCustom];
        [sendbtn setFrame:CGRectMake(20, 200+44+21+36+96, 280, 44)];
        [sendbtn setTitle:@"Send" forState:UIControlStateNormal];
        [sendbtn.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:18]];
        [sendbtn setTitleColor:[UIColor colorWithRed:204.0/255.0f green:229.0/255.0f blue:255.0/255.0f alpha:1] forState:UIControlStateNormal];
        [sendbtn addTarget:self action:@selector(Signin:) forControlEvents:UIControlEventTouchUpInside];
        [sendbtn setTitleShadowColor:[UIColor colorWithRed:21.0/255.0f green:52.0/255.0f blue:84.0/255.0f alpha:1] forState:UIControlStateNormal];
        sendbtn.titleLabel.shadowOffset=CGSizeMake(0, 1);
        [sendbtn setBackgroundImage:[[UIImage imageNamed:@"btn_light_44.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 12, 0, 12)] forState:UIControlStateNormal];
        
        [self.view addSubview:sendbtn];
        
    }
    
    if([hintname isEqualToString:@"forgetpassword"]){
        hint_title.text=@"Forgot Password";
        NSMutableAttributedString * desc = [[NSMutableAttributedString alloc] initWithString:@"You can reset your EXFE password through this identity. Confirm sending reset token to your mailbox?"];
        [desc addAttribute:(NSString*)kCTForegroundColorAttributeName  value:(id)[UIColor colorWithRed:0xff/255.0 green:0x7e/255.0 blue:0x98/255.0 alpha:1].CGColor range:NSMakeRange(0,19)];
        [desc addAttribute:(NSString*)kCTForegroundColorAttributeName value:(id)FONT_COLOR_HL range:NSMakeRange(19,4)];
        [desc release];
        [hint_title setHidden:NO];
        [hint_desc setHidden:NO];
        
        [sendbtn removeTarget:self action:@selector(sendVerify:) forControlEvents:UIControlEventTouchUpInside];
        [sendbtn addTarget:self action:@selector(sendPwd:) forControlEvents:UIControlEventTouchUpInside];
        
        [sendbtn setHidden:NO];
    }
    else if([hintname isEqualToString:@"verification"]){
        hint_title.text=@"Verification";
        NSMutableAttributedString * desc = [[NSMutableAttributedString alloc] initWithString:@"This identity requires verification before using. Confirm sending verification to your mailbox?"];
        if([provider isEqualToString:@"phone"])
            desc = [[NSMutableAttributedString alloc] initWithString:@"This identity requires verification before using. Confirm sending verification to your phone?"];
      
          [desc addAttribute:(NSString*)kCTForegroundColorAttributeName value:(id)[UIColor colorWithRed:0xff/255.0 green:0x7e/255.0 blue:0x98/255.0 alpha:1].CGColor range:NSMakeRange(0,[desc length])];
        
//        [desc addAttribute:(NSString*)kCTForegroundColorAttributeName value:(id)[UIColor colorWithRed:255/255.0 green:240/255.0 blue:243/255.0 alpha:1.0].CGColor range:NSMakeRange(0,[desc length])];
        [desc addAttribute:(NSString*)kCTForegroundColorAttributeName value:(id)FONT_COLOR_250.CGColor range:NSMakeRange(49,[desc length]-49)];
        CTFontRef fontref16= CTFontCreateWithName(CFSTR("HelveticaNeue"), 16.0, NULL);
        [desc addAttribute:(NSString*)kCTFontAttributeName value:(id)fontref16 range:NSMakeRange(0,[desc length])];
        CFRelease(fontref16);

//        NSShadow *shadowDic=[[NSShadow alloc] init];
//        [shadowDic setShadowBlurRadius:1];
//        [shadowDic setShadowColor:[UIColor redColor]];
//        [shadowDic setShadowOffset:CGSizeMake(0, 1)];
//        [desc addAttribute:NSShadowAttributeName value:shadowDic range:NSMakeRange(0,49)];
//        [shadowDic release];

//        NSShadow *shadowDicblack=[[NSShadow alloc] init];
//        [shadowDicblack setShadowBlurRadius:1];
//        [shadowDicblack setShadowColor:[UIColor blackColor]];
//        [shadowDicblack setShadowOffset:CGSizeMake(0, 1)];
//        [desc addAttribute:NSShadowAttributeName value:shadowDicblack range:NSMakeRange(49,[desc length]-49)];
//        [shadowDicblack release];
        [hint_desc setText:desc];
        
        [desc release];
        [hint_title setHidden:NO];
        [hint_desc setHidden:NO];
        [sendbtn setTitle:@"Send" forState:UIControlStateNormal];
//        [sendbtn setEnabled:YES];
        [sendbtn removeTarget:self action:@selector(sendPwd:) forControlEvents:UIControlEventTouchUpInside];
        [sendbtn addTarget:self action:@selector(sendVerify:) forControlEvents:UIControlEventTouchUpInside];
        [sendbtn setHidden:NO];
        
    }
}
- (void) backLandingView:(id)sender{
    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction)sendVerify:(id)sender{
//RESTKIT0.2  
//    RKClient *client = [RKClient sharedClient];
//    [client setBaseURL:[RKURL URLWithBaseURLString:API_V2_ROOT]];
//    NSString *provider=[Util findProvider:textUsername.text];
//    NSString *endpoint = @"/users/VerifyIdentity";
//    
//    RKParams* params = [RKParams params];
//    [params setValue:provider forParam:@"provider"];
//    [params setValue:textUsername.text forParam:@"external_username"];

//    [client setValue:app.accesstoken forHTTPHeaderField:@"token"];
    [spin removeFromSuperview];
    [sendbtn addSubview:spin];
    [spin setHidden:NO];
//RESTKIT0.2
//    [client post:endpoint usingBlock:^(RKRequest *request){
//        request.params=params;
//        request.onDidFailLoadWithError=^(NSError *error){
//            [spin setHidden:YES];
//        };
//        request.onDidLoadResponse=^(RKResponse *response){
//            if (response.statusCode == 200) {
//                [spin setHidden:YES];
//
//                NSMutableAttributedString * desc = [[NSMutableAttributedString alloc] initWithString:@"Verification sent, it should arrive in minutes. Please check your mailbox and follow the instruction."];
//                if([provider isEqualToString:@"phone"])
//                  desc = [[NSMutableAttributedString alloc] initWithString:@"Verification sent, it should arrive in minutes. Please check your phone and follow the instruction."];
//
//                [desc addAttribute:(NSString*)kCTForegroundColorAttributeName value:(id)FONT_COLOR_250.CGColor range:NSMakeRange(0,[desc length])];
//                
//                CTFontRef fontref16= CTFontCreateWithName(CFSTR("HelveticaNeue"), 16.0, NULL);
//                [desc addAttribute:(NSString*)kCTFontAttributeName value:(id)fontref16 range:NSMakeRange(0,[desc length])];
//                CFRelease(fontref16);
//
//                [hint_desc setText:desc];
//                [desc release];
//                [sendbtn setTitle:@"Done" forState:UIControlStateNormal];
//                [sendbtn removeTarget:self action:@selector(sendVerify:) forControlEvents:UIControlEventTouchUpInside];
//                [sendbtn addTarget:self action:@selector(backLandingView:) forControlEvents:UIControlEventTouchUpInside];
//            }
//        };
//    }];
}

- (void) countdownResend:(NSTimer*)theTimer{
    sendbtn.tag=sendbtn.tag-1;
    
    [sendbtn setTitle:[NSString stringWithFormat:@"Resend in %u seconds",sendbtn.tag] forState:UIControlStateNormal];

    if(sendbtn.tag==0)
    {
        [theTimer invalidate];
        [sendbtn setTitle:@"Send" forState:UIControlStateNormal];
        [sendbtn removeTarget:self action:@selector(sendPwd:) forControlEvents:UIControlEventTouchUpInside];
        [sendbtn addTarget:self action:@selector(sendVerify:) forControlEvents:UIControlEventTouchUpInside];
    }
}

- (IBAction)sendPwd:(id)sender{
  //RESTKIT0.2
//    RKClient *client = [RKClient sharedClient];
//    NSString *endpoint = [NSString stringWithFormat:@"/users/forgotpassword"];
//    RKParams* rsvpParams = [RKParams params];
//    NSString *provider=[Util findProvider:textUsername.text];
//    [rsvpParams setValue:provider forParam:@"provider"];
//    [rsvpParams setValue:textUsername.text forParam:@"external_username"];
//    
//    AppDelegate *app=(AppDelegate *)[[UIApplication sharedApplication] delegate];
//    
//    [client setValue:app.accesstoken forHTTPHeaderField:@"token"];
//    
//    [client post:endpoint usingBlock:^(RKRequest *request){
//        request.method=RKRequestMethodPOST;
//        request.params=rsvpParams;
//        request.onDidLoadResponse=^(RKResponse *response){
//            if (response.statusCode == 200) {
////                [hint_desc setText:@"Password sent, it should arrive in minutes. Please check your mailbox and follow the instruction."];
//                [sendbtn setHidden:YES];
//            }
//        };
//    }];
}
//#pragma mark RKObjectLoaderDelegate methods

@end
