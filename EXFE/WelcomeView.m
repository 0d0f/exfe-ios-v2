//
//  WelcomeView.m
//  EXFE
//
//  Created by huoju on 9/4/12.
//
//

#import "WelcomeView.h"

@implementation WelcomeView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        gobutton = [UIButton buttonWithType:UIButtonTypeCustom];
        [gobutton setTitle:@"Go" forState:UIControlStateNormal];
        [gobutton.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:18]];
        [gobutton setTitleColor:FONT_COLOR_FA forState:UIControlStateNormal];
        [gobutton setBackgroundImage:[[UIImage imageNamed:@"btn_dark_44.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 6, 0, 6)]  forState:UIControlStateNormal];
        [gobutton addTarget:self action:@selector(goNext) forControlEvents:UIControlEventTouchUpInside];
        [gobutton setFrame:CGRectMake(40, 350, 200, 44)];
        [self addSubview:gobutton];
        [self initWelcome1];
        // Initialization code
    }
    return self;
}
- (void) initWelcome1{
    
    NSString *str1=@"Thanks for using EXFE\nA utility for hanging out with friends.\n\nWe save you from calling up every one RSVP, losing in endless emails and messages off the point.\n\n·X· (cross) is a gathering of people, for any intent. It’s private by default, everything inside is accessible to only attendees. When you get an idea to call up friends to do something together, just Gather a ·X·.\n\nEXFE your friends.";
    
    
    welcome1 = [[NSMutableAttributedString alloc] initWithString:str1];
    
    CTTextAlignment alignment = kCTLeftTextAlignment;
    float linespaceing=1;
    float minheight=18;
    
    CTParagraphStyleSetting allsetting[3] = {
        {kCTParagraphStyleSpecifierLineSpacing, sizeof(CGFloat), &linespaceing},
        {kCTParagraphStyleSpecifierMinimumLineHeight, sizeof(CGFloat), &minheight},
        {kCTParagraphStyleSpecifierAlignment, sizeof(alignment), &alignment},
    };
    CTParagraphStyleRef allstyle = CTParagraphStyleCreate(allsetting, 3);
    [welcome1 addAttribute:(id)kCTParagraphStyleAttributeName value:(id)allstyle range:NSMakeRange(0,[welcome1 length])];

    alignment = kCTCenterTextAlignment;

    CTParagraphStyleSetting psetting[3] = {
        {kCTParagraphStyleSpecifierLineSpacing, sizeof(CGFloat), &linespaceing},
        {kCTParagraphStyleSpecifierMinimumLineHeight, sizeof(CGFloat), &minheight},
        {kCTParagraphStyleSpecifierAlignment, sizeof(alignment), &alignment},
    };
    CTParagraphStyleRef pstyle = CTParagraphStyleCreate(psetting, 3);
    [welcome1 addAttribute:(id)kCTParagraphStyleAttributeName value:(id)pstyle range:NSMakeRange(0,[@"Thanks for using EXFE\nA utility for hanging out with friends." length])];
    [welcome1 addAttribute:(NSString*)kCTFontAttributeName value:(id)CTFontCreateWithName(CFSTR("HelveticaNeue"), 15.0, NULL) range:NSMakeRange(0,[welcome1 length])];

    [welcome1 addAttribute:(NSString*)kCTFontAttributeName value:(id)CTFontCreateWithName(CFSTR("HelveticaNeue"), 21.0, NULL) range:NSMakeRange(0,[@"Thanks for using EXFE" length])];
    
    [welcome1 addAttribute:(NSString*)kCTForegroundColorAttributeName value:(id)[UIColor whiteColor].CGColor range:NSMakeRange(0,[welcome1 length])];
    [welcome1 addAttribute:(NSString*)kCTForegroundColorAttributeName value:(id)FONT_COLOR_HL.CGColor range:NSMakeRange(0+[@"Thanks for using " length],4)];

    [welcome1 addAttribute:(NSString*)kCTForegroundColorAttributeName value:(id)FONT_COLOR_HL.CGColor range:NSMakeRange(0+[@"Thanks for using EXFE\nA utility for hanging out with friends.\n\nWe save you from calling up every one RSVP, losing in endless emails and messages off the point.\n\n" length],3)];

    [welcome1 addAttribute:(NSString*)kCTForegroundColorAttributeName value:(id)FONT_COLOR_HL.CGColor range:NSMakeRange([welcome1 length]-[@".\n\nEXFE your friends." length]-3,3)];
    [welcome1 addAttribute:(NSString*)kCTForegroundColorAttributeName value:(id)FONT_COLOR_HL.CGColor range:NSMakeRange([welcome1 length]-[@" your friends." length]-4,4)];
    [welcome1 addAttribute:(NSString*)kCTFontAttributeName value:(id)CTFontCreateWithName(CFSTR("HelveticaNeue-Italic"), 15.0, NULL) range:NSMakeRange([welcome1 length]-[@"Gather a ·X·.\n\nEXFE your friends." length],[@"Gather a ·X·" length])];


    
    

}

- (void) drawWelcome1{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    CGContextSetTextMatrix(context, CGAffineTransformIdentity);
    CGContextTranslateCTM(context, 0, self.bounds.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)welcome1);
    
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, CGRectMake(6, self.frame.size.height-30-276.5, 308, 276.5));
    CTFrameRef theFrame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, [welcome1 length]), path, NULL);
    CFRelease(framesetter);
    CFRelease(path);
    CTFrameDraw(theFrame, context);
    CFRelease(theFrame);
}
- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    CGFloat colors [] = {
        0/255.0f, 0/255.0f, 0/255.0f, 0.9,
        25/255.0f, 25/255.0f, 25/255.0f, 0.9
    };
    CGColorSpaceRef baseSpace = CGColorSpaceCreateDeviceRGB();
    CGGradientRef gradient = CGGradientCreateWithColorComponents(baseSpace, colors, NULL, 2);
    CGColorSpaceRelease(baseSpace);
    baseSpace = NULL;
    CGPoint startPoint = CGPointMake(CGRectGetMidX(rect), CGRectGetMinY(rect));
    CGPoint endPoint = CGPointMake(CGRectGetMidX(rect), CGRectGetMaxY(rect));
    CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, 0);
    CGGradientRelease(gradient), gradient = NULL;
    CGContextRestoreGState(context);
    [self drawWelcome1];
}

@end
