//
//  EFSearchIdentityCell.m
//  EXFE
//
//  Created by 0day on 13-4-24.
//
//

#import "EFSearchIdentityCell.h"

@implementation EFSearchIdentityCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self.accessButton setImage:[UIImage imageNamed:@"pass_question.png"] forState:UIControlStateNormal];
        self.accessButton.imageEdgeInsets = (UIEdgeInsets){0, 0, 0, -21};
        self.avatarImageView.image = [UIImage imageNamed:@"portrait_default.png"];
        self.userNameLabel.font = [UIFont fontWithName:@"HelveticaNeue-LightItalic" size:21];
    }
    
    return self;
}

+ (NSString *)reuseIdentifier {
    return NSStringFromClass([self class]);
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
