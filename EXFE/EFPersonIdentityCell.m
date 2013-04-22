//
//  EFPersonIdentityCell.m
//  EXFE
//
//  Created by 0day on 13-4-18.
//
//

#import "EFPersonIdentityCell.h"
#import "Identity+EXFE.h"
#import "RoughIdentity.h"
#import "Util.h"

#import <QuartzCore/QuartzCore.h>

#define kLineHeight (44.0f)
#define kButtonWidth    (156.0f)
#define kLineWidth (kButtonWidth * 2)

@interface EFPersonIdentityCellButton : UIButton
@property (nonatomic, assign) RoughIdentity *roughIdentity;
@property (nonatomic, retain) UIImageView *providerImageView;
@property (nonatomic, retain) UILabel *providerExternalNameLabel;
@property (nonatomic, assign) BOOL isSelected;
@property (nonatomic, retain) CAGradientLayer *gradientLayer;
@end

@implementation EFPersonIdentityCellButton

+ (id)buttonWithType:(UIButtonType)buttonType {
    EFPersonIdentityCellButton *button = [super buttonWithType:buttonType];
    button.backgroundColor = [UIColor clearColor];
    button.isSelected = NO;
    
    button.layer.borderWidth = 0.5f;
    button.layer.borderColor = [UIColor COLOR_RGBA(0, 0, 0, 84)].CGColor;
    
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.colors = @[(id)[UIColor COLOR_RGBA(0xFF, 0xFF, 0xFF, 40)].CGColor,
                             (id)[UIColor COLOR_RGBA(0xFF, 0xFF, 0xFF, 10)].CGColor];
    gradientLayer.frame = (CGRect){{0, 0}, {kButtonWidth, kLineHeight}};
    gradientLayer.hidden = YES;
    [button.layer addSublayer:gradientLayer];
    button.gradientLayer = gradientLayer;
    
    UILabel *label = [[UILabel alloc] initWithFrame:(CGRect){{30, 0}, {kButtonWidth - 30, kLineHeight}}];
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor whiteColor];
    label.shadowColor = [UIColor blackColor];
    label.shadowOffset = (CGSize){0, 1};
    label.font = [UIFont fontWithName:@"HelveticaNeue-Italic" size:14];
    [button addSubview:label];
    button.providerExternalNameLabel = label;
    [label release];
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:(CGRect){{6, 13}, {18, 18}}];
    [button addSubview:imageView];
    button.providerImageView = imageView;
    [imageView release];
    
    return button;
}

- (void)dealloc {
    [_gradientLayer release];
    [_roughIdentity release];
    [_providerImageView release];
    [_providerExternalNameLabel release];
    [super dealloc];
}

- (void)setIsSelected:(BOOL)isSelected {
    if (isSelected == _isSelected)
        return;
    
    _isSelected = isSelected;
    if (isSelected) {
        self.gradientLayer.hidden = NO;
    } else {
        self.gradientLayer.hidden = YES;
    }
}

- (void)setRoughIdentity:(RoughIdentity *)roughIdentity {
    if (_roughIdentity == roughIdentity)
        return;
    
    if (roughIdentity) {
        Provider provider = [Identity getProviderCode:roughIdentity.provider];
        NSString *displayIdentity = nil;
        
        switch (provider) {
            case kProviderEmail:
            case kProviderPhone:
                displayIdentity = roughIdentity.externalID;
                break;
            case kProviderTwitter:
                displayIdentity = [NSString stringWithFormat:@"@%@", roughIdentity.externalUsername];
                break;
            default:
                displayIdentity = [NSString stringWithFormat:@"%@@%@", roughIdentity.externalUsername, roughIdentity.provider];
                break;
        }
        
        UIImage *providerImage = nil;
        switch (provider) {
            case kProviderEmail:{
                providerImage = [UIImage imageNamed:@"identity_email_18_grey.png"];
            }   break;
            case kProviderPhone:
                providerImage = [UIImage imageNamed:@"identity_phone_18_grey.png"];
                break;
            case kProviderFacebook:
                providerImage = [UIImage imageNamed:@"identity_facebook_18_grey.png"];
                break;
            case kProviderTwitter:
                providerImage = [UIImage imageNamed:@"identity_twitter_18_grey.png"];
                break;
                
            default:
                // no identity info, fall back to default
                providerImage = [UIImage imageNamed:@"identity_email_18_grey.png"];
                break;
        }
        
        self.providerImageView.image = providerImage;
        self.providerExternalNameLabel.text = displayIdentity;
    }
}

@end

@interface EFPersonIdentityCell ()
- (void)layoutButtons;
@end
@implementation EFPersonIdentityCell {
    UIView *_baseView;
    NSMutableArray *_buttons;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.contentView.backgroundColor = [UIColor blackColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        _baseView = [[UIView alloc] initWithFrame:(CGRect){{4, 0}, {kLineWidth, CGRectGetHeight(self.frame)}}];
        _baseView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleBottomMargin;
        _baseView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"conv_bg.png"]];
        [self.contentView addSubview:_baseView];
        
        UIImageView *shadowImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"shadow_4.png"]];
        shadowImageView.frame = (CGRect){{0, 0}, {320, 4}};
        [self.contentView addSubview:shadowImageView];
        [shadowImageView release];
    }
    
    return self;
}

- (void)dealloc {
    [_baseView release];
    [_buttons release];
    [_roughIdentities release];
    [super dealloc];
}

- (void)buttonPressed:(id)sender {
    EFPersonIdentityCellButton *button = (EFPersonIdentityCellButton *)sender;
    button.isSelected = !button.isSelected;
    NSUInteger index = [_buttons indexOfObject:button];
    RoughIdentity *roughIdentity = _roughIdentities[index];
    
    if (button.isSelected) {
        [self.delegate personIdentityCell:self didSelectRoughIdentity:roughIdentity];
    } else {
        [self.delegate personIdentityCell:self didDeselectRoughIdentity:roughIdentity];
    }
}

+ (CGFloat)heightWithRoughIdentities:(NSArray *)identities {
    NSUInteger count = [identities count];
    NSUInteger numberOfLines = (count / 2) +  (count % 2);
    return numberOfLines * kLineHeight;
}

- (void)setRoughIdentities:(NSArray *)roughIdentities {
    if (_roughIdentities == roughIdentities)
        return;
    if (_roughIdentities) {
        [_roughIdentities release];
        _roughIdentities = nil;
    }
    if (roughIdentities) {
        _roughIdentities = [roughIdentities retain];
        [self layoutButtons];
    }
}

- (void)layoutButtons {
    if (_buttons) {
        for (EFPersonIdentityCellButton *button in _buttons) {
            [button removeFromSuperview];
        }
        [_buttons removeAllObjects];
    } else {
        _buttons = [[NSMutableArray alloc] initWithCapacity:8];
    }
    
    for (int i = 0; i < [_roughIdentities count]; i++) {
        EFPersonIdentityCellButton *button = [EFPersonIdentityCellButton buttonWithType:UIButtonTypeCustom];
        button.frame = (CGRect){{(i % 2) * kButtonWidth, (i / 2) * kLineHeight}, {kButtonWidth, kLineHeight}};
        [button addTarget:self
                   action:@selector(buttonPressed:)
         forControlEvents:UIControlEventTouchUpInside];
        
        RoughIdentity *roughIdentity = _roughIdentities[i];
        BOOL shouldSelected = [self.dataSource shouldPersonIdentityCell:self
                                                    selectRoughIdentity:roughIdentity];
        button.roughIdentity = roughIdentity;
        button.isSelected = shouldSelected;
        
        [_buttons addObject:button];
        [_baseView addSubview:button];
    }
}

@end