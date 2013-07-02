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
#import "LocalContact.h"
#import "Identity+EXFE.h"
#import "RoughIdentity.h"
#import "EFContactObject.h"
#import "EFKit.h"

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
    
    // avatar
    UIImage *avatarImage = nil;
    EFContactObject *contactObject = self.cell.contactObject;
    
    if (contactObject.imageKey) {
        if ([[EFDataManager imageManager] isImageCachedInMemoryForKey:contactObject.imageKey]) {
            avatarImage = [[EFDataManager imageManager] cachedImageInMemoryForKey:contactObject.imageKey];
        } else {
            avatarImage = [UIImage imageNamed:@"portrait_default.png"];
            [[EFDataManager imageManager] cachedImageForKey:contactObject.imageKey
                                            completeHandler:^(UIImage *image){
                                                if (self.cell && image && contactObject == self.cell.contactObject) {
                                                    [self setNeedsDisplay];
                                                }
                                            }];
        }
    } else {
        avatarImage = [UIImage imageNamed:@"portrait_default.png"];
    }
    
    CGRect avatarRect = (CGRect){{10, 5}, {40, 40}};
    CGFloat cornerRadius = 3.0f;
    
    CGContextSaveGState(context);
    CGPathRef clipPath = [UIBezierPath bezierPathWithRoundedRect:avatarRect cornerRadius:cornerRadius].CGPath;
    CGContextAddPath(context, clipPath);
    CGContextClip(context);
    [avatarImage drawInRect:avatarRect];
    CGContextRestoreGState(context);
    
    // provider image
    if (self.cell.providerIconList != nil) {
        [self.cell.providerIcon drawInRect:CGRectMake(self.frame.size.width - 18 - 10, (CGRectGetHeight(self.frame) - 18) * 0.5f, 18, 18)];
        int i = 1;
        for (UIImage *icon in self.cell.providerIconList) {
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
    
    // avatar image
    UIImage *avatarImage = nil;
    EFContactObject *contactObject = self.cell.contactObject;
    
    if (contactObject.imageKey) {
        if ([[EFDataManager imageManager] isImageCachedInMemoryForKey:contactObject.imageKey]) {
            avatarImage = [[EFDataManager imageManager] cachedImageInMemoryForKey:contactObject.imageKey];
        } else {
            avatarImage = [UIImage imageNamed:@"portrait_default.png"];
            [[EFDataManager imageManager] cachedImageForKey:contactObject.imageKey
                                            completeHandler:^(UIImage *image){
                                                if (self.cell && image && contactObject == self.cell.contactObject) {
                                                    [self setNeedsDisplay];
                                                }
                                            }];
        }
    } else {
        avatarImage = [UIImage imageNamed:@"portrait_default.png"];
    }
    
    CGRect avatarRect = (CGRect){{10, 5}, {40, 40}};
    CGFloat cornerRadius = 3.0f;
    
    CGContextSaveGState(context);
    CGPathRef clipPath = [UIBezierPath bezierPathWithRoundedRect:avatarRect cornerRadius:cornerRadius].CGPath;
    CGContextAddPath(context, clipPath);
    CGContextClip(context);
    [avatarImage drawInRect:avatarRect];
    CGContextRestoreGState(context);
    
    // provider image
    if (self.cell.providerIconList != nil) {
        [self.cell.providerIcon drawInRect:CGRectMake(self.frame.size.width - 18 - 10, (CGRectGetHeight(self.frame) - 18) * 0.5f, 18, 18)];
        int i = 1;
        for (UIImage *icon in self.cell.providerIconList) {
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
@property (nonatomic, assign) EFChoosePeopleViewCell *cell;
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
    
    // avatar image
    UIImage *avatarImage = nil;
    EFContactObject *contactObject = self.cell.contactObject;
    
    if (contactObject.imageKey) {
        if ([[EFDataManager imageManager] isImageCachedInMemoryForKey:contactObject.imageKey]) {
            avatarImage = [[EFDataManager imageManager] cachedImageInMemoryForKey:contactObject.imageKey];
        } else {
            avatarImage = [UIImage imageNamed:@"portrait_default.png"];
            [[EFDataManager imageManager] cachedImageForKey:contactObject.imageKey
                                            completeHandler:^(UIImage *image){
                                                if (self.cell && image && contactObject == self.cell.contactObject) {
                                                    [self setNeedsDisplay];
                                                }
                                            }];
        }
    } else {
        avatarImage = [UIImage imageNamed:@"portrait_default.png"];
    }
    
    CGRect avatarRect = (CGRect){{10, 5}, {40, 40}};
    CGFloat cornerRadius = 3.0f;
    
    CGContextSaveGState(context);
    CGPathRef clipPath = [UIBezierPath bezierPathWithRoundedRect:avatarRect cornerRadius:cornerRadius].CGPath;
    CGContextAddPath(context, clipPath);
    CGContextClip(context);
    [avatarImage drawInRect:avatarRect];
    CGContextRestoreGState(context);
    
    // accept image
    [[UIImage imageNamed:@"rsvp_accepted_18w.png"] drawInRect:(CGRect){{CGRectGetWidth(self.frame) - 18 -10, (CGRectGetHeight(self.frame) - 18) * 0.5f}, {18, 18}}];
}
@end

#pragma mark - EFChoosePeopleViewCell
@interface EFChoosePeopleViewCell ()
@end

@implementation EFChoosePeopleViewCell

+ (NSString *)reuseIdentifier {
    return NSStringFromClass([self class]);
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        CGRect bounds = (CGRect){{0.0f, 0.0f}, 320.0f, 50.0f};
        
        self.contentView.backgroundColor = [UIColor clearColor];
        
        // avatar image view
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:(CGRect){{10, 5}, {40, 40}}];
        imageView.layer.cornerRadius = 3.0f;
        imageView.layer.masksToBounds = YES;
        imageView.layer.shouldRasterize = YES;
        imageView.layer.rasterizationScale = [UIScreen mainScreen].scale;
        [self.contentView addSubview:imageView];
        self.avatarImageView = imageView;
        [imageView release];
        
        // username label
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
        
        // button
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.backgroundColor = [UIColor clearColor];
        [button addTarget:self
                   action:@selector(buttonPressed:)
         forControlEvents:UIControlEventTouchUpInside];
        button.frame = (CGRect){{260, 0}, {60, 50}};
        [self.contentView addSubview:button];
        self.accessButton = button;
        
        EFChoosePeopleBackgroundView *backgroundView = [[EFChoosePeopleBackgroundView alloc] initWithFrame:bounds];
        backgroundView.cell = self;
        self.backgroundView = backgroundView;
        [backgroundView release];
        
        EFChoosePeopleSelectedBackgroundView *selectedBackgroundView = [[EFChoosePeopleSelectedBackgroundView alloc] initWithFrame:bounds];
        selectedBackgroundView.cell = self;
        self.multipleSelectionBackgroundView = selectedBackgroundView;
        [selectedBackgroundView release];
    }
    
    return self;
}

- (void)dealloc {
    ((EFChoosePeopleBackgroundView *)self.backgroundView).cell = nil;
    ((EFChoosePeopleHightedBackgroundView *)self.backgroundView).cell = nil;
    ((EFChoosePeopleSelectedBackgroundView *)self.backgroundView).cell = nil;
    [_accessButton release];
    [_avatarImageView release];
    [_userNameLabel release];
    [_providerIconList release];
    [_providerIcon release];
    [super dealloc];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    if (selected) {
        self.userNameLabel.textColor = [UIColor whiteColor];
    } else {
        self.userNameLabel.textColor = [UIColor blackColor];
    }
    
    [super setSelected:selected animated:animated];
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    BOOL shouldSelect = [self.dataSource shouldChoosePeopleViewCellSelected:self];
    
    if (!shouldSelect) {
        if (highlighted) {
            EFChoosePeopleHightedBackgroundView *backgroundView = [[EFChoosePeopleHightedBackgroundView alloc] initWithFrame:self.bounds];
            backgroundView.cell = self;
            self.backgroundView = backgroundView;
            [backgroundView release];
        } else {
            EFChoosePeopleBackgroundView *backgroundView = [[EFChoosePeopleBackgroundView alloc] initWithFrame:self.bounds];
            backgroundView.cell = self;
            self.backgroundView = backgroundView;
            [backgroundView release];
        }
        
        self.userNameLabel.textColor = [UIColor blackColor];
    }
}

#pragma mark - Action

- (IBAction)buttonPressed:(id)sender {
    if ([self.delegate respondsToSelector:@selector(choosePeopleViewCellButtonPressed:)]) {
        [self.delegate choosePeopleViewCellButtonPressed:self];
    }
}

#pragma mark - Getter && Setter

- (void)setContactObject:(EFContactObject *)contactObject {
    if (contactObject == _contactObject)
        return;
    
    if (_contactObject) {
        [_contactObject release];
        _contactObject = nil;
    }
    if (contactObject) {
        _contactObject = [contactObject retain];
        
        self.userNameLabel.text = contactObject.name;
        self.userNameLabel.frame = (CGRect){{56, 12}, {190, 26}};
//        if (contactObject.imageKey) {
//            if ([[EFDataManager imageManager] isImageCachedInMemoryForKey:contactObject.imageKey]) {
//                self.avatarImageView.image = [[EFDataManager imageManager] cachedImageInMemoryForKey:contactObject.imageKey];
//            } else {
//                self.avatarImageView.image = [UIImage imageNamed:@"portrait_default.png"];
//                [[EFDataManager imageManager] cachedImageForKey:contactObject.imageKey
//                                                completeHandler:^(UIImage *image){
//                                                    if (image && contactObject == self.contactObject) {
//                                                        self.avatarImageView.image = image;
//                                                    } else {
//                                                        self.avatarImageView.image = [UIImage imageNamed:@"portrait_default.png"];
//                                                    }
//                                                }];
//            }
//        } else {
//            self.avatarImageView.image = [UIImage imageNamed:@"portrait_default.png"];
//        }
        
        if (1 == contactObject.roughIdentities.count) {
            NSString *iconName = [NSString stringWithFormat:@"identity_%@_18_grey.png", ((RoughIdentity *)contactObject.roughIdentities[0]).provider];
            UIImage *icon = [UIImage imageNamed:iconName];
            
            self.providerIcon = icon;
            self.providerIconList = nil;
        } else {
            NSMutableArray *iconList = [[NSMutableArray alloc] initWithCapacity:contactObject.roughIdentities.count];
            NSMutableDictionary *addDict = [[NSMutableDictionary alloc] initWithCapacity:contactObject.roughIdentities.count];
            
            for (RoughIdentity *roughtIdentity in contactObject.roughIdentities) {
                NSString *imageName = nil;
                switch ([Identity getProviderCode:roughtIdentity.provider]) {
                    case kProviderTwitter:
                        imageName = @"identity_twitter_18_grey.png";
                        break;
                    case kProviderFacebook:
                        imageName = @"identity_facebook_18_grey.png";
                        break;
                    case kProviderEmail:
                        imageName = @"identity_email_18_grey.png";
                        break;
                    case kProviderPhone:
                        imageName = @"identity_phone_18_grey.png";
                        break;
                    default:
                        break;
                }
                
                if (imageName) {
                    if ([addDict valueForKey:imageName]) {
                        continue;
                    }
                    [iconList insertObject:[UIImage imageNamed:imageName] atIndex:0];
                    [addDict setValue:@"YES" forKey:imageName];
                }
            }
            
            self.providerIcon = nil;
            self.providerIconList = iconList;
            [iconList release];
            [addDict release];
        }
    }
}

@end
