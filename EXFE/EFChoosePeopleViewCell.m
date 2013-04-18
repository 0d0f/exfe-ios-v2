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

@interface EFChoosePeopleViewCell ()
@property (nonatomic, retain) NSArray *backgroundColors;
@end

@implementation EFChoosePeopleViewCell

- (id)init {
    self = [[[[NSBundle mainBundle] loadNibNamed:@"EFChoosePeopleViewCell"
                                           owner:nil
                                         options:nil] lastObject] retain];
    return self;
}

- (void)awakeFromNib {
    self.avatarImageView.layer.cornerRadius = 3.0f;
    self.avatarImageView.layer.masksToBounds = YES;
}

- (void)dealloc {
    [_avatarImageView release];
    [_userNameLabel release];
    [_providerIconSet release];
    [_providerIcon release];
    [super dealloc];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    if (selected) {
        self.backgroundColors = @[(id)[UIColor COLOR_RGB(0x3A, 0x6E, 0xA5)].CGColor,
                                  (id)[UIColor COLOR_RGB(0x3B, 0x6E, 0xA5)].CGColor];
    } else {
        self.backgroundColors = @[(id)[UIColor COLOR_RGB(0xFC, 0xFC, 0xFC)].CGColor,
                                  (id)[UIColor COLOR_RGB(0xFA, 0xFA, 0xFA)].CGColor];
    }
    [self setNeedsDisplay];
}

#pragma mark - custom
- (void)customWithLocalContact:(LocalContact *)person {
    self.userNameLabel.text = person.name;
    
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
    self.userNameLabel.text = identity.name;
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

#pragma mark - DrawRect

- (void)drawRect:(CGRect)rect {
    //// General Declarations
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    //// Color Declarations
    UIColor* strokeColor = [UIColor COLOR_RGBA(0, 0, 0, 30)];
    
    //// Gradient Declarations
    NSArray *gradientColors = self.backgroundColors;
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
