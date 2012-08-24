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
    [self presentModalViewController:signView animated:YES];
}
- (void)TwitterSigninButtonPress:(id)sender{
    OAuthLoginViewController *oauth = [[OAuthLoginViewController alloc] initWithNibName:@"OAuthLoginViewController" bundle:nil];
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
    signindelegate=[[SigninDelegate alloc]init];
    signindelegate.parent=self;

    signintoolbar=[[SigninIconToolbarView alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height-50, self.view.bounds.size.width, 50) style:@"landing" delegate:self];
    signintoolbar.backgroundColor=[UIColor colorWithPatternImage:[UIImage imageNamed:@"signinbar_bg.png"]];
//    UIImage *signbtn_backimg = [UIImage imageNamed:@"signinbar_btnbg.png"];
//    UIImageView *backimg=[[UIImageView alloc] initWithFrame:CGRectMake(14, 10, 126, 31)];
//    backimg.image=signbtn_backimg;
//    backimg.contentMode=UIViewContentModeScaleToFill;
//    backimg.contentStretch = CGRectMake(0.5, 0.5, 0, 0);
//    [signintoolbar addSubview:backimg];
//    [backimg release];
//  
//    signinbutton=[UIButton buttonWithType:UIButtonTypeCustom];
//    [signinbutton setFrame:CGRectMake(14, 10, 126, 31)];
//    [signinbutton setTitle:@"Start with email" forState:UIControlStateNormal];
//    [signinbutton.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:16]];
//    [signinbutton setTitleColor:FONT_COLOR_51 forState:UIControlStateNormal];
//    [signinbutton setTitleShadowColor:[UIColor whiteColor] forState:UIControlStateNormal];
//    signinbutton.titleLabel.shadowOffset=CGSizeMake(0, 1);
//    
//    [signinbutton addTarget:self action:@selector(SigninButtonPress:) forControlEvents:UIControlEventTouchUpInside];
//    [signintoolbar addSubview:signinbutton];
//    
//    twitterbutton=[UIButton buttonWithType:UIButtonTypeCustom];
//    [twitterbutton setFrame:CGRectMake(212+13, 10, 32, 32)];
//    [twitterbutton setBackgroundImage:[UIImage imageNamed:@"identity_twitter_32.png"] forState:UIControlStateNormal];
//    [twitterbutton addTarget:self action:@selector(TwitterSigninButtonPress:) forControlEvents:UIControlEventTouchUpInside];
//    
//    [signintoolbar addSubview:twitterbutton];
    
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
