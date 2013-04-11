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
        _sublayer.frame = CGRectMake(0, 0, 320, 200);
        _sublayer.name = @"cover";
        [self addSublayer:_sublayer];
        
        _curveParamBase = CGPointMake(198, 80);
        _curveParamControl1 = CGRectMake(198 - _curveParamBase.x, 80 - _curveParamBase.y, 76, 0);
        _curveParamControl2 = CGRectMake(320 - _curveParamBase.x, 100 - _curveParamBase.y, -46, 0);
        _maskPosition = CGPointMake(0, 0);
    }
    return self;
}

- (void)dealloc{
    
    [super dealloc];
}

- (void)updateCurvePath:(UIBezierPath*)path{
    
    CGFloat minY = 0.0f;
    

    CGFloat y0 = _curveParamBase.y + _curveParamControl1.origin.y;
    CGFloat y3 = _curveParamBase.y + _curveParamControl2.origin.y;
    CGFloat y1 = y0 + _curveParamControl1.size.height;
    CGFloat y2 = y3 + _curveParamControl2.size.height;
    
    CGFloat midY = y0;
    CGFloat maxY = y3;
    
    CGFloat minX = 0.0f;
    CGFloat maxX = CGRectGetWidth(self.bounds) * 2;
    
    CGFloat x0 = _curveParamBase.x + _curveParamControl1.origin.x;
    CGFloat x3 = _curveParamBase.x + _curveParamControl2.origin.x;
    CGFloat x1 = x0 + _curveParamControl1.size.width;
    CGFloat x2 = x3 + _curveParamControl2.size.width;
    
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
    maskLayer.position = _maskPosition;
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
