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
#import "EFContactObject.h"
#import "EFKit.h"

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
        
        self.multipleSelectionBackgroundView = self.backgroundView;
    }
    
    return self;
}


+ (NSString *)reuseIdentifier {
    return NSStringFromClass([self class]);
}

- (void)tipButtonPressed:(id)sender {
    if (!_popoverController) {
        EFSearchTipViewController *tipViewController = [[EFSearchTipViewController alloc] initWithNibName:@"EFSearchTipViewController" bundle:nil];
        _popoverController = [[EFPopoverController alloc] initWithContentViewController:tipViewController];
        [_popoverController setContentSize:tipViewController.view.frame.size animated:YES];
        
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

- (void)customWithIdentityString:(NSString *)string candidateProvider:(Provider)candidateProvider identity:(Identity *)identity {
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
    
    if (identity) {
        self.accessButton.hidden = YES;
        textColor = [UIColor COLOR_BLUE_EXFE];
    }
    
    self.userNameLabel.text = string;
    UIImage *defaultImage = [UIImage imageNamed:@"portrait_default.png"];
    self.avatarImageView.image = defaultImage;
    
    if (providerName.length != 0) {
        UIImage *providerIcon = [UIImage imageNamed:[NSString stringWithFormat:@"identity_%@_18_grey.png", providerName]];
        self.providerIcon = providerIcon;
        if (identity) {
            if (identity.name.length) {
                self.userNameLabel.text = identity.name;
            }
            NSString *imageKey = identity.avatar_filename;
            
            if (!imageKey) {
                self.avatarImageView.image = defaultImage;
            } else {
                if ([[EFDataManager imageManager] isImageCachedInMemoryForKey:imageKey]) {
                    self.avatarImageView.image = [[EFDataManager imageManager] cachedImageInMemoryForKey:imageKey];
                } else {
                    [[EFDataManager imageManager] cachedImageForKey:imageKey
                                                    completeHandler:^(UIImage *image){
                                                        if (image) {
                                                            self.avatarImageView.image = image;
                                                        }
                                                    }];
                }
            }
        } else {
            self.avatarImageView.image = [UIImage imageNamed:@"portrait_default.png"];
        }
    }
    
    self.userNameLabel.textColor = textColor;
}

@end
