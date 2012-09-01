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
