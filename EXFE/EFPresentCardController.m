//
//  EFPresentCardController.m
//  EXFE
//
//  Created by 0day on 13-5-24.
//
//

#import "EFPresentCardController.h"

#import <QuartzCore/QuartzCore.h>

#define kBackgroundMaskColor    [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.85f]
#define kCardCornerRadius       (11.0f)
#define kCardBorderColor        [UIColor colorWithWhite:1.0f alpha:0.2f]
#define kCardBorderWidth        (1.0f)
#define kDefaultContentSize     (CGSize){300.0f, 440.0f}

typedef void (^completionBlock)(void);

@interface EFPresentCardController ()
@property (nonatomic, retain) UIView *backgroundMaskView;
@property (nonatomic, retain) UIView *cardView;
@property (nonatomic, retain) UIViewController *presentdingViewController;
@property (nonatomic, copy) completionBlock completionHandler;
@end

@interface EFPresentCardController (Private)
- (void)_initUI;
- (void)_presentAnimated:(BOOL)animated;
- (void)_dismissAnimated:(BOOL)animated completionHandler:(void (^)(void))handler;
@end

@implementation EFPresentCardController

#pragma mark - Memory Manager

- (id)initWithContentViewController:(UIViewController *)viewController {
    self = [super init];
    if (self) {
        self.contentSize = kDefaultContentSize;
        self.contentViewController = viewController;
    }
    
    return self;
}

- (void)dealloc {
    [_contentViewController release];
    [_presentdingViewController release];
    [_backgroundMaskView release];
    [_cardView release];
    [super dealloc];
}

#pragma mark - Public

- (void)presentFromViewController:(UIViewController *)viewController animated:(BOOL)animated {
    NSParameterAssert(viewController);
    
    [self retain];
    self.presentdingViewController = viewController;
    
    [self _initUI];
    [self _presentAnimated:animated];
}

- (void)dismissAnimated:(BOOL)animated withCompletionHandler:(void (^)(void))handler {
    [self _dismissAnimated:animated completionHandler:handler];
}

#pragma mark - Aimation delegate

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    if (_completionHandler) {
        self.completionHandler();
    }
    [self release];
}

#pragma mark - Private

- (void)_initUI {
    UIView *rootView = self.presentdingViewController.view.window.rootViewController.view;
    CGRect rootViewBounds = rootView.bounds;
    
    // background mask view
    UIView *backgroundMaskView = [[UIView alloc] initWithFrame:rootViewBounds];
    backgroundMaskView.backgroundColor = kBackgroundMaskColor;
    backgroundMaskView.layer.opacity = 0.0f;
    [rootView addSubview:backgroundMaskView];
    self.backgroundMaskView = backgroundMaskView;
    [backgroundMaskView release];
    
    // card view
    CGRect cardFrame = (CGRect){{floor((CGRectGetWidth(rootViewBounds) - self.contentSize.width) * 0.5f), floor(CGRectGetHeight(rootViewBounds) - self.contentSize.height)}, {self.contentSize.width, floor(self.contentSize.height + kCardCornerRadius)}};
    UIView *cardView = [[UIView alloc] initWithFrame:cardFrame];
    cardView.layer.borderColor = kCardBorderColor.CGColor;
    cardView.layer.borderWidth = kCardBorderWidth;
    cardView.layer.cornerRadius = kCardCornerRadius;
    cardView.layer.masksToBounds = YES;
    cardView.layer.transform = CATransform3DMakeTranslation(0.0f, CGRectGetHeight(cardFrame), 0.0f);
    
    self.contentViewController.view.frame = (CGRect){{0.0f, 0.0f}, self.contentSize};
    [cardView addSubview:self.contentViewController.view];
    
    [rootView addSubview:cardView];
    self.cardView = cardView;
    [cardView release];
}

- (void)_presentAnimated:(BOOL)animated {
    CGFloat newOpacity = 1.0f;
    CATransform3D newTransform = CATransform3DIdentity;
    
    if (animated) {
        // opacity animation
        CABasicAnimation *opacityAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
        opacityAnimation.fromValue = [self.backgroundMaskView.layer valueForKey:@"opacity"];
        opacityAnimation.toValue = [NSNumber numberWithDouble:newOpacity];
        opacityAnimation.duration = 0.233f;
        opacityAnimation.fillMode = kCAFillModeForwards;
        opacityAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        
        [self.backgroundMaskView.layer addAnimation:opacityAnimation forKey:@"opacity"];
        
        // transform animation
        CABasicAnimation *transformAnimation = [CABasicAnimation animationWithKeyPath:@"transform"];
        transformAnimation.fromValue = [self.cardView.layer valueForKey:@"transform"];
        transformAnimation.toValue = [NSValue valueWithCATransform3D:newTransform];
        transformAnimation.duration = 0.233f;
        transformAnimation.fillMode = kCAFillModeForwards;
        transformAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        
        [self.cardView.layer addAnimation:transformAnimation forKey:@"opacity"];
    }
    
    self.backgroundMaskView.layer.opacity = newOpacity;
    self.cardView.layer.transform = newTransform;
}

- (void)_dismissAnimated:(BOOL)animated completionHandler:(void (^)(void))handler {
    self.completionHandler = handler;
    
    CGFloat newOpacity = 0.0f;
    CATransform3D newTransform = CATransform3DMakeTranslation(0.0f, CGRectGetHeight(self.cardView.bounds), 0.0f);
    
    if (animated) {
        // opacity animation
        CABasicAnimation *opacityAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
        opacityAnimation.fromValue = [self.backgroundMaskView.layer valueForKey:@"opacity"];
        opacityAnimation.toValue = [NSNumber numberWithDouble:newOpacity];
        opacityAnimation.duration = 0.2335f;
        opacityAnimation.fillMode = kCAFillModeForwards;
        opacityAnimation.delegate = self;
        opacityAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        
        [self.backgroundMaskView.layer addAnimation:opacityAnimation forKey:@"opacity"];
        
        // transform animation
        CABasicAnimation *transformAnimation = [CABasicAnimation animationWithKeyPath:@"transform"];
        transformAnimation.fromValue = [self.cardView.layer valueForKey:@"transform"];
        transformAnimation.toValue = [NSValue valueWithCATransform3D:newTransform];
        transformAnimation.duration = 0.233f;
        transformAnimation.fillMode = kCAFillModeForwards;
        transformAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        
        [self.cardView.layer addAnimation:transformAnimation forKey:@"opacity"];
    }
    
    self.backgroundMaskView.layer.opacity = newOpacity;
    self.cardView.layer.transform = newTransform;}

@end
