//
//  EFSearchIdentityCell.m
//  EXFE
//
//  Created by 0day on 13-4-24.
//
//

#import "EFSearchIdentityCell.h"

#import "EFPopoverController.h"
#import "EFSearchTipViewController.h"

@implementation EFSearchIdentityCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self.accessButton setImage:[UIImage imageNamed:@"pass_question.png"] forState:UIControlStateNormal];
        self.accessButton.imageEdgeInsets = (UIEdgeInsets){0, 0, 0, -21};
        [self.accessButton addTarget:self
                              action:@selector(tipButtonPressed:)
                    forControlEvents:UIControlEventTouchUpInside];
        self.avatarImageView.image = [UIImage imageNamed:@"portrait_default.png"];
        self.userNameLabel.font = [UIFont fontWithName:@"HelveticaNeue-LightItalic" size:21];
    }
    
    return self;
}

+ (NSString *)reuseIdentifier {
    return NSStringFromClass([self class]);
}

- (void)tipButtonPressed:(id)sender {
    EFSearchTipViewController *tipViewController = [[EFSearchTipViewController alloc] initWithNibName:@"EFSearchTipViewController" bundle:nil];
    EFPopoverController *popoverController = [[EFPopoverController alloc] initWithContentViewController:tipViewController];
    [popoverController setContentSize:tipViewController.view.frame.size animated:YES];
    [tipViewController release];
    
    popoverController.backgroundArrowView.gradientColors = @[(id)[UIColor COLOR_RGBA(0x33, 0x33, 0x33, 245)].CGColor, (id)[UIColor COLOR_RGBA(0x22, 0x22, 0x22, 245)].CGColor];
    popoverController.backgroundArrowView.strokeWidth = 0.0f;
    popoverController.backgroundArrowView.strokeColor = [UIColor clearColor];
    
    [popoverController presentFromRect:(CGRect){{287, 0}, {33, 50}}
                                inView:self
                        arrowDirection:kEFArrowDirectionRight
                              animated:YES
                              complete:nil];
    [popoverController release];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    UIColor *textColor = self.userNameLabel.textColor;
    [super setSelected:selected animated:animated];
    self.userNameLabel.textColor = textColor;
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    UIColor *textColor = self.userNameLabel.textColor;
    [super setHighlighted:highlighted animated:animated];
    self.userNameLabel.textColor = textColor;
}

- (void)customWithIdentityString:(NSString *)string candidateProvider:(Provider)candidateProvider matchProvider:(Provider)matchProvider {
    NSString *providerName = nil;
    UIColor *textColor = [UIColor blackColor];
    
    switch (candidateProvider) {
        case kProviderUnknown:
            self.accessButton.hidden = NO;
            break;
        case kProviderPhone:
        {
            NSString *cachedString = string;
            string = [Util formatPhoneNumber:string];
            if (!string.length)
                string = cachedString;
        }
        case kProviderFacebook:
        case kProviderEmail:
        case kProviderTwitter:
            self.accessButton.hidden = YES;
            providerName = [Identity getProviderString:candidateProvider];
            break;
        default:
            self.accessButton.hidden = NO;
            break;
    }
    
    switch (matchProvider) {
        case kProviderPhone:
        case kProviderFacebook:
        case kProviderEmail:
        case kProviderTwitter:
            textColor = [UIColor COLOR_BLUE_EXFE];
            break;
        default:
            break;
    }
    
    UIImage *providerIcon = [UIImage imageNamed:[NSString stringWithFormat:@"identity_%@_18_grey.png", providerName]];
    self.providerIcon = providerIcon;
    
    self.userNameLabel.text = string;
    self.userNameLabel.textColor = textColor;
}

@end
