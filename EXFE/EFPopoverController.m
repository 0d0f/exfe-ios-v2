//
//  EFPopoverController.m
//  EFFE
//
//  Created by 0day on 13-4-4.
//
//

#import "EFPopoverController.h"

#import "AppDelegate.h"
#import "Util.h"

#define kMinEdgeDistance    (10.0f)


@interface EFPopoverController ()
@property (nonatomic, retain) UIWindow *innerWindow;
@property (nonatomic, assign) UIWindow *originWindow;
@end

@implementation EFPopoverController {
    struct {
        BOOL isPresnted;
    }_flags;

}

- (id)initWithContentViewController:(UIViewController *)controller {
    self = [super init];
    if (self) {
        self.contentViewController = controller;
        _backgroundArrowView = [[EFArrowView alloc] initWithFrame:CGRectZero];
        _backgroundArrowView.gradientColors = @[(id)[UIColor COLOR_RGBA(0xFF, 0xFF, 0xFF, 245.0f)].CGColor, (id)[UIColor COLOR_RGBA(0xEA, 0xEA, 0xEA, 245.0f)].CGColor];
        _backgroundArrowView.alpha = 0.96f;
    }
    
    return self;
}

- (void)dealloc {
    [_backgroundArrowView release];
    [_contentViewController release];
    [super dealloc];
}

- (void)setContentSize:(CGSize)contentSize {
    [self setContentSize:contentSize animated:NO];
}

- (void)presentFromRect:(CGRect)rect inView:(UIView *)view arrowDirection:(EFArrowDirection)direction animated:(BOOL)animated complete:(void (^)(void))handler {
    if (_flags.isPresnted)
        return;
    _flags.isPresnted = YES;
    
    [self retain];
    
    // cache origin window
    self.originWindow = ((AppDelegate *)[UIApplication sharedApplication].delegate).window;
    
    // init new window
    CGRect screenBounds = [UIScreen mainScreen].bounds;
    UIWindow *innerWindow = [[UIWindow alloc] initWithFrame:screenBounds];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                          action:@selector(tapHandler:)];
    tap.delegate = self;
    [innerWindow addGestureRecognizer:tap];
    [tap release];
    self.innerWindow = innerWindow;
    [innerWindow release];
    
    // convert frame
    rect = [view convertRect:rect toView:self.originWindow];
    
    self.contentViewController.view.frame = (CGRect){{0, 0}, _contentSize};
    CGRect viewFrame = self.contentViewController.view.frame;
    
    CGFloat maxViewWidth = _contentSize.width + 2 * kMinEdgeDistance;
    CGFloat maxViewHeight = _contentSize.height + 2 * kMinEdgeDistance;
    CGFloat halfMaxViewWidth = 0.5f * maxViewWidth;
    CGFloat halfMaxViewHeight = 0.5f * maxViewHeight;
    
    CGRect containViewFrame = view.frame;
    CGPoint arrowPoint = CGPointZero;
    EFArrowDirection finalArrowDirection = kEFArrowDirectionUnknow;
    
    if (direction & kEFArrowDirectionDown) {
        arrowPoint = (CGPoint){CGRectGetMidX(rect), CGRectGetMinY(rect)};
        CGFloat y = arrowPoint.y - (maxViewHeight + CGRectGetMinY(view.frame));
        if (y >= 0.0f) {
            finalArrowDirection = kEFArrowDirectionDown;
            
            y += kMinEdgeDistance;
            
            CGFloat x = arrowPoint.x - halfMaxViewWidth;
            if (x <= 0) {
                x = kMinEdgeDistance;
            } else if (x + maxViewWidth > CGRectGetWidth(screenBounds)) {
                x = CGRectGetWidth(screenBounds) - maxViewWidth + kMinEdgeDistance;
            } else {
                x += kMinEdgeDistance;
            }
            
            y += CGRectGetMinY(view.frame);
            
            viewFrame.origin = (CGPoint){x, y};
        }
    }
    
    if ((direction & kEFArrowDirectionUp) && (kEFArrowDirectionUnknow == finalArrowDirection)) {
        arrowPoint = (CGPoint){CGRectGetMidX(rect), CGRectGetMaxY(rect)};
        CGFloat height = arrowPoint.y + maxViewHeight;
        CGFloat y = arrowPoint.y;
        if (height <= CGRectGetMaxY(containViewFrame)) {
            finalArrowDirection = kEFArrowDirectionUp;
            
            y -= kMinEdgeDistance;
            
            CGFloat x = arrowPoint.x - halfMaxViewWidth;
            if (x <= 0) {
                x = kMinEdgeDistance;
            } else if (x + maxViewWidth > CGRectGetWidth(screenBounds)) {
                x = CGRectGetWidth(screenBounds) - maxViewWidth + kMinEdgeDistance;
            } else {
                x += kMinEdgeDistance;
            }
            
            viewFrame.origin = (CGPoint){x, y};
        }
    }
    
    if ((direction & kEFArrowDirectionRight) && kEFArrowDirectionUnknow == finalArrowDirection) {
        arrowPoint = (CGPoint){CGRectGetMinX(rect), CGRectGetMidY(rect)};
        CGFloat x = arrowPoint.x - maxViewWidth;
        if (x >= 0) {
            finalArrowDirection = kEFArrowDirectionRight;
            
            CGFloat y = arrowPoint.y - halfMaxViewHeight;
            if (y <= 0) {
                y = 0;
            } else if (y + maxViewHeight > CGRectGetHeight(screenBounds)) {
                y = 2 * y - CGRectGetHeight(screenBounds) + maxViewHeight;
            }
            
            viewFrame.origin = (CGPoint){x + kMinEdgeDistance, y + kMinEdgeDistance};
        }
    }
    
    if ((direction & kEFArrowDirectionLeft) && kEFArrowDirectionUnknow == finalArrowDirection) {
        arrowPoint = (CGPoint){CGRectGetMaxX(rect), CGRectGetMidY(rect)};
        CGFloat x = arrowPoint.x - maxViewWidth;
        if (x >= 0) {
            finalArrowDirection = kEFArrowDirectionLeft;
            
            CGFloat y = arrowPoint.y - halfMaxViewHeight;
            if (y <= 0) {
                y = 0;
            } else if (y + maxViewHeight > CGRectGetHeight(screenBounds)) {
                y = 2 * y - CGRectGetHeight(screenBounds) + maxViewHeight;
            }
            
            viewFrame.origin = (CGPoint){x + kMinEdgeDistance, y + kMinEdgeDistance};
        }
    }
    
    CGRect bgFrame = viewFrame;
    bgFrame.origin.x -= kMinEdgeDistance;
    bgFrame.origin.y -= kMinEdgeDistance;
    bgFrame.size.width += kMinEdgeDistance * 2;
    bgFrame.size.height += kMinEdgeDistance * 2;
    
    _backgroundArrowView.frame = bgFrame;
    [_backgroundArrowView setPointPosition:(CGPoint){arrowPoint.x - CGRectGetMinX(bgFrame), arrowPoint.y - CGRectGetMinY(bgFrame)} andArrowDirection:finalArrowDirection];
    [_backgroundArrowView setNeedsDisplay];
    
    self.contentViewController.view.frame = (CGRect){{kMinEdgeDistance, kMinEdgeDistance}, viewFrame.size};
    [_backgroundArrowView addSubview:self.contentViewController.view];
    
    _backgroundArrowView.alpha = 0.0f;
    
    [self.innerWindow addSubview:_backgroundArrowView];
    [self.innerWindow makeKeyAndVisible];
    
    [UIView setAnimationsEnabled:animated];
    [UIView animateWithDuration:0.25f
                     animations:^{
                         self.backgroundArrowView.alpha = 1.0f;
                     }
                     completion:^(BOOL finished){
                         [UIView setAnimationsEnabled:YES];
                         if (handler)
                             handler();
                     }];

}

- (void)dismissWithAnimated:(BOOL)animated complete:(void (^)(void))handler {
    if (!_flags.isPresnted)
        return;
    _flags.isPresnted = NO;
    
    [UIView setAnimationsEnabled:animated];
    [UIView animateWithDuration:0.25f
                     animations:^{
                         self.backgroundArrowView.alpha = 0.0f;
                     }
                     completion:^(BOOL finished){
                         [UIView setAnimationsEnabled:YES];
                         [self.contentViewController.view removeFromSuperview];
                         [self.backgroundArrowView removeFromSuperview];
                         
                         [self.originWindow makeKeyAndVisible];
                         self.innerWindow.hidden = YES;
                         
                         self.innerWindow = nil;
                         
                         if (handler)
                             handler();
                         
                         [self release];
                     }];

}

- (void)setContentSize:(CGSize)contentSize animated:(BOOL)animated {
    _contentSize = contentSize;
}

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    CGPoint location = [gestureRecognizer locationInView:self.backgroundArrowView];
    if (CGRectContainsPoint(self.backgroundArrowView.bounds, location))
        return NO;
    return YES;
}

#pragma mark - Gesture
- (void)tapHandler:(UITapGestureRecognizer *)gesture {
    [self dismissWithAnimated:YES complete:nil];
}

@end
