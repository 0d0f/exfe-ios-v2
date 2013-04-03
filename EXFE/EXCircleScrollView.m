//
//  EXCircleScrollView.m
//  EXFE
//
//  Created by 0day on 13-4-1.
//
//

#import "EXCircleScrollView.h"

@interface EXCircleScrollView ()
- (void)_layout;
- (void)_panEndHandler;
@end

@implementation EXCircleScrollView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self
                                                                              action:@selector(pangeHandler:)];
        pan.delegate = self;
        [self addGestureRecognizer:pan];
        [pan release];
        
        [self addObserver:self
               forKeyPath:@"frame"
                  options:NSKeyValueObservingOptionNew
                  context:nil];
        [self addObserver:self
               forKeyPath:@"pageHorizontalOffset"
                  options:NSKeyValueObservingOptionNew
                  context:nil];
    }
    return self;
}

- (void)dealloc {
    [_backgroundView release];
    [self removeObserver:self
              forKeyPath:@"frame"];
    [self removeObserver:self
              forKeyPath:@"pageHorizontalOffset"];
    [super dealloc];
}

- (void)layoutSubviews {
    if (self.backgroundView) {
        CGRect bgViewFrame = self.bounds;
        bgViewFrame.origin.x = self.pageHorizontalOffset;
        self.backgroundView.frame = bgViewFrame;
    }
}

#pragma mark - KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (object == self) {
        if ([keyPath isEqualToString:@"frame"]) {
            if ([_delegate respondsToSelector:@selector(circleViewDidScroll:)]) {
                [_delegate circleViewDidScroll:self];
            }
        } else if ([keyPath isEqualToString:@"pageHorizontalOffset"]) {
            if ([_delegate respondsToSelector:@selector(circleViewDidScroll:)]) {
                [_delegate circleViewDidScroll:self];
            }
        }
    }
}

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if (self.scrollEnable)
        return YES;
    else
        return NO;
}

#pragma mark - Gesture Handler
- (void)pangeHandler:(UIPanGestureRecognizer *)gesture {
    static CGPoint startLocation = {0, 0};
    CGPoint currentLocation = [gesture locationInView:self];
    UIGestureRecognizerState state = gesture.state;
    
    switch (state) {
        case UIGestureRecognizerStateBegan:
        {
            startLocation = currentLocation;
            if ([_delegate respondsToSelector:@selector(circleViewWillScroll:)]) {
                [_delegate circleViewWillScroll:self];
            }
        }
            break;
        case UIGestureRecognizerStateChanged:
        {
            CGFloat horizontalChange = 0;
            horizontalChange = startLocation.x - currentLocation.x;
            self.pageHorizontalOffset += horizontalChange;
        }
            break;
        case UIGestureRecognizerStateEnded:
        {
            CGFloat horizontalChange = 0;
            horizontalChange = startLocation.x - currentLocation.x;
            self.pageHorizontalOffset += horizontalChange;
            [self _panEndHandler];
        }
            break;
        default:
            break;
    }
}

#pragma mark - Getter && Setter
- (void)setPageHorizontalOffset:(CGFloat)pageHorizontalOffset {
    [self setPageHorizontalOffset:pageHorizontalOffset
                         animated:NO
                       completion:nil];
}

- (void)setBackgroundView:(UIView *)backgroundView {
    if (backgroundView == _backgroundView)
        return;
    if (_backgroundView) {
        [_backgroundView removeFromSuperview];
        [_backgroundView release];
        _backgroundView = nil;
    }
    
    if (backgroundView) {
        _backgroundView = [backgroundView retain];
        [self insertSubview:_backgroundView atIndex:0];
    }
}

#pragma mark - Public
- (void)setPageHorizontalOffset:(CGFloat)pageHorizontalOffset animated:(BOOL)animated completion:(void (^)(void))handler {
    if (pageHorizontalOffset == _pageHorizontalOffset)
        return;
    _pageHorizontalOffset = pageHorizontalOffset;
    
    [UIView setAnimationsEnabled:animated];
    [UIView animateWithDuration:0.25f
                     animations:^{
                         [self _layout];
                     }
                     completion:^(BOOL finished){
                         [UIView setAnimationsEnabled:YES];
                         if (handler)
                             handler();
                     }];
}

#pragma mark - Private
- (void)_layout {
    CGRect viewFrame = self.frame;
    viewFrame.origin.x = -self.pageHorizontalOffset;
    self.frame = viewFrame;
    
    if (self.backgroundView) {
        CGRect bgViewFrame = self.bounds;
        bgViewFrame.origin.x = self.pageHorizontalOffset;
        self.backgroundView.frame = bgViewFrame;
    }
}

- (void)_panEndHandler {
    CGRect viewFrame = self.frame;
    if (CGRectGetMinX(viewFrame) < 0.0f) {
        [self setPageHorizontalOffset:0.0f
                             animated:YES
                           completion:nil];
    } else if (CGRectGetMaxX(viewFrame) > self.contentHorizontalWidth) {
        CGFloat newOffset = self.contentHorizontalWidth - CGRectGetWidth(viewFrame);
        newOffset = (newOffset < 0) ? 0 : newOffset;
        [self setPageHorizontalOffset:newOffset
                             animated:YES
                           completion:nil];
    }
}

@end
