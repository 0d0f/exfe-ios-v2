//
//  GatherExfeeInputCell.m
//  EXFE
//
//  Created by huoju on 8/9/12.
//
//

#import "GatherExfeeInputCell.h"

#import <QuartzCore/QuartzCore.h>
#import "LocalContact.h"
#import "Identity.h"
#import "Util.h"
#import "EFKit.h"

@implementation GatherExfeeInputCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
//        contentView.backgroundColor = [UIColor clearColor];
//        
//        CAGradientLayer *gradientLayer = [CAGradientLayer layer];
//        gradientLayer.colors = @[(id)[UIColor COLOR_RGB(0xFC, 0xFC, 0xFC)].CGColor, (id)[UIColor COLOR_RGB(0xFA, 0xFA, 0xFA)].CGColor];
//        gradientLayer.frame = (CGRect){{0, 0}, {320, 50}};
//        [self.layer addSublayer:gradientLayer];
//        
//        CALayer *topLine = [CALayer layer];
//        topLine.backgroundColor = [UIColor COLOR_RGBA(0, 0, 0, 30)].CGColor;
//        topLine.frame = (CGRect){{0, 0}, {320.0f, 0.5f}};
//        [self.layer addSublayer:topLine];
//        
//        CALayer *bottomLine = [CALayer layer];
//        bottomLine.backgroundColor = [UIColor COLOR_RGBA(0, 0, 0, 30)].CGColor;
//        bottomLine.frame = (CGRect){{0, 49.5f}, {320.0f, 0.5f}};
//        [cell.contentView.layer addSublayer:bottomLine];
    }
    
    return self;
}

#pragma mark - Getter && Setter
- (void)setTitle:(NSString *)s {
    [_title release];
	_title = [s copy];
	[self setNeedsDisplay]; 
}

- (void)setAvatar:(UIImage *)a {
	[_avatar release];
	_avatar = [a copy];
	[self setNeedsDisplay]; 
}

- (void)setProviderIcon:(UIImage *)a {
	[_providerIcon release];
	_providerIcon = [a copy];
	[self setNeedsDisplay]; 
}

- (void)setProviderIconSet:(NSArray *)s{
    if (_providerIconSet != nil) {
        [_providerIconSet release];
    }
    
    _providerIconSet = [s copy];
    [self setNeedsDisplay];
}

#pragma mark - custom
- (void)customWithLocalContact:(LocalContact *)person {
    self.title = person.name;
    
    UIImage *avatar = [UIImage imageWithData:person.avatar];
    if (!avatar)
        self.avatar = [UIImage imageNamed:@"portrait_default.png"];
    else
        self.avatar = avatar;
    
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
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    if ([iconset count] > 1) {
        CGRect frame = CGRectMake(0.0, 0.0, (18 + 10) * ([iconset count] + 1), 110);
        button.frame = frame;
//        [button addTarget:self action:@selector(checkButtonTapped:event:) forControlEvents:UIControlEventTouchUpInside];
        self.accessoryView = button;
    }
    [iconset release];
}

- (void)customWithIdentity:(Identity *)identity {
    self.title = identity.name;
    if (!self.title || [self.title isEqualToString:@""])
        self.title = identity.external_username;
    
    if (identity.provider && ![identity.provider isEqualToString:@""]) {
        NSString *iconName = [NSString stringWithFormat:@"identity_%@_18_grey.png",identity.provider];
        UIImage *icon = [UIImage imageNamed:iconName];
        self.providerIcon = icon;
        self.providerIconSet = nil;
    }
    NSString *imageKey = identity.avatar_filename;
    UIImage *defaultImage = [UIImage imageNamed:@"portrait_default.png"];
    
    if (!imageKey) {
        self.avatar = defaultImage;
    } else {
        if ([[EFDataManager imageManager] isImageCachedInMemoryForKey:imageKey]) {
            self.avatar = [[EFDataManager imageManager] cachedImageInMemoryForKey:imageKey];
        } else {
            self.avatar = defaultImage;
            [[EFDataManager imageManager] cachedImageForKey:imageKey
                                            completeHandler:^(UIImage *image){
                                                if (image) {
                                                    self.avatar = image;
                                                }
                                            }];
        }
    }
}

#pragma mark -

- (void)layoutSubviews {
	CGRect b = [self bounds];
	[contentView setFrame:b];
    [super layoutSubviews];
}

- (void)drawContentView:(CGRect)r {
    //// General Declarations
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    //// Color Declarations
    UIColor* strokeColor = [UIColor COLOR_RGBA(0, 0, 0, 30)];
    
    //// Gradient Declarations
    NSArray* gradientColors = [NSArray arrayWithObjects:
                               (id)[UIColor COLOR_RGB(0xFC, 0xFC, 0xFC)].CGColor,
                               (id)[UIColor COLOR_RGB(0xFA, 0xFA, 0xFA)].CGColor, nil];
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
    
    [_title drawInRect:CGRectMake(60, 11, 190, 20) withFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:20] lineBreakMode:UILineBreakModeClip alignment:UITextAlignmentLeft];
    [_avatar drawInRect:CGRectMake(10, 5, 40, 40)];
    
    if (_providerIconSet != nil) {
        [_providerIcon drawInRect:CGRectMake(self.frame.size.width - 18 - 10, 13, 18, 18)];
        int i=1;
        for(UIImage *icon in _providerIconSet){
            [icon drawInRect:CGRectMake(self.frame.size.width - (18 + 10) * i, 13, 18, 18)];
            i++;
        }
    } else if(_providerIcon != nil) {
        [_providerIcon drawInRect:CGRectMake(self.frame.size.width - 18 - 10, 13, 18, 18)];
        [[UIImage imageWithData:nil] drawInRect:CGRectMake(self.frame.size.width - (18 + 10) * 3, 13, 18 * 3, 18)];
    }
}

@end
