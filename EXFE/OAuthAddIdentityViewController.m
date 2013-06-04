//
//  OAuthAddIdentityViewController.m
//  EXFE
//
//  Created by huoju on 11/13/12.
//
//

#import "OAuthAddIdentityViewController.h"

@interface OAuthAddIdentityViewController ()

@end

@implementation OAuthAddIdentityViewController
@synthesize oauth_url;
@synthesize parentView;
@synthesize webview;

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
    [Flurry logEvent:@"OAUTH_ADD_IDENTITY"];
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
    titlelabel.text=@"Authorization";
    titlelabel.backgroundColor=[UIColor clearColor];
    titlelabel.textAlignment=UITextAlignmentCenter;
    [titlelabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:20]];
    [titlelabel setShadowColor:[UIColor colorWithWhite:0 alpha:0.75]];
    [titlelabel setShadowOffset:CGSizeMake(0, 1)];
    [titlelabel setTextColor:[UIColor whiteColor]];
    [toolbar addSubview:titlelabel];
    [self.view addSubview:toolbar];

    MBProgressHUD *hud=[MBProgressHUD showHUDAddedTo:self.webview animated:YES];
    hud.mode=MBProgressHUDModeCustomView;
    EXSpinView *bigspin = [[EXSpinView alloc] initWithPoint:CGPointMake(0, 0) size:40];
    [bigspin startAnimating];
    hud.customView=bigspin;
    [bigspin release];
    hud.labelText = @"Loading";

    [webview loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:oauth_url]]];
}

- (BOOL)webView:(UIWebView *)webview shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    NSString *URLString = [[request URL] absoluteString];
    
//    NSLog(@"%@",URLString);
    if ([URLString rangeOfString:@"token="].location != NSNotFound && [URLString rangeOfString:@"://oauthcallback/"].location != NSNotFound) {
        if([parentView isKindOfClass:[AddIdentityViewController class]]){
            [((AddIdentityViewController*)parentView) oauthSuccess];
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:NotificationRefreshUserSelf object:self];

        [MBProgressHUD hideHUDForView:self.webview animated:YES];
        [self dismissModalViewControllerAnimated:YES];
    }
    return YES;
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)cancel {
    [self dismissModalViewControllerAnimated:YES];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
//    if(firstLoading==YES)
//    {
//        firstLoading=NO;
        [MBProgressHUD hideHUDForView:self.webview animated:YES];
//    }
    
}
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
//    if(firstLoading==YES)
//    {
//        firstLoading=NO;
        [MBProgressHUD hideHUDForView:self.webview animated:YES];
//    }
}




@end
