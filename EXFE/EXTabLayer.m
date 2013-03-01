//
//  EXTabLayer.m
//  EXFE
//
//  Created by Stony Wang on 13-2-28.
//
//

#import "EXTabLayer.h"
#import "Util.h"

@interface EXTabLayer (){
    
}
@end

@implementation EXTabLayer

- (id) init{
    self = [super init];
    if (self) {
        // Initialization code
        _imglayer = [CALayer layer];
        [self addSublayer:_imglayer];
        
        _sublayer = [CALayer layer];
        _sublayer.backgroundColor = [UIColor blackColor].CGColor;
        _sublayer.opacity = COLOR255(0x55);
        _sublayer.frame = CGRectMake(0, 0, 320, 300);
        _sublayer.name = @"cover";
        [self addSublayer:_sublayer];
        
        _curveBase = 0.f;
        _curveCenter = CGPointZero;
        _curveParamRect = CGSizeMake(78, 15);
        _curveParamControl = CGSizeMake(32, 0);
    }
    return self;
}

- (void)dealloc{
    
    [super dealloc];
}

- (void)updateCurvePath:(UIBezierPath*)path{
    
    
    CGFloat minY = _curveBase;
    

    CGFloat y0 = _curveCenter.y - _curveParamRect.height / 2.0f;
    CGFloat y3 = _curveCenter.y + _curveParamRect.height / 2.0f;
    CGFloat y1 = y0 + _curveParamControl.height;
    CGFloat y2 = y3 - _curveParamControl.height;
    
    CGFloat midY = y0;
    CGFloat maxY = y3;
    
    CGFloat minX = 0;
    CGFloat maxX = CGRectGetWidth(self.bounds) * 2;
    
    CGFloat x0 = _curveCenter.x - _curveParamRect.width / 2.0f;
    CGFloat x3 = _curveCenter.x + _curveParamRect.width / 2.0f;
    CGFloat x1 = x0 + _curveParamControl.width;
    CGFloat x2 = x3 - _curveParamControl.width;
    
    [path removeAllPoints];
    [path moveToPoint:CGPointMake(minX, minY)];
    [path addLineToPoint:CGPointMake(minX, midY)];
    [path addLineToPoint:CGPointMake(x0, y0)];
    [path addCurveToPoint:CGPointMake(x3, y3) controlPoint1:CGPointMake(x1, y1) controlPoint2:CGPointMake(x2, y2)];
    [path addLineToPoint:CGPointMake(maxX, maxY)];
    [path addLineToPoint:CGPointMake(maxX, minY)];
    [path closePath];
}


//- (void)display{
//    self.contents = (id)[UIImage imageNamed:@"x_titlebg_default.jpg"].CGImage;
//}

- (void)layoutSublayers{
    
    UIBezierPath *curvePath= [UIBezierPath bezierPath];
    [self updateCurvePath:curvePath];
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    maskLayer.path = [curvePath CGPath];
    self.mask = maskLayer;
    self.masksToBounds = YES;
    
    [super layoutSublayers];
}

//+ (BOOL)needsDisplayForKey:(NSString *)key {
//    if ([key isEqualToString:@"curveBase"]
//        || [key isEqualToString:@"curveCenter"]) {
//        return YES;
//    }
//    else {
//        return [super needsDisplayForKey:key];
//    }
//}

- (void) setimage:(UIImage*)image{
    _imglayer.contents = (id)image.CGImage;
    _imglayer.frame = self.bounds;
}
@end
