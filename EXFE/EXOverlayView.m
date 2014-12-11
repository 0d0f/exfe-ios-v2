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
@synthesize color;
@synthesize cornerRadius;
@synthesize arrowHeight;
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
    UIBezierPath *framepath=nil;
    transparentPath.usesEvenOddFillRule=YES;

    if(self.arrowHeight>0 &&self.cornerRadius>0){
        framepath=[UIBezierPath bezierPathWithRoundedRect:CGRectMake(rect.origin.x, rect.origin.y, rect.size.width, rect.size.height-self.arrowHeight) cornerRadius:self.cornerRadius];
        [framepath appendPath:[UIBezierPath bezierPathWithRect:CGRectMake(0, rect.size.height-8, rect.size.width,self.arrowHeight)]];
        [framepath appendPath:transparentPath];
    }
    else if(self.arrowHeight==0 && self.cornerRadius>0){
        framepath=[UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:self.cornerRadius];
        [framepath appendPath:transparentPath];
    }

    CGContextRef currentContext = UIGraphicsGetCurrentContext();
    CGContextBeginPath(currentContext);
    if(framepath!=nil)
        CGContextAddPath(currentContext, framepath.CGPath);
    CGContextClosePath(currentContext);
    CGContextSaveGState(currentContext);
    CGContextClip(currentContext);
    if(backgroundimage!=nil)
    {
        CGImageRef imageref = CGImageRetain(backgroundimage.CGImage);
        CGRect image_rect;
        image_rect.origin.x=0;
        image_rect.origin.y=0;
        image_rect.size = backgroundimage.size;
        CGContextDrawTiledImage(currentContext, image_rect, imageref);
        CGImageRelease(imageref);
    }
    else if(color!=nil){
        [color set];
        UIBezierPath *path = [UIBezierPath bezierPathWithRect:rect];
        [path fill];
        [path stroke];
    }
    else if(gradientcolors){
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
        
        CGContextSetStrokeColorWithColor(currentContext, [[UIColor redColor] CGColor]);
        CGContextStrokePath(currentContext);
    }

    
}

@end
