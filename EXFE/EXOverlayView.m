//
//  EXOverlayView.m
//  EXFE
//
//  Created by huoju on 7/24/12.
//
//

#import "EXOverlayView.h"

@implementation EXOverlayView
@synthesize transparentPath;
@synthesize backgroundimage;

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
    
//    UIBezierPath *triangle = [UIBezierPath bezierPath];
//    [triangle moveToPoint:CGPointMake(5,44)];
//    [triangle addLineToPoint:CGPointMake(5,80)];
//    [triangle addLineToPoint:CGPointMake(20,44+18)];
//    [triangle addLineToPoint:CGPointMake(5,44)];
    transparentPath.usesEvenOddFillRule=YES;
    
//    UIBezierPath *framepath = [UIBezierPath bezierPathWithRect:rect];
    UIBezierPath *framepath = [UIBezierPath bezierPathWithRoundedRect:rect
                                                           cornerRadius:5];
    
    [framepath appendPath:transparentPath];
    
    CGContextRef currentContext = UIGraphicsGetCurrentContext();
    CGContextBeginPath(currentContext);
    CGContextAddPath(currentContext, framepath.CGPath);
    CGContextClosePath(currentContext);
    CGContextClip(currentContext);
//    UIImage *currentImage=`
    CGImageRef imageref = CGImageRetain(backgroundimage.CGImage);
    
    CGRect image_rect;
    image_rect.size = backgroundimage.size;
//    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextDrawTiledImage(currentContext, image_rect, imageref);
    CGImageRelease(imageref);

}

@end
