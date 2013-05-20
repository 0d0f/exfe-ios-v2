//
//  EFHeadView.m
//  EFHeadAnimation
//
//  Created by 0day on 13-5-17.
//  Copyright (c) 2013年 0d0f. All rights reserved.
//

#import "EFHeadView.h"

#import <QuartzCore/QuartzCore.h>

#define kDefaultHeight      (56.0f)
#define kAvatarLayerFrame   ((CGRect){{0.0f, 0.0f}, {50.0f, 50.0f}})
#define kAvatarViewFrame    ((CGRect){{0.0f, 0.0f}, {kDefaultHeight, kDefaultHeight}})
#define kHalfTitleHeight    (22.0f)
#define kTitleViewWidth     (300.0f)
#define kTitleViewFrame     ((CGRect){{0.0f, 0.0f}, {kTitleViewWidth, kHalfTitleHeight * 2}})
#define kTitleLayerStartFrame     ((CGRect){{0.0f, 0.0f}, {10.0f, kHalfTitleHeight * 2}})
#define kTitleLayerBlank    (3.0f)
#define kTitleLayerAnimationDelay   (0.05f)
#define kTitleLayerAnimationCommonDelay (0.08f)

@interface EFHeadView ()
@property (nonatomic, retain) UIView *avatarView;
@property (nonatomic, retain) CALayer *avatarLayer;

@property (nonatomic, retain) UIView *titleView;
@property (nonatomic, retain) NSArray *titleLayers;

@property (nonatomic, assign) BOOL isShowed;

- (void)headShowAnimation;
- (void)headDismissAnimation;

- (void)titleShowAnimation;
- (void)titleDismissAnimation;

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
        leftAvatarLayer.bounds = (CGRect){{0.0f, 0.0f}, {200.0f, CGRectGetHeight(kAvatarViewFrame)}};
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
        mask.contents = (id)[UIImage imageNamed:@"portrait_circle@2x.png"].CGImage;
        mask.frame = kAvatarViewFrame;
        [avatarView.layer addSublayer:mask];
        
        avatarView.center = self.center;
        [self addSubview:avatarView];
        
        self.avatarView = avatarView;
        [avatarView release];
        
        // gesture
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                              action:@selector(tapHandler:)];
        [avatarView addGestureRecognizer:tap];
        [tap release];
        
        // title View
        UIView *titleView = [[UIView alloc] initWithFrame:kTitleViewFrame];
        titleView.backgroundColor = [UIColor clearColor];
        titleView.center = self.center;
        titleView.layer.shadowColor = [UIColor blackColor].CGColor;
        titleView.layer.shadowOffset = (CGSize){0.0f, 1.0f};
        titleView.layer.shadowOpacity = 0.3f;
        titleView.layer.shadowRadius = 0.5f;
        titleView.layer.shouldRasterize = YES;
        titleView.layer.rasterizationScale = [UIScreen mainScreen].scale;
        
        NSMutableArray *layers = [[NSMutableArray alloc] initWithCapacity:4];
        for (int i = 0; i < 4; i++) {
            CALayer *layer = i < 3 ? [CALayer layer] : [CAGradientLayer layer];
            CGRect frame = kTitleLayerStartFrame;
            layer.frame = frame;
            layer.cornerRadius = kHalfTitleHeight;
            layer.masksToBounds = YES;
            layer.position = (CGPoint){CGRectGetWidth(titleView.frame) * 0.5f - i * kTitleLayerBlank, CGRectGetHeight(titleView.frame) * 0.5f};
            
            layer.backgroundColor = [UIColor colorWithWhite:(1.0f - (3.0f - i) / 3.0f)  alpha:1.0f].CGColor;
            
            [titleView.layer addSublayer:layer];
            [layers addObject:layer];
        }
        
        ((CALayer *)layers[0]).backgroundColor = [UIColor colorWithRed:(24.0f / 255.0f)
                                                                 green:(80.0f / 255.0f)
                                                                  blue:(140.0f / 255.0f)
                                                                 alpha:1.0f].CGColor;
        
        ((CALayer *)layers[1]).backgroundColor = [UIColor colorWithRed:(54.0f / 255.0f)
                                                                 green:(135.0f / 255.0f)
                                                                  blue:(221.0f / 255.0f)
                                                                 alpha:1.0f].CGColor;
        
        ((CALayer *)layers[2]).backgroundColor = [UIColor colorWithRed:(150.0f / 255.0f)
                                                                 green:(201.0f / 255.0f)
                                                                  blue:1.0f
                                                                 alpha:1.0f].CGColor;
        
        ((CAGradientLayer *)layers[3]).colors = @[(id)[UIColor colorWithRed:(238.0f / 255.0f) green:(238.0f / 255.0f) blue:(238.0f / 255.0f) alpha:1.0f].CGColor,
                                                  (id)[UIColor whiteColor].CGColor];
        
        self.titleLayers = layers;
        [layers release];
        
        [self insertSubview:titleView belowSubview:avatarView];
        self.titleView = titleView;
        [titleView release];
        
        self.isShowed = NO;
    }
    return self;
}

- (void)dealloc {
    [_titleLabel release];
    [_avatarView release];
    [_headImage release];
    [_titleLabel release];
    [super dealloc];
}

#pragma mark - Gesture

- (void)tapHandler:(UITapGestureRecognizer *)gesture {
    if (self.isShowed) {
        [self dismiss];
    } else {
        [self show];
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

- (void)show {
    self.isShowed = YES;
    [self headShowAnimation];
    [self titleShowAnimation];
}

- (void)dismiss {
    self.isShowed = NO;
    [self headDismissAnimation];
    [self titleDismissAnimation];
}

#pragma mark - Private

- (void)headShowAnimation {
    CATransform3D newTransform = CATransform3DMakeTranslation(-120.0f, 0.0f, 0.0f);
    
    CABasicAnimation *avatarAnimation = [CABasicAnimation animationWithKeyPath:@"transform"];
    avatarAnimation.fillMode = kCAFillModeForwards;
    avatarAnimation.duration = 0.9f;
    avatarAnimation.fromValue = [self.avatarView.layer valueForKeyPath:@"transform"]; // [NSValue valueWithCATransform3D:CATransform3DIdentity];
    avatarAnimation.toValue = [NSValue valueWithCATransform3D:newTransform];
    avatarAnimation.timingFunction = [CAMediaTimingFunction functionWithControlPoints:0.68 :-0.55 :0.265 :1.55];
    
    [self.avatarView.layer addAnimation:avatarAnimation forKey:@"show"];
    self.avatarView.layer.transform = newTransform;
}

- (void)headDismissAnimation {
    CATransform3D newTransform = CATransform3DIdentity;
    
    CABasicAnimation *avatarAnimation = [CABasicAnimation animationWithKeyPath:@"transform"];
    avatarAnimation.fillMode = kCAFillModeForwards;
    avatarAnimation.duration = 0.9f;
    avatarAnimation.fromValue = [self.avatarView.layer valueForKeyPath:@"transform"]; // [NSValue valueWithCATransform3D:CATransform3DMakeTranslation(-120.0f, 0.0f, 0.0f)];
    avatarAnimation.toValue = [NSValue valueWithCATransform3D:CATransform3DIdentity];
    avatarAnimation.timingFunction = [CAMediaTimingFunction functionWithControlPoints:0.68 :-0.55 :0.265 :1.55];
    
    [self.avatarView.layer addAnimation:avatarAnimation forKey:@"dismiss"];
    self.avatarView.layer.transform = newTransform;
}

- (void)titleShowAnimation {
    for (int i = 0; i < 4; i++) {
        CALayer *layer = self.titleLayers[i];
        
        CGPoint newPosition = (CGPoint){kTitleViewWidth * 0.5f - i * kTitleLayerBlank, CGRectGetHeight(layer.bounds) * 0.5f};      
        CGRect newBounds = layer.bounds;
        newBounds.size = (CGSize){kTitleViewWidth - 3 * kTitleLayerBlank, CGRectGetHeight(layer.bounds)};
        
        double delayInSeconds = (3 - i) * kTitleLayerAnimationDelay + kTitleLayerAnimationCommonDelay;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [CATransaction begin];
            [CATransaction setAnimationDuration:0.9f];
            [CATransaction setAnimationTimingFunction:[CAMediaTimingFunction functionWithControlPoints:0.68 :-0.55 :0.265 :1.55]];
            layer.position = newPosition;
            [CATransaction commit];
            
//            if (i != 3) {
//                CABasicAnimation *alphaAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
//                alphaAnimation.duration = 0.9f;
//                alphaAnimation.removedOnCompletion = NO;
//                alphaAnimation.fromValue = [NSNumber numberWithDouble:0.0f];
//                alphaAnimation.toValue = [NSNumber numberWithDouble:1.0f];
//                [layer addAnimation:alphaAnimation forKey:@"alpha"];
//            }
//            
            [CATransaction begin];
            [CATransaction setAnimationDuration:0.65f];
            [CATransaction setAnimationTimingFunction:[CAMediaTimingFunction functionWithControlPoints:0.68 :-0.55 :0.265 :1.55]];
            layer.bounds = newBounds;
            [CATransaction commit];
        });
    }
//    CABasicAnimation *alphaAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
//    alphaAnimation.duration = 0.9f;
//    alphaAnimation.removedOnCompletion = NO;
//    alphaAnimation.fromValue = [NSNumber numberWithDouble:0.0f];
//    alphaAnimation.toValue = [NSNumber numberWithDouble:1.0f];
//    [self.titleView.layer addAnimation:alphaAnimation forKey:@"alpha"];
}

- (void)titleDismissAnimation {
    for (int i = 0; i < 4; i++) {
        CALayer *layer = self.titleLayers[i];
        
        CGPoint newPosition = (CGPoint){kTitleViewWidth * 0.5f - i * kTitleLayerBlank, CGRectGetHeight(layer.frame) * 0.5f};
        CGRect newBounds = kTitleLayerStartFrame;
        
        double delayInSeconds = (3 - i) * 0.015f + kTitleLayerAnimationCommonDelay;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [CATransaction begin];
            [CATransaction setAnimationDuration:0.9f];
            [CATransaction setAnimationTimingFunction:[CAMediaTimingFunction functionWithControlPoints:0.68 :-0.55 :0.265 :1.55]];
            layer.position = newPosition;
            [CATransaction commit];
            
            //            if (i != 3) {
            //                CABasicAnimation *alphaAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
            //                alphaAnimation.duration = 0.9f;
            //                alphaAnimation.removedOnCompletion = NO;
            //                alphaAnimation.fromValue = [NSNumber numberWithDouble:0.0f];
            //                alphaAnimation.toValue = [NSNumber numberWithDouble:1.0f];
            //                [layer addAnimation:alphaAnimation forKey:@"alpha"];
            //            }
            //
            [CATransaction begin];
            [CATransaction setAnimationDuration:0.65f];
            [CATransaction setAnimationTimingFunction:[CAMediaTimingFunction functionWithControlPoints:0.68 :-0.55 :0.265 :1.55]];
            layer.bounds = newBounds;
            [CATransaction commit];
        });
    }
}

@end
