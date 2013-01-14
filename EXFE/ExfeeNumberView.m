//
//  ExfeeNumberView.m
//  EXFE
//
//  Created by huoju on 12/24/12.
//
//

#import "ExfeeNumberView.h"

@implementation ExfeeNumberView
@synthesize acceptednumber;
@synthesize allnumber;

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
    
    CGContextSetFillColorWithColor(currentContext, [UIColor colorWithWhite:0.96 alpha:1].CGColor);
    CGContextFillRect(currentContext, rect);
    
    
    CGContextSetFillColorWithColor(currentContext, [UIColor blackColor].CGColor);
    CGContextSetLineWidth(currentContext, 0.5);

    CGContextMoveToPoint(currentContext, 15, 13);    // This sets up the start point
    CGContextAddLineToPoint(currentContext, 44, 47); // This moves to the end point.
    
    CGContextStrokePath(currentContext);
    
    CTFontRef acceptedfontref= CTFontCreateWithName(CFSTR("HelveticaNeue-Light"), 26.0, NULL);
    
//    acceptednumber=55;

    NSMutableAttributedString *acceptedattribstring=[[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%i",acceptednumber]];
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

    CGPathAddRect(path, NULL,CGRectMake(0,rect.size.height-acceptedTextSize.height+3, 32, 32));
    CTFrameRef theFrame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, [acceptedattribstring length]), path, NULL);
    CFRelease(framesetter);
    CFRelease(path);
    CFRelease(acceptedfontref);
    CTFrameDraw(theFrame, currentContext);
    [acceptedattribstring release];

    
    CTFontRef allfontref= CTFontCreateWithName(CFSTR("HelveticaNeue-Light"), 20.0, NULL);
//    allnumber=88;
    NSMutableAttributedString *allattribstring=[[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%i",allnumber]];
    [allattribstring addAttribute:(NSString*)kCTFontAttributeName value:(id)allfontref range:NSMakeRange(0,[allattribstring length])];
    [allattribstring addAttribute:(NSString*)kCTForegroundColorAttributeName value:(id)FONT_COLOR_51.CGColor range:NSMakeRange(0,[allattribstring length])];
    
    paragraphstyle = CTParagraphStyleCreate(setting, 1);
    [allattribstring addAttribute:(id)kCTParagraphStyleAttributeName value:(id)paragraphstyle range:NSMakeRange(0,[allattribstring length])];
    CFRelease(paragraphstyle);
    
    framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)allattribstring);
    path = CGPathCreateMutable();
    CGSize allTextSize = CTFramesetterSuggestFrameSizeWithConstraints(framesetter, CFRangeMake(0, [allattribstring length]), nil, rect.size, &range);
    
    CGPathAddRect(path, NULL,CGRectMake(rect.size.width-24,rect.size.height-16-allTextSize.height-10, 24, 30));
    theFrame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, [allattribstring length]), path, NULL);
    CFRelease(framesetter);
    CFRelease(path);
    CFRelease(allfontref);
    CTFrameDraw(theFrame, currentContext);
    [allattribstring release];
    
    CTFontRef textfontref= CTFontCreateWithName(CFSTR("HelveticaNeue-Light"), 10.0, NULL);
    NSMutableAttributedString *textstring=[[NSMutableAttributedString alloc] initWithString:@"Accepted"];
    [textstring addAttribute:(NSString*)kCTFontAttributeName value:(id)textfontref range:NSMakeRange(0,[textstring length])];
    [textstring addAttribute:(NSString*)kCTForegroundColorAttributeName value:(id)FONT_COLOR_25.CGColor range:NSMakeRange(0,[textstring length])];
    
    paragraphstyle = CTParagraphStyleCreate(setting, 1);
    [textstring addAttribute:(id)kCTParagraphStyleAttributeName value:(id)paragraphstyle range:NSMakeRange(0,[textstring length])];
    CFRelease(paragraphstyle);
    
    framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)textstring);
    path = CGPathCreateMutable();
    CGPathAddRect(path, NULL,CGRectMake(0,0, rect.size.width, 12));
    theFrame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, [textstring length]), path, NULL);
    CFRelease(framesetter);
    CFRelease(path);
    CFRelease(textfontref);
    CTFrameDraw(theFrame, currentContext);
    [textstring release];
}

@end
