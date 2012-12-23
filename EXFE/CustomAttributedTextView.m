//
//  CustomAttributedTextView.m
//  EXFE
//
//  Created by huoju on 12/18/12.
//
//

#import "CustomAttributedTextView.h"

@implementation CustomAttributedTextView
@synthesize text;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initializatio8n code
    }
    return self;
}

- (void)setText:(NSString *)s {
	[text release];
	text = [s copy];
	[self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
//    [text drawInRect:rect];
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    
    CGContextSetTextMatrix(context, CGAffineTransformIdentity);
    CGContextTranslateCTM(context, 0, self.bounds.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    CGContextSetShadowWithColor(context, CGSizeMake(0, 1.0f), 1.0f, [UIColor blackColor].CGColor);

    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)text);
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, rect);
    CTFrameRef theFrame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, [text length]), path, NULL);
    CFRelease(framesetter);
    CFRelease(path);
    CTFrameDraw(theFrame, context);
    CFRelease(theFrame);
    
}

@end
