//
//  EXCurveImageView.m
//  EXFE
//
//  Created by Stony Wang on 12-12-20.
//
//

#import "EXCurveImageView.h"
#import "UIImage+Alpha.h"

@implementation EXCurveImageView
@synthesize CurveFrame;


//- (void)setCurveFrame:(CGRect)frame{
//    CurveFrame = frame;
//    [self setNeedsDisplay]; 
//}

- (id)initWithFrame:(CGRect)frame withCurveFrame:(CGRect)curveFrame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        CurveFrame = curveFrame;
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    if (CurveFrame.size.height == 0 || CurveFrame.size.width == 0){
        [super drawRect:rect];
        return;
    }
    
    if (self.image == nil){
        return;
    }
    
    UIImage *image = [self.image imageWithAlpha];
    
    // Build a context that's the same dimensions as the new size
    CGContextRef context = CGBitmapContextCreate(NULL,
                                                 self.frame.size.width,
                                                 self.frame.size.height,
                                                 CGImageGetBitsPerComponent(image.CGImage),
                                                 0,
                                                 CGImageGetColorSpace(image.CGImage),
                                                 CGImageGetBitmapInfo(image.CGImage));
    
    // Create a clipping path with rounded corners
    CGContextBeginPath(context);
    {
        // Drawing code
        CGContextSaveGState(context);
        CGRect rr = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
        CGContextTranslateCTM(context, CGRectGetMinX(rr), CGRectGetMinY(rr));
        int ovalWidth = self.frame.size.width / 4;
        int ovalHeight = self.frame.size.height / 4;
        CGContextScaleCTM(context, ovalWidth, ovalHeight);
        CGFloat fw = CGRectGetWidth(rr) / ovalWidth;
        CGFloat fh = CGRectGetHeight(rr) / ovalHeight;
        
        CGContextMoveToPoint(context, fw, fh/2);
        CGContextAddArcToPoint(context, fw, fh, fw/2, fh, 1);
        CGContextAddArcToPoint(context, 0, fh, 0, fh/2, 1);
        CGContextAddArcToPoint(context, 0, 0, fw/2, 0, 1);
        CGContextAddArcToPoint(context, fw, 0, fw, fh/2, 1);
        CGContextClosePath(context);
        
        
        CGContextRestoreGState(context);
    }
    
    CGContextClosePath(context);
    CGContextClip(context);
    
    // Draw the image to the context; the clipping path will make anything outside the rounded rect transparent
    CGContextDrawImage(context, CGRectMake(0, 0, self.frame.size.width, self.frame.size.height), image.CGImage);
    
    // Create a CGImage from the context
    CGImageRef clippedImage = CGBitmapContextCreateImage(context);
    CGContextRelease(context);
    
    // Create a UIImage from the CGImage
    UIImage *roundedImage = [UIImage imageWithCGImage:clippedImage];
    CGImageRelease(clippedImage);
    
    [roundedImage drawInRect:rect];
}
@end
