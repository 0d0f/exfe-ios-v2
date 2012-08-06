//
//  CASmoothFontTextLayer.m
//  EXFE
//
//  Created by huoju on 8/6/12.
//
//

#import "CASmoothFontTextLayer.h"

@implementation CASmoothFontTextLayer
- (void)drawInContext:(CGContextRef)ctx
{
    CGContextSetFillColorWithColor(ctx, [UIColor yellowColor].CGColor);
    CGContextFillRect (ctx, [self bounds]);
    CGContextSetAllowsFontSmoothing(ctx, true);
    CGContextSetShouldSmoothFonts (ctx, true);
    CGContextSetShouldAntialias(ctx, true);
    CGContextSetShouldSubpixelPositionFonts(ctx, true);
    [super drawInContext:ctx];
}
@end
