//
//  EFStatusBar.m
//  EXFE
//
//  Created by 0day on 13-5-13.
//
//

#import "EFStatusBar.h"

#import "Util.h"
#import "AppDelegate.h"

#define kRight

@interface EFStatusBar ()
@property (nonatomic, strong) UIWindow *window;
@property (nonatomic, strong) UILabel *messageLabel;
@end

@implementation EFStatusBar

+ (EFStatusBar *)defaultStatusBar {
    static EFStatusBar *StatusBar;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        CGRect statusBarFrame = [UIApplication sharedApplication].statusBarFrame;
        StatusBar = [[self alloc] initWithFrame:(CGRect){{0, 0}, statusBarFrame.size}];
    });
    
    return StatusBar;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
        label.backgroundColor = [UIColor blackColor];
        label.textColor = [UIColor whiteColor];
        label.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:14];
        label.textAlignment = NSTextAlignmentRight;
        [self addSubview:label];
        self.messageLabel = label;
        
        CGRect statusBarFrame = [UIApplication sharedApplication].statusBarFrame;
        UIWindow *window = [[UIWindow alloc] initWithFrame:(CGRect){{0, 0}, statusBarFrame.size}];
        window.backgroundColor = [UIColor clearColor];
        window.windowLevel = UIWindowLevelStatusBar;
        self.window = window;
        
        [window addSubview:self];
        [window makeKeyAndVisible];
        
        UIWindow *keyWindow = ((AppDelegate *)[UIApplication sharedApplication].delegate).window;
        [keyWindow makeKeyWindow];
    }
    return self;
}


#pragma mark - Getter && Setter

- (NSString *)currentPresentedMessage {
    return self.messageLabel.text;
}

#pragma mark - Public

- (void)presentMessage:(NSString *)message {
    [self presentMessage:message
           withTextColor:[UIColor COLOR_SNOW]
         backgroundColor:[UIColor blackColor]];
}

- (void)presentMessage:(NSString *)message withTextColor:(UIColor *)textColor backgroundColor:(UIColor *)bgColor {
    self.messageLabel.text = message;
    self.messageLabel.textColor = textColor;
    self.messageLabel.backgroundColor = bgColor;
    
    [self.messageLabel sizeToFit];
    CGRect labelFrame = self.messageLabel.frame;
    CGRect statusBarFrame = [UIApplication sharedApplication].statusBarFrame;
    labelFrame.origin = (CGPoint){floor(CGRectGetWidth(statusBarFrame) - CGRectGetWidth(labelFrame))};
    labelFrame.size.height = CGRectGetHeight(statusBarFrame);
    
    self.messageLabel.frame = labelFrame;
}

- (void)dismiss {
    self.messageLabel.backgroundColor = [UIColor clearColor];
    self.messageLabel.text = nil;
}

@end
