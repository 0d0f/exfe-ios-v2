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

@property (nonatomic, strong) UIImage *backgroundImage;

@property (nonatomic, strong) CAShapeLayer *maskLayer;

- (void)showButtonWithMaskPath:(CGPathRef)maskPath animated:(BOOL)animated;
- (void)dismissButtonWithMaskPath:(CGPathRef)maskPath animated:(BOOL)animated;

@end

@implementation EFTabBarBackgroundView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        CAShapeLayer *maskLayer = [CAShapeLayer layer];
        maskLayer.fillRule = kCAFillRuleEvenOdd;
        self.layer.mask = maskLayer;
        
        self.maskLayer = maskLayer;
    }
    
    return self;
}


- (void)showButtonWithMaskPath:(CGPathRef)maskPath animated:(BOOL)animated {
    if (animated) {
        // mask animation
        CABasicAnimation *maskAnimation = [CABasicAnimation animationWithKeyPath:@"path"];
        maskAnimation.duration = 0.233f;
        maskAnimation.fromValue = (id)self.maskLayer.path;
        maskAnimation.toValue = (__bridge id)maskPath;
        maskAnimation.fillMode = kCAFillModeForwards;
        maskAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        
        [self.maskLayer addAnimation:maskAnimation forKey:@"maskAnimation"];
    }
    
    self.maskLayer.path = maskPath;
}

- (void)dismissButtonWithMaskPath:(CGPathRef)maskPath animated:(BOOL)animated {
    if (animated) {
        // mask animation
        CABasicAnimation *maskAnimation = [CABasicAnimation animationWithKeyPath:@"path"];
        maskAnimation.duration = 0.233f;
        maskAnimation.fromValue = (id)self.maskLayer.path;
        maskAnimation.toValue = (__bridge id)maskPath;
        maskAnimation.fillMode = kCAFillModeForwards;
        maskAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        
        [self.maskLayer addAnimation:maskAnimation forKey:@"maskAnimation"];
    }
    
    self.maskLayer.path = maskPath;
}

- (void)setBackgroundImage:(UIImage *)backgroundImage {
    if (_backgroundImage == backgroundImage)
        return;
    
    if (_backgroundImage) {
        _backgroundImage = nil;
    }
    if (backgroundImage) {
        _backgroundImage = backgroundImage;
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
@property (nonatomic, strong) UIButton *leftButton;
@property (nonatomic, strong) NSMutableArray *buttons;
@property (nonatomic, weak) EFTabBarItemControl *alertButton;
@property (nonatomic, strong) UIView *buttonBaseView;
@property (nonatomic, assign) BOOL isButtonsShowed;
@property (nonatomic, strong) UIImageView *shadowImageView;
@property (nonatomic, strong) EFTabBarBackgroundView *backgroundView;
@property (nonatomic, assign) NSUInteger preSelectedIndex;
@property (nonatomic, assign) EFTabBarItemState preSelectedTabBarItemState;
@property (nonatomic, strong) UIView *gestureView;
@property (nonatomic, copy) EFTabBarTitlePressedBlock titlePressedBlock;

@property (nonatomic, strong) UIScrollView  *scrollView;
@property (nonatomic, assign) NSUInteger    visibleCount;
@property (nonatomic, strong) UIImageView   *tabBarArrowView;

@property (nonatomic, weak) UIWindow *originWindow;
@property (nonatomic, strong) UIWindow *window;
@end

@interface EFTabBar (Private)
- (void)_resetButtons;
- (void)_showButtonsAnimated:(BOOL)animated;
- (void)_dismissButtonsAnimated:(BOOL)animated;
- (void)_addGestureRecognizers;
- (EFTabBarItemControl *)_selectedButton;
- (CGRect)_buttonFrameAtIndex:(NSInteger)index;
- (void)_setSelectedIndex:(NSUInteger)index;
- (void)_changeTitleFrameAimated:(BOOL)animated;
- (void)_addMaskWindow;
- (void)_removeMaskWindow;
- (void)_layoutMaskAnimated:(BOOL)animated;
- (void)_reorderTabBarItems;
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
        self.clipsToBounds = YES;
        
        // title label
        UILabel *label = [[UILabel alloc] initWithFrame:(CGRect){{kTitleEdgeBlank, floor((CGRectGetHeight(frame) - 20.0f - CGRectGetHeight(frame) + kTabBarItemSize.height) * 0.5f)}, {CGRectGetWidth(frame) - kTitleEdgeBlank * 2, CGRectGetHeight(frame) - kTabBarItemSize.height}}];
        label.textAlignment = NSTextAlignmentCenter;
        label.font = [UIFont fontWithName:@"HelveticaNeue" size:21];
        label.backgroundColor = [UIColor clearColor];
        label.textColor = [UIColor whiteColor];
        label.shadowColor = [UIColor colorWithWhite:0.0f alpha:0.5f];
        label.shadowOffset = (CGSize){0, 1.0f};
        label.numberOfLines = (style == kEFTabBarStyleDoubleHeight) ? 2 : 1;
        label.tag = 0x0101;
        [self addSubview:label];
        _titleLabel = label;
        
        // gesture view
        UIView *gestureView = [[UIView alloc] initWithFrame:(CGRect){{10.0f, 0.0f}, {CGRectGetWidth(frame) - 30.0f, 50.0f}}];
        gestureView.backgroundColor = [UIColor clearColor];
        [self addSubview:gestureView];
        self.gestureView = gestureView;
        
        // default background image
        self.backgroundImage = kDefaultBackgroundImage;
        
        // outer shadow
        UIView *outerShadowView = [[UIView alloc] initWithFrame:frame];
        outerShadowView.backgroundColor = [UIColor clearColor];
        
        [self insertSubview:outerShadowView belowSubview:label];
        
        // backgroundView
        _backgroundView = [[EFTabBarBackgroundView alloc] initWithFrame:kDoubleheightStyleFrame];
        _backgroundView.backgroundImage = self.backgroundImage;
        [self insertSubview:_backgroundView belowSubview:label];
        
        CGPoint startPoint = (CGPoint){CGRectGetWidth(self.frame), CGRectGetHeight(self.bounds)};
        CGPoint endPoint = (CGPoint){startPoint.x - 122.0f, floor(CGRectGetHeight(self.bounds) - 20.0f)};
        CGPathRef maskPath = CreateMaskPath(self.bounds, startPoint, endPoint);
        
        [self.backgroundView showButtonWithMaskPath:maskPath animated:NO];
        
        CGPathRelease(maskPath);
        
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
         forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchDragExit];
        [self addSubview:button];
        self.leftButton = button;
        
        // scroll view
        CGRect scrollViewFrame = (CGRect){{0.0f, CGRectGetHeight(frame) - kTabBarButtonSize.height}, {CGRectGetWidth(frame), kTabBarButtonSize.height}};
        UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:scrollViewFrame];
        scrollView.showsHorizontalScrollIndicator = NO;
        scrollView.showsVerticalScrollIndicator = NO;
        scrollView.backgroundColor = [UIColor clearColor];
        scrollView.delegate = self;
        [self.backgroundView addSubview:scrollView];
        self.scrollView = scrollView;
        
        // button base view
        UIView *baseView = [[UIView alloc] initWithFrame:(CGRect){CGPointZero, kTabBarButtonSize}];
        baseView.backgroundColor = [UIColor clearColor];
        baseView.clipsToBounds = NO;
        [self.scrollView addSubview:baseView];
        self.buttonBaseView = baseView;
        
        // arrow
        UIImageView *arrowView = [[UIImageView alloc] initWithFrame:(CGRect){CGPointZero, {6.0f, 30.0f}}];
        arrowView.image = [UIImage imageNamed:@"tab_tri.png"];
        arrowView.center = (CGPoint){CGRectGetWidth(frame) - 3.0f, CGRectGetMidY(scrollViewFrame)};
        arrowView.alpha = 0.0f;
        [self.backgroundView insertSubview:arrowView atIndex:0];
        self.tabBarArrowView = arrowView;
        
        // shadow
        UIImageView *shadowImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tabshadow_x.png"]];
        shadowImageView.contentMode = UIViewContentModeTopLeft;
        shadowImageView.frame = (CGRect){{0, CGRectGetHeight(frame) - 26}, {640, 44}};
        [self addSubview:shadowImageView];
        self.shadowImageView = shadowImageView;
        
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
    self.tabBarViewController = nil;
    self.tabBarItems = nil;
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (object == self.titleLabel && [keyPath isEqualToString:@"text"]) {
        [self _changeTitleFrameAimated:YES];
    } else if (object == self.tabBarViewController && [keyPath isEqualToString:@"selectedIndex"]) {
        UIViewController<EFTabBarDataSource> *viewController = (UIViewController<EFTabBarDataSource> *)self.tabBarViewController.viewControllers[self.tabBarViewController.selectedIndex];
        self.shadowImageView.image = viewController.shadowImage;
        
        if (!self.isButtonsShowed) {
            for (NSUInteger index = 0; index < self.tabBarItems.count; index++) {
                if (index == self.tabBarViewController.selectedIndex) {
                    UIView *selectedControl = [self.buttons objectAtIndex:self.tabBarViewController.selectedIndex];
                    CGRect frame = (CGRect){{CGRectGetWidth(self.scrollView.frame) - kTabBarButtonSize.width, 0.0f}, selectedControl.frame.size};
                    frame = [self.scrollView convertRect:frame toView:selectedControl.superview];
                    
                    CGPoint center = selectedControl.center;
                    center.x = CGRectGetMidX(frame);
                    selectedControl.center = center;
                } else {
                    UIView *control = [self.buttons objectAtIndex:index];
                    control.frame = [self _buttonFrameAtIndex:index];
                }
            }
        }
    } else if ([object isKindOfClass:[EFTabBarItem class]] && [keyPath isEqualToString:@"shouldPop"]) {
        NSUInteger index = [self.tabBarItems indexOfObject:object];
        NSAssert(index != NSNotFound, @"index shouldn't be NSNotFound");
        EFTabBarItemControl *button = (EFTabBarItemControl *)self.buttons[index];
        
        if (((EFTabBarItem *)object).shouldPop) {
            [self _popButton:button];
        }
    }
}

#pragma mark - Getter && Setter

- (void)setTabBarItems:(NSMutableArray *)tabBarItems {
    if (_tabBarItems == tabBarItems)
        return;
    
    if (_tabBarItems) {
        for (EFTabBarItem *item in _tabBarItems) {
            [item removeObserver:self
                      forKeyPath:@"shouldPop"];
        }
        _tabBarItems = nil;
    }
    
    if (tabBarItems) {
        _tabBarItems = tabBarItems;
        for (EFTabBarItem *item in tabBarItems) {
            [item addObserver:self
                   forKeyPath:@"shouldPop"
                      options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
                      context:NULL];
        }
        
        // resize scrollView content size
        NSUInteger count = tabBarItems.count;
        
        CGSize contentSize = (CGSize){CGRectGetWidth(self.scrollView.frame) + count * (kTabBarButtonSize.width + kButtonSpacing)};
        self.scrollView.contentSize = contentSize;
        
        [self _resetButtons];
        [self _reorderTabBarItems];
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
        _backgroundImage = nil;
    }
    if (backgroundImage) {
        _backgroundImage = backgroundImage;
    }
    
    self.backgroundView.backgroundImage = backgroundImage;
}

- (void)setTabBarViewController:(EFTabBarViewController *)tabBarViewController {
    if (_tabBarViewController == tabBarViewController) {
        return;
    }
    
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

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    // fix content offset
    CGPoint contentOffset = scrollView.contentOffset;
    CGFloat contentOffsetX = contentOffset.x;
    contentOffsetX -= kTabBarButtonSize.width + kButtonSpacing;
    contentOffsetX = contentOffsetX < 0.0f ? 0.0f : contentOffsetX;
    
    // mask
    [self _layoutMaskAnimated:NO];
    
    // selected control center
    UIView *selectedControl = [self.buttons objectAtIndex:self.tabBarViewController.selectedIndex];
    CGFloat contentOffsetX2 = contentOffset.x;
    contentOffsetX2  = contentOffsetX2 < 0.0f ? 0.0f : contentOffsetX2;
    NSUInteger index = (NSUInteger)floor(contentOffsetX2 / (kTabBarButtonSize.width + kButtonSpacing));
    
    if (index <= self.self.tabBarViewController.selectedIndex) {
        CGRect frame = (CGRect){{CGRectGetWidth(self.scrollView.frame) - kTabBarButtonSize.width + contentOffset.x, 0.0f}, selectedControl.frame.size};
        frame = [self.scrollView convertRect:frame toView:selectedControl.superview];
        
        CGPoint center = selectedControl.center;
        center.x = CGRectGetMidX(frame);
        selectedControl.center = center;
    } else {
        CGRect frame = [self _buttonFrameAtIndex:self.tabBarViewController.selectedIndex];
        CGPoint center = (CGPoint){CGRectGetMidX(frame), CGRectGetMidY(frame)};
        selectedControl.center = center;
        
        if (self.visibleCount < self.tabBarItems.count) {
            if (index <= self.visibleCount) {
                CGFloat alpha = contentOffsetX / (self.visibleCount * (kTabBarButtonSize.width + kButtonSpacing));
                self.tabBarArrowView.alpha = alpha;
            } else {
                if (contentOffset.x < CGRectGetWidth(self.buttonBaseView.frame) - (kTabBarButtonSize.width + kButtonSpacing)) {
                    self.tabBarArrowView.alpha = 1.0f;
                } else {
                    self.tabBarArrowView.alpha = 0.0f;
                }
            }
        }
    }
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    if (velocity.x <= 0) {
        [self _dismissButtonsAnimated:YES];
    } else {
        [self _showButtonsAnimated:YES];
    }
}

#pragma mark - Action

- (void)buttonPressed:(EFTabBarItemControl *)sender {
    NSUInteger index = [self.buttons indexOfObject:sender];
    
    if (sender.tabBarItem.shouldPop) {
        [self _setSelectedIndex:index];
    } else {
        if (self.isButtonsShowed) {
            sender.tabBarItem.tabBarItemLevel = kEFTabBarItemLevelNormal;
            [self _setSelectedIndex:index];
            [self _reorderTabBarItems];
        } else {
            [self _showButtonsAnimated:YES];
        }
    }
}

- (void)backButtonPressed:(UIButton *)sender {
    [self _back];
}

- (void)_back {
    self.scrollView.delegate = nil;
    
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
    self.tabBarViewController = nil;
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

- (void)_popButton:(EFTabBarItemControl *)button {
    if (!self.isButtonsShowed) {
        [self _dismissButtonsAnimated:YES];
    }
}

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
    baseViewFrame.origin.x = CGRectGetWidth(self.scrollView.frame) - (kTabBarButtonSize.width + kButtonSpacing);
    baseViewFrame.size.width = (count + 1) * (kTabBarButtonSize.width + kButtonSpacing);
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
                NSUInteger nextIndex = (self.tabBarViewController.selectedIndex + 1) % self.visibleCount;
                [self _setSelectedIndex:nextIndex];
            } else if (UISwipeGestureRecognizerDirectionRight) {
                NSInteger nextIndex = self.tabBarViewController.selectedIndex - 1;
                if (nextIndex < 0) {
                    nextIndex = self.visibleCount - 1;
                }
                [self _setSelectedIndex:nextIndex];
            }
        };
        
        button.tabBarItemTitleDidChangeHandler = ^(EFTabBarItemControl *control){
            if (control.tabBarItem.title.length) {
                [self _popButton:control];
            }
        };
        
        button.frame = [self _buttonFrameAtIndex:i];
        [self.buttonBaseView addSubview:button];
        
        
        [buttons addObject:button];
        i++;
    }
    
    self.buttons = buttons;
}

- (void)_showButtonsAnimated:(BOOL)animated {
    [self _removeMaskWindow];
    
    if (!self.isButtonsShowed) {
        // cache index & state
        self.preSelectedIndex = self.tabBarViewController.selectedIndex;
        self.preSelectedTabBarItemState = self.tabBarViewController.selectedViewController.customTabBarItem.tabBarItemState;
    }
    
    self.isButtonsShowed = YES;
    self.gestureView.userInteractionEnabled = NO;
    self.scrollView.scrollEnabled = YES;
    self.tabBarArrowView.hidden = NO;
    
    // disable the contol swipe
    for (EFTabBarItemControl *button in self.buttons) {
        button.swipeEnable = NO;
    }
    
    // highlight selected one
    self.tabBarViewController.selectedViewController.customTabBarItem.tabBarItemState = kEFTabBarItemStateHighlight;
    
    // Change Offset
    [self.scrollView setContentOffset:(CGPoint){self.visibleCount * (kTabBarButtonSize.width + kButtonSpacing), 0.0f} animated:animated];
    
    [self _addMaskWindow];
}

- (void)_dismissButtonsAnimated:(BOOL)animated {
    [self _removeMaskWindow];
    self.gestureView.userInteractionEnabled = YES;
    self.scrollView.scrollEnabled = NO;
    self.tabBarArrowView.hidden = YES;
    
    CGPoint contetOffset = self.scrollView.contentOffset;
    
    ((UIViewController<EFTabBarDataSource> *)(self.tabBarViewController.viewControllers[self.preSelectedIndex])).customTabBarItem.tabBarItemState = self.preSelectedTabBarItemState;
    
    // enable the contol swipe
    for (EFTabBarItemControl *button in self.buttons) {
        button.swipeEnable = YES;
    }
    
    // destination frame
    CGRect scrollViewDestinationFrame = self.scrollView.frame;
    scrollViewDestinationFrame.origin.y = CGRectGetHeight(self.frame) - kTabBarButtonSize.height;
    
    __weak typeof(self) weakSelf = self;
    void (^animationBlock)(void) = ^{
        weakSelf.scrollView.frame = scrollViewDestinationFrame;
    };
    
    if (animated) {
        [UIView animateWithDuration:0.233f
                         animations:animationBlock];
    } else {
        animationBlock();
    }
    
    // tabBar arrow
    CGPoint tabBarArrowCenter = self.tabBarArrowView.center;
    tabBarArrowCenter.y = CGRectGetMidY(self.scrollView.frame);
    self.tabBarArrowView.center = tabBarArrowCenter;
    
    // change content offset
    [self.scrollView setContentOffset:CGPointZero animated:animated];
    
    if (contetOffset.x == 0) {
        // layout when swipe occurs.
        [self _layoutMaskAnimated:animated];
    }
    
    self.isButtonsShowed = NO;
}

- (void)_addGestureRecognizers {
    // double tap
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                action:@selector(doubleTapHandler:)];
    doubleTap.numberOfTapsRequired = 2;
    [self.gestureView addGestureRecognizer:doubleTap];
    
    // single tap
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                action:@selector(singleTapHandler:)];
    singleTap.numberOfTapsRequired = 1;
    [self.gestureView addGestureRecognizer:singleTap];
    
    [singleTap requireGestureRecognizerToFail:doubleTap];
    
    // swipe
    UISwipeGestureRecognizer *swipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self
                                                                                action:@selector(swipeHandler:)];
    [self.gestureView addGestureRecognizer:swipe];
}

- (EFTabBarItemControl *)_selectedButton {
    return self.buttons[self.tabBarViewController.selectedIndex];
}

- (CGRect)_buttonFrameAtIndex:(NSInteger)index {
    return (CGRect){{(index + 1) * (kTabBarButtonSize.width + kButtonSpacing) + kButtonSpacing, 0}, kTabBarButtonSize};
}

- (void)_setSelectedIndex:(NSUInteger)index {
    if (index != self.tabBarViewController.selectedIndex) {
        self.shadowImageView.alpha = 0.0f;
        [UIView animateWithDuration:0.233f
                         animations:^{
                             self.shadowImageView.alpha = 1.0f;
                         } completion:^(BOOL finished){
                         }];
    }
    
    [self.tabBarViewController setSelectedIndex:index
                                       animated:YES];
    [self _dismissButtonsAnimated:YES];
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
        UIWindow *window = [[UIWindow alloc] initWithFrame:frame];
        window.backgroundColor = [UIColor clearColor];
        
        UITapGestureRecognizer *windowTap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                    action:@selector(windowTapHandler:)];
        [window addGestureRecognizer:windowTap];
        
        UIPanGestureRecognizer *windowPan = [[UIPanGestureRecognizer alloc] initWithTarget:self
                                                                                          action:@selector(windowPanHandler:)];
        [window addGestureRecognizer:windowPan];
        
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

- (void)_layoutMaskAnimated:(BOOL)animated {
    CGPoint contentOffset = self.scrollView.contentOffset;
    CGFloat contentOffsetX = contentOffset.x;
    contentOffsetX -= kTabBarButtonSize.width + kButtonSpacing;
    contentOffsetX = contentOffsetX < 0.0f ? 0.0f : contentOffsetX;
    
    // mask animation
    CGPoint startPoint = (CGPoint){CGRectGetWidth(self.frame) - contentOffsetX, CGRectGetHeight(self.bounds)};
    CGPoint endPoint = (CGPoint){startPoint.x - 122.0f, floor(CGRectGetHeight(self.bounds) - 20.0f)};
    
    CGPathRef maskPath = CreateMaskPath(self.bounds, startPoint, endPoint);
    
    [self.backgroundView showButtonWithMaskPath:maskPath animated:animated];
    
    CGPathRelease(maskPath);
    
    // shadow image view
    CGRect shadowFrame = self.shadowImageView.frame;
    shadowFrame.origin = (CGPoint){-contentOffsetX, CGRectGetHeight(self.frame) - 26.0f};
    __weak typeof (self) weakSelf = self;
    
    void (^animation)(void) = ^{
        weakSelf.shadowImageView.frame = shadowFrame;
    };
    
    if (animated) {
        [UIView animateWithDuration:0.233f
                         animations:animation];
    } else {
        animation();
    }
}

- (void)_reorderTabBarItems {
    NSMutableArray *visibleTabBarItems = [[NSMutableArray alloc] init];
    NSMutableArray *hidenTabBarItems = [[NSMutableArray alloc] init];
    
    EFTabBarItem *defaultTabBarItem = nil;
    
    for (int index = 0; index < self.tabBarItems.count; index++) {
        EFTabBarItem *item = self.tabBarItems[index];
        if (kEFTabBarItemLevelNormal == item.tabBarItemLevel) {
            [visibleTabBarItems addObject:item];
        } else if (kEFTabBarItemLevelLow == item.tabBarItemLevel) {
            [hidenTabBarItems addObject:item];
        } else {
            defaultTabBarItem = item;
            [visibleTabBarItems addObject:item];
        }
    }
    
    [self.tabBarItems removeAllObjects];
    [self.tabBarItems addObjectsFromArray:visibleTabBarItems];
    [self.tabBarItems addObjectsFromArray:hidenTabBarItems];
    
    self.visibleCount = visibleTabBarItems.count;
    
    for (NSUInteger index = 0; index < self.tabBarItems.count; index++) {
        UIViewController<EFTabBarDataSource> *viewController = self.tabBarViewController.viewControllers[index];
        EFTabBarItem *orderedTabBarItem = self.tabBarItems[index];
        
        if (orderedTabBarItem != viewController.customTabBarItem) {
            NSUInteger j = 0;
            for (j = index + 1; j < self.tabBarViewController.viewControllers.count; j++) {
                UIViewController<EFTabBarDataSource> *viewController2 = self.tabBarViewController.viewControllers[index];
                if (orderedTabBarItem == viewController2.customTabBarItem) {
                    break;
                }
            }
            
            [self.tabBarViewController exchangeViewControllerAtIndex:index withViewControllerAtIndex:j];
        }
    }
    
    if (defaultTabBarItem) {
        NSUInteger defaultIndex = [self.tabBarItems indexOfObject:defaultTabBarItem];
        self.tabBarViewController.defaultIndex = defaultIndex;
    } else {
        self.tabBarViewController.defaultIndex = 0;
    }
}

@end
