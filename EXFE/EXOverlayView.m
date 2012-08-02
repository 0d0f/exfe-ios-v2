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
    transparentPath.usesEvenOddFillRule=YES;
    
    UIBezierPath *framepath = [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:5];
    [framepath appendPath:transparentPath];
    CGContextRef currentContext = UIGraphicsGetCurrentContext();
    CGContextBeginPath(currentContext);
    CGContextAddPath(currentContext, framepath.CGPath);
    CGContextClosePath(currentContext);
    CGContextClip(currentContext);
    CGImageRef imageref = CGImageRetain(backgroundimage.CGImage);
    CGRect image_rect;
    image_rect.size = backgroundimage.size;
    CGContextDrawTiledImage(currentContext, image_rect, imageref);
    CGImageRelease(imageref);
}

@end
