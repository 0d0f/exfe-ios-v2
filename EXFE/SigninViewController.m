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
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}
- (void)dealloc
{
    [signindelegate release];
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
        editinginterval=CFAbsoluteTimeGetCurrent();
        [self performSelector:@selector(getUser) withObject:self afterDelay:1.2];
    } else {
        avatarview.image=nil;
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
