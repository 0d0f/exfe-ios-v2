//
//  EFUserLocationAnnotationView.m
//  EXFE
//
//  Created by 0day on 13-8-9.
//
//

#import "EFUserLocationAnnotationView.h"

#import <QuartzCore/QuartzCore.h>
#import "Util.h"

@interface EFUserLocationAnimationView : UIView

@end

@implementation EFUserLocationAnimationView

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetShouldAntialias(context, YES);
    
    UIColor *strokeColor = [UIColor whiteColor];
    
    UIColor *shadowColor = [UIColor COLOR_RGB(0x5B, 0x78, 0xFF)];
    CGSize shadowOffset = CGSizeZero;
    CGFloat shadowBlurRadius = 2.0f;
    
    CGRect pathRect = (CGRect){{1.0f, 1.0f}, {CGRectGetWidth(rect) - 2.0f, CGRectGetHeight(rect) - 2.0f}};
    UIBezierPath *path = [UIBezierPath bezierPathWithOvalInRect:pathRect];
    
    CGContextSaveGState(context);
    CGContextSetShadowWithColor(context, shadowOffset, shadowBlurRadius, shadowColor.CGColor);
    [strokeColor setStroke];
    path.lineWidth = 0.5f;
    [path stroke];
    
    CGContextRestoreGState(context);
}

@end

@interface EFUserLocationAnnotationView ()

@property (nonatomic, strong) UIImageView *arrowView;
@property (nonatomic, strong) EFUserLocationAnimationView *animationView;

- (void)playAnimation;
- (void)stopAnimation;

@end

@implementation EFUserLocationAnnotationView

- (id)initWithAnnotation:(id<MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
    if (self) {
        self.frame = (CGRect){{0.0f, 0.0f}, {30.0f, 30.0f}};
        self.arrowView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"map_arrow_22blue.png"]];
        self.arrowView.frame = (CGRect){{4.0f, 4.0f}, self.arrowView.frame.size};
        [self addSubview:self.arrowView];
        
        self.animationView = [[EFUserLocationAnimationView alloc] initWithFrame:(CGRect){{0.0f, 0.0f}, {30.0f, 30.0f}}];
        self.animationView.backgroundColor = [UIColor clearColor];
        [self addSubview:self.animationView];
    }
    
    return self;
}

- (void)setUserHeading:(CLHeading *)userHeading {
    CLLocationDirection direction = _userHeading.trueHeading;
    if (direction < 0) {
        return;
    }
    
    [self willChangeValueForKey:@"userHeading"];
    
    _userHeading = userHeading;
    
    self.arrowView.layer.transform = CATransform3DMakeRotation((M_PI / 180.0f) * direction, 0.0f, 0.0f, 1.0f);
    
    [self didChangeValueForKey:@"userHeading"];
}

- (void)didMoveToSuperview {
    if (self.superview) {
        [self playAnimation];
    } else {
        [self stopAnimation];
    }
}

- (void)playAnimation {
    self.animationView.layer.transform = CATransform3DIdentity;
    CABasicAnimation *scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform"];
    scaleAnimation.duration = 1.0f;
    scaleAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    scaleAnimation.fromValue = [self.animationView.layer valueForKey:@"transform"];
    scaleAnimation.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeScale(2.0f, 2.0f, 1.0f)];
    scaleAnimation.delegate = self;
    scaleAnimation.fillMode = kCAFillModeForwards;
    [self.animationView.layer addAnimation:scaleAnimation forKey:@"scale"];
    self.animationView.layer.transform = CATransform3DMakeScale(2.0f, 2.0f, 1.0f);
    
    self.animationView.layer.opacity = 0.0f;
    CABasicAnimation *opacityAnimation1 = [CABasicAnimation animationWithKeyPath:@"opacity"];
    opacityAnimation1.duration = 0.2f;
    opacityAnimation1.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    opacityAnimation1.fromValue = [self.animationView.layer valueForKey:@"opacity"];
    opacityAnimation1.toValue = [NSNumber numberWithDouble:1.0f];
    opacityAnimation1.fillMode = kCAFillModeForwards;
    [self.animationView.layer addAnimation:opacityAnimation1 forKey:@"opacity"];
    self.animationView.layer.opacity = 1.0f;
    
    double delayInSeconds = 0.2f;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        CABasicAnimation *opacityAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
        opacityAnimation.duration = 0.8f;
        opacityAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        opacityAnimation.fromValue = [self.animationView.layer valueForKey:@"opacity"];
        opacityAnimation.toValue = [NSNumber numberWithDouble:0.0f];
        opacityAnimation.fillMode = kCAFillModeForwards;
        [self.animationView.layer addAnimation:opacityAnimation forKey:@"opacity"];
        self.animationView.layer.opacity = 0.0f;
    });
}

- (void)stopAnimation {
    [self.animationView.layer removeAllAnimations];
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    double delayInSeconds = 1.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self playAnimation];
    });
}

@end
