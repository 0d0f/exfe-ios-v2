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
@property (nonatomic, strong) UIView *backgroundMaskView;
@property (nonatomic, strong) UIView *cardView;
@property (nonatomic, strong) UIViewController *presentdingViewController;
@property (nonatomic, copy) completionBlock completionHandler;
@end

@interface EFPresentCardController (Private)
- (void)_initUI;
- (void)_addGestures;
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


#pragma mark - Public

- (void)presentFromViewController:(UIViewController *)viewController animated:(BOOL)animated {
    NSParameterAssert(viewController);
    
    self.presentdingViewController = viewController;
    
    [self _initUI];
    [self _addGestures];
    [self _presentAnimated:animated];
}

- (void)dismissAnimated:(BOOL)animated withCompletionHandler:(void (^)(void))handler {
    [self _dismissAnimated:animated completionHandler:handler];
}

#pragma mark - Gesture Handler

- (void)handleTap:(UITapGestureRecognizer *)gesture {
    if (UIGestureRecognizerStateEnded == gesture.state) {
        CGPoint location = [gesture locationInView:self.backgroundMaskView];
        if (!CGRectContainsPoint(self.cardView.frame, location)) {
            [self dismissAnimated:YES withCompletionHandler:nil];
        }
    }
}

- (void)handlePan:(UIPanGestureRecognizer *)gesture {
    static CGPoint startLocation = (CGPoint){0.0f, 0.0f};
    
    switch (gesture.state) {
        case UIGestureRecognizerStateBegan:
        {
            startLocation = [gesture locationInView:self.cardView];
        }
            break;
        case UIGestureRecognizerStateChanged:
        {
            CGPoint translation = [gesture translationInView:self.cardView];
            CGFloat opacity = (1.0f - (translation.y) / self.contentSize.height);
            
            if (opacity >= 0.0f && opacity <= 1.0f) {
                self.backgroundMaskView.layer.opacity = opacity;
                CATransform3D newTransform = CATransform3DMakeTranslation(0.0f, translation.y, 0.0f);
                self.cardView.layer.transform = newTransform;
            }
        }
            break;
        case UIGestureRecognizerStateEnded:
        {
            CGPoint velocity = [gesture velocityInView:self.cardView];
            
            if (velocity.y < 0) {
                [self _presentAnimated:YES];
            } else {
                [self dismissAnimated:YES withCompletionHandler:nil];
            }
        }
            break;
        default:
            break;
    }
}

#pragma mark - Aimation delegate

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    if (_completionHandler) {
        self.completionHandler();
    }
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
}

- (void)_addGestures {
    // tap
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                          action:@selector(handleTap:)];
    [self.backgroundMaskView addGestureRecognizer:tap];
    
    // pan
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self
                                                                          action:@selector(handlePan:)];
    [self.cardView addGestureRecognizer:pan];
    
    [tap requireGestureRecognizerToFail:pan];
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
        
        [self.backgroundMaskView.layer addAnimation:opacityAnimation forKey:@""];
        
        // transform animation
        CABasicAnimation *transformAnimation = [CABasicAnimation animationWithKeyPath:@"transform"];
        transformAnimation.fromValue = [self.cardView.layer valueForKey:@"transform"];
        transformAnimation.toValue = [NSValue valueWithCATransform3D:newTransform];
        transformAnimation.duration = 0.233f;
        transformAnimation.fillMode = kCAFillModeForwards;
        transformAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        
        [self.cardView.layer addAnimation:transformAnimation forKey:@""];
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
        
        [self.backgroundMaskView.layer addAnimation:opacityAnimation forKey:@""];
        
        // transform animation
        CABasicAnimation *transformAnimation = [CABasicAnimation animationWithKeyPath:@"transform"];
        transformAnimation.fromValue = [self.cardView.layer valueForKey:@"transform"];
        transformAnimation.toValue = [NSValue valueWithCATransform3D:newTransform];
        transformAnimation.duration = 0.233f;
        transformAnimation.fillMode = kCAFillModeForwards;
        transformAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        
        [self.cardView.layer addAnimation:transformAnimation forKey:@""];
    }
    
    self.backgroundMaskView.layer.opacity = newOpacity;
    self.cardView.layer.transform = newTransform;}

@end
