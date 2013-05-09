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
#import "RoughIdentity.h"
#import "ImgCache.h"

@implementation EFSearchIdentityCell {
    EFPopoverController *_popoverController;
}

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

- (void)dealloc {
    [_popoverController release];
    [super dealloc];
}

+ (NSString *)reuseIdentifier {
    return NSStringFromClass([self class]);
}

- (void)tipButtonPressed:(id)sender {
    if (!_popoverController) {
        EFSearchTipViewController *tipViewController = [[EFSearchTipViewController alloc] initWithNibName:@"EFSearchTipViewController" bundle:nil];
        _popoverController = [[EFPopoverController alloc] initWithContentViewController:tipViewController];
        [_popoverController setContentSize:tipViewController.view.frame.size animated:YES];
        [tipViewController release];
        
        _popoverController.backgroundArrowView.gradientColors = @[(id)[UIColor COLOR_RGBA(0x33, 0x33, 0x33, 245)].CGColor, (id)[UIColor COLOR_RGBA(0x22, 0x22, 0x22, 245)].CGColor];
        _popoverController.backgroundArrowView.strokeWidth = 0.0f;
        _popoverController.backgroundArrowView.strokeColor = [UIColor clearColor];
    }
    
    CGRect screenBounds = [UIScreen mainScreen].bounds;
    [_popoverController presentFromRect:(CGRect){{287, 0}, {33, 50}}
                                inView:self
                            containRect:(CGRect){{0, 70}, {CGRectGetWidth(screenBounds), CGRectGetHeight(screenBounds) - 70}}
                        arrowDirection:kEFArrowDirectionRight
                              animated:YES
                              complete:nil];
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

//- (void)customWithIdentity:(Identity *)identity {
//    [super customWithIdentity:identity];
//    self.accessButton.hidden = YES;
//    self.userNameLabel.textColor = [UIColor COLOR_BLUE_EXFE];
//}

- (void)customWithIdentityString:(NSString *)string candidateProvider:(Provider)candidateProvider matchProvider:(Provider)matchProvider identity:(Identity *)identity {
    NSString *providerName = nil;
    UIColor *textColor = [UIColor blackColor];
    
    switch (candidateProvider) {
        case kProviderUnknown:
            self.accessButton.hidden = NO;
            break;
        case kProviderPhone:
        {
            if (string && string.length && [string characterAtIndex:0] != '+') {
                NSString *countryCode = [Util getTelephoneCountryCode];
                string = [NSString stringWithFormat:@"+%@ %@", countryCode, string];
            }
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
        {
            if ([Identity getProviderCode:identity.provider] != kProviderPhone || [identity.identity_id intValue] != 0) {
                [self customWithIdentity:identity];
            }
            
            self.accessButton.hidden = YES;
            textColor = [UIColor COLOR_BLUE_EXFE];
        }
            break;
        default:
            break;
    }
    
    if (!identity || ([Identity getProviderCode:identity.provider] == kProviderPhone && [identity.identity_id intValue] == 0)) {
        UIImage *providerIcon = [UIImage imageNamed:[NSString stringWithFormat:@"identity_%@_18_grey.png", providerName]];
        self.providerIcon = providerIcon;
        if (identity) {
            if (identity.avatar_filename) {
                UIImage *avatar = [[ImgCache sharedManager] getImgFromCache:identity.avatar_filename];
                if (!avatar || [avatar isEqual:[NSNull null]]) {
                    self.avatarImageView.image = [UIImage imageNamed:@"portrait_default.png"];
                    
                    dispatch_queue_t imgQueue = dispatch_queue_create("fetchimg thread", NULL);
                    dispatch_async(imgQueue, ^{
                        UIImage *avatar = [[ImgCache sharedManager] getImgFrom:identity.avatar_filename];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            if (avatar != nil && ![avatar isEqual:[NSNull null]]) {
                                self.avatarImageView.image = avatar;
                            }
                        });
                    });
                    dispatch_release(imgQueue);
                } else {
                    self.avatarImageView.image = avatar;
                }
            }
        } else {
            self.avatarImageView.image = [UIImage imageNamed:@"portrait_default.png"];
        }
        
        self.userNameLabel.text = string;
    }
    
    self.userNameLabel.textColor = textColor;
}

@end
