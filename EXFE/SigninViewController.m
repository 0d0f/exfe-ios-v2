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
    
//    NSString *identity=@"virushuo@gmail.com";
//    NSString *password=@"tmdtmd";
    NSString *password=[textPassword text];
    NSString *identity=[textUsername text];

    NSDictionary* params=[NSDictionary dictionaryWithObjectsAndKeys:identity, @"external_id",
                          @"email", @"provider",
                          password, @"password", nil];
    
    [[RKClient sharedClient] post:@"/users/signin" params:params delegate:self];
    
}
- (IBAction) TwitterLoginButtonPress:(id) sender{
    OAuthLoginViewController *oauth = [[OAuthLoginViewController alloc] initWithNibName:@"OAuthLoginViewController" bundle:nil];
    oauth.delegate=self;
    
    [self presentModalViewController:oauth animated:YES];
    

}
#pragma Mark - OAuthlogin Delegate
- (void)OAuthloginViewControllerDidCancel:(UIViewController *)oauthlogin {
    [self dismissModalViewControllerAnimated:YES];        
    [oauthlogin release]; 
    oauthlogin = nil; 
}
-(void)OAuthloginViewControllerDidSuccess:(OAuthLoginViewController *)oauthloginViewController userid:(NSString*)userid username:(NSString*)username external_id:(NSString*)external_id token:(NSString*)token
{
//    [self loginSuccessWithUserId:userid username:username external_id:external_id token:token];

    [self loginSuccessWith:token userid:userid username:username];
}
#pragma Mark - RKRequestDelegate

- (void)request:(RKRequest*)request didLoadResponse:(RKResponse*)response {
    
    if ([request isGET]) {
        if ([response isOK]) {
            NSLog(@"Data returned: %@", [response bodyAsString]);
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

- (void)loginSuccessWith:(NSString *)token userid:(NSString *)userid username:(NSString *)username {
    [[NSUserDefaults standardUserDefaults] setObject:token forKey:@"access_token"];
    [[NSUserDefaults standardUserDefaults] setObject:userid forKey:@"userid"];
    [[NSUserDefaults standardUserDefaults] synchronize];

    AppDelegate *app=(AppDelegate *)[[UIApplication sharedApplication] delegate];

    app.userid=[userid intValue];
    app.accesstoken=token;

    [APIProfile LoadUsrWithUserId:app.userid delegate:self];

    
}

- (void) processResponse:(id)obj{
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
                        [self loginSuccessWith:token userid:userid username:username];
                    }
                }
                else{
                    NSLog(@"%@",obj);
                }
            }
        }
    }
    NSLog(@"POST returned a JSON response:%@",obj);
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
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
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
            NSString *json=[NSString stringWithFormat:@"{\"provider\":\"%@\",\"external_username\":\"%@\"}",@"email",textUsername.text];
            json=[NSString stringWithFormat:@"[%@]",json];
            RKClient *client = [RKClient sharedClient];
            NSString *endpoint = [NSString stringWithFormat:@"/identities/get"];
            RKParams* rsvpParams = [RKParams params];
            [rsvpParams setValue:json forParam:@"identities"];
            AppDelegate *app=(AppDelegate *)[[UIApplication sharedApplication] delegate];

            [client setValue:app.accesstoken forHTTPHeaderField:@"token"];
            
            [client post:endpoint usingBlock:^(RKRequest *request){
                request.method=RKRequestMethodPOST;
                request.params=rsvpParams;
                request.onDidLoadResponse=^(RKResponse *response){
                    if (response.statusCode == 200) {
                        NSDictionary *body=[response.body objectFromJSONData];
                        id code=[[body objectForKey:@"meta"] objectForKey:@"code"];
                        if(code)
                            if([code intValue]==200) {
                                NSDictionary* response = [body objectForKey:@"response"];
                                NSArray *identities = [response objectForKey:@"identities"];
                                if(identities && [identities count]>0) {
                                    NSDictionary *identity=[identities objectAtIndex:0];
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
    NSArray *subviews=[hintpannel subviews];
    for(UIView *view in subviews){
        [view removeFromSuperview];
    }
    if([hintname isEqualToString:@"forgetpassword"]){
        UILabel *label=[[UILabel alloc] initWithFrame:CGRectMake(10, 10, 300, 30)];
        label.text=@"Forgot Password";
        [hintpannel addSubview:label];
        [label release];
        UILabel *labeldesc=[[UILabel alloc] initWithFrame:CGRectMake(10, 40, 300, 80)];
        labeldesc.text=@"You can reset your EXFE password through this identity. Confirm sending reset token to your mailbox?";
        [labeldesc setLineBreakMode:UILineBreakModeWordWrap];
        labeldesc.numberOfLines = 0;
        [hintpannel addSubview:labeldesc];
        [labeldesc release];
    }
}
#pragma mark RKObjectLoaderDelegate methods

- (void)objectLoader:(RKObjectLoader *)objectLoader didLoadObjects:(NSArray *)objects {
    AppDelegate *app=(AppDelegate *)[[UIApplication sharedApplication] delegate];
	NSFetchRequest* request = [User fetchRequest];
    NSPredicate *predicate = [NSPredicate
                              predicateWithFormat:@"user_id = %u", app.userid];    
    [request setPredicate:predicate];
	NSArray *users = [[User objectsWithFetchRequest:request] retain];
    
    if(users!=nil && [users count] >0)
    {
        User* user=[users objectAtIndex:0];
        NSLog(@"%@",user.name );
        [[NSUserDefaults standardUserDefaults] setObject:user.name forKey:@"username"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        app.username=user.name;
    }
    [delegate SigninDidFinish];
}

- (void)objectLoader:(RKObjectLoader *)objectLoader didFailWithError:(NSError *)error {
    NSLog(@"Error!:%@",error);
    //    [self stopLoading];
}

@end
