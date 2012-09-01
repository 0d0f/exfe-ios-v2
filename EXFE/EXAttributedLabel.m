//
//  EXAttributedLabel.m
//  EXFE
//
//  Created by huoju on 8/29/12.
//
//

#import "EXAttributedLabel.h"

@implementation EXAttributedLabel
@synthesize attributedText;

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
    if(attributedText!=nil)
    {
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextSaveGState(context);
        CGContextSetTextMatrix(context, CGAffineTransformIdentity);
        CGContextTranslateCTM(context, 0, self.bounds.size.height);
        CGContextScaleCTM(context, 1.0, -1.0);

        CFAttributedStringRef attributedTextref=(CFAttributedStringRef)attributedText;
        CTFramesetterRef framesetterattributedText = CTFramesetterCreateWithAttributedString(attributedTextref);
        CGMutablePathRef path = CGPathCreateMutable();
        CGPathAddRect(path, NULL, rect);
        CTFrameRef theFrame = CTFramesetterCreateFrame(framesetterattributedText, CFRangeMake(0, [attributedText length]), path, NULL);
        CFRelease(framesetterattributedText);
        CFRelease(path);
        CTFrameDraw(theFrame, context);
        CFRelease(theFrame);
        CGContextRestoreGState(context);
    }
}

@end
