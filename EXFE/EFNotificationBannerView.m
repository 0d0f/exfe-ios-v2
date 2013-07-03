//
//  EFNotificationBannerView.m
//  EXFE
//
//  Created by 0day on 13-5-8.
//
//

#import "EFNotificationBannerView.h"

#import <QuartzCore/QuartzCore.h>
#import "Util.h"

#define kViewHeight (40.0f)
#define kDefaultAutoDismissTimeIntervalWithButton       (-1.0f)
#define kDefaultAutoDismissTimeIntervalWithoutButton    (4.33f)

typedef void (^ButtonPressedHandlerBlock)(void);

@interface EFNotificationBannerView ()

@property (nonatomic, strong) UIWindow *window;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *messageLabel;
@property (nonatomic, strong) UIView *maskView;
@property (nonatomic, strong) UIButton *button;
@property (nonatomic, copy) ButtonPressedHandlerBlock buttonPressedHandler;
@property (nonatomic, strong) NSTimer *timer;

@end

@implementation EFNotificationBannerView

- (id)initWithTitle:(NSString *)title message:(NSString *)message {
    self = [self initWithTitle:title
                       message:message
                   buttonTitle:nil
          buttonPressedHandler:nil];
    return self;
}

- (id)initWithTitle:(NSString *)title message:(NSString *)message buttonTitle:(NSString *)buttonTitle buttonPressedHandler:(void (^)(void))handler {
    CGRect windowBounds = [UIScreen mainScreen].bounds;
    self = [super initWithFrame:(CGRect){{0, 0}, {CGRectGetWidth(windowBounds), kViewHeight}}];
    if (self) {
        UIView *maskView = [[UIView alloc] initWithFrame:self.bounds];
        maskView.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.2f];
        [self addSubview:maskView];
        self.maskView = maskView;
        
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:(CGRect){{10, 4}, {260, 21}}];
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.textColor = [UIColor whiteColor];
        titleLabel.shadowColor = [UIColor colorWithWhite:0.0f alpha:0.5f];
        titleLabel.shadowOffset = (CGSize){0.0f, 0.5f};
        titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:14];
        titleLabel.text = title;
        [self addSubview:titleLabel];
        self.titleLabel = titleLabel;
        
        UILabel *messageLabel = [[UILabel alloc] initWithFrame:(CGRect){{10, 18}, {260, 18}}];
        messageLabel.backgroundColor = [UIColor clearColor];
        messageLabel.textColor = [UIColor whiteColor];
        messageLabel.shadowColor = [UIColor colorWithWhite:0.0f alpha:0.5f];
        messageLabel.shadowOffset = (CGSize){0.0f, 0.5f};
        messageLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:10];
        messageLabel.text = message;
        [self addSubview:messageLabel];
        self.messageLabel = messageLabel;
        
        if (buttonTitle && buttonTitle.length) {
            UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
            button.frame = (CGRect){{271, 3}, {45, 33}};
            UIImage *buttonBackgroundImage = [UIImage imageNamed:@"btn_white_30"];
            buttonBackgroundImage = [buttonBackgroundImage resizableImageWithCapInsets:(UIEdgeInsets){0, 10, 0, 10}];
            [button setBackgroundImage:buttonBackgroundImage forState:UIControlStateNormal];
            [button setTitleColor:[UIColor COLOR_RED_MEXICAN] forState:UIControlStateNormal];
            [button setTitle:buttonTitle forState:UIControlStateNormal];
            [button addTarget:self
                       action:@selector(buttonPressed:)
             forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:button];
            self.button = button;
            
            self.autoDismissTimeInterval = kDefaultAutoDismissTimeIntervalWithButton;
        } else {
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            button.frame = self.bounds;
            button.backgroundColor = [UIColor clearColor];
            [button addTarget:self
                       action:@selector(bannerPressed:)
             forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:button];
            
            self.autoDismissTimeInterval = kDefaultAutoDismissTimeIntervalWithoutButton;
        }
        
        UIWindow *window = [[UIWindow alloc] initWithFrame:(CGRect){{0, 0}, {CGRectGetWidth(windowBounds), kViewHeight}}];
        window.backgroundColor = [UIColor clearColor];
        window.windowLevel = UIWindowLevelStatusBar;
        
        [window makeKeyAndVisible];
        
        self.window = window;
    }
    
    return self;
}


- (void)drawRect:(CGRect)rect {
    CGRect windowBounds = [UIScreen mainScreen].bounds;
    UIImage *backgroundImage = [UIImage imageNamed:@"cautionbar.png"];
    
    [backgroundImage drawInRect:(CGRect){{0, 0}, {CGRectGetWidth(windowBounds), kViewHeight}}];
}

#pragma mark - Action

- (void)buttonPressed:(id)sender {
    if (_buttonPressedHandler) {
        self.buttonPressedHandler();
    }
    [self dismiss];
}

- (void)bannerPressed:(id)sender {
    [self dismiss];
}

#pragma mark - TimerHandler

- (void)timerHandler:(NSTimer *)timer {
    [self dismiss];
}

#pragma mark - Public

- (void)show {
    
    self.hidden = YES;
    self.alpha = 0.0f;
    [_window addSubview:self];
    
    [CATransaction flush];
    
    CATransition *cubeAnimation = [CATransition animation];
    [cubeAnimation setDuration:0.5f];
    [cubeAnimation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    [cubeAnimation setType:@"cube"];
    [cubeAnimation setSubtype:kCATransitionFromBottom];
    
    [self.layer addAnimation:cubeAnimation forKey:@"cube"];
    self.hidden = NO;
    
    [UIView animateWithDuration:0.5f
                          delay:0.0f
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         self.alpha = 1.0f;
                     }
                     completion:nil];
    
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    animation.fromValue = [NSNumber numberWithDouble:0.0f];
    animation.toValue = [NSNumber numberWithDouble:1.0f];
    animation.duration = 1.0f;
    animation.repeatCount = HUGE_VALF;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    animation.autoreverses = YES;
    
    [self.maskView.layer addAnimation:animation forKey:@"dissolve"];
    
    
    if (self.autoDismissTimeInterval > 0) {
        self.timer = [NSTimer scheduledTimerWithTimeInterval:self.autoDismissTimeInterval
                                                      target:self
                                                    selector:@selector(timerHandler:)
                                                    userInfo:nil
                                                     repeats:NO];
    }
}

- (void)dismiss {
    if ([_timer isValid]) {
        [_timer invalidate];
    }
    if (_timer) {
        _timer = nil;
    }
    
    CATransition *animation = [CATransition animation];
    [animation setDuration:0.5f];
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
    [animation setType:@"cube"];
    [animation setSubtype:kCATransitionFromTop];
    animation.delegate = self;
    animation.removedOnCompletion = NO;
    [self.layer addAnimation:animation forKey:@"cube"];
    
    self.hidden = YES;
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    [self removeFromSuperview];
    
    _window.hidden = YES;
    _window = nil;
    
    if ([self.delegate respondsToSelector:@selector(notificationBannerViewDidDismiss:)]) {
        [self.delegate notificationBannerViewDidDismiss:self];
    }
    
}

@end
