//
//  LandingViewController.m
//  EXFE
//
//  Created by ju huo on 5/22/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "LandingViewController.h"
#import "SigninViewController.h"
#import "AppDelegate.h"

@interface LandingViewController ()

@end

@implementation LandingViewController
@synthesize delegate;

- (IBAction) SigninButtonPress:(id) sender{
    SigninViewController *signView=[[[SigninViewController alloc]initWithNibName:@"SigninViewController" bundle:nil] autorelease];
    signView.delegate=self;
    CGRect inFrame = [signView.view frame];
    CGRect outFrame = [self.view frame];
    outFrame.origin.y -= inFrame.size.height;
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.5];
    [self.view setFrame:outFrame];
    [UIView commitAnimations];
    [self presentModalViewController:signView animated:YES];
}
- (void)dismissSigninView{

//    CGRect inFrame = [signView.view frame];
    CGRect outFrame = [self.view frame];
    outFrame.origin.y = 0;
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.5];
    [self.view setFrame:outFrame];
    [UIView commitAnimations];
    [self dismissModalViewControllerAnimated:YES];
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

- (void)SigninDidFinish{
    
    [self.navigationController dismissModalViewControllerAnimated:YES];
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
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
    [self.view setFrame:[UIScreen mainScreen].bounds];

    signindelegate=[[SigninDelegate alloc]init];
    signindelegate.parent=self;

    signintoolbar=[[SigninIconToolbarView alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height-50, self.view.bounds.size.width, 50) style:@"landing" delegate:self];
    signintoolbar.backgroundColor=[UIColor colorWithPatternImage:[UIImage imageNamed:@"signinbar_bg.png"]];
    [self.view addSubview:signintoolbar];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}
- (void)dealloc {
    [signintoolbar release];
//    [signinbutton release];
//    [twitterbutton release];
    [signindelegate release];
    [super dealloc];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
