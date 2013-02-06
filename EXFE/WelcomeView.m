//
//  WelcomeView.m
//  EXFE
//
//  Created by huoju on 9/4/12.
//
//

#import "WelcomeView.h"

@implementation WelcomeView
@synthesize parent;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
//        gobutton = [UIButton buttonWithType:UIButtonTypeCustom];
//        [gobutton setTitle:@"Go" forState:UIControlStateNormal];
//        [gobutton.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:18]];
//        [gobutton setTitleColor:FONT_COLOR_FA forState:UIControlStateNormal];
//        [gobutton setBackgroundImage:[[UIImage imageNamed:@"btn_dark_44.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 6, 0, 6)]  forState:UIControlStateNormal];
//        [gobutton addTarget:self action:@selector(goNext) forControlEvents:UIControlEventTouchUpInside];
//        [gobutton setFrame:CGRectMake(50, self.frame.size.height-30-44, 200, 44)];
        
        closebutton = [UIButton buttonWithType:UIButtonTypeCustom];
        [closebutton setTitle:@"Close" forState:UIControlStateNormal];
        [closebutton.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:18]];
        [closebutton setTitleColor:FONT_COLOR_FA forState:UIControlStateNormal];
        [closebutton setBackgroundImage:[[UIImage imageNamed:@"btn_dark_44.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 6, 0, 6)]  forState:UIControlStateNormal];
        [closebutton addTarget:self action:@selector(closeWelcome) forControlEvents:UIControlEventTouchUpInside];
        [closebutton setFrame:CGRectMake(50, self.frame.size.height-30-44, 200, 44)];
        self.backgroundColor=[UIColor clearColor];
        [closebutton setHidden:NO];
//        [self addSubview:gobutton];
        [self addSubview:closebutton];
//        [self initWelcome1];
        [self initWelcome2];
//        self.layer.cornerRadius=5;
//        self.layer.masksToBounds=YES;
        viewpage=0;
        // Initialization code
    }
    return self;
}
- (void) initWelcome1{
    
    NSString *str1=@"Thanks for using EXFE\nA utility for gathering with friends.\n\nWe save you from calling up every one RSVP, losing in endless emails and messages off the point.\n\n·X· (cross) is a gathering of people, for any intent. It’s private by default, everything inside is accessible to only attendees. When you get an idea to call up friends to do something together, just Gather a ·X·.\n\nEXFE your friends.";
    
    
    welcome1 = [[NSMutableAttributedString alloc] initWithString:str1];
    
    CTTextAlignment alignment = kCTLeftTextAlignment;
    //float linespaceing=1;
    //float minheight=18;
    
    CTParagraphStyleSetting allsetting[3] = {
//        {kCTParagraphStyleSpecifierLineSpacing, sizeof(CGFloat), &linespaceing},
//        {kCTParagraphStyleSpecifierMinimumLineHeight, sizeof(CGFloat), &minheight},
        {kCTParagraphStyleSpecifierAlignment, sizeof(alignment), &alignment},
    };
    CTParagraphStyleRef allstyle = CTParagraphStyleCreate(allsetting, 3);
    [welcome1 addAttribute:(id)kCTParagraphStyleAttributeName value:(id)allstyle range:NSMakeRange(0,[welcome1 length])];

    alignment = kCTCenterTextAlignment;

    CTParagraphStyleSetting psetting[3] = {
//        {kCTParagraphStyleSpecifierLineSpacing, sizeof(CGFloat), &linespaceing},
//        {kCTParagraphStyleSpecifierMinimumLineHeight, sizeof(CGFloat), &minheight},
        {kCTParagraphStyleSpecifierAlignment, sizeof(alignment), &alignment},
    };
    CTParagraphStyleRef pstyle = CTParagraphStyleCreate(psetting, 3);
    [welcome1 addAttribute:(id)kCTParagraphStyleAttributeName value:(id)pstyle range:NSMakeRange(0,[@"Thanks for using EXFE\nA utility for gathering with friends." length])];
    [welcome1 addAttribute:(NSString*)kCTFontAttributeName value:(id)CTFontCreateWithName(CFSTR("HelveticaNeue"), 15.0, NULL) range:NSMakeRange(0,[welcome1 length])];

    [welcome1 addAttribute:(NSString*)kCTFontAttributeName value:(id)CTFontCreateWithName(CFSTR("HelveticaNeue"), 21.0, NULL) range:NSMakeRange(0,[@"Thanks for using EXFE" length])];
    
    [welcome1 addAttribute:(NSString*)kCTForegroundColorAttributeName value:(id)[UIColor whiteColor].CGColor range:NSMakeRange(0,[welcome1 length])];
    [welcome1 addAttribute:(NSString*)kCTForegroundColorAttributeName value:(id)FONT_COLOR_HL.CGColor range:NSMakeRange(0+[@"Thanks for using " length],4)];

    [welcome1 addAttribute:(NSString*)kCTForegroundColorAttributeName value:(id)FONT_COLOR_HL.CGColor range:NSMakeRange(0+[@"Thanks for using EXFE\nA utility for gathering with friends.\n\nWe save you from calling up every one RSVP, losing in endless emails and messages off the point.\n\n" length],3)];

    [welcome1 addAttribute:(NSString*)kCTForegroundColorAttributeName value:(id)FONT_COLOR_HL.CGColor range:NSMakeRange([welcome1 length]-[@".\n\nEXFE your friends." length]-3,3)];
    [welcome1 addAttribute:(NSString*)kCTForegroundColorAttributeName value:(id)FONT_COLOR_HL.CGColor range:NSMakeRange([welcome1 length]-[@" your friends." length]-4,4)];
    [welcome1 addAttribute:(NSString*)kCTFontAttributeName value:(id)CTFontCreateWithName(CFSTR("HelveticaNeue-Italic"), 15.0, NULL) range:NSMakeRange([welcome1 length]-[@"Gather a ·X·.\n\nEXFE your friends." length],[@"Gather a ·X·" length])];
}

- (void) drawWelcome2{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    CGContextSetTextMatrix(context, CGAffineTransformIdentity);
    CGContextTranslateCTM(context, 0, self.bounds.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    
    UIImage *rome=[UIImage imageNamed:@"rome.jpg"];
    CGImageRef romeref = CGImageRetain(rome.CGImage);
    CGContextDrawImage(context,CGRectMake(73, self.frame.size.height-276.5+120+10-40, 160, 120) , romeref);
    CGImageRelease(romeref);

    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)welcome2);
    
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, CGRectMake(6+20, self.frame.size.height-40-276.5-120-40-30, 308-20*2, 276.5));
    CTFrameRef theFrame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, [welcome2 length]), path, NULL);
    CFRelease(framesetter);
    CFRelease(path);
    CTFrameDraw(theFrame, context);
    CFRelease(theFrame);
    CGContextRestoreGState(context);
}

- (void) initWelcome2{
    NSString *str=@"“Rome wasn't built in a day.”\n\nEXFE [ˈɛksfi] is still in pilot stage. We’re building up blocks, consequently some bugs or unfinished pages may happen. Our apologies for any trouble you may encounter. Any feedback, please email feedback@exfe.com. Much appreciated.";
    
    welcome2 = [[NSMutableAttributedString alloc] initWithString:str];
    
    CTTextAlignment alignment = kCTCenterTextAlignment;
    //float linespaceing=1;
    //float minheight=18;
    
    CTParagraphStyleSetting allsetting[3] = {
//        {kCTParagraphStyleSpecifierLineSpacing, sizeof(CGFloat), &linespaceing},
//        {kCTParagraphStyleSpecifierMinimumLineHeight, sizeof(CGFloat), &minheight},
        {kCTParagraphStyleSpecifierAlignment, sizeof(alignment), &alignment},
    };
    CTParagraphStyleRef allstyle = CTParagraphStyleCreate(allsetting, 3);
    [welcome2 addAttribute:(id)kCTParagraphStyleAttributeName value:(id)allstyle range:NSMakeRange(0,[welcome2 length])];

    alignment = kCTLeftTextAlignment;

    CTParagraphStyleSetting psetting[3] = {
//        {kCTParagraphStyleSpecifierLineSpacing, sizeof(CGFloat), &linespaceing},
//        {kCTParagraphStyleSpecifierMinimumLineHeight, sizeof(CGFloat), &minheight},
        {kCTParagraphStyleSpecifierAlignment, sizeof(alignment), &alignment},
    };
    CTParagraphStyleRef pstyle = CTParagraphStyleCreate(psetting, 3);
    [welcome2 addAttribute:(id)kCTParagraphStyleAttributeName value:(id)pstyle range:NSMakeRange([@"“Rome wasn't built in a day.”\n\n" length],[welcome2 length]-[@"“Rome wasn't built in a day.”\n\n" length])];
    
    [welcome2 addAttribute:(NSString*)kCTFontAttributeName value:(id)CTFontCreateWithName(CFSTR("HelveticaNeue"), 14.0, NULL) range:NSMakeRange(0,[welcome2 length])];
    
    [welcome2 addAttribute:(NSString*)kCTFontAttributeName value:(id)CTFontCreateWithName(CFSTR("HelveticaNeue-Italic"), 14.0, NULL) range:NSMakeRange([@"“Rome wasn't built in a day.”\n\nEXFE [ˈɛksfi] is still in pilot stage. We’re building up blocks, consequently some bugs or unfinished pages may happen. Our apologies for any trouble you may encounter. Any feedback, please email " length],17)];

    
    [welcome2 addAttribute:(NSString*)kCTFontAttributeName value:(id)CTFontCreateWithName(CFSTR("HelveticaNeue"), 20.0, NULL) range:NSMakeRange(0,[@"“Rome wasn't built in a day.”" length])];
    
    [welcome2 addAttribute:(NSString*)kCTForegroundColorAttributeName value:(id)[UIColor whiteColor].CGColor range:NSMakeRange(0,[welcome2 length])];

    [welcome2 addAttribute:(NSString*)kCTForegroundColorAttributeName value:(id)FONT_COLOR_HL.CGColor range:NSMakeRange([@"“Rome wasn't built in a day.”\n\n" length],4)];
}
- (void) drawWelcome1{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    CGContextSetTextMatrix(context, CGAffineTransformIdentity);
    CGContextTranslateCTM(context, 0, self.bounds.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)welcome1);
    
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, CGRectMake(6+20, self.frame.size.height-30-276.5, 308-40, 276.5));
    CTFrameRef theFrame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, [welcome1 length]), path, NULL);
    CFRelease(framesetter);
    CFRelease(path);
    CTFrameDraw(theFrame, context);
    CFRelease(theFrame);
    CGContextRestoreGState(context);
}
- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextClearRect(context, rect);
    CGContextSaveGState(context);
    CGFloat colors [] = {
        21/255.0f, 51/255.0f, 83/255.0f, 1,
        25/255.0f, 25/255.0f, 25/255.0f, 1

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
    
//    CGRect innerrect= CGRectMake(5, 10, rect.size.width-20, rect.size.height-20);
//    CGContextSaveGState(context);
//    CGFloat colorsinner [] = {
//        21/255.0f, 51/255.0f, 83/255.0f, 0.9,
//        25/255.0f, 25/255.0f, 25/255.0f, 0.9
//    };
//    baseSpace = CGColorSpaceCreateDeviceRGB();
//    gradient = CGGradientCreateWithColorComponents(baseSpace, colorsinner, NULL, 2);
//    CGColorSpaceRelease(baseSpace);
//    baseSpace = NULL;
//    startPoint = CGPointMake(CGRectGetMidX(innerrect), CGRectGetMinY(innerrect));
//    endPoint = CGPointMake(CGRectGetMidX(innerrect), CGRectGetMaxY(innerrect));
//    CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, 0);
//    CGGradientRelease(gradient), gradient = NULL;
//    CGContextRestoreGState(context);

    
//    if(viewpage==0)
//        [self drawWelcome1];
//    else if(viewpage==1)
        [self drawWelcome2];
}
- (void) goNext{
    viewpage=1;
//    [gobutton setHidden:YES];
    [closebutton setHidden:NO];
    [self setNeedsDisplay];
}

- (void) closeWelcome{
        [self removeFromSuperview];
    
}

@end
