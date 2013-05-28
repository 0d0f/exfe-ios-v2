//
//  EFTabBar.m
//  EFHeaderBarDemo
//
//  Created by 0day on 13-5-16.
//  Copyright (c) 2013年 0d0f. All rights reserved.
//

#import "EFTabBar.h"

#import <QuartzCore/QuartzCore.h>
#import "EFTabBarViewController.h"
#import "EFTabBarItem.h"
#import "EFTabBarItemControl.h"

#define kTitleEdgeBlank                 (30.0f)
#define kTabBarItemSize                 ((CGSize){30.0f, 30.0f})
#define kTabBarButtonSize               ((CGSize){54.0f, 44.0f})
#define kButtonSpacing                  (6.0f)

#define kInnserShadowRadius             (4.0f)
#define kOuterShadowRadius              (10.0f)

#define kNormalStyleFrame               ((CGRect){{0.0f, 0.0f}, {320.0f, 70.0f}})
#define kDoubleheightStyleFrame         ((CGRect){{0.0f, 0.0f}, {320.0f, 100.0f}})

#define kButtonNormalStyleFrame         ((CGRect){{0.0f, 3.0f}, {44.0f, 44.0f}})
#define kButtonDoubleheightStyleFrame   ((CGRect){{0.0f, 18.0f}, {44.0f, 44.0f}})

#define kDefaultBackgroundImage [UIImage imageNamed:@"x_titlebg_default.jpg"]

#pragma mark - EFTabBarBackgroundView

inline static CGMutablePathRef CreateMaskPath(CGRect viewBounds, CGPoint startPoint, CGPoint endPoint) {
    CGPoint controlPoint1 = (CGPoint){floor(startPoint.x - 47.0f), startPoint.y};
    CGPoint controlPoint2 = (CGPoint){floor(endPoint.x + 75.0f), endPoint.y};
    
    CGMutablePathRef maskPath = CGPathCreateMutable();
    CGPathMoveToPoint(maskPath, NULL, 0.0f, 0.0f);
    CGPathAddLineToPoint(maskPath, NULL, CGRectGetWidth(viewBounds), 0.0f);
    CGPathAddLineToPoint(maskPath, NULL, CGRectGetWidth(viewBounds), CGRectGetHeight(viewBounds));
    CGPathAddLineToPoint(maskPath, NULL, startPoint.x, startPoint.y);
    CGPathAddCurveToPoint(maskPath, NULL, controlPoint1.x, controlPoint1.y, controlPoint2.x, controlPoint2.y, endPoint.x, endPoint.y);
    CGPathAddLineToPoint(maskPath, NULL, 0.0f, endPoint.y);
    CGPathCloseSubpath(maskPath);
    
    return maskPath;
}

@interface EFTabBarBackgroundView : UIView

@property (nonatomic, retain) UIImage *backgroundImage;

@property (nonatomic, retain) CAShapeLayer *maskLayer;
@property (nonatomic, retain) CAShapeLayer *innerShadowLayer;

- (void)showButtonWithMaskPath:(CGPathRef)maskPath innerShadowPath:(CGPathRef)shadowPath  animated:(BOOL)animated;
- (void)dismissButtonWithMaskPath:(CGPathRef)maskPath innerShadowPath:(CGPathRef)shadowPath animated:(BOOL)animated;

@end

@implementation EFTabBarBackgroundView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        CAShapeLayer *maskLayer = [CAShapeLayer layer];
        maskLayer.fillRule = kCAFillRuleEvenOdd;
        self.layer.mask = maskLayer;
        
        self.maskLayer = maskLayer;
        
        CAShapeLayer *innerShadowLayer = [CAShapeLayer layer];
        innerShadowLayer.needsDisplayOnBoundsChange = YES;
        innerShadowLayer.shouldRasterize = YES;
        innerShadowLayer.rasterizationScale = [UIScreen mainScreen].scale;
        innerShadowLayer.contentsScale = [UIScreen mainScreen].scale;
        innerShadowLayer.shadowColor = [UIColor blackColor].CGColor;
        innerShadowLayer.shadowOffset = (CGSize){0.0f, 0.0f};
        innerShadowLayer.shadowOpacity = 0.5f;
        innerShadowLayer.shadowRadius = kInnserShadowRadius;
        innerShadowLayer.fillRule = kCAFillRuleEvenOdd;
        [self.layer addSublayer:innerShadowLayer];
        
        self.innerShadowLayer = innerShadowLayer;
    }
    
    return self;
}

- (void)dealloc {
    [_innerShadowLayer release];
    [_maskLayer release];
    [_backgroundImage release];
    [super dealloc];
}

- (void)showButtonWithMaskPath:(CGPathRef)maskPath innerShadowPath:(CGPathRef)shadowPath  animated:(BOOL)animated {
    if (animated) {
        // mask animation
        CABasicAnimation *maskAnimation = [CABasicAnimation animationWithKeyPath:@"path"];
        maskAnimation.duration = 0.233f;
        maskAnimation.fromValue = (id)self.maskLayer.path;
        maskAnimation.toValue = (id)maskPath;
        maskAnimation.fillMode = kCAFillModeForwards;
        maskAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        
        [self.maskLayer addAnimation:maskAnimation forKey:@"maskAnimation"];
        
        // shadow animation
        CABasicAnimation *shadowAnimation = [CABasicAnimation animationWithKeyPath:@"path"];
        shadowAnimation.duration = 0.233f;
        shadowAnimation.fromValue = (id)self.innerShadowLayer.path;
        shadowAnimation.toValue = (id)shadowPath;
        shadowAnimation.fillMode = kCAFillModeForwards;
        shadowAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        
        [self.innerShadowLayer addAnimation:shadowAnimation forKey:@"shadowAnimation"];
    }
    
    self.maskLayer.path = maskPath;
    self.innerShadowLayer.path = shadowPath;
}

- (void)dismissButtonWithMaskPath:(CGPathRef)maskPath innerShadowPath:(CGPathRef)shadowPath animated:(BOOL)animated {
    if (animated) {
        // mask animation
        CABasicAnimation *maskAnimation = [CABasicAnimation animationWithKeyPath:@"path"];
        maskAnimation.duration = 0.233f;
        maskAnimation.fromValue = (id)self.maskLayer.path;
        maskAnimation.toValue = (id)maskPath;
        maskAnimation.fillMode = kCAFillModeForwards;
        maskAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        
        [self.maskLayer addAnimation:maskAnimation forKey:@"maskAnimation"];
        
        // shadow animation
        CABasicAnimation *shadowAnimation = [CABasicAnimation animationWithKeyPath:@"path"];
        shadowAnimation.duration = 0.233f;
        shadowAnimation.fromValue = (id)self.innerShadowLayer.path;
        shadowAnimation.toValue = (id)shadowPath;
        shadowAnimation.fillMode = kCAFillModeForwards;
        shadowAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        
        [self.innerShadowLayer addAnimation:shadowAnimation forKey:@"shadowAnimation"];
    }
    
    self.maskLayer.path = maskPath;
    self.innerShadowLayer.path = shadowPath;
}

- (void)setBackgroundImage:(UIImage *)backgroundImage {
    if (_backgroundImage == backgroundImage)
        return;
    
    if (_backgroundImage) {
        [_backgroundImage release];
        _backgroundImage = nil;
    }
    if (backgroundImage) {
        _backgroundImage = [backgroundImage retain];
    }
    
    [self setNeedsDisplay];
    
    CATransition *fadeAnimation = [CATransition animation];
    fadeAnimation.duration = 0.233f;
    fadeAnimation.type = @"fade";
    fadeAnimation.fillMode = kCAFillModeForwards;
    [self.layer addAnimation:fadeAnimation forKey:@"fadeAnimation"];
}

- (void)drawRect:(CGRect)rect {
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGFloat locations[2] = {0.0, 1.0};
    CGFloat components1[8] = {0.0f, 0.0f, 0.0f, 0.12f,  // Start color
                             0.0f, 0.0f, 0.0f, 0.33f};  // End color
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    
    CGContextSetAllowsAntialiasing(context, YES);
    CGContextSetAllowsFontSmoothing(context, YES);
    
    CGRect imageRect = kDoubleheightStyleFrame;
    CGSize imageSize = self.backgroundImage.size;
    imageRect.size.height = ceil(CGRectGetWidth(imageRect) * imageSize.height / imageSize.width);
    imageRect.origin.y = CGRectGetHeight(kDoubleheightStyleFrame) - CGRectGetHeight(imageRect);
    [self.backgroundImage drawInRect:imageRect];
    
    // gradient 1
    CGGradientRef gradient1 = CGGradientCreateWithColorComponents(colorSpace, components1, locations, 2);
    CGContextDrawLinearGradient(context, gradient1, (CGPoint){CGRectGetMidX(kDoubleheightStyleFrame), 0.0f}, (CGPoint){CGRectGetMidX(kDoubleheightStyleFrame), CGRectGetHeight(kDoubleheightStyleFrame)}, kCGGradientDrawsBeforeStartLocation);
    CGGradientRelease(gradient1);
    
    CGFloat components2[8] = {0.0f, 0.0f, 0.0f, 0.25f,  // Start color
                              0.0f, 0.0f, 0.0f, 0.0f};  // End color
    
    // gradient 2
    CGGradientRef gradient2 = CGGradientCreateWithColorComponents(colorSpace, components2, locations, 2);
    CGContextDrawLinearGradient(context, gradient2, (CGPoint){0.0f, CGRectGetMidY(kDoubleheightStyleFrame)}, (CGPoint){50.0f, CGRectGetMidY(kDoubleheightStyleFrame)}, kCGGradientDrawsBeforeStartLocation);
    CGGradientRelease(gradient2);
    
    CGContextRestoreGState(context);
    CGColorSpaceRelease(colorSpace);
}

@end

#pragma mark - EFTabBar

@interface EFTabBar ()
@property (nonatomic, retain) UIButton *leftButton;
@property (nonatomic, retain) NSArray *buttons;
@property (nonatomic, retain) UIView *buttonBaseView;
@property (nonatomic, assign) BOOL isButtonsShowed;
@property (nonatomic, retain) UIImageView *shadowImageView;
@property (nonatomic, retain) EFTabBarBackgroundView *backgroundView;
@property (nonatomic, retain) CAShapeLayer *outerShadowLayer;
@property (nonatomic, assign) NSUInteger preSelectedIndex;
@property (nonatomic, assign) EFTabBarItemState preSelectedTabBarItemState;
@property (nonatomic, retain) UIView *gestureView;
@property (nonatomic, copy) EFTabBarTitlePressedBlock titlePressedBlock;

@property (nonatomic, assign) UIWindow *originWindow;
@property (nonatomic, retain) UIWindow *window;
@end

@interface EFTabBar (Private)
- (void)_resetButtons;
- (void)_layoutButtons;
- (void)_showButtonsAnimated:(BOOL)animated;
- (void)_dismissButtonsAnimated:(BOOL)animated;
- (void)_addGestureRecognizers;
- (EFTabBarItemControl *)_preSelectedButton;
- (EFTabBarItemControl *)_selectedButton;
- (CGRect)_buttonFrameAtIndex:(NSUInteger)index;
- (void)_setSelectedIndex:(NSUInteger)index;
- (void)_changeTitleFrameAimated:(BOOL)animated;
- (void)_addMaskWindow;
- (void)_removeMaskWindow;
@end

@interface EFTabBar (Action)
- (void)_back;
@end

@implementation EFTabBar

- (id)initWithStyle:(EFTabBarStyle)style {
    CGRect frame = CGRectZero;
    if (kEFTabBarStyleDoubleHeight == style) {
        frame = kDoubleheightStyleFrame;
    } else {
        frame = kNormalStyleFrame;
    }
    
    self = [super initWithFrame:frame];
    if (self) {
        // title label
        UILabel *label = [[UILabel alloc] initWithFrame:(CGRect){{kTitleEdgeBlank, floor((CGRectGetHeight(frame) - 20.0f - CGRectGetHeight(frame) + kTabBarItemSize.height) * 0.5f)}, {CGRectGetWidth(frame) - kTitleEdgeBlank * 2, CGRectGetHeight(frame) - kTabBarItemSize.height}}];
        label.textAlignment = NSTextAlignmentCenter;
        label.font = [UIFont fontWithName:@"HelveticaNeue" size:21];
        label.backgroundColor = [UIColor clearColor];
        label.textColor = [UIColor whiteColor];
        label.shadowColor = [UIColor colorWithWhite:0.0f alpha:0.5f];
        label.shadowOffset = (CGSize){0, 1.0f};
        label.numberOfLines = (style == kEFTabBarStyleDoubleHeight) ? 2 : 1;
        [self addSubview:label];
        _titleLabel = label;
        
        // gesture view
        UIView *gestureView = [[UIView alloc] initWithFrame:(CGRect){{10.0f, 0.0f}, {CGRectGetWidth(frame) - 30.0f, 50.0f}}];
        gestureView.backgroundColor = [UIColor clearColor];
        [self addSubview:gestureView];
        self.gestureView = gestureView;
        [gestureView release];
        
        // default background image
        self.backgroundImage = kDefaultBackgroundImage;
        
        // outer shadow
        UIView *outerShadowView = [[UIView alloc] initWithFrame:frame];
        outerShadowView.backgroundColor = [UIColor clearColor];
        
        CAShapeLayer *outerShadowLayer = [CAShapeLayer layer];
        outerShadowLayer.shouldRasterize = YES;
        outerShadowLayer.rasterizationScale = [UIScreen mainScreen].scale;
        outerShadowLayer.contentsScale = [UIScreen mainScreen].scale;
        outerShadowLayer.fillMode = kCAFillRuleEvenOdd;
        outerShadowLayer.shadowOffset = (CGSize){0.0f, 0.0f};
        outerShadowLayer.shadowOpacity = 1.0f;
        outerShadowLayer.shadowRadius = kOuterShadowRadius;
        
//        [outerShadowView.layer addSublayer:outerShadowLayer];
        self.outerShadowLayer = outerShadowLayer;
        
        [self insertSubview:outerShadowView belowSubview:label];
        
        [outerShadowView release];
        
        // backgroundView
        _backgroundView = [[EFTabBarBackgroundView alloc] initWithFrame:kDoubleheightStyleFrame];
        _backgroundView.backgroundImage = self.backgroundImage;
        [self insertSubview:_backgroundView belowSubview:label];
        
        // left button
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        if (kEFTabBarStyleDoubleHeight == style) {
            button.frame = kButtonDoubleheightStyleFrame;
        } else {
            button.frame = kButtonNormalStyleFrame;
        }
        
        [button setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
        [button setImage:[UIImage imageNamed:@"back_pressed"] forState:UIControlStateHighlighted];
        button.imageEdgeInsets = (UIEdgeInsets){0, -24, 0, 0};
        [button addTarget:self
                   action:@selector(backButtonPressed:)
         forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:button];
        self.leftButton = button;
        
        // button base view
        UIView *baseView = [[UIView alloc] initWithFrame:(CGRect){{0, CGRectGetHeight(frame) - kTabBarButtonSize.height}, {CGRectGetWidth(frame), kTabBarButtonSize.height}}];
        baseView.backgroundColor = [UIColor clearColor];
        [self addSubview:baseView];
        self.buttonBaseView = baseView;
        [baseView release];
        
        // shadow
        UIImageView *shadowImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"x_shadow"]];
        shadowImageView.frame = (CGRect){{0, CGRectGetHeight(frame) - 25}, {640, 30}};
//        [self addSubview:shadowImageView];
        self.shadowImageView = shadowImageView;
        [shadowImageView release];
        
        // gesture
        [self _addGestureRecognizers];
        
        // other default values
        self.isButtonsShowed = NO;
        
        [self.titleLabel addObserver:self
                          forKeyPath:@"text"
                             options:NSKeyValueObservingOptionNew
                             context:NULL];
        
        self.tabBarStyle = style;
    }
    return self;
}

- (void)dealloc {
    [self.titleLabel removeObserver:self
                         forKeyPath:@"text"];
    self.originWindow = nil;
    self.window = nil;
    self.tabBarViewController = nil;
    [_outerShadowLayer release];
    [_gestureView release];
    [_backgroundView release];
    [_buttons release];
    [_leftButton release];
    [_titleLabel release];
    [super dealloc];
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (object == self.titleLabel && [keyPath isEqualToString:@"text"]) {
        [self _changeTitleFrameAimated:YES];
    } else if (object == self.tabBarViewController && [keyPath isEqualToString:@"selectedIndex"]) {
        UIViewController<EFTabBarDataSource> *viewController = (UIViewController<EFTabBarDataSource> *)self.tabBarViewController.viewControllers[self.tabBarViewController.selectedIndex];
        self.outerShadowLayer.shadowColor = viewController.shadowColor.CGColor;
    }
}

#pragma mark - Getter && Setter

- (void)setTabBarItems:(NSArray *)tabBarItems {
    if (_tabBarItems == tabBarItems)
        return;
    
    if (_tabBarItems) {
        [_tabBarItems release];
        _tabBarItems = nil;
    }
    
    if (tabBarItems) {
        _tabBarItems = [tabBarItems retain];
        [self _resetButtons];
        [self _layoutButtons];
    }
}

- (void)setTabBarStyle:(EFTabBarStyle)tabBarStyle {
    if (_tabBarStyle == tabBarStyle)
        return;
    
    _tabBarStyle = tabBarStyle;
    [self _changeTitleFrameAimated:YES];
}

- (void)setBackgroundImage:(UIImage *)backgroundImage {
    if (backgroundImage == _backgroundImage)
        return;
    
    if (_backgroundImage) {
        [_backgroundImage release];
        _backgroundImage = nil;
    }
    if (backgroundImage) {
        _backgroundImage = [backgroundImage retain];
    }
    
    self.backgroundView.backgroundImage = backgroundImage;
}

- (void)setTabBarViewController:(EFTabBarViewController *)tabBarViewController {
    if (_tabBarViewController == tabBarViewController)
        return;
    
    if (_tabBarViewController) {
        [_tabBarViewController removeObserver:self
                                   forKeyPath:@"selectedIndex"];
        _tabBarViewController = nil;
    }
    if (tabBarViewController) {
        [tabBarViewController addObserver:self
                               forKeyPath:@"selectedIndex"
                                  options:NSKeyValueObservingOptionNew
                                  context:NULL];
        _tabBarViewController = tabBarViewController;
    }
}

#pragma mark - Public

- (void)setSelectedIndex:(NSUInteger)index {
    [self _setSelectedIndex:index];
}

#pragma mark - Action

- (void)buttonPressed:(EFTabBarItemControl *)sender {
    NSUInteger index = [self.buttons indexOfObject:sender];
    
    if (self.isButtonsShowed) {
        if (index != self.tabBarViewController.selectedIndex) {
            [self.tabBarViewController setSelectedIndex:index
                                               animated:YES];
        }
        [self _dismissButtonsAnimated:YES];
    } else {
        [self _showButtonsAnimated:YES];
    }
}

- (void)backButtonPressed:(UIButton *)sender {
    [self _back];
}

- (void)_back {
    if (self.tabBarViewController.backButtonActionHandler) {
        self.tabBarViewController.backButtonActionHandler();
    } else {
        UIViewController *presentingViewController = self.tabBarViewController.presentingViewController;
        UIViewController *parentViewController = self.tabBarViewController.parentViewController;
        
        if ([parentViewController isKindOfClass:[UINavigationController class]] &&
            parentViewController == self.tabBarViewController.navigationController) {
            // navigation
            [self.tabBarViewController.navigationController popViewControllerAnimated:YES];
        } else if (presentingViewController.presentedViewController == self.tabBarViewController) {
            // model
            [self.tabBarViewController.presentingViewController dismissViewControllerAnimated:YES
                                                                                   completion:nil];
        }
    }
}

#pragma mark - Gesture Handle

- (void)doubleTapHandler:(UITapGestureRecognizer *)gesture {
    if (UIGestureRecognizerStateEnded == gesture.state) {
        [self _setSelectedIndex:self.tabBarViewController.defaultIndex];
    }
}

- (void)singleTapHandler:(UITapGestureRecognizer *)gesture {
    if (UIGestureRecognizerStateEnded == gesture.state) {
        if (self.isButtonsShowed) {
            [self _dismissButtonsAnimated:YES];
        }
        
        if (_titlePressedBlock) {
            self.titlePressedBlock();
        }
    }
}

- (void)swipeHandler:(UISwipeGestureRecognizer *)gesture {
    if (UIGestureRecognizerStateEnded == gesture.state) {
        if (self.isButtonsShowed) {
            [self _dismissButtonsAnimated:YES];
        }
        
        if (UISwipeGestureRecognizerDirectionRight == gesture.direction) {
            [self _back];
        }
    }
}

- (void)windowTapHandler:(UITapGestureRecognizer *)gesture {
    if (UIGestureRecognizerStateEnded == gesture.state) {
        [self _dismissButtonsAnimated:YES];
    }
}

- (void)windowPanHandler:(UIPanGestureRecognizer *)gesture {
    if (UIGestureRecognizerStateEnded == gesture.state) {
        [self _dismissButtonsAnimated:YES];
    }
}

#pragma mark - Private

- (void)_resetButtons {
    // remove pre buttons
    if (self.buttons) {
        for (EFTabBarItemControl *button in self.buttons) {
            [button removeFromSuperview];
        }
        self.buttons = nil;
    }
    
    // resize button base view
    NSUInteger count = [self.tabBarItems count];
    CGRect baseViewFrame = self.buttonBaseView.frame;
    baseViewFrame.size.width = count * (kTabBarButtonSize.width + kButtonSpacing) - kButtonSpacing;
    self.buttonBaseView.frame = baseViewFrame;
    
    // add buttons
    NSMutableArray *buttons = [[NSMutableArray alloc] initWithCapacity:count];
    int i = 0;
    for (EFTabBarItem *tabBarItem in self.tabBarItems) {
        EFTabBarItemControl *button = [EFTabBarItemControl controlWithTabBarItem:tabBarItem];
        button.touchUpInsideActionHandler = ^(EFTabBarItemControl *control){
            [self buttonPressed:control];
        };
        button.swipeActionHandler = ^(EFTabBarItemControl *control, UISwipeGestureRecognizerDirection direction){
            NSAssert(self.tabBarViewController.viewControllers.count, @"TabBarViewController.viewController can't be empty.");
            
            if (UISwipeGestureRecognizerDirectionLeft == direction) {
                NSUInteger nextIndex = (self.tabBarViewController.selectedIndex + 1) % self.tabBarViewController.viewControllers.count;
                [self _setSelectedIndex:nextIndex];
            } else if (UISwipeGestureRecognizerDirectionRight) {
                NSInteger nextIndex = self.tabBarViewController.selectedIndex - 1;
                if (nextIndex < 0) {
                    nextIndex = self.tabBarViewController.viewControllers.count - 1;
                }
                [self _setSelectedIndex:nextIndex];
            }
        };
        
        if (!i) {
            CGRect frame = [self.buttonBaseView convertRect:[self _buttonFrameAtIndex:i] toView:self];
            frame.origin = (CGPoint){CGRectGetWidth(self.frame) - kTabBarButtonSize.width, CGRectGetHeight(self.frame) - kTabBarButtonSize.height};
            button.frame = frame;
            [self addSubview:button];
        } else {
            button.frame = [self _buttonFrameAtIndex:i];
            [self.buttonBaseView addSubview:button];
        }
        
        
        [buttons addObject:button];
        i++;
    }
    
    self.buttons = buttons;
    [buttons release];
}

- (void)_layoutButtons {
    [self _dismissButtonsAnimated:NO];
}

- (void)_showButtonsAnimated:(BOOL)animated {
    self.isButtonsShowed = YES;
    
    // disable the contol swipe
    for (EFTabBarItemControl *button in self.buttons) {
        button.swipeEnable = NO;
    }
    
    // cache index & state
    self.preSelectedIndex = self.tabBarViewController.selectedIndex;
    self.preSelectedTabBarItemState = self.tabBarViewController.selectedViewController.customTabBarItem.tabBarItemState;
    
    // highlight selected one
    self.tabBarViewController.selectedViewController.customTabBarItem.tabBarItemState = kEFTabBarItemStateHighlight;
    
    // Destination frame
    CGRect destinationFrame = self.buttonBaseView.frame;
    destinationFrame.origin = (CGPoint){CGRectGetWidth(self.frame) - CGRectGetWidth(destinationFrame), CGRectGetHeight(self.frame) - kTabBarButtonSize.height};
    
    CGRect shadowFrame = self.shadowImageView.frame;
    if (animated) {
        CGPoint offset = (CGPoint){CGRectGetMinX(destinationFrame) - CGRectGetMinX(self.buttonBaseView.frame), CGRectGetMinY(destinationFrame) - CGRectGetMinY(self.buttonBaseView.frame)};
        shadowFrame.origin.x += (offset.x + kTabBarButtonSize.width);
        shadowFrame.origin.y += offset.y;
    }
    
    // mask animation
    CGPoint startPoint = (CGPoint){CGRectGetWidth(self.frame) - CGRectGetWidth(destinationFrame) + kTabBarButtonSize.width, CGRectGetHeight(self.bounds)};
    CGPoint endPoint = (CGPoint){startPoint.x - 122.0f, floor(CGRectGetHeight(self.bounds) - 20.0f)};
    
    CGPathRef maskPath = CreateMaskPath(self.bounds, startPoint, endPoint);
    
    CGRect largerRect = CGRectMake(self.bounds.origin.x,
                                   self.bounds.origin.y,
                                   self.bounds.size.width,
                                   self.bounds.size.height + kInnserShadowRadius);
    CGPoint largerStartPoint = (CGPoint){startPoint.x, startPoint.y + kInnserShadowRadius};
    CGPoint largerEndPoint = (CGPoint){endPoint.x, endPoint.y + kInnserShadowRadius};
    
    CGMutablePathRef shadowPath = CreateMaskPath(largerRect, largerStartPoint, largerEndPoint);
    CGPathAddPath(shadowPath, NULL, maskPath);
    CGPathCloseSubpath(shadowPath);
    
    [self.backgroundView showButtonWithMaskPath:maskPath
                                innerShadowPath:shadowPath
                                       animated:YES];
    
    CABasicAnimation *shadowAnimation = [CABasicAnimation animationWithKeyPath:@"path"];
    shadowAnimation.duration = 0.233f;
    shadowAnimation.fromValue = (id)self.outerShadowLayer.path;
    shadowAnimation.toValue = (id)maskPath;
    shadowAnimation.fillMode = kCAFillModeForwards;
    shadowAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    
    [self.outerShadowLayer addAnimation:shadowAnimation forKey:@"shadowAnimation"];
    self.outerShadowLayer.path = maskPath;
    
    CGPathRelease(maskPath);
    CGPathRelease(shadowPath);
    
    // buttons animation
    [UIView setAnimationsEnabled:animated];
    [UIView animateWithDuration:0.233f
                     animations:^{
                         self.buttonBaseView.frame = destinationFrame;
                         self.shadowImageView.frame = shadowFrame;
                     }
                     completion:^(BOOL finished){
                         [UIView setAnimationsEnabled:YES];
                     }];
    
    // selected button animation
    EFTabBarItemControl *selectedButton = [self _selectedButton];
    [UIView animateWithDuration:0.233f
                          delay:0.0f
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         CGRect frame = [self _buttonFrameAtIndex:self.tabBarViewController.selectedIndex];
                         frame = [self.buttonBaseView convertRect:frame toView:self];
                         selectedButton.frame = frame;
                     }
                     completion:^(BOOL finished){
                         [selectedButton removeFromSuperview];
                         selectedButton.frame = [self _buttonFrameAtIndex:self.tabBarViewController.selectedIndex];
                         [self.buttonBaseView addSubview:selectedButton];
                         [UIView setAnimationsEnabled:YES];
                     }];
    
    [self _addMaskWindow];
}

- (void)_dismissButtonsAnimated:(BOOL)animated {
    [self _removeMaskWindow];
    
    ((UIViewController<EFTabBarDataSource> *)(self.tabBarViewController.viewControllers[self.preSelectedIndex])).customTabBarItem.tabBarItemState = self.preSelectedTabBarItemState;
    
    // enable the contol swipe
    for (EFTabBarItemControl *button in self.buttons) {
        button.swipeEnable = YES;
    }
    
    // Destination frame
    CGRect destinationFrame = self.buttonBaseView.frame;
    destinationFrame.origin = (CGPoint){CGRectGetWidth(self.frame), CGRectGetHeight(self.frame) - kTabBarButtonSize.height};
    
    CGRect shadowFrame = self.shadowImageView.frame;
    if (animated) {
        CGPoint offset = (CGPoint){CGRectGetMinX(destinationFrame) - CGRectGetMinX(self.buttonBaseView.frame), CGRectGetMinY(destinationFrame) - CGRectGetMinY(self.buttonBaseView.frame)};
        shadowFrame.origin.x += (offset.x - kTabBarButtonSize.width);
        shadowFrame.origin.y += offset.y;
    }
    
    // mask animation
    CGPoint startPoint = (CGPoint){CGRectGetWidth(self.frame), CGRectGetHeight(self.bounds)};
    CGPoint endPoint = (CGPoint){startPoint.x - 122.0f, floor(CGRectGetHeight(self.bounds) - 20.0f)};
    
    CGPathRef maskPath = CreateMaskPath(self.bounds, startPoint, endPoint);
    
    CGRect largerRect = CGRectMake(self.bounds.origin.x,
                                   self.bounds.origin.y,
                                   self.bounds.size.width,
                                   self.bounds.size.height + kInnserShadowRadius);
    CGPoint largerStartPoint = (CGPoint){startPoint.x, startPoint.y + kInnserShadowRadius};
    CGPoint largerEndPoint = (CGPoint){endPoint.x, endPoint.y + kInnserShadowRadius};
    
    CGMutablePathRef shadowPath = CreateMaskPath(largerRect, largerStartPoint, largerEndPoint);
    CGPathAddPath(shadowPath, NULL, maskPath);
    CGPathCloseSubpath(shadowPath);
    
    [self.backgroundView dismissButtonWithMaskPath:maskPath
                                   innerShadowPath:shadowPath
                                          animated:YES];
    
    CABasicAnimation *shadowAnimation = [CABasicAnimation animationWithKeyPath:@"path"];
    shadowAnimation.duration = 0.233f;
    shadowAnimation.fromValue = (id)self.outerShadowLayer.path;
    shadowAnimation.toValue = (id)maskPath;
    shadowAnimation.fillMode = kCAFillModeForwards;
    shadowAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    
    [self.outerShadowLayer addAnimation:shadowAnimation forKey:@"shadowAnimation"];
    self.outerShadowLayer.path = maskPath;
    
    CGPathRelease(maskPath);
    CGPathRelease(shadowPath);
    
    if (animated) {
        // selected button animation
        EFTabBarItemControl *selectedButton = [self _selectedButton];
        CGRect frame = selectedButton.frame;
        frame = [self.buttonBaseView convertRect:frame toView:self];
        [selectedButton removeFromSuperview];
        selectedButton.frame = frame;
        [self addSubview:selectedButton];
        
        [UIView setAnimationsEnabled:animated];
        [UIView animateWithDuration:0.233f
                              delay:0.0f
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             CGRect frame = selectedButton.frame;
                             frame.origin = (CGPoint){CGRectGetWidth(self.frame) - kTabBarButtonSize.width, CGRectGetHeight(self.frame) - kTabBarButtonSize.height};
                             selectedButton.frame = frame;
                         }
                         completion:^(BOOL finished){
                             [UIView setAnimationsEnabled:YES];
                         }];
    }
    
    // buttons animation
    [UIView setAnimationsEnabled:animated];
    [UIView animateWithDuration:0.233f
                     animations:^{
                         self.buttonBaseView.frame = destinationFrame;
                         self.shadowImageView.frame = shadowFrame;
                     }
                     completion:^(BOOL finished){
                         [UIView setAnimationsEnabled:YES];
                     }];
    
    self.isButtonsShowed = NO;
}

- (void)_addGestureRecognizers {
    // double tap
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                action:@selector(doubleTapHandler:)];
    doubleTap.numberOfTapsRequired = 2;
    [self.gestureView addGestureRecognizer:doubleTap];
    [doubleTap release];
    
    // single tap
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                action:@selector(singleTapHandler:)];
    singleTap.numberOfTapsRequired = 1;
    [self.gestureView addGestureRecognizer:singleTap];
    [singleTap release];
    
    [singleTap requireGestureRecognizerToFail:doubleTap];
    
    // swipe
    UISwipeGestureRecognizer *swipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self
                                                                                action:@selector(swipeHandler:)];
    [self.gestureView addGestureRecognizer:swipe];
    [swipe release];
}

- (EFTabBarItemControl *)_selectedButton {
    return self.buttons[self.tabBarViewController.selectedIndex];
}

- (CGRect)_buttonFrameAtIndex:(NSUInteger)index {
    return (CGRect){{index * (kTabBarButtonSize.width + kButtonSpacing), 0}, kTabBarButtonSize};
}

- (void)_setSelectedIndex:(NSUInteger)index {
    if (self.isButtonsShowed) {
        [self.tabBarViewController setSelectedIndex:index
                                           animated:YES];
        [self _dismissButtonsAnimated:YES];
    } else if (index != self.tabBarViewController.selectedIndex) {
        EFTabBarItemControl *preButton = [self _selectedButton];
        
        [self.tabBarViewController setSelectedIndex:index
                                           animated:YES];
        
        // Destination frame
        CGRect destinationFrame = self.buttonBaseView.frame;
        destinationFrame.origin = (CGPoint){CGRectGetWidth(self.frame), CGRectGetHeight(self.frame) - kTabBarButtonSize.height};
        
        CGRect shadowFrame = self.shadowImageView.frame;
        CGPoint offset = (CGPoint){CGRectGetMinX(destinationFrame) - CGRectGetMinX(self.buttonBaseView.frame), CGRectGetMinY(destinationFrame) - CGRectGetMinY(self.buttonBaseView.frame)};
        shadowFrame.origin.x += offset.x;    // (offset.x - kTabBarButtonSize.width);
        shadowFrame.origin.y += offset.y;
        
        // mask animation
        CGPoint startPoint = (CGPoint){CGRectGetWidth(self.frame), CGRectGetHeight(self.bounds)};
        CGPoint endPoint = (CGPoint){startPoint.x - 122.0f, floor(CGRectGetHeight(self.bounds) - 20.0f)};
        
        CGPathRef maskPath = CreateMaskPath(self.bounds, startPoint, endPoint);
        
        CGRect largerRect = CGRectMake(self.bounds.origin.x,
                                       self.bounds.origin.y,
                                       self.bounds.size.width,
                                       self.bounds.size.height + kInnserShadowRadius);
        CGPoint largerStartPoint = (CGPoint){startPoint.x, startPoint.y + kInnserShadowRadius};
        CGPoint largerEndPoint = (CGPoint){endPoint.x, endPoint.y + kInnserShadowRadius};
        
        CGMutablePathRef shadowPath = CreateMaskPath(largerRect, largerStartPoint, largerEndPoint);
        CGPathAddPath(shadowPath, NULL, maskPath);
        CGPathCloseSubpath(shadowPath);
        
        [self.backgroundView dismissButtonWithMaskPath:maskPath
                                       innerShadowPath:shadowPath
                                              animated:YES];
        
        CABasicAnimation *shadowAnimation = [CABasicAnimation animationWithKeyPath:@"path"];
        shadowAnimation.duration = 0.233f;
        shadowAnimation.fromValue = (id)self.outerShadowLayer.path;
        shadowAnimation.toValue = (id)maskPath;
        shadowAnimation.fillMode = kCAFillModeForwards;
        shadowAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        
        [self.outerShadowLayer addAnimation:shadowAnimation forKey:@"shadowAnimation"];
        self.outerShadowLayer.path = maskPath;
        
        CGPathRelease(maskPath);
        CGPathRelease(shadowPath);
        
        // selected button animation
        CGRect preButtonFrame = preButton.frame;
        preButtonFrame = [self.buttonBaseView convertRect:preButtonFrame fromView:self];
        [preButton removeFromSuperview];
        preButton.frame = preButtonFrame;
        [self.buttonBaseView addSubview:preButton];
        
        EFTabBarItemControl *selectedButton = [self _selectedButton];
        CGRect frame = selectedButton.frame;
        frame = [self.buttonBaseView convertRect:frame toView:self];
        [selectedButton removeFromSuperview];
        selectedButton.frame = frame;
        [self addSubview:selectedButton];
        
        [UIView animateWithDuration:0.233f
                              delay:0.0f
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             CGRect frame = selectedButton.frame;
                             frame.origin = (CGPoint){CGRectGetWidth(self.frame) - kTabBarButtonSize.width, CGRectGetHeight(self.frame) - kTabBarButtonSize.height};
                             selectedButton.frame = frame;
                             
                             CGRect preFrame = [self _buttonFrameAtIndex:[self.buttons indexOfObject:preButton]];
                             preButton.frame = preFrame;
                         }
                         completion:^(BOOL finished){
                         }];
        
        // buttons animation
        [UIView animateWithDuration:0.233f
                         animations:^{
                             self.buttonBaseView.frame = destinationFrame;
                             self.shadowImageView.frame = shadowFrame;
                         }
                         completion:^(BOOL finished){
                         }];
    }
}

- (void)_changeTitleFrameAimated:(BOOL)animated {
    // resize frame
    CGRect viewFrame = CGRectZero;
    CGRect leftButtonFrame = CGRectZero;
    
    if (kEFTabBarStyleDoubleHeight == self.tabBarStyle) {
        viewFrame = kDoubleheightStyleFrame;
        leftButtonFrame = kButtonDoubleheightStyleFrame;
        self.titleLabel.numberOfLines = 2;
    } else {
        viewFrame = kNormalStyleFrame;
        leftButtonFrame = kButtonNormalStyleFrame;
        self.titleLabel.numberOfLines = 1;
    }
    
    CGSize titleLabelSize = (CGSize){CGRectGetWidth(viewFrame) - kTitleEdgeBlank * 2, 1000};
    NSString *text = self.titleLabel.text;
    
    titleLabelSize = [text sizeWithFont:self.titleLabel.font
                      constrainedToSize:titleLabelSize
                          lineBreakMode:self.titleLabel.lineBreakMode];
    titleLabelSize.width = CGRectGetWidth(viewFrame) - kTitleEdgeBlank * 2;
    
    [UIView setAnimationsEnabled:animated];
    [UIView animateWithDuration:0.233f
                     animations:^{
                         self.frame = viewFrame;
                         self.leftButton.frame = leftButtonFrame;
                         self.titleLabel.frame = (CGRect){{kTitleEdgeBlank, floor((CGRectGetHeight(viewFrame) - 20.0f - titleLabelSize.height) * 0.5f)}, titleLabelSize};
                     }
                     completion:^(BOOL finished){
                         [UIView setAnimationsEnabled:YES];
                     }];
}

- (void)_addMaskWindow {
    CGRect frame = [UIScreen mainScreen].bounds;
    frame = CGRectOffset(frame, 0.0f, CGRectGetHeight(self.bounds) + CGRectGetHeight([UIApplication sharedApplication].statusBarFrame));
    
    if (!self.window) {
        UIWindow *window = [[[UIWindow alloc] initWithFrame:frame] autorelease];
        window.backgroundColor = [UIColor clearColor];
        
        UITapGestureRecognizer *windowTap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                    action:@selector(windowTapHandler:)];
        [window addGestureRecognizer:windowTap];
        [windowTap release];
        
        UIPanGestureRecognizer *windowPan = [[UIPanGestureRecognizer alloc] initWithTarget:self
                                                                                          action:@selector(windowPanHandler:)];
        [window addGestureRecognizer:windowPan];
        [windowPan release];
        
        self.window = window;
    }
    
    self.window.frame = frame;
    self.originWindow = [UIApplication sharedApplication].keyWindow;
    [self.window makeKeyAndVisible];
}

- (void)_removeMaskWindow {
    if (!self.window.hidden) {
        self.window.hidden = YES;
        [self.originWindow makeKeyAndVisible];
    }
}

@end
