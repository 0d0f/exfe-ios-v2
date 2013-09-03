//
//  EFRomeViewController.m
//  EXFE
//
//  Created by 0day on 13-5-24.
//
//

#import "EFRomeViewController.h"

#import <QuartzCore/QuartzCore.h>
#import "Util.h"

@interface EFRomeViewController ()

@end

@implementation EFRomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // close button
    UIImage *closeButtonBackgroundImage = [UIImage imageNamed:@"btn_white_44"];
    closeButtonBackgroundImage = [closeButtonBackgroundImage resizableImageWithCapInsets:(UIEdgeInsets){0.0f, 10.0f, 0.0f, 10.0f}];
    [self.closeButton setBackgroundImage:closeButtonBackgroundImage forState:UIControlStateNormal];
    [self.closeButton setTitle:NSLocalizedString(@"Close", nil) forState:UIControlStateNormal];
    
    // CAGradientLayer
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.colors = @[(id)[UIColor COLOR_BLUE_NAVY].CGColor,
                             (id)[UIColor COLOR_BLACK_19].CGColor];
    gradientLayer.bounds = self.view.bounds;
    gradientLayer.position = self.view.center;
    [self.view.layer insertSublayer:gradientLayer atIndex:0];
}

- (void)viewDidUnload {
    [self setCloseButton:nil];
    [super viewDidUnload];
}

#pragma mark - Action Handler

- (IBAction)closeButtonPressed:(id)sender {
    if (_closeButtonPressedHandler) {
        self.closeButtonPressedHandler();
    }
}

- (IBAction)sendButtonPressed:(id)sender {
    if ([MFMailComposeViewController canSendMail]) {
        NSString *version = [[[NSBundle mainBundle] infoDictionary] valueForKey:@"CFBundleShortVersionString"];
        NSString *buildNumber = [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString*)kCFBundleVersionKey];
        
        MFMailComposeViewController *mailController = [[MFMailComposeViewController alloc] init];
        mailController.mailComposeDelegate = self;
        [mailController setToRecipients:@[@"feedback@exfe.com"]];
        [mailController setSubject:[NSString stringWithFormat:@"Feedback (%@#%@)", version, buildNumber]];
        [self.view.window.rootViewController presentViewController:mailController animated:YES completion:nil];
    }
}

#pragma mark - MFMailComposeViewControllerDelegate

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    [controller.presentingViewController dismissViewControllerAnimated:YES
                                                            completion:nil];
}

@end
