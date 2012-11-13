//
//  AddIdentityViewController.m
//  EXFE
//
//  Created by huoju on 11/12/12.
//
//

#import "AddIdentityViewController.h"

@interface AddIdentityViewController ()

@end

@implementation AddIdentityViewController
@synthesize profileview;

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
//    signindelegate=[[SigninDelegate alloc]init];
//    signindelegate.parent=self;
    
    signintoolbar=[[SigninIconToolbarView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 50) style:@"signin" delegate:self];
    signintoolbar.backgroundColor=[UIColor colorWithPatternImage:[UIImage imageNamed:@"signinbar_bg.png"]];
    [self.view addSubview:signintoolbar];
    
    UIImage *textfieldback = [UIImage imageNamed:@"textfield_bg_rect.png"];
    identitybackimg=[[UIImageView alloc] initWithFrame:CGRectMake(20, 70, 230, 41)];
    identitybackimg.image=textfieldback;
    identitybackimg.contentMode=UIViewContentModeScaleToFill;
    identitybackimg.contentStretch = CGRectMake(0.5, 0.5, 0, 0);
    [self.view addSubview:identitybackimg];
    
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
    
    avatarview=[[UIImageView alloc] initWithFrame:CGRectMake(260, 70, 40, 40)];
    avatarview.image=nil;
    [self.view addSubview:avatarview];
    avatarframeview=[[UIImageView alloc] initWithFrame:CGRectMake(260, 70, 40, 41)];
    avatarframeview.image=nil;
    [self.view addSubview:avatarframeview];
    
    
    addbtn=[UIButton buttonWithType:UIButtonTypeCustom];
    [addbtn setFrame:CGRectMake(20, 140, 280, 44)];
    [addbtn setTitle:@"Add" forState:UIControlStateNormal];
    [addbtn.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:18]];
    [addbtn setTitleColor:[UIColor colorWithRed:204.0/255.0f green:229.0/255.0f blue:255.0/255.0f alpha:1] forState:UIControlStateNormal];
    [addbtn addTarget:self action:@selector(addIdentity:) forControlEvents:UIControlEventTouchUpInside];
    [addbtn setTitleShadowColor:[UIColor colorWithRed:21.0/255.0f green:52.0/255.0f blue:84.0/255.0f alpha:1] forState:UIControlStateNormal];
    addbtn.titleLabel.shadowOffset=CGSizeMake(0, 1);
    [addbtn setBackgroundImage:[[UIImage imageNamed:@"btn_light_44.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 12, 0, 12)] forState:UIControlStateNormal];
    [self.view addSubview:addbtn];
    
    labelSignError=[[UILabel alloc] initWithFrame:CGRectMake(20, 135+40+4, 280, 18)];
    labelSignError.backgroundColor=[UIColor clearColor];
    labelSignError.text=@"";
    labelSignError.textColor=[UIColor colorWithRed:204/255.f green:81/255.f blue:71/255.f alpha:1.0];
    labelSignError.shadowColor=[UIColor whiteColor];
    labelSignError.shadowOffset=CGSizeMake(0, 1);
    [self.view addSubview:labelSignError];
    
    
    spin=[[EXSpinView alloc] initWithPoint:CGPointMake([addbtn frame].size.width-18-10, ([addbtn frame].size.height-18)/2) size:18];
    [addbtn addSubview:spin];
    [setupnewbtn addSubview:spin];
    [spin startAnimating];
    [spin setHidden:YES];
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

- (void) getUser{
    //    if(CFAbsoluteTimeGetCurrent()-editinginterval>1.2)
    //    {
    NSString *provider=[Util findProvider:textUsername.text];
    if(![provider isEqualToString:@""]){
        
        NSString *json=@"";
        json=[json stringByAppendingFormat:@"{\"provider\":\"%@\",\"external_username\":\"%@\"}",provider,textUsername.text];
        json=[NSString stringWithFormat:@"[%@]",json];
        AppDelegate *app=(AppDelegate *)[[UIApplication sharedApplication] delegate];
        RKClient *client = [RKClient sharedClient];
        [client setBaseURL:[RKURL URLWithBaseURLString:API_V2_ROOT]];
//        MBProgressHUD *hud=[MBProgressHUD showHUDAddedTo:self.view animated:YES];
//        hud.labelText = @"Adding...";
//        hud.mode=MBProgressHUDModeCustomView;
//        EXSpinView *bigspin = [[EXSpinView alloc] initWithPoint:CGPointMake(0, 0) size:40];
//        [bigspin startAnimating];
//        hud.customView=bigspin;
//        [bigspin release];
    
        NSString *endpoint = [NSString stringWithFormat:@"/identities/get"];
        RKParams* rsvpParams = [RKParams params];
        [rsvpParams setValue:json forParam:@"identities"];
        [client setValue:app.accesstoken forHTTPHeaderField:@"token"];
        [client post:endpoint usingBlock:^(RKRequest *request){
            request.method=RKRequestMethodPOST;
            request.params=rsvpParams;
            request.onDidLoadResponse=^(RKResponse *response){
//                [MBProgressHUD hideHUDForView:self.view animated:YES];
                if (response.statusCode == 200) {
                    NSDictionary *body=[response.body objectFromJSONData];
                    if([body isKindOfClass:[NSDictionary class]]) {
                        id code=[[body objectForKey:@"meta"] objectForKey:@"code"];
                        if(code)
                            if([code intValue]==200) {
                                NSDictionary* response = [body objectForKey:@"response"];
                                NSArray *identities = [response objectForKey:@"identities"];
                                if(identities && [identities count]>0){
                                    NSDictionary *identity = [identities objectAtIndex:0];
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
                            }
                    }
                }
         
            };
            request.onDidFailLoadWithError=^(NSError *error){
//                [MBProgressHUD hideHUDForView:self.view animated:YES];
            };
        }];
    }
}

- (void) addIdentity:(id) sender{
    
//    api.local.exfe.com/v2/users/208/addIdentity?token=764ca290b978ddc65e1364e50b3692575c9460c764a1dd6a798d78db93aec13e external_username='xxx@leaskh.com' provider='email'
    AppDelegate *app=(AppDelegate *)[[UIApplication sharedApplication] delegate];
    RKClient *client = [RKClient sharedClient];
    [client setBaseURL:[RKURL URLWithBaseURLString:API_V2_ROOT]];
    NSString *endpoint = [NSString stringWithFormat:@"/users/%u/addIdentity",app.userid];
    
    RKParams* rsvpParams = [RKParams params];
    NSString *provider=[Util findProvider:textUsername.text];
    
    if([provider isEqualToString:@"twitter"] || [provider isEqualToString:@"facebook"]){
        [rsvpParams setValue:@"" forParam:@"external_username"];
        NSString *callback=@"oauth://handleOAuthAddIdentity";
        [rsvpParams setValue:callback forParam:@"device_callback"];
        [rsvpParams setValue:@"iOS" forParam:@"device"];
    }
    else
        [rsvpParams setValue:textUsername.text forParam:@"external_username"];
    [rsvpParams setValue:provider forParam:@"provider"];
    
    [client setValue:app.accesstoken forHTTPHeaderField:@"token"];
    [client post:endpoint usingBlock:^(RKRequest *request){
        request.method=RKRequestMethodPOST;
        request.params=rsvpParams;
        request.onDidLoadResponse=^(RKResponse *response){
            //                [MBProgressHUD hideHUDForView:self.view animated:YES];
            if (response.statusCode == 200) {
                NSDictionary *body=[response.body objectFromJSONData];
                if([body isKindOfClass:[NSDictionary class]]) {
                    id code=[[body objectForKey:@"meta"] objectForKey:@"code"];
                    if(code){
                        if([code intValue]==200) {
                            NSDictionary *responseobj=[body objectForKey:@"response"];
                            if([responseobj isKindOfClass:[NSDictionary class]]){
                                if([responseobj objectForKey:@"url"]!=nil){
                                    NSLog(@"redirect_to_oauthurl: %@",[responseobj objectForKey:@"url"]);
                                    OAuthAddIdentityViewController *oauth=[[OAuthAddIdentityViewController alloc] initWithNibName:@"OAuthAddIdentityViewController" bundle:nil];
                                    oauth.parentView=self;
                                    oauth.oauth_url=[responseobj objectForKey:@"url"];
                                    [self presentModalViewController:oauth animated:YES];

                                }else{

                                    [((ProfileViewController*)profileview) refreshIdentities];
                                    [self.navigationController popViewControllerAnimated:YES];
//                                    [self dismissModalViewControllerAnimated:YES];
                                }
                            }
                        }
                        else{
                            if([[body objectForKey:@"meta"] objectForKey:@"errorType"]!=nil && [[[body objectForKey:@"meta"] objectForKey:@"errorType"] isEqualToString:@"no_connected_identity"] ){
                                NSLog(@"error:%@",[[body objectForKey:@"meta"] objectForKey:@"errorType"]);
                            }
                        }
                    }
                }
            }
            
        };
        request.onDidFailLoadWithError=^(NSError *error){
            NSLog(@"error %@",error);
            //                [MBProgressHUD hideHUDForView:self.view animated:YES];
        };
    }];
}

- (void) oauthSuccess{
    [((ProfileViewController*)profileview) refreshIdentities];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) TwitterSigninButtonPress:(id)sender{
    OAuthAddIdentityViewController *oauth=[[OAuthAddIdentityViewController alloc] initWithNibName:@"OAuthAddIdentityViewController" bundle:nil];
    [self presentModalViewController:oauth animated:YES];
    [oauth release];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
