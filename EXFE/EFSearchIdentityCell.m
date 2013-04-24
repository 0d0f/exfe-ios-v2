//
//  EFSearchIdentityCell.m
//  EXFE
//
//  Created by 0day on 13-4-24.
//
//

#import "EFSearchIdentityCell.h"

@implementation EFSearchIdentityCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self.accessButton setImage:[UIImage imageNamed:@"pass_question.png"] forState:UIControlStateNormal];
    self.avatarImageView.image = [UIImage imageNamed:@"portrait_default.png"];
}

+ (NSString *)reuseIdentifier {
    return NSStringFromClass([self class]);
}

- (void)customWithIdentityString:(NSString *)string candidateProvider:(Provider)candidateProvider matchProvider:(Provider)matchProvider {
    NSString *providerName = nil;
    switch (candidateProvider) {
        case kProviderUnknown:
            self.accessButton.hidden = NO;
            break;
        case kProviderPhone:
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
    
    UIImage *providerIcon = [UIImage imageNamed:[NSString stringWithFormat:@"identity_%@_18_grey.png", providerName]];
    self.providerIcon = providerIcon;
    
    self.userNameLabel.text = string;
}

@end
