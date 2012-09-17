//
//  OAuthLoginViewControllerViewController.m
//  EXFE
//
//  Created by ju huo on 5/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "OAuthLoginViewController.h"
#import "URLParser.h"
//#define EXFE_OAUTH_LINK @"https://exfe.com/oauth"
@interface OAuthLoginViewController ()
@end

@implementation OAuthLoginViewController
@synthesize webView;
@synthesize delegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (void)webViewDidStartLoad:(UIWebView *)webView
{
    if(firstLoading==YES)
    {
//        NSLog(@"web start load");
//        MBProgressHUD *hud=[MBProgressHUD showHUDAddedTo:self.webView animated:YES];
        
//        MBProgressHUD *hud=[MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
//        hud.labelText = @"Loading";
        
    }
}
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    if(firstLoading==YES)
    {
        firstLoading=NO;
//        [MBProgressHUD hideHUDForView:self.webView animated:YES];
//        NSLog(@"web stop load");
    }
    
}
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    if(firstLoading==YES)
    {
        firstLoading=NO;
//        [MBProgressHUD hideHUDForView:self.webView animated:YES];
//        NSLog(@"web stop load");
    }
}
- (void)viewDidLoad {
    
    [super viewDidLoad];
    toolbar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 47)];
    [toolbar setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"navbar.png"]]];
	self.title = @"Sign In";
    UIImage *btn_dark = [UIImage imageNamed:@"btn_dark.png"];
    UIImageView *backimg=[[UIImageView alloc] initWithFrame:CGRectMake(5, 7, 50, 30)];
    backimg.image=btn_dark;
    backimg.contentMode=UIViewContentModeScaleToFill;
    backimg.contentStretch = CGRectMake(0.5, 0.5, 0, 0);
    [toolbar addSubview:backimg];
    [backimg release];

    cancelbutton=[UIButton buttonWithType:UIButtonTypeCustom];
    [cancelbutton setFrame:CGRectMake(5, 7, 50, 30)];
    [cancelbutton setTitle:@"Cancel" forState:UIControlStateNormal];
    [cancelbutton.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:12]];
    [cancelbutton setTitleColor:FONT_COLOR_FA forState:UIControlStateNormal];
    
    [cancelbutton addTarget:self action:@selector(cancel) forControlEvents:UIControlEventTouchUpInside];
    [toolbar addSubview:cancelbutton];
    
    titlelabel=[[UILabel alloc] initWithFrame:CGRectMake(65, 10, 230, 24)];
    titlelabel.text=@"Twitter Authorization";
    titlelabel.backgroundColor=[UIColor clearColor];
    titlelabel.textAlignment=UITextAlignmentCenter;
    [titlelabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:20]];
    [titlelabel setShadowColor:[UIColor colorWithWhite:0 alpha:0.75]];
    [titlelabel setShadowOffset:CGSizeMake(0, 1)];
    [titlelabel setTextColor:[UIColor whiteColor]];
    [toolbar addSubview:titlelabel];
    [self.view addSubview:toolbar];
    
    NSString *callback=@"oauth://handleTwitterLogin";
    NSString *urlstr=[NSString stringWithFormat:@"%@/TwitterAuthenticate?device=iOS&device_callback=%@",EXFE_OAUTH_LINK,callback];
    
//    NSString *urlstr=[NSString stringWithFormat:@"https://exfe.com/oAuth/twitterRedirect?device=iOS&device_callback=%@",callback];
    firstLoading=YES;
    [webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlstr]]];
}

- (void)cancel {
    [self.delegate OAuthloginViewControllerDidCancel:self];
}

- (BOOL)webView:(UIWebView *)webview shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    NSString *URLString = [[request URL] absoluteString];
    if ([URLString rangeOfString:@"token="].location != NSNotFound && [URLString rangeOfString:@"oauth://handleTwitterLogin"].location != NSNotFound) {
        URLParser *parser = [[[URLParser alloc] initWithURLString:URLString] autorelease];
        NSString *err = [parser valueForVariable:@"err"];
        if(!err)
        {
        NSString *userid = [parser valueForVariable:@"userid"];
        NSString *name = [parser valueForVariable:@"name"];
        NSString *identity_status = [parser valueForVariable:@"identity_status"];
        if([identity_status isEqualToString:@"new"]){
            [[NSUserDefaults standardUserDefaults] setObject:@"YES" forKey:@"NEWUSER"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }

        name=[Util decodeFromPercentEscapeString:name];
            
        NSString *token = [parser valueForVariable:@"token"];
        NSString *external_id = [parser valueForVariable:@"external_id"];
        [self.delegate OAuthloginViewControllerDidSuccess:self userid:userid username:name external_id:external_id token:token];
//        [parser release];
        }
        return NO;
    }
    return YES;
}
-(void)dealloc{
    [toolbar release];
    [titlelabel release];
    [super dealloc];
}
- (void)viewDidUnload
{
    [webView stopLoading];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
