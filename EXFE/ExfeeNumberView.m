//
//  ExfeeNumberView.m
//  EXFE
//
//  Created by huoju on 12/24/12.
//
//

#import "ExfeeNumberView.h"

@implementation ExfeeNumberView

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
    CGContextRef currentContext = UIGraphicsGetCurrentContext();
    CGContextSaveGState(currentContext);
    CGContextTranslateCTM(currentContext, 0, self.bounds.size.height);
    CGContextScaleCTM(currentContext, 1.0, -1.0);

    CGContextSetFillColorWithColor(currentContext, [UIColor blackColor].CGColor);
    CGContextSetLineWidth(currentContext, 1);

    CGContextMoveToPoint(currentContext, 0, 0);    // This sets up the start point
    CGContextAddLineToPoint(currentContext, 50, 50); // This moves to the end point.
    CGContextStrokePath(currentContext);
    
    CTFontRef acceptedfontref= CTFontCreateWithName(CFSTR("HelveticaNeue"), 24.0, NULL);
    NSMutableAttributedString *acceptedattribstring=[[NSMutableAttributedString alloc] initWithString:@"55"];
    [acceptedattribstring addAttribute:(NSString*)kCTFontAttributeName value:(id)acceptedfontref range:NSMakeRange(0,[acceptedattribstring length])];
    [acceptedattribstring addAttribute:(NSString*)kCTForegroundColorAttributeName value:(id)FONT_COLOR_HL.CGColor range:NSMakeRange(0,[acceptedattribstring length])];
    
    CTTextAlignment alignment = kCTCenterTextAlignment;
    CTParagraphStyleSetting setting[1] = {
        {kCTParagraphStyleSpecifierAlignment, sizeof(alignment), &alignment}
    };
    CTParagraphStyleRef paragraphstyle = CTParagraphStyleCreate(setting, 1);
    [acceptedattribstring addAttribute:(id)kCTParagraphStyleAttributeName value:(id)paragraphstyle range:NSMakeRange(0,[acceptedattribstring length])];
    CFRelease(paragraphstyle);
    
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)acceptedattribstring);
    CGMutablePathRef path = CGPathCreateMutable();

    CFRange range;
    CGSize acceptedTextSize = CTFramesetterSuggestFrameSizeWithConstraints(framesetter, CFRangeMake(0, [acceptedattribstring length]), nil, rect.size, &range);

    CGPathAddRect(path, NULL,CGRectMake(0,rect.size.height-acceptedTextSize.height, 30, 30));
    CTFrameRef theFrame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, [acceptedattribstring length]), path, NULL);
    CFRelease(framesetter);
    CFRelease(path);
    CFRelease(acceptedfontref);
    CTFrameDraw(theFrame, currentContext);
    [acceptedattribstring release];

    
    CTFontRef allfontref= CTFontCreateWithName(CFSTR("HelveticaNeue"), 24.0, NULL);
    NSMutableAttributedString *allattribstring=[[NSMutableAttributedString alloc] initWithString:@"88"];
    [allattribstring addAttribute:(NSString*)kCTFontAttributeName value:(id)allfontref range:NSMakeRange(0,[allattribstring length])];
    [allattribstring addAttribute:(NSString*)kCTForegroundColorAttributeName value:(id)FONT_COLOR_51.CGColor range:NSMakeRange(0,[allattribstring length])];
    
    paragraphstyle = CTParagraphStyleCreate(setting, 1);
    [allattribstring addAttribute:(id)kCTParagraphStyleAttributeName value:(id)paragraphstyle range:NSMakeRange(0,[allattribstring length])];
    CFRelease(paragraphstyle);
    
    framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)allattribstring);
    path = CGPathCreateMutable();
    CGSize allTextSize = CTFramesetterSuggestFrameSizeWithConstraints(framesetter, CFRangeMake(0, [allattribstring length]), nil, rect.size, &range);
    
    CGPathAddRect(path, NULL,CGRectMake(15,0, 30, 30));
    theFrame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, [allattribstring length]), path, NULL);
    CFRelease(framesetter);
    CFRelease(path);
    CFRelease(allfontref);
    CTFrameDraw(theFrame, currentContext);
    [allattribstring release];

}

@end
