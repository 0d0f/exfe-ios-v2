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
#define kTabBarButtonSize               ((CGSize){44.0f, 44.0f})
#define kButtonSpacing                  (16.0f)

#define kNormalStyleFrame               ((CGRect){{0.0f, 0.0f}, {320.0f, 70.0f}})
#define kDoubleheightStyleFrame         ((CGRect){{0.0f, 0.0f}, {320.0f, 100.0f}})

#define kButtonNormalStyleFrame         ((CGRect){{0.0f, 3.0f}, {44.0f, 44.0f}})
#define kButtonDoubleheightStyleFrame   ((CGRect){{0.0f, 18.0f}, {44.0f, 44.0f}})

#define kDefaultBackgroundImage [UIImage imageNamed:@"x_titlebg_default.jpg"]

#pragma mark - EFTabBarBackgroundView

inline static CGPathRef CreateMaskPath(CGRect viewBounds, CGPoint startPoint, CGPoint endPoint) {
    CGPoint controlPoint1 = (CGPoint){startPoint.x - 47.0f, startPoint.y};
    CGPoint controlPoint2 = (CGPoint){endPoint.x + 75.0f, endPoint.y};
    
    CGMutablePathRef maskPath = CGPathCreateMutable();
    CGPathMoveToPoint(maskPath, NULL, 0.0f, 0.0f);
    CGPathAddLineToPoint(maskPath, NULL, CGRectGetWidth(viewBounds), 0.0f);
    CGPathAddLineToPoint(maskPath, NULL, CGRectGetWidth(viewBounds), CGRectGetHeight(viewBounds));
    CGPathAddLineToPoint(maskPath, NULL, startPoint.x, startPoint.y);
    CGPathAddCurveToPoint(maskPath, NULL, controlPoint1.x, controlPoint1.y, controlPoint2.x, controlPoint2.y, endPoint.x, endPoint.y);
    CGPathAddLineToPoint(maskPath, NULL, 0.0f, endPoint.y);
    
    return maskPath;
}

@interface EFTabBarBackgroundView : UIView

@property (nonatomic, retain) UIImage *backgroundImage;
@property (nonatomic, retain) CAShapeLayer *maskLayer;

- (void)showButtonWithPath:(CGPathRef)maskPath;
- (void)dismissButtonWithPath:(CGPathRef)maskPath;

@end

@implementation EFTabBarBackgroundView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        CAShapeLayer *maskLayer = [CAShapeLayer layer];
        maskLayer.fillRule = kCAFillRuleEvenOdd;
        self.maskLayer = maskLayer;
        self.layer.mask = maskLayer;
    }
    
    return self;
}

- (void)dealloc {
    [_maskLayer release];
    [_backgroundImage release];
    [super dealloc];
}

- (void)showButtonWithPath:(CGPathRef)maskPath {
    // mask animation
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"path"];
    animation.duration = 0.233f;
    animation.fromValue = (id)self.maskLayer.path;
    animation.toValue = (id)maskPath;
    animation.fillMode = kCAFillModeForwards;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    animation.removedOnCompletion = NO;
    
    [self.maskLayer addAnimation:animation forKey:@"maskAnimation"];
    self.maskLayer.path = maskPath;
}

- (void)dismissButtonWithPath:(CGPathRef)maskPath {
    // mask animation
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"path"];
    animation.duration = 0.233f;
    animation.fromValue = (id)self.maskLayer.path;
    animation.toValue = (id)maskPath;
    animation.fillMode = kCAFillModeForwards;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    animation.removedOnCompletion = NO;
    
    [self.maskLayer addAnimation:animation forKey:@"maskAnimation"];
    self.maskLayer.path = maskPath;
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
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    
    CGRect imageRect = kDoubleheightStyleFrame;
    CGSize imageSize = self.backgroundImage.size;
    imageRect.size.height = ceil(CGRectGetWidth(imageRect) * imageSize.height / imageSize.width);
    imageRect.origin.y = CGRectGetHeight(kDoubleheightStyleFrame) - CGRectGetHeight(imageRect);
    [self.backgroundImage drawInRect:imageRect];
    
    CGContextRestoreGState(context);
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
@property (nonatomic, assign) NSUInteger preSelectedIndex;
@property (nonatomic, assign) EFTabBarItemState preSelectedTabBarItemState;
@property (nonatomic, retain) UIView *gestureView;
@end

@interface EFTabBar (Private)
- (void)_resetButtons;
- (void)_layoutButtons;
- (void)_showButtonsAnimated:(BOOL)animated;
- (void)_dismissButtonsAnimated:(BOOL)animated;
- (void)_addGestureRecognizers;
- (EFTabBarItemControl *)_selectedButton;
- (CGRect)_buttonFrameAtIndex:(NSUInteger)index;
- (void)_setSelectedIndex:(NSUInteger)index;
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
        
        // backgroundView
        _backgroundView = [[EFTabBarBackgroundView alloc] initWithFrame:kDoubleheightStyleFrame];
        _backgroundView.backgroundImage = self.backgroundImage;
        [self insertSubview:_backgroundView atIndex:0];
        
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
        [self addSubview:shadowImageView];
        self.shadowImageView = shadowImageView;
        [shadowImageView release];
        
        // gesture
        [self _addGestureRecognizers];
        
        // other default values
        self.isButtonsShowed = NO;
        
        self.tabBarStyle = style;
    }
    return self;
}

- (void)dealloc {
    self.tabBarViewController = nil;
    [_gestureView release];
    [_backgroundView release];
    [_buttons release];
    [_leftButton release];
    [_titleLabel release];
    [super dealloc];
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
    
    // resize frame
    CGRect viewFrame = CGRectZero;
    CGRect leftButtonFrame = CGRectZero;
    
    if (kEFTabBarStyleDoubleHeight == tabBarStyle) {
        viewFrame = kDoubleheightStyleFrame;
        leftButtonFrame = kButtonDoubleheightStyleFrame;
        self.titleLabel.numberOfLines = 2;
    } else {
        viewFrame = kNormalStyleFrame;
        leftButtonFrame = kButtonNormalStyleFrame;
        self.titleLabel.numberOfLines = 1;
    }
    
    // resize label frame
    CGSize titleLabelSize = (CGSize){CGRectGetWidth(viewFrame) - kTitleEdgeBlank * 2, 1000};
    titleLabelSize = [self.titleLabel.text sizeWithFont:self.titleLabel.font
                                      constrainedToSize:titleLabelSize
                                          lineBreakMode:self.titleLabel.lineBreakMode];
    titleLabelSize.width = CGRectGetWidth(viewFrame) - kTitleEdgeBlank * 2;
    
    [UIView animateWithDuration:0.233f
                     animations:^{
                         self.frame = viewFrame;
                         self.leftButton.frame = leftButtonFrame;
                         self.titleLabel.frame = (CGRect){{kTitleEdgeBlank, floor((CGRectGetHeight(viewFrame) - 20.0f - titleLabelSize.height) * 0.5f)}, titleLabelSize};
                     }];
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

- (void)swipeHandler:(UISwipeGestureRecognizer *)gesture {
    if (UIGestureRecognizerStateEnded == gesture.state) {
        if (UISwipeGestureRecognizerDirectionRight == gesture.direction) {
            [self _back];
        }
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
    [self.backgroundView showButtonWithPath:maskPath];
    CGPathRelease(maskPath);
    
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
}

- (void)_dismissButtonsAnimated:(BOOL)animated {
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
    [self.backgroundView dismissButtonWithPath:maskPath];
    CGPathRelease(maskPath);
    
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
        [self.backgroundView dismissButtonWithPath:maskPath];
        CGPathRelease(maskPath);
        
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

@end
