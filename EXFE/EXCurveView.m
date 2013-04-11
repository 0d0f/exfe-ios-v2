//
//  UICurveView.m
//  EXFE
//
//  Created by Stony Wang on 13-1-10.
//
//

#import "EXCurveView.h"
#import <QuartzCore/QuartzCore.h>
#import "Util.h"

@implementation EXCurveView
@synthesize CurveFrame;

- (void)setCurveFrame:(CGRect)frame{
    CurveFrame = frame;
    [self changeLayer];
}

- (id)initWithFrame:(CGRect)frame withCurveFrame:(CGRect)curveFrame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        CurveFrame = curveFrame;
        [self changeLayer];
    }
    return self;
}

- (void)changeLayer{
    
    if (CGRectIsNull(CurveFrame)) {
        self.layer.masksToBounds = NO;
        return;
    }
    
    CGRect bounds = self.bounds;
    
    CGFloat x0 = (CurveFrame.origin.x + CurveFrame.size.width * 0.0f);
    CGFloat y0 = (CurveFrame.origin.y + CurveFrame.size.height * 0.0f);
    CGFloat x1 = (CurveFrame.origin.x + 72);
    CGFloat y1 = (CurveFrame.origin.y + CurveFrame.size.height * 0.0f);
    CGFloat x2 = (CurveFrame.origin.x + 122 - 46);
    CGFloat y2 = (CurveFrame.origin.y + CurveFrame.size.height * 1.0f);
    CGFloat x3 = (CurveFrame.origin.x + CurveFrame.size.width * 1.0f);
    CGFloat y3 = (CurveFrame.origin.y + CurveFrame.size.height * 1.0f);
    
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    
    UIBezierPath *curvePath = [UIBezierPath bezierPath];
    [curvePath moveToPoint:CGPointMake(0, 0)];
    [curvePath addLineToPoint:CGPointMake(0, y0)];
    [curvePath addLineToPoint:CGPointMake(x0, y0)];
    [curvePath addCurveToPoint:CGPointMake(x3, y3) controlPoint1:CGPointMake(x1, y1) controlPoint2:CGPointMake(x2, y2)];
    [curvePath addLineToPoint:CGPointMake(bounds.size.width, y3)];
    [curvePath addLineToPoint:CGPointMake(bounds.size.width, 0)];
    [curvePath closePath];
    maskLayer.path = [curvePath CGPath];
   
    self.layer.mask = maskLayer;
    self.layer.masksToBounds = YES;
//    self.layer.shadowColor = [UIColor COLOR_WA(0, 0xFF)].CGColor;
//    self.layer.shadowOffset = CGSizeMake(0, 2);
//    self.layer.shadowOpacity = 0.75;
//    self.layer.shadowRadius = 6;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
