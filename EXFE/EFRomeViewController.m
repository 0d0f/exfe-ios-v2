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
    
    // CAGradientLayer
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.colors = @[(id)[UIColor COLOR_BLUE_NAVY].CGColor,
                             (id)[UIColor COLOR_BLACK_19].CGColor];
    gradientLayer.bounds = self.view.bounds;
    gradientLayer.position = self.view.center;
    [self.view.layer insertSublayer:gradientLayer atIndex:0];
}

- (void)dealloc {
    [_closeButton release];
    [super dealloc];
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

@end
