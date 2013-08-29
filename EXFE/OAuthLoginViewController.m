//
//  OAuthLoginViewControllerViewController.m
//  EXFE
//
//  Created by ju huo on 5/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "OAuthLoginViewController.h"
#import "Util.h"
#import "URLParser.h"
#import "UIApplication+EXFE.h"
#import "MBProgressHUD.h"
#import "EXSpinView.h"

@interface OAuthLoginViewController ()
@property (nonatomic, copy) NSString *matchedURL;
@property (nonatomic, copy) NSString *javaScriptString;
@property (nonatomic, readwrite, assign) Provider provider;
@end

@implementation OAuthLoginViewController
- (void)setExternal_username:(NSString *)external_username
{
    _external_username = external_username;
    
    if (external_username) {
        switch (self.provider) {
            case kProviderTwitter:
                self.matchedURL = @"https://api.twitter.com/oauth/auth";
                self.javaScriptString = [NSString stringWithFormat:@"document.getElementById('username_or_email').value='%@';", external_username];
                
                break;
            case kProviderFacebook:
                self.matchedURL = @"http://m.facebook.com/login.php?";
                self.javaScriptString = [NSString stringWithFormat:@"document.getElementsByName('email')[0].value='%@';", external_username];
                break;
            default:
                break;
        }
    }
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil provider:(Provider)provider
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.onSuccess = nil;
        self.onCancel = nil;
        self.matchedURL = nil;
        self.javaScriptString = nil;
        self.provider = provider;
        
        // eg:  exfe://oauthcallback
        NSString *callback = [NSString stringWithFormat: @"%@://oauthcallback", [UIApplication sharedApplication].defaultScheme];
        self.oAuthURL = [NSString stringWithFormat:@"%@/Authenticate?device=iOS&device_callback=%@&provider=%@", EXFE_OAUTH_LINK, [Util EFPercentEscapedQueryStringPairMemberFromString:callback], [Util EFPercentEscapedQueryStringPairMemberFromString:[Identity getProviderString:provider]]];
    }
    return self;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    [Flurry logEvent:@"OAUTH_SIGN_IN"];
    toolbar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 47)];
    [toolbar setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"navbar.png"]]];
	self.title = NSLocalizedString(@"Sign In", nil);
    UIImage *btn_dark = [UIImage imageNamed:@"btn_dark.png"];
    UIImageView *backimg=[[UIImageView alloc] initWithFrame:CGRectMake(5, 7, 50, 30)];
    backimg.image=btn_dark;
    backimg.contentMode=UIViewContentModeScaleToFill;
    backimg.contentStretch = CGRectMake(0.5, 0.5, 0, 0);
    [toolbar addSubview:backimg];

    cancelbutton=[UIButton buttonWithType:UIButtonTypeCustom];
    [cancelbutton setFrame:CGRectMake(5, 7, 50, 30)];
    [cancelbutton setTitle:NSLocalizedString(@"Cancel", nil) forState:UIControlStateNormal];
    [cancelbutton.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:12]];
    [cancelbutton setTitleColor:FONT_COLOR_FA forState:UIControlStateNormal];
    
    [cancelbutton addTarget:self action:@selector(cancel) forControlEvents:UIControlEventTouchUpInside];
    [toolbar addSubview:cancelbutton];
    
    titlelabel=[[UILabel alloc] initWithFrame:CGRectMake(65, 10, 230, 24)];
    switch (_provider) {
        case kProviderTwitter:
            titlelabel.text = NSLocalizedString(@"Twitter Authorization", nil);
            break;
        case kProviderFacebook:
            titlelabel.text = NSLocalizedString(@"Facebook Authorization", nil);
            break;
        default:
            break;
    }
    
    titlelabel.backgroundColor=[UIColor clearColor];
    titlelabel.textAlignment=UITextAlignmentCenter;
    [titlelabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:20]];
    [titlelabel setShadowColor:[UIColor colorWithWhite:0 alpha:0.75]];
    [titlelabel setShadowOffset:CGSizeMake(0, 1)];
    [titlelabel setTextColor:[UIColor whiteColor]];
    [toolbar addSubview:titlelabel];
    [self.view addSubview:toolbar];
    
    firstLoading = YES;
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.oAuthURL]]];
}

- (void)cancel {
    [self dismissViewControllerAnimated:YES completion:^{
        if (self.onCancel) {
            self.onCancel();
        }
    }];
}

- (void)viewDidUnload
{
    [self.webView stopLoading];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    if(firstLoading==YES)
    {
        MBProgressHUD *hud=[MBProgressHUD showHUDAddedTo:self.webView animated:YES];
        hud.mode=MBProgressHUDModeCustomView;
        EXSpinView *bigspin = [[EXSpinView alloc] initWithPoint:CGPointMake(0, 0) size:40];
        [bigspin startAnimating];
        hud.customView=bigspin;
        hud.labelText = NSLocalizedString(@"Loading", nil);
    }
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    if(firstLoading==YES)
    {
        firstLoading=NO;
        [MBProgressHUD hideHUDForView:self.webView animated:YES];
    }
    
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    if(firstLoading==YES)
    {
        firstLoading=NO;
        [MBProgressHUD hideHUDForView:self.webView animated:YES];
        NSString *currentURL = webView.request.URL.absoluteString;
        if (self.matchedURL && self.javaScriptString) {
            if ([currentURL hasPrefix:self.matchedURL]) {
                [webView stringByEvaluatingJavaScriptFromString:self.javaScriptString];
            }
        }
    }
}
- (BOOL)webView:(UIWebView *)webview shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    if ([@"oauthcallback" isEqualToString:request.URL.host] && [request.URL.parameterString rangeOfString:@"token="].location != NSNotFound) {
        
        URLParser *parser = [[URLParser alloc] initWithURLString:request.URL.absoluteString];
        NSString *err = [parser valueForVariable:@"err"];
        if(!err)
        {
            NSString *userid = [parser valueForVariable:@"userid"];
            NSString *name = [parser valueForVariable:@"name"];
            
            name = [Util decodeFromPercentEscapeString:name];
            
            NSString *token = [parser valueForVariable:@"token"];
            NSString *external_id = [parser valueForVariable:@"external_id"];
            if (self.onSuccess) {
                NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:4];
                [params setValue:userid forKey:@"userid"];
                [params setValue:name forKey:@"name"];
                [params setValue:token forKey:@"token"];
                [params setValue:external_id forKey:@"external_id"];
                
                self.onSuccess(params);
            }
        }
        [self dismissViewControllerAnimated:YES completion:nil];
        return NO;
    }
    return YES;
}

@end
