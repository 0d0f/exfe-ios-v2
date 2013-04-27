//
//  EFChoosePeopleViewCell.m
//  EXFE
//
//  Created by 0day on 13-4-17.
//
//

#import "EFChoosePeopleViewCell.h"

#import <QuartzCore/QuartzCore.h>
#import "Util.h"
#import "ImgCache.h"
#import "LocalContact.h"
#import "Identity+EXFE.h"
#import "RoughIdentity.h"

#pragma mark - BackgroundView
@interface EFChoosePeopleBackgroundView : UIView
@property (nonatomic, assign) EFChoosePeopleViewCell *cell;
@end
@implementation EFChoosePeopleBackgroundView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.userInteractionEnabled = YES;
    }
    
    return self;
}

- (void)drawRect:(CGRect)rect {
    //// General Declarations
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    //// Color Declarations
    UIColor* strokeColor = [UIColor COLOR_RGBA(0xCC, 0xCC, 0xCC, 84)];
    
    //// Gradient Declarations
    NSArray *gradientColors = @[(id)[UIColor COLOR_RGB(0xFC, 0xFC, 0xFC)].CGColor,
                                (id)[UIColor COLOR_RGB(0xFA, 0xFA, 0xFA)].CGColor];
    CGFloat gradientLocations[] = {0, 1};
    CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (CFArrayRef)gradientColors, gradientLocations);
    
    //// Rectangle Drawing
    UIBezierPath* rectanglePath = [UIBezierPath bezierPathWithRect: CGRectMake(-0.5f, -0.5f, CGRectGetWidth(self.frame) + 1.0f, CGRectGetHeight(self.frame) + 0.5f)];
    CGContextSaveGState(context);
    [rectanglePath addClip];
    
    CGContextDrawLinearGradient(context, gradient, CGPointMake(CGRectGetMidX(self.frame), 0), CGPointMake(CGRectGetMidX(self.frame), CGRectGetHeight(self.frame)), 0);
    CGContextRestoreGState(context);
    
    [strokeColor setStroke];
    rectanglePath.lineWidth = 0.5f;
    [rectanglePath stroke];
    
    //// Cleanup
    CGGradientRelease(gradient);
    CGColorSpaceRelease(colorSpace);
    
    if (self.cell.providerIconSet != nil) {
        [self.cell.providerIcon drawInRect:CGRectMake(self.frame.size.width - 18 - 10, (CGRectGetHeight(self.frame) - 18) * 0.5f, 18, 18)];
        int i = 1;
        for (UIImage *icon in self.cell.providerIconSet) {
            [icon drawInRect:CGRectMake(self.frame.size.width - (18 + 2) * i - 10, (CGRectGetHeight(self.frame) - 18) * 0.5f, 18, 18)];
            [[UIImage imageWithData:nil] drawInRect:CGRectMake(self.frame.size.width - (18 + 10) * i, (CGRectGetHeight(self.frame) - 18) * 0.5f, 18, 18)];
            if (++i > 3) {
                break;
            }
        }
    } else if(self.cell.providerIcon != nil) {
        [self.cell.providerIcon drawInRect:CGRectMake(self.frame.size.width - 18 - 10, (CGRectGetHeight(self.frame) - 18) * 0.5f, 18, 18)];
        [[UIImage imageWithData:nil] drawInRect:CGRectMake(self.frame.size.width - (18 + 2) * 3 - 10, (CGRectGetHeight(self.frame) - 18) * 0.5f, 18 * 3, 18)];
    }
}
@end

#pragma mark - BackgroundView
@interface EFChoosePeopleHightedBackgroundView : UIView
@property (nonatomic, assign) EFChoosePeopleViewCell *cell;
@end
@implementation EFChoosePeopleHightedBackgroundView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.userInteractionEnabled = YES;
    }
    
    return self;
}

- (void)drawRect:(CGRect)rect {
    //// General Declarations
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    //// Color Declarations
    UIColor* strokeColor = [UIColor COLOR_RGBA(0xCC, 0xCC, 0xCC, 84)];
    
    //// Gradient Declarations
    NSArray *gradientColors = @[(id)[UIColor COLOR_RGB(0xE6, 0xE6, 0xE6)].CGColor,
                                (id)[UIColor COLOR_RGB(0xE6, 0xE6, 0xE6)].CGColor];
    CGFloat gradientLocations[] = {0, 1};
    CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (CFArrayRef)gradientColors, gradientLocations);
    
    //// Rectangle Drawing
    UIBezierPath* rectanglePath = [UIBezierPath bezierPathWithRect: CGRectMake(-0.5f, -0.5f, CGRectGetWidth(self.frame) + 1.0f, CGRectGetHeight(self.frame) + 0.5f)];
    CGContextSaveGState(context);
    [rectanglePath addClip];
    
    CGContextDrawLinearGradient(context, gradient, CGPointMake(CGRectGetMidX(self.frame), 0), CGPointMake(CGRectGetMidX(self.frame), CGRectGetHeight(self.frame)), 0);
    CGContextRestoreGState(context);
    
    [strokeColor setStroke];
    rectanglePath.lineWidth = 0.5f;
    [rectanglePath stroke];
    
    //// Cleanup
    CGGradientRelease(gradient);
    CGColorSpaceRelease(colorSpace);
    
    if (self.cell.providerIconSet != nil) {
        [self.cell.providerIcon drawInRect:CGRectMake(self.frame.size.width - 18 - 10, (CGRectGetHeight(self.frame) - 18) * 0.5f, 18, 18)];
        int i = 1;
        for (UIImage *icon in self.cell.providerIconSet) {
            [icon drawInRect:CGRectMake(self.frame.size.width - (18 + 2) * i - 10, (CGRectGetHeight(self.frame) - 18) * 0.5f, 18, 18)];
            [[UIImage imageWithData:nil] drawInRect:CGRectMake(self.frame.size.width - (18 + 10) * i, (CGRectGetHeight(self.frame) - 18) * 0.5f, 18, 18)];
            if (++i > 3) {
                break;
            }
        }
    } else if(self.cell.providerIcon != nil) {
        [self.cell.providerIcon drawInRect:CGRectMake(self.frame.size.width - 18 - 10, (CGRectGetHeight(self.frame) - 18) * 0.5f, 18, 18)];
        [[UIImage imageWithData:nil] drawInRect:CGRectMake(self.frame.size.width - (18 + 2) * 3 - 10, (CGRectGetHeight(self.frame) - 18) * 0.5f, 18 * 3, 18)];
    }
}
@end

#pragma mark - SelectedBackgroundView
@interface EFChoosePeopleSelectedBackgroundView : UIView
@end
@implementation EFChoosePeopleSelectedBackgroundView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.userInteractionEnabled = YES;
    }
    
    return self;
}

- (void)drawRect:(CGRect)rect {
    //// General Declarations
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    //// Color Declarations
    UIColor* strokeColor = [UIColor COLOR_RGBA(0xCC, 0xCC, 0xCC, 84)];
    
    //// Gradient Declarations
    NSArray *gradientColors = @[(id)[UIColor COLOR_BLUE_EXFE].CGColor,
                                (id)[UIColor COLOR_BLUE_EXFE].CGColor];
    CGFloat gradientLocations[] = {0, 1};
    CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (CFArrayRef)gradientColors, gradientLocations);
    
    //// Rectangle Drawing
    UIBezierPath* rectanglePath = [UIBezierPath bezierPathWithRect: CGRectMake(-0.5f, -0.5f, CGRectGetWidth(self.frame) + 1.0f, CGRectGetHeight(self.frame) + 0.5f)];
    CGContextSaveGState(context);
    [rectanglePath addClip];
    
    CGContextDrawLinearGradient(context, gradient, CGPointMake(CGRectGetMidX(self.frame), 0), CGPointMake(CGRectGetMidX(self.frame), CGRectGetHeight(self.frame)), 0);
    CGContextRestoreGState(context);
    
    [strokeColor setStroke];
    rectanglePath.lineWidth = 0.5f;
    [rectanglePath stroke];
    
    //// Cleanup
    CGGradientRelease(gradient);
    CGColorSpaceRelease(colorSpace);
    
    [[UIImage imageNamed:@"rsvp_accepted_18w.png"] drawInRect:(CGRect){{CGRectGetWidth(self.frame) - 18 -10, (CGRectGetHeight(self.frame) - 18) * 0.5f}, {18, 18}}];
}
@end

#pragma mark - EFChoosePeopleViewCell
@interface EFChoosePeopleViewCell ()
@end

@implementation EFChoosePeopleViewCell

- (id)init {
    self = [[[[NSBundle mainBundle] loadNibNamed:@"EFChoosePeopleViewCell"
                                           owner:nil
                                         options:nil] lastObject] retain];
    return self;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:(CGRect){{10, 5}, {40, 40}}];
        imageView.layer.cornerRadius = 3.0f;
        imageView.layer.masksToBounds = YES;
        [self.contentView addSubview:imageView];
        self.avatarImageView = imageView;
        [imageView release];
        
        EFLabel *label = [[EFLabel alloc] initWithFrame:(CGRect){{56, 12}, {190, 26}}];
        label.edgeInsets = (UIEdgeInsets){0, 4, 0, 0};
        label.backgroundColor = [UIColor clearColor];
        label.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:21];
        label.textColor = [UIColor blackColor];
        if ([label respondsToSelector:@selector(lineBreakMode)]) {
            label.lineBreakMode = UILineBreakModeClip;
        }
        [self.contentView addSubview:label];
        self.userNameLabel = label;
        [label release];
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.backgroundColor = [UIColor clearColor];
        [button addTarget:self
                   action:@selector(buttonPressed:)
         forControlEvents:UIControlEventTouchUpInside];
        button.frame = (CGRect){{260, 0}, {60, 50}};
        [self.contentView addSubview:button];
        self.accessButton = button;
    }
    
    return self;
}

+ (NSString *)reuseIdentifier {
    return NSStringFromClass([self class]);
}

- (void)dealloc {
    [_accessButton release];
    [_avatarImageView release];
    [_userNameLabel release];
    [_providerIconSet release];
    [_providerIcon release];
    [super dealloc];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    if (selected) {
        EFChoosePeopleSelectedBackgroundView *backgroundView = [[EFChoosePeopleSelectedBackgroundView alloc] initWithFrame:self.bounds];
        self.backgroundView = backgroundView;
        [backgroundView release];
        self.userNameLabel.textColor = [UIColor whiteColor];
    } else {
        EFChoosePeopleBackgroundView *backgroundView = [[EFChoosePeopleBackgroundView alloc] initWithFrame:self.bounds];
        backgroundView.cell = self;
        self.backgroundView = backgroundView;
        [backgroundView release];
        self.userNameLabel.textColor = [UIColor blackColor];
    }
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    BOOL shouldSelect = [self.dataSource shouldChoosePeopleViewCellSelected:self];
    if (!shouldSelect) {
        if (highlighted) {
            EFChoosePeopleHightedBackgroundView *backgroundView = [[EFChoosePeopleHightedBackgroundView alloc] initWithFrame:self.bounds];
            backgroundView.cell = self;
            self.backgroundView = backgroundView;
            [backgroundView release];
            self.userNameLabel.textColor = [UIColor blackColor];
        } else {
            EFChoosePeopleBackgroundView *backgroundView = [[EFChoosePeopleBackgroundView alloc] initWithFrame:self.bounds];
            backgroundView.cell = self;
            self.backgroundView = backgroundView;
            [backgroundView release];
            self.userNameLabel.textColor = [UIColor blackColor];
        }
    }
}

#pragma mark - Action

- (IBAction)buttonPressed:(id)sender {
    if ([self.delegate respondsToSelector:@selector(choosePeopleViewCellButtonPressed:)]) {
        [self.delegate choosePeopleViewCellButtonPressed:self];
    }
}

#pragma mark - custom

- (void)customWithLocalContact:(LocalContact *)person {
    self.userNameLabel.text = person.name;
    self.userNameLabel.frame = (CGRect){{56, 12}, {190, 26}};
    
    UIImage *avatar = [UIImage imageWithData:person.avatar];
    if (!avatar)
        self.avatarImageView.image = [UIImage imageNamed:@"portrait_default.png"];
    else
        self.avatarImageView.image = avatar;
    
    NSMutableArray *iconset = [[NSMutableArray alloc] initWithCapacity:3];
    if (person.social) {
        NSArray *socialArray = [NSKeyedUnarchiver unarchiveObjectWithData:person.social];
        if (socialArray && [socialArray isKindOfClass:[NSArray class]]) {
            for (NSDictionary *socialdict in socialArray) {
                if ([[socialdict objectForKey:@"service"] isEqualToString:@"twitter"]) {
                    [iconset addObject:[UIImage imageNamed:@"identity_twitter_18_grey.png"]];
                }
                if ([[socialdict objectForKey:@"service"] isEqualToString:@"facebook"]) {
                    [iconset addObject:[UIImage imageNamed:@"identity_facebook_18_grey.png"]];
                }
            }
        }
    }
    
    if (person.im) {
        NSArray *imArray = [NSKeyedUnarchiver unarchiveObjectWithData:person.im];
        if (imArray && [imArray isKindOfClass: [NSArray class]]) {
            for (NSDictionary *imdict in imArray) {
                if([[imdict objectForKey:@"service"] isEqualToString:@"Facebook"]){
                    [iconset addObject:[UIImage imageNamed:@"identity_facebook_18_grey.png"]];
                }
            }
        }
    }
    
    if (person.emails) {
        NSArray *emailsArray = [NSKeyedUnarchiver unarchiveObjectWithData:person.emails];
        
        if (emailsArray && [emailsArray isKindOfClass:[NSArray class]]) {
            [iconset addObject:[UIImage imageNamed:@"identity_email_18_grey.png"]];
        }
    }
    
    if (person.phones) {
        NSArray *phonesArray = [NSKeyedUnarchiver unarchiveObjectWithData:person.phones];
        
        if (phonesArray && [phonesArray isKindOfClass:[NSArray class]]) {
            [iconset addObject:[UIImage imageNamed:@"identity_phone_18_grey.png"]];
        }
    }
    
    self.providerIconSet = iconset;
    self.providerIcon = nil;
    
    [iconset release];
}

- (void)customWithIdentity:(Identity *)identity {
    self.userNameLabel.text = identity.name;
    self.userNameLabel.frame = (CGRect){{56, 12}, {190, 26}};
    
    if (!self.userNameLabel.text || [self.userNameLabel.text isEqualToString:@""]) {
        self.userNameLabel.text = identity.external_username;
    }
    
    if (identity.provider && ![identity.provider isEqualToString:@""]) {
        NSString *iconName = [NSString stringWithFormat:@"identity_%@_18_grey.png",identity.provider];
        UIImage *icon = [UIImage imageNamed:iconName];
        self.providerIcon = icon;
        self.providerIconSet = nil;
    }
    if (identity.avatar_filename) {
        UIImage *avatar = [[ImgCache sharedManager] getImgFromCache:identity.avatar_filename];
        if (!avatar || [avatar isEqual:[NSNull null]]) {
            self.avatarImageView.image = [UIImage imageNamed:@"portrait_default.png"];
            
            dispatch_queue_t imgQueue = dispatch_queue_create("fetchimg thread", NULL);
            dispatch_async(imgQueue, ^{
                UIImage *avatar = [[ImgCache sharedManager] getImgFrom:identity.avatar_filename];
                dispatch_async(dispatch_get_main_queue(), ^{
                    if(avatar!=nil && ![avatar isEqual:[NSNull null]]) {
                        self.avatarImageView.image = avatar;
                    }
                });
            });
            dispatch_release(imgQueue);
        } else {
            self.avatarImageView.image = avatar;
        }
    }
}

- (void)customWithRoughtIdentity:(RoughIdentity *)roughtIdentity {
    self.userNameLabel.text = roughtIdentity.externalUsername;
    self.userNameLabel.frame = (CGRect){{56, 12}, {190, 26}};
    
    self.avatarImageView.image = [UIImage imageNamed:@"portrait_default.png"];
    if (roughtIdentity.provider && ![roughtIdentity.provider isEqualToString:@""]) {
        NSString *iconName = [NSString stringWithFormat:@"identity_%@_18_grey.png", roughtIdentity.provider];
        UIImage *icon = [UIImage imageNamed:iconName];
        self.providerIcon = icon;
        self.providerIconSet = nil;
    }
}

@end
