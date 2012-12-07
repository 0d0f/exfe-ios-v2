//
//  EXGradientToolbarView.m
//  EXFE
//
//  Created by huoju on 12/6/12.
//
//

#import "EXGradientToolbarView.h"

@implementation EXGradientToolbarView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    
    UIBezierPath *framepath =[UIBezierPath bezierPathWithRect:rect];
    CGContextRef currentContext = UIGraphicsGetCurrentContext();
    CGContextBeginPath(currentContext);
    CGContextAddPath(currentContext, framepath.CGPath);
    CGContextClosePath(currentContext);
    CGContextSaveGState(currentContext);

    CGFloat colors [] = {
        250/255.0f, 250/255.0f, 250/255.0f, 1,
        221/255.0f, 221/255.0f, 221/255.0f, 1
    };
    CGColorSpaceRef baseSpace = CGColorSpaceCreateDeviceRGB();
    CGGradientRef gradient = CGGradientCreateWithColorComponents(baseSpace, colors, NULL, 2);
    CGColorSpaceRelease(baseSpace);
    baseSpace = NULL;
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGPoint startPoint = CGPointMake(CGRectGetMidX(rect), CGRectGetMinY(rect));
    CGPoint endPoint = CGPointMake(CGRectGetMidX(rect), CGRectGetMaxY(rect));
    CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, 0);
    CGGradientRelease(gradient), gradient = NULL;
    

//    CGContextSetShadowWithColor(currentContext, CGSizeMake(3, -3), 2, [UIColor blackColor].CGColor);
//    CGContextSetShadow(currentContext, CGSizeMake(4,4), 3);
//    CGContextFillPath(currentContext);

}

@end
