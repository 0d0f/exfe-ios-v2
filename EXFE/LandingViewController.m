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
//    backgroundview=[[LandingBackgroundView alloc] initWithFrame:self.view.bounds];
//    [self.view addSubview:backgroundview];
//    logo=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"exfe_170.png"]];
//    [logo setFrame:CGRectMake(69, 164, 182, 182)];
//    [self.view addSubview:logo];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}
- (void)dealloc {
//    [backgroundview release];
    [super dealloc];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
