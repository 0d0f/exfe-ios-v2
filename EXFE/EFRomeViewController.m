//
//  EFRomeViewController.m
//  EXFE
//
//  Created by 0day on 13-5-24.
//
//

#import "EFRomeViewController.h"

#import <QuartzCore/QuartzCore.h>
#import "CCTemplate.h"
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
    
    self.rome_title.font = [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:21];
    self.rome_title.text = NSLocalizedString(@"“Rome wasn't built in a day.”", nil);
    
    
    NSString *fullText = [NSLocalizedString(@"{{PRODUCT_APP_NAME}} is still piloting. We’re building up blocks, consequently some bugs or unpolished features may exist. Apologies for any trouble you may encounter. Please email feedback@shuady.com for any problem.", nil) templateFromDict:[Util keywordDict]];
    
    NSString *emailText = @"feedback@shuady.com";
    NSRange emailRange = [fullText rangeOfString:emailText];
    self.rome_description.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:14];
    self.rome_description.numberOfLines = 10;
    self.rome_description.delegate = self;
    [self.rome_description setText:fullText afterInheritingLabelAttributesAndConfiguringWithBlock:^NSMutableAttributedString *(NSMutableAttributedString *mutableAttributedString) {
        NSString *highlight = [NSLocalizedString(@"{{PRODUCT_APP_NAME}}", @"Use as search pattern") templateFromDict:[Util keywordDict]];
        NSRange range = [[mutableAttributedString string] rangeOfString:highlight options:NSCaseInsensitiveSearch];
        
        NSString * fontType = @"HelveticaNeue";
        CTFontRef textfontref= CTFontCreateWithName((__bridge CFStringRef)fontType, 14, NULL);
        [mutableAttributedString addAttribute:(NSString *)kCTFontAttributeName value:(__bridge id)textfontref range:range];
        CFRelease(textfontref);
        return mutableAttributedString;
    }];

    NSTextCheckingResult *tcresult = [NSTextCheckingResult linkCheckingResultWithRange:emailRange URL:[NSURL URLWithString:@"mailto:feedback@shuady.com"]];
    NSString * fontType = @"HelveticaNeue-LightItalic";
    CTFontRef textfontref= CTFontCreateWithName((__bridge CFStringRef)fontType, 14, NULL);
    [self.rome_description addLinkWithTextCheckingResult:tcresult attributes:@{(NSString *)kCTFontAttributeName: (__bridge id)textfontref}];
    CFRelease(textfontref);
    [self.rome_description sizeToFit];
    
    self.much_thanks.frame = CGRectMake(15, CGRectGetMaxY(self.rome_description.frame), CGRectGetWidth(self.view.bounds) - 2 * 15, 50);
    self.much_thanks.text = NSLocalizedString(@"Much appreciated.", nil);
    [self.much_thanks sizeToFit];
}

//- (void)viewDidUnload {
//    [self setCloseButton:nil];
//    [super viewDidUnload];
//}

#pragma mark - Action Handler

- (IBAction)closeButtonPressed:(id)sender {
    if (_closeButtonPressedHandler) {
        self.closeButtonPressedHandler();
    }
}

- (void)sendMail:(NSURL *)url {
    if ([MFMailComposeViewController canSendMail]) {
        NSString *version = [[[NSBundle mainBundle] infoDictionary] valueForKey:@"CFBundleShortVersionString"]; //CFBundleShortVersionString
        NSString *buildNumber = [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString*)kCFBundleVersionKey]; //CFBundleVersion
        
        MFMailComposeViewController *mailController = [[MFMailComposeViewController alloc] init];
        mailController.mailComposeDelegate = self;
        [mailController setToRecipients:@[@"feedback@exfe.com"]];
        [mailController setSubject:[NSString stringWithFormat:NSLocalizedString(@"Feedback (%@#%@)", nil), version, buildNumber]];
        [self.view.window.rootViewController presentViewController:mailController animated:YES completion:nil];
    }
}

#pragma mark - MFMailComposeViewControllerDelegate

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    [controller.presentingViewController dismissViewControllerAnimated:YES
                                                            completion:nil];
}

#pragma mark - TTTAttributedLabelDelegate
- (void)attributedLabel:(TTTAttributedLabel *)label
   didSelectLinkWithURL:(NSURL *)url
{
    if ([[url scheme] isEqualToString:@"mailto"]) {
        RKLogDebug("%@", url);
        [self sendMail: url];
    }
    
}

@end
