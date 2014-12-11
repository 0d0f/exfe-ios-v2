//
//  EXQuoteView.m
//  BubbleTextField
//
//  Created by huoju on 8/17/12.
//  Copyright (c) 2012 huoju. All rights reserved.
//

#import "EXQuoteView.h"

@implementation EXQuoteView
@synthesize arrowHeight;
@synthesize arrowleft;
@synthesize cornerRadius;
@synthesize gradientcolors;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.opaque=NO;
        // Initialization code
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    int x=rect.origin.x;
    int y=rect.origin.y;
    int r=cornerRadius;
    int width=rect.size.width;
    int height=rect.size.height;
    
    int arrow_height=arrowHeight;
    int arrow_left=arrowleft;
    UIBezierPath *path=[UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(x+r, y)];
    [path addArcWithCenter:CGPointMake(x+r, y+r) radius:r startAngle:-M_PI_2 endAngle:-M_PI clockwise:NO]; //left-top
    
    [path addLineToPoint:CGPointMake(x, height-2*r-arrow_height)];
    [path addArcWithCenter:CGPointMake(x+r, y+height-r-arrow_height) radius:r startAngle:-M_PI endAngle:M_PI_2 clockwise:NO]; //left-bottom
    
    [path addLineToPoint:CGPointMake(x+arrow_left, y+height-arrow_height)];
    [path addLineToPoint:CGPointMake(x+arrow_left+arrow_height, y+height)];
    [path addLineToPoint:CGPointMake(x+arrow_left+arrow_height*2, y+height-arrow_height)];
    
    [path addLineToPoint:CGPointMake(x+width-r, y+height-arrow_height)];
    [path addArcWithCenter:CGPointMake(x+width-r, y-arrow_height+height-r) radius:r startAngle:M_PI_2 endAngle:0 clockwise:NO];//right-bottom
    [path addLineToPoint:CGPointMake(x+width, y+r)];
    [path addArcWithCenter:CGPointMake(x+width-r, y+r) radius:r startAngle:0 endAngle:-M_PI_2 clockwise:NO];//right-top
    [path addLineToPoint:CGPointMake(x+r, y)];
    
    [[UIColor clearColor] set];
    UIRectFill(rect);
    
    CGContextRef currentContext = UIGraphicsGetCurrentContext();
    CGContextBeginPath(currentContext);
    CGContextAddPath(currentContext, path.CGPath);
    CGContextClosePath(currentContext);
    CGContextSaveGState(currentContext);
    CGContextClip(currentContext);
    
    CGFloat colors [] = {
        38/255.0f, 44/255.0f, 51/255.0f, 0.95,
        58/255.0f, 66/255.0f, 76/255.0f, 0.95
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
    
    CGContextRestoreGState(currentContext);
    [[UIColor colorWithRed:38/255.0f green:44/255.0f blue:51/255.0f alpha:1] set];
    [path stroke];
}

@end
