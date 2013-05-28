//
//  EFHeadView.m
//  EFHeadAnimation
//
//  Created by 0day on 13-5-17.
//  Copyright (c) 2013年 0d0f. All rights reserved.
//

#import "EFHeadView.h"

#import <QuartzCore/QuartzCore.h>
#import "Util.h"

#define kDefaultHeight      (56.0f)
#define kAvatarLayerFrame   ((CGRect){{0.0f, 0.0f}, {50.0f, 50.0f}})
#define kAvatarViewFrame    ((CGRect){{0.0f, 0.0f}, {kDefaultHeight, kDefaultHeight}})
#define kHalfTitleHeight    (22.0f)
#define kTitleViewWidth     (306.0f)
#define kTitleViewFrame     ((CGRect){{0.0f, 0.0f}, {kTitleViewWidth, kHalfTitleHeight * 2}})
#define kTitleLayerWidth    (320.0f)
#define kTitleLayerFrame     ((CGRect){{0.0f, 0.0f}, {kTitleLayerWidth, kDefaultHeight}})
#define kTitleLayerBlank    (3.0f)
#define kTitleLayerAnimationDelay   (0.05f)
#define kTitleLayerAnimationCommonDelay (0.08f)
#define kTitleLayerY    (8.0f)

@interface EFHeadViewTopLayer : CALayer
@end

@implementation EFHeadViewTopLayer

- (void)dealloc {
    [super dealloc];
}

- (void)drawInContext:(CGContextRef)ctx {
    UIColor *color = nil;
    
    UIGraphicsPushContext(ctx);
    
    color = [UIColor COLOR_CARBON];
    [color set];
    [@"Gather a" drawAtPoint:CGPointMake(179.0f, 10.0f)
                    forWidth:200.0f
                    withFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:21]
              lineBreakMode:UILineBreakModeClip];
    
    color = [UIColor COLOR_BLUE_EXFE];
    [color set];
    [@"·X·" drawAtPoint:CGPointMake(262.0f, 10.0f)
               forWidth:40.0f
               withFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:21]
          lineBreakMode:UILineBreakModeClip];
    
    UIGraphicsPopContext();
}

@end

@interface EFHeadView ()
@property (nonatomic, retain) UIView *avatarView;
@property (nonatomic, retain) CALayer *avatarLayer;

@property (nonatomic, retain) UIView *titleView;
@property (nonatomic, retain) NSArray *titleLayers;

@property (nonatomic, retain) EFHeadViewTopLayer *topLayer;
@property (assign) NSUInteger animationCount;

- (void)headShowAnimated:(BOOL)animated;
- (void)titleShowAnimated:(BOOL)animated;

- (void)plusAnimationCount;
- (void)minusAnimationCount;

@end

@implementation EFHeadView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        UIColor *backgroundColor = [UIColor colorWithRed:(238.0f / 255.0f) green:(238.0f / 255.0f) blue:(238.0f / 255.0f) alpha:1.0f];
        
        self.backgroundColor = backgroundColor;
        
        // avatar View
        UIView *avatarView = [[UIView alloc] initWithFrame:kAvatarViewFrame];
        avatarView.backgroundColor = [UIColor clearColor];
        
        CALayer *leftAvatarLayer = [CALayer layer];
        leftAvatarLayer.bounds = (CGRect){{0.0f, 0.0f}, {200.0f, CGRectGetHeight(kAvatarViewFrame) + 4}};
        leftAvatarLayer.backgroundColor = backgroundColor.CGColor;
        leftAvatarLayer.anchorPoint = (CGPoint){1.0f, 0.5f};
        leftAvatarLayer.position = (CGPoint){CGRectGetWidth(avatarView.frame) * 0.5f, CGRectGetHeight(avatarView.frame) * 0.5f};
        [avatarView.layer addSublayer:leftAvatarLayer];
        
        CALayer *avatarLayer = [CALayer layer];
        avatarLayer.frame = kAvatarLayerFrame;
        avatarLayer.anchorPoint = (CGPoint){0.5f, 0.5f};
        avatarLayer.position = (CGPoint){CGRectGetWidth(avatarView.frame) * 0.5f, CGRectGetHeight(avatarView.frame) * 0.5f};
        avatarLayer.cornerRadius = 25.0f;
        avatarLayer.masksToBounds = YES;
        [avatarView.layer addSublayer:avatarLayer];
        self.avatarLayer = avatarLayer;
        
        CALayer *mask = [CALayer layer];
        mask.contents = (id)[UIImage imageNamed:@"portrait_circle_clear.png"].CGImage;
        mask.frame = kAvatarViewFrame;
        [avatarView.layer addSublayer:mask];
        
        avatarView.center = (CGPoint){CGRectGetMidX(self.frame), CGRectGetHeight(self.frame) * 0.5f};
        [self addSubview:avatarView];
        
        self.avatarView = avatarView;
        [avatarView release];
        
        // title View
        UIView *titleView = [[UIView alloc] initWithFrame:kTitleViewFrame];
        titleView.backgroundColor = [UIColor clearColor];
        titleView.center = (CGPoint){CGRectGetMidX(self.frame), kTitleLayerY + kHalfTitleHeight};
        
        // layers
        NSMutableArray *layers = [[NSMutableArray alloc] initWithCapacity:4];
        CGRect frame = kTitleLayerFrame;
        frame.size.width = CGRectGetWidth(frame) * 0.5f;
        
        for (int i = 3; i >= 0; i--) {
            CALayer *layer = [CALayer layer];
            layer.bounds = (CGRect){{0.0f, 0.0f}, {10.0f, CGRectGetHeight(kTitleLayerFrame)}};
            layer.hidden = YES;
            layer.contentsGravity = kCAGravityTopRight;
            layer.contents = (id)[UIImage imageNamed:[NSString stringWithFormat:@"xlist_top_%d.png", i]].CGImage;
            layer.anchorPoint = (CGPoint){1.0f, 0.0f};
            layer.position = (CGPoint){CGRectGetWidth(titleView.frame) * 0.5f, -(CGRectGetHeight(kTitleLayerFrame) - CGRectGetHeight(kTitleViewFrame)) * 0.5f};
            layer.contentsScale = [UIScreen mainScreen].scale;
            layer.backgroundColor = [UIColor clearColor].CGColor;
            
            [titleView.layer addSublayer:layer];
            [layers addObject:layer];
        }
        
        self.titleLayers = layers;
        [layers release];
        
        // topLayer
        EFHeadViewTopLayer *topLayer = [EFHeadViewTopLayer layer];
        topLayer.contentsScale = [UIScreen mainScreen].scale;
        topLayer.frame = titleView.frame;
        topLayer.position = (CGPoint){0.0f, CGRectGetHeight(titleView.frame) * 0.5f};
        topLayer.backgroundColor = [UIColor clearColor].CGColor;
        [topLayer setNeedsDisplay];
        topLayer.opacity = 0.0f;
        [titleView.layer addSublayer:topLayer];
        self.topLayer = topLayer;
        
        // gesture
        UITapGestureRecognizer *headTap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                  action:@selector(tapHandler:)];
        [avatarView addGestureRecognizer:headTap];
        [headTap release];
        
        UITapGestureRecognizer *titleTap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                   action:@selector(tapHandler:)];
        [titleView addGestureRecognizer:titleTap];
        [titleTap release];
        
        [self insertSubview:titleView belowSubview:avatarView];
        self.titleView = titleView;
        [titleView release];
        
        self.showed = NO;
        self.animationCount = 0;
    }
    return self;
}

- (void)dealloc {
    [_topLayer release];
    [_avatarView release];
    [_headImage release];
    [_titleLabel release];
    [super dealloc];
}

#pragma mark - Gesture

- (void)tapHandler:(UITapGestureRecognizer *)gesture {
    switch (gesture.state) {
        case UIGestureRecognizerStateEnded:
        {
            if (gesture.view == self.avatarView && _headPressedHandler) {
                self.headPressedHandler();
            } else if (gesture.view == self.titleView && _titlePressedHandler) {
                if (CGRectContainsPoint((CGRect){{CGRectGetMidX(self.titleView.frame), 0.0f}, {CGRectGetWidth(self.titleView.frame) * 0.5f, CGRectGetHeight(self.titleView.frame)}}, [gesture locationInView:self.titleView])) {
                    self.titlePressedHandler();
                }
            }
        }
            break;
        default:
            break;
    }
}

#pragma mark - Getter && Setter

- (void)setHeadImage:(UIImage *)headImage {
    if (headImage == _headImage)
        return;
    
    if (_headImage) {
        [_headImage release];
        _headImage = nil;
    }
    if (headImage) {
        _headImage = [headImage retain];
        self.avatarLayer.contents = (id)headImage.CGImage;
    } else {
        self.avatarLayer.contents = nil;
    }
}

#pragma mark - Public

- (void)showAnimated:(BOOL)animated {
    [self headShowAnimated:animated];
    [self titleShowAnimated:animated];
}

#pragma mark - Animation Delegate

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    [self minusAnimationCount];
}

#pragma mark - Private

- (void)headShowAnimated:(BOOL)animated {
    CATransform3D newTransform = CATransform3DMakeTranslation(-121.0f, 0.0f, 0.0f);
    
    if (animated) {
        CABasicAnimation *avatarAnimation = [CABasicAnimation animationWithKeyPath:@"transform"];
        avatarAnimation.fillMode = kCAFillModeForwards;
        avatarAnimation.duration = 0.9f;
        avatarAnimation.fromValue = [self.avatarView.layer valueForKeyPath:@"transform"];
        avatarAnimation.toValue = [NSValue valueWithCATransform3D:newTransform];
        avatarAnimation.timingFunction = [CAMediaTimingFunction functionWithControlPoints:0.68 :-0.55 :0.265 :1.55];
        avatarAnimation.delegate = self;
        
        [self.avatarView.layer addAnimation:avatarAnimation forKey:@"show"];
    }
    
    [self plusAnimationCount];
    self.avatarView.layer.transform = newTransform;
}

- (void)titleShowAnimated:(BOOL)animated {
    for (int i = 0; i < 4; i++) {
        CALayer *layer = self.titleLayers[i];
        layer.hidden = NO;
        
        CGPoint newPosition = (CGPoint){CGRectGetMaxX(self.titleView.frame), -(CGRectGetHeight(kTitleLayerFrame) - CGRectGetHeight(kTitleViewFrame)) * 0.5f};
        CGRect newBounds = kTitleLayerFrame;
        
        if (animated) {
            double delayInSeconds = (3 - i) * kTitleLayerAnimationDelay + kTitleLayerAnimationCommonDelay;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                [self plusAnimationCount];
                [CATransaction begin];
                [CATransaction setAnimationDuration:0.9f];
                [CATransaction setAnimationTimingFunction:[CAMediaTimingFunction functionWithControlPoints:0.68 :-0.55 :0.265 :1.55]];
                [CATransaction setCompletionBlock:^{
                    [self minusAnimationCount];
                }];
                layer.position = newPosition;
                [CATransaction commit];
                
                [self plusAnimationCount];
                [CATransaction begin];
                [CATransaction setAnimationDuration:0.9f];
                [CATransaction setAnimationTimingFunction:[CAMediaTimingFunction functionWithControlPoints:0.68 :-0.55 :0.265 :1.55]];
                [CATransaction setCompletionBlock:^{
                    [self minusAnimationCount];
                }];
                layer.bounds = newBounds;
                [CATransaction commit];
            });
        } else {
            layer.position = newPosition;
            layer.bounds = newBounds;
        }
    }
    
    CGPoint topLayerPosition = (CGPoint){CGRectGetMidX(self.titleView.frame) - 4 * kTitleLayerBlank, CGRectGetHeight(self.titleView.frame) * 0.5f};
    if (animated) {
        double delayInSeconds = kTitleLayerAnimationCommonDelay;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [self plusAnimationCount];
            [CATransaction begin];
            [CATransaction setAnimationDuration:0.65f];
            [CATransaction setAnimationTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
            [CATransaction setCompletionBlock:^{
                [self minusAnimationCount];
            }];
            self.topLayer.opacity = 1.0f;
            self.topLayer.position = topLayerPosition;
            [CATransaction commit];
        });
    } else {
        self.topLayer.opacity = 1.0f;
        self.topLayer.position = topLayerPosition;
        
        self.showed = YES;
        if (_showCompletionHandler) {
            self.showCompletionHandler();
        }
    }
}

- (void)plusAnimationCount {
    self.animationCount += 1;
}

- (void)minusAnimationCount {
    self.animationCount -= 1;
    
    if (!self.animationCount) {
        self.showed = YES;
    }
    
    if (self.showed && _showCompletionHandler) {
        self.showCompletionHandler();
    }
}

@end
