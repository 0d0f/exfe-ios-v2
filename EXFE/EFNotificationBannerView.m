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

typedef void (^ActionHandlerBlock)(void);

@interface EFNotificationBannerView ()

@property (nonatomic, strong) UIWindow *window;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *messageLabel;
@property (nonatomic, strong) UILabel *retryLabel;
@property (nonatomic, strong) UIView *maskView;
@property (nonatomic, strong) UIButton *button;
@property (nonatomic, copy) ActionHandlerBlock bannerPressedHandler;
@property (nonatomic, copy) ActionHandlerBlock buttonPressedHandler;
@property (nonatomic, strong) NSTimer *timer;

@end

@implementation EFNotificationBannerView

- (id)initWithTitle:(NSString *)title message:(NSString *)message bannerPressedHandler:(void (^)(void))bannerHandler buttonPressedHandler:(void (^)(void))handler {
    return [[EFNotificationBannerView alloc] initWithTitle:title message:message bannerPressedHandler:bannerHandler buttonPressedHandler:handler needRetry:YES];
}
- (id)initWithTitle:(NSString *)title message:(NSString *)message bannerPressedHandler:(void (^)(void))bannerHandler {
    return [[EFNotificationBannerView alloc] initWithTitle:title message:message bannerPressedHandler:bannerHandler buttonPressedHandler:nil needRetry:NO];
}

- (id)initWithTitle:(NSString *)title message:(NSString *)message bannerPressedHandler:(void (^)(void))bannerHandler buttonPressedHandler:(void (^)(void))handler needRetry:(BOOL)needRetry {
    CGRect windowBounds = [UIScreen mainScreen].bounds;
    self = [super initWithFrame:(CGRect){{0, 0}, {CGRectGetWidth(windowBounds), kViewHeight}}];
    if (self) {
        UIView *maskView = [[UIView alloc] initWithFrame:self.bounds];
        maskView.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.2f];
        [self addSubview:maskView];
        self.maskView = maskView;
        
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:(CGRect){{10, 1}, {260, 21}}];
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.textColor = [UIColor whiteColor];
        titleLabel.shadowColor = [UIColor colorWithWhite:0.0f alpha:0.5f];
        titleLabel.shadowOffset = (CGSize){0.0f, 0.5f};
        titleLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:14];
        titleLabel.text = title;
        [self addSubview:titleLabel];
        self.titleLabel = titleLabel;
        
        if (needRetry) {
            UILabel *retryLabel = [[UILabel alloc] initWithFrame:(CGRect){{0.0f, 0.0f}, {320.0f, kViewHeight}}];
            retryLabel.textAlignment = NSTextAlignmentCenter;
            retryLabel.backgroundColor = [UIColor clearColor];
            retryLabel.textColor = [UIColor colorWithWhite:1.0f alpha:0.12f];
            retryLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:24];
            retryLabel.text = NSLocalizedString(@"TAP TO RETRY", nil);
            [retryLabel sizeToFit];
            retryLabel.center = (CGPoint){CGRectGetWidth(self.bounds) * 0.5f, CGRectGetHeight(self.bounds) * 0.5f};
            [self insertSubview:retryLabel belowSubview:self.maskView];
            self.retryLabel = retryLabel;
        }
        
        UILabel *messageLabel = [[UILabel alloc] initWithFrame:(CGRect){{10, 18}, {260, 21}}];
        messageLabel.backgroundColor = [UIColor clearColor];
        messageLabel.textColor = [UIColor whiteColor];
        messageLabel.shadowColor = [UIColor colorWithWhite:0.0f alpha:0.5f];
        messageLabel.shadowOffset = (CGSize){0.0f, 0.5f};
        messageLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:14];
        messageLabel.text = message;
        [self addSubview:messageLabel];
        self.messageLabel = messageLabel;
        
        BOOL hasMessage = YES;
        if (!message || 0 == message.length) {
            hasMessage = NO;
        }
        
        if (!hasMessage) {
            self.titleLabel.numberOfLines = 2;
            [self.titleLabel sizeToFit];
            
            CGFloat maxWidth = 290.0f;
            
            if (CGRectGetWidth(self.titleLabel.frame) > maxWidth) {
                CGRect titleLabelFrame = self.titleLabel.frame;
                titleLabelFrame.size.width = maxWidth;
                self.titleLabel.frame = titleLabelFrame;
            }
            
            self.titleLabel.center = (CGPoint){self.titleLabel.center.x, CGRectGetHeight(self.bounds) * 0.5f};
        }
        
        self.bannerPressedHandler = bannerHandler;
        self.buttonPressedHandler = handler;
        
        if (needRetry) {
            self.autoDismissTimeInterval = kDefaultAutoDismissTimeIntervalWithButton;
            
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            button.frame = (CGRect){{276, 3}, {44, 33}};
            [button setImage:[UIImage imageNamed:@"cautionbar_cancel.png"] forState:UIControlStateNormal];
            [button setImage:[UIImage imageNamed:@"cautionbar_cancel_pressed.png"] forState:UIControlStateHighlighted];
            [button addTarget:self
                       action:@selector(buttonPressed:)
             forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:button];
            self.button = button;
        } else {
            self.autoDismissTimeInterval = kDefaultAutoDismissTimeIntervalWithoutButton;
        }
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                              action:@selector(handleTap:)];
        [self addGestureRecognizer:tap];
        
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

#pragma mark - Gesture

- (void)handleTap:(UITapGestureRecognizer *)tap {
    if (_bannerPressedHandler) {
        self.bannerPressedHandler();
    }
    [self dismiss];
}

#pragma mark - Action

- (void)buttonPressed:(id)sender {
    if (_buttonPressedHandler) {
        self.buttonPressedHandler();
    }
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
    animation.duration = 1.5f;
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
