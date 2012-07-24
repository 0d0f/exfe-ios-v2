//
//  EXOverlayView.m
//  EXFE
//
//  Created by huoju on 7/24/12.
//
//

#import "EXOverlayView.h"

@implementation EXOverlayView

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
    // Start by filling the area with the blue color
    
    UIBezierPath *triangle = [UIBezierPath bezierPath];
    [triangle moveToPoint:CGPointMake(5,44)];
    [triangle addLineToPoint:CGPointMake(5,80)];
    [triangle addLineToPoint:CGPointMake(20,44+18)];
    [triangle addLineToPoint:CGPointMake(5,44)];
    triangle.usesEvenOddFillRule=YES;
    
    UIBezierPath *framepath = [UIBezierPath bezierPathWithRect:rect];
    [framepath appendPath:triangle];
    
    CGContextRef currentContext = UIGraphicsGetCurrentContext();
    CGContextBeginPath(currentContext);
    CGContextAddPath(currentContext, framepath.CGPath);
    CGContextClosePath(currentContext);
    CGContextClip(currentContext);

    [[UIColor greenColor] setFill];
    UIRectFill( rect );

}

@end
