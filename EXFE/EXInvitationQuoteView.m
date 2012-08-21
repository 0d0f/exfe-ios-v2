//
//  EXInvitationQuoteView.m
//  EXFE
//
//  Created by huoju on 8/18/12.
//
//

#import "EXInvitationQuoteView.h"

@implementation EXInvitationQuoteView
@synthesize invitation;
@synthesize Line1;
@synthesize Line2;
@synthesize Line3;
@synthesize point;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
    }
    return self;
}


- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);

    CGContextSetTextMatrix(context, CGAffineTransformIdentity);
    CGContextTranslateCTM(context, 0, self.bounds.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)Line1);
    CFRange range;
    CGSize Line1coreTextSize = CTFramesetterSuggestFrameSizeWithConstraints(framesetter, CFRangeMake(0, [Line1 length]), nil, CGSizeMake(rect.size.width, 18), &range);
    CGRect titlerect=CGRectMake(10, rect.size.height-4-Line1coreTextSize.height, rect.size.width-20, Line1coreTextSize.height);
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, titlerect);
    CTFrameRef theFrame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, [Line1 length]), path, NULL);
    CFRelease(framesetter);
    CFRelease(path);
    CTFrameDraw(theFrame, context);
    CFRelease(theFrame);
    
    CTFramesetterRef framesetterLine2 = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)Line2);
    CGSize Line2coreTextSize = CTFramesetterSuggestFrameSizeWithConstraints(framesetterLine2, CFRangeMake(0, [Line2 length]), nil, CGSizeMake(rect.size.width-20-19, 13), &range);
    CGRect line2rect=CGRectMake(10+19+3, rect.size.height-4-Line1coreTextSize.height-Line2coreTextSize.height, rect.size.width-20, Line2coreTextSize.height);
    CGMutablePathRef pathline2 = CGPathCreateMutable();
    CGPathAddRect(pathline2, NULL, line2rect);
    CTFrameRef theFrameline2 = CTFramesetterCreateFrame(framesetterLine2, CFRangeMake(0, [Line2 length]), pathline2, NULL);
    CFRelease(framesetterLine2);
    CFRelease(pathline2);
    CTFrameDraw(theFrameline2, context);
    CFRelease(theFrameline2);
  
    CTFramesetterRef framesetterLine3 = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)Line3);
    CGSize Line3coreTextSize = CTFramesetterSuggestFrameSizeWithConstraints(framesetterLine3, CFRangeMake(0, [Line3 length]), nil, CGSizeMake(150, 13), &range);
    
    CGRect line3rect=CGRectMake(rect.size.width-10-150, rect.size.height-4-Line1coreTextSize.height-Line2coreTextSize.height-Line3coreTextSize.height, 150, Line3coreTextSize.height);
    CGMutablePathRef pathline3 = CGPathCreateMutable();
    CGPathAddRect(pathline3, NULL, line3rect);
    CTFrameRef theFrameline3 = CTFramesetterCreateFrame(framesetterLine3, CFRangeMake(0, [Line3 length]), pathline3, NULL);
    CFRelease(framesetterLine3);
    CFRelease(pathline3);
    CTFrameDraw(theFrameline3, context);
    CFRelease(theFrameline3);
    
    NSString *iconname=[NSString stringWithFormat:@"identity_%@_18.png",invitation.identity.provider];
    UIImage *icon=[UIImage imageNamed:iconname];
    CGImageRef imageref = CGImageRetain(icon.CGImage);
    CGContextDrawImage(context,CGRectMake(10, rect.size.height-4-Line1coreTextSize.height-18+2, 18, 18),imageref);
    CGImageRelease(imageref);
}

@end
