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

- (void)customWithIdentity:(Identity *)identity {
    [super customWithIdentity:identity];
    self.accessButton.hidden = YES;
    self.userNameLabel.textColor = [UIColor COLOR_BLUE_EXFE];
}

- (void)customWithIdentityString:(NSString *)string candidateProvider:(Provider)candidateProvider matchProvider:(Provider)matchProvider {
    NSString *providerName = nil;
    UIColor *textColor = [UIColor blackColor];
    BOOL isIdentityFound = NO;
    
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
        {
            NSDictionary *matchedDictionary = [Util parseIdentityString:string byProvider:matchProvider];
            RoughIdentity *roughtIdentity = [RoughIdentity identityWithDictionary:matchedDictionary];
            
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"provider LIKE %@ AND external_id LIKE %@", roughtIdentity.provider, roughtIdentity.externalID];
            NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Identity"];
            fetchRequest.predicate = predicate;
            NSArray *identities =  [[RKObjectManager sharedManager].managedObjectStore.persistentStoreManagedObjectContext executeFetchRequest:fetchRequest error:nil];
            
            if (identities && [identities count]) {
                [self customWithIdentity:identities[0]];
                isIdentityFound = YES;
                self.accessButton.hidden = YES;
            }
            
            textColor = [UIColor COLOR_BLUE_EXFE];
        }
            break;
        default:
            break;
    }
    
    if (!isIdentityFound) {
        UIImage *providerIcon = [UIImage imageNamed:[NSString stringWithFormat:@"identity_%@_18_grey.png", providerName]];
        self.providerIcon = providerIcon;
        self.avatarImageView.image = [UIImage imageNamed:@"portrait_default.png"];
        
        self.userNameLabel.text = string;
    }
    
    self.userNameLabel.textColor = textColor;
}

@end
