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

@interface EFUserLocationAnnotationView ()

@property (nonatomic, strong) UIImageView *arrowView;
@property (nonatomic, strong) UIView *animationView;

@end

@implementation EFUserLocationAnnotationView

- (id)initWithAnnotation:(id<MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
    if (self) {
        self.frame = (CGRect){{0.0f, 0.0f}, {30.0f, 30.0f}};
        self.arrowView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"map_arrow_22blue.png"]];
        self.arrowView.frame = (CGRect){{4.0f, 4.0f}, self.arrowView.frame.size};
        [self addSubview:self.arrowView];
        
        self.animationView = [[UIView alloc] initWithFrame:(CGRect){{0.5f, 0.5f}, {29.0f, 29.0f}}];
        self.animationView.layer.cornerRadius = 14.5f;
        self.animationView.layer.borderColor = [UIColor COLOR_RGB(0x5B, 0x9C, 0xFC)].CGColor;
        self.animationView.layer.borderWidth = 1.0f;
        [self addSubview:self.animationView];
    }
    
    return self;
}

- (void)setUserHeading:(CLHeading *)userHeading {
    [self willChangeValueForKey:@"userHeading"];
    
    _userHeading = userHeading;
    
    CLLocationDirection direction = _userHeading.trueHeading;
    self.arrowView.layer.transform = CATransform3DMakeRotation((M_PI / 160.0f) * direction, 0.0f, 0.0f, 1.0f);
    
    [self didChangeValueForKey:@"userHeading"];
}

- (void)playAnimation {
    CABasicAnimation *scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform"];
    scaleAnimation.duration = 1.0f;
    scaleAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    scaleAnimation.fromValue = [self.animationView.layer valueForKey:@"transform"];
    scaleAnimation.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeScale(2.0f, 2.0f, 1.0f)];
    [self.animationView.layer addAnimation:scaleAnimation forKey:@"scale"];
    
    CABasicAnimation *opacityAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    opacityAnimation.duration = 1.0f;
    opacityAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    opacityAnimation.fromValue = [self.animationView.layer valueForKey:@"opacity"];
    opacityAnimation.toValue = [NSNumber numberWithDouble:0.0f];
    [self.animationView.layer addAnimation:opacityAnimation forKey:@"opacity"];
}

@end
