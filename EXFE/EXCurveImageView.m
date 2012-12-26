//
//  EXCurveImageView.m
//  EXFE
//
//  Created by Stony Wang on 12-12-20.
//
//

#import "EXCurveImageView.h"
#import "UIImage+Alpha.h"
#import "UIImage+RoundedCorner.h"

@implementation EXCurveImageView
@synthesize CurveFrame;
@synthesize image;

- (void)setCurveFrame:(CGRect)frame{
    CurveFrame = frame;
    [self setNeedsDisplay]; 
}


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
    
    //UIImage *roundedImage = [self.image roundedCornerImage:CurveFrame.size.height borderSize:0];
    
    UIImage *imageAlpha = [self.image imageWithAlpha];
    
    // Build a context that's the same dimensions as the new size
    CGContextRef context = CGBitmapContextCreate(NULL,
                                                 self.frame.size.width,
                                                 self.frame.size.height,
                                                 CGImageGetBitsPerComponent(imageAlpha.CGImage),
                                                 0,
                                                 CGImageGetColorSpace(imageAlpha.CGImage),
                                                 CGImageGetBitmapInfo(imageAlpha.CGImage));
    
    // Create a clipping path with rounded corners
    CGContextBeginPath(context);
    {
        // Drawing code
        CGContextSaveGState(context);
        CGRect rr = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
        CGContextTranslateCTM(context, CGRectGetMinX(rr), CGRectGetMinY(rr));
//        int ovalWidth = self.frame.size.width / 4;
//        int ovalHeight = self.frame.size.height / 4;
        int ovalWidth = self.frame.size.width;
        int ovalHeight = self.frame.size.height;

        CGContextScaleCTM(context, ovalWidth, ovalHeight);
        CGFloat fw = CGRectGetWidth(rr) / ovalWidth;
        CGFloat fh = CGRectGetHeight(rr) / ovalHeight;
        
        CGFloat x0 = fw / CGRectGetWidth(rr) * (CurveFrame.origin.x + CurveFrame.size.width * 0.0f);
        CGFloat y0 = fh / CGRectGetHeight(rr) * (CGRectGetHeight(rr) - CurveFrame.origin.y - CurveFrame.size.height * 0.0f);
        CGFloat x1 = fw / CGRectGetWidth(rr) * (CurveFrame.origin.x + CurveFrame.size.width * 0.7f);
        CGFloat y1 = fh / CGRectGetHeight(rr) * (CGRectGetHeight(rr) - CurveFrame.origin.y - CurveFrame.size.height * 0.0f);
        CGFloat x2 = fw / CGRectGetWidth(rr) * (CurveFrame.origin.x + CurveFrame.size.width * 0.3f);
        CGFloat y2 = fh / CGRectGetHeight(rr) *(CGRectGetHeight(rr) - CurveFrame.origin.y - CurveFrame.size.height * 1.0f);
        CGFloat x3 = fw / CGRectGetWidth(rr) * (CurveFrame.origin.x + CurveFrame.size.width * 1.0f);
        CGFloat y3 = fh / CGRectGetHeight(rr) *(CGRectGetHeight(rr) - CurveFrame.origin.y - CurveFrame.size.height * 1.0f);
        
        CGContextMoveToPoint(context, 0, fh);
        CGContextAddLineToPoint(context, 0,  y0);
        CGContextAddLineToPoint(context, x0, y0);
        
        CGContextAddCurveToPoint(context, x1, y1, x2, y2, x3, y3);
        
        CGContextAddLineToPoint(context, fw , y3);
        CGContextAddLineToPoint(context, fw , fh);
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
