//
//  EXBackgroundView.m
//  EXFE
//
//  Created by huoju on 8/24/12.
//
//

#import "EXBackgroundView.h"

@implementation EXBackgroundView

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
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    CGFloat colors [] = {
        173/255.0f, 204/255.0f, 237/255.0f, 0.95,
        72/255.0f, 101/255.0f, 133/255.0f, 0.95
    };
    CGColorSpaceRef baseSpace = CGColorSpaceCreateDeviceRGB();
    CGGradientRef gradient = CGGradientCreateWithColorComponents(baseSpace, colors, NULL, 2);
    CGColorSpaceRelease(baseSpace);
    baseSpace = NULL;
    CGPoint startPoint = CGPointMake(CGRectGetMidX(rect), CGRectGetMinY(rect));
    CGPoint endPoint = CGPointMake(CGRectGetMidX(rect), CGRectGetMaxY(rect));
    CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, 0);
    CGGradientRelease(gradient), gradient = NULL;
    CGContextRestoreGState(context);

}

@end
