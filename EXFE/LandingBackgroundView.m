//
//  LandingBackground.m
//  EXFE
//
//  Created by huoju on 8/22/12.
//
//

#import "LandingBackgroundView.h"

@implementation LandingBackgroundView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void) drawCircle:(CGPoint)center radius:(float)r str:(NSAttributedString*)str isRing:(BOOL)isring{
    if(circleRects==nil)
       circleRects=[[NSMutableDictionary alloc] initWithCapacity:4];

    [[UIColor colorWithRed:228/255.0f green:247/255.0f blue:253/255.0f alpha:1] setFill];
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    CGContextSetTextMatrix(context, CGAffineTransformIdentity);
    CGContextTranslateCTM(context, 0, self.bounds.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);

    CGMutablePathRef circlepath = CGPathCreateMutable();
    CGPathMoveToPoint(circlepath, NULL, center.x, center.y);
    CGPathAddArc(circlepath, NULL, center.x, center.y, r , 2*M_PI, 0, YES);
    CGPathCloseSubpath(circlepath);
    CGContextAddPath(context, circlepath);
    CGContextClosePath(context);
    if(isring==NO){
        CGContextFillPath(context);
        if(str !=nil){
            CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)str);
            CFRange range;
            float rectl=r*sqrtf(2);
            CGSize coreTextSize = CTFramesetterSuggestFrameSizeWithConstraints(framesetter, CFRangeMake(0, [str length]), nil, CGSizeMake(r*2,rectl), &range);
            CGRect rect=CGRectMake(center.x-coreTextSize.width/2,center.y-coreTextSize.height/2, coreTextSize.width,coreTextSize.height);
            CGMutablePathRef textpath = CGPathCreateMutable();
            CGPathAddRect(textpath, NULL, rect);
            CTFrameRef theFrame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, [str length]), textpath, NULL);
            CFRelease(framesetter);
            CFRelease(textpath);
            CTFrameDraw(theFrame, context);
            CFRelease(theFrame);
        }
    }
    CGPathRelease(circlepath);

    if(isring==YES){
        CGMutablePathRef circlepathinner = CGPathCreateMutable();
        CGPathMoveToPoint(circlepathinner, NULL, center.x, center.y);
        CGPathAddArc(circlepathinner, NULL, center.x, center.y, r-2 , 2*M_PI, 0, YES);
        CGPathCloseSubpath(circlepathinner);
        CGContextAddPath(context, circlepathinner);
        CGContextClosePath(context);
        CGContextEOFillPath(context);
        CGPathRelease(circlepathinner);
        
    }
    CGContextRestoreGState(context);
}
- (void) drawBigTitle{
    NSAttributedString *bigtitle=titleexfe;
    int y=self.frame.size.height-30-64;
    if(bigtitlename!=nil){
        if([bigtitlename isEqualToString:@"thex"]){
            bigtitle=titlethex;
            y=self.frame.size.height-30-64;
        }
        else if([bigtitlename isEqualToString:@"rsvp"]){
            bigtitle=titlersvp;
            y=self.frame.size.height-30-64-(64-50);
        }
        else if([bigtitlename isEqualToString:@"handy"]){
            bigtitle=titlehandy;
            y=self.frame.size.height-30-64-(64-50);
        }
        else if([bigtitlename isEqualToString:@"safe"]){
            bigtitle=titlesafe;
            y=self.frame.size.height-30-64-(64-50);
        }
        else if([bigtitlename isEqualToString:@"exfe"]){
            bigtitle=titleexfe;
            y=self.frame.size.height-30-64;
        }
    }
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    CGContextSetTextMatrix(context, CGAffineTransformIdentity);
    CGContextTranslateCTM(context, 0, self.bounds.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)bigtitle);
    CFRange range;
    CGRect rectstrthex=CGRectMake(0,y,320,64);
    CGMutablePathRef textpath = CGPathCreateMutable();
    CGPathAddRect(textpath, NULL, rectstrthex);
    CTFrameRef theFrame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, [bigtitle length]), textpath, NULL);
    CFRelease(framesetter);
    CFRelease(textpath);
    CTFrameDraw(theFrame, context);
    CFRelease(theFrame);
    CGContextRestoreGState(context);
}
- (void)drawRect:(CGRect)rect
{
    [self initAttributedString];
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    CGFloat colors [] = {
        72/255.0f, 101/255.0f, 133/255.0f, 0.95,
        173/255.0f, 204/255.0f, 237/255.0f, 0.95
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
    CGContextSaveGState(context);
    CGContextTranslateCTM(context, 0, self.bounds.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);

    UIImage *ximg=[UIImage imageNamed:@"exfe_170.png"];
    CGImageRef ximageref = CGImageRetain(ximg.CGImage);
    float logo_y=self.frame.size.height-164-182;
    logorect=CGRectMake(69,logo_y, 182, 182);
    CGContextDrawImage(context,logorect , ximageref);
    CGImageRelease(ximageref);
    CGContextRestoreGState(context);

    float centerx=182/2+69;
    float centery=182/2+logo_y;
    
    float l_r=self.frame.size.width/2;
    int angle=-45;
    float t_y=l_r*sin(angle/360.0*M_PI*2);
    float t_x=l_r*cos(angle/360.0*M_PI*2);
    int circle_r=17.0;
    BOOL isring=NO;
    
    NSMutableAttributedString *handy=[[[NSMutableAttributedString alloc] initWithString:@"Handy"] autorelease];
    
    CTFontRef handyfontref=CTFontCreateWithName(CFSTR("HelveticaNeue"), 10.0, NULL);
    [handy addAttribute:(NSString*)kCTFontAttributeName value:(id)handyfontref range:NSMakeRange(0,[handy length])];
    CFRelease(handyfontref);
    [handy addAttribute:(NSString*)kCTForegroundColorAttributeName value:(id)[UIColor colorWithRed:21/255.0f green:52/255.0f blue:84/255.0f alpha:1].CGColor range:NSMakeRange(0,[handy length])];
    if([bigtitlename isEqualToString:@"handy"])
        isring=NO;
    else
        isring=YES;

    [self drawCircle:CGPointMake(centerx+t_x, centery+t_y) radius:circle_r str:handy isRing:isring];
    
    [circleRects setObject:[NSValue valueWithCGRect:CGRectMake(centerx+t_x-circle_r, centery+t_y-circle_r, 2*circle_r, 2*circle_r)] forKey:@"handy"];
    
    angle=-150;
    t_y=l_r*sin(angle/360.0*M_PI*2);
    t_x=l_r*cos(angle/360.0*M_PI*2);
    NSMutableAttributedString *safe=[[[NSMutableAttributedString alloc] initWithString:@"Safe"] autorelease];
    CTFontRef safefontref=CTFontCreateWithName(CFSTR("HelveticaNeue-Italic"), 14.0, NULL);
    [safe addAttribute:(NSString*)kCTFontAttributeName value:(id)safefontref range:NSMakeRange(0,[safe length])];
    CFRelease(safefontref);
    [safe addAttribute:(NSString*)kCTForegroundColorAttributeName value:(id)[UIColor colorWithRed:21/255.0f green:52/255.0f blue:84/255.0f alpha:1].CGColor range:NSMakeRange(0,[safe length])];
    if([bigtitlename isEqualToString:@"safe"])
        isring=NO;
    else
        isring=YES;
    [self drawCircle:CGPointMake(centerx+t_x, centery+t_y) radius:17.0 str:safe isRing:isring];
    [circleRects setObject:[NSValue valueWithCGRect:CGRectMake(centerx+t_x-circle_r, centery+t_y-circle_r, 2*circle_r, 2*circle_r)] forKey:@"safe"];

    angle=135;

    t_y=l_r*sin(angle/360.0*M_PI*2);
    t_x=l_r*cos(angle/360.0*M_PI*2);
    NSMutableAttributedString *thex=[[[NSMutableAttributedString alloc] initWithString:@"·X·"] autorelease];
    CTFontRef thexfontref=CTFontCreateWithName(CFSTR("HelveticaNeue"), 18.0, NULL) ;
    [thex addAttribute:(NSString*)kCTFontAttributeName value:(id)thexfontref range:NSMakeRange(0,[thex length])];
    CFRelease(thexfontref);
    [thex addAttribute:(NSString*)kCTForegroundColorAttributeName value:(id)FONT_COLOR_HL.CGColor range:NSMakeRange(0,[thex length])];
    if([bigtitlename isEqualToString:@"thex"])
        isring=NO;
    else
        isring=YES;
    [self drawCircle:CGPointMake(centerx+t_x, centery+t_y) radius:17.0 str:thex isRing:isring];
    [circleRects setObject:[NSValue valueWithCGRect:CGRectMake(centerx+t_x-circle_r, centery+t_y-circle_r, 2*circle_r, 2*circle_r)] forKey:@"thex"];

    
    angle=30;
    t_y=l_r*sin(angle/360.0*M_PI*2);
    t_x=l_r*cos(angle/360.0*M_PI*2);
    NSMutableAttributedString *rsvp=[[[NSMutableAttributedString alloc] initWithString:@"RSVP"] autorelease];
    CTFontRef rsvpfontref=CTFontCreateWithName(CFSTR("HelveticaNeue-Italic"), 11.0, NULL);
    [rsvp addAttribute:(NSString*)kCTFontAttributeName value:(id)rsvpfontref range:NSMakeRange(0,[rsvp length])];
    CFRelease(rsvpfontref);
    [rsvp addAttribute:(NSString*)kCTForegroundColorAttributeName value:(id)[UIColor colorWithRed:21/255.0f green:52/255.0f blue:84/255.0f alpha:1].CGColor range:NSMakeRange(0,[rsvp length])];
    if([bigtitlename isEqualToString:@"rsvp"])
        isring=NO;
    else
        isring=YES;

    [self drawCircle:CGPointMake(centerx+t_x, centery+t_y) radius:17.0 str:rsvp isRing:isring];
    [circleRects setObject:[NSValue valueWithCGRect:CGRectMake(centerx+t_x-circle_r, centery+t_y-circle_r, 2*circle_r, 2*circle_r)] forKey:@"rsvp"];
    [self drawBigTitle];
}
- (void) initAttributedString{
    CTFontRef titlefont32ref=CTFontCreateWithName(CFSTR("HelveticaNeue"), 32, NULL);
    CTFontRef titlefont12ref=CTFontCreateWithName(CFSTR("HelveticaNeue"), 12, NULL);
    CTFontRef titlefont18ref=CTFontCreateWithName(CFSTR("HelveticaNeue"), 18, NULL);
    
    if(titleexfe==nil){
        titleexfe=[[NSMutableAttributedString alloc] initWithString:@"       EXFE [’ɛksfi]\nA utility for hanging out with friends."];
        [titleexfe addAttribute:(NSString*)kCTFontAttributeName value:(id)titlefont12ref range:NSMakeRange(0,7)];
        [titleexfe addAttribute:(NSString*)kCTFontAttributeName value:(id)titlefont32ref range:NSMakeRange(0+7,5)];
        [titleexfe addAttribute:(NSString*)kCTFontAttributeName value:(id)titlefont12ref range:NSMakeRange(6+7,7)];
        [titleexfe addAttribute:(NSString*)kCTFontAttributeName value:(id)titlefont18ref range:NSMakeRange(14+7,[titleexfe length]-14-7)];
        [titleexfe addAttribute:(NSString*)kCTForegroundColorAttributeName value:(id)FONT_COLOR_FA.CGColor range:NSMakeRange(0,[titleexfe length])];
        
        
        CTTextAlignment alignment = kCTCenterTextAlignment;
        CTParagraphStyleSetting titlesetting[1] = {
            {kCTParagraphStyleSpecifierAlignment, sizeof(alignment), &alignment}
        };
        CTParagraphStyleRef titlestyle = CTParagraphStyleCreate(titlesetting, 1);
        [titleexfe addAttribute:(id)kCTParagraphStyleAttributeName value:(id)titlestyle range:NSMakeRange(0,[titleexfe length])];
    }
    if(titlethex==nil){
        titlethex=[[NSMutableAttributedString alloc] initWithString:@"        ·X· (cross)\nA gathering of people for any intent."];
        [titlethex addAttribute:(NSString*)kCTFontAttributeName value:(id)titlefont12ref range:NSMakeRange(0,8)];
        [titlethex addAttribute:(NSString*)kCTFontAttributeName value:(id)titlefont32ref range:NSMakeRange(0+8,4)];
        [titlethex addAttribute:(NSString*)kCTFontAttributeName value:(id)titlefont12ref range:NSMakeRange(5+8,7)];
        [titlethex addAttribute:(NSString*)kCTFontAttributeName value:(id)titlefont18ref range:NSMakeRange(13+8,[titlethex length]-13-8)];
        
        [titlethex addAttribute:(NSString*)kCTForegroundColorAttributeName value:(id)FONT_COLOR_FA.CGColor range:NSMakeRange(0,[titlethex length])];
        
        CTTextAlignment alignment = kCTCenterTextAlignment;
        CTParagraphStyleSetting titlesetting[1] = {
            {kCTParagraphStyleSpecifierAlignment, sizeof(alignment), &alignment}
        };
        CTParagraphStyleRef titlestyle = CTParagraphStyleCreate(titlesetting, 1);
        [titlethex addAttribute:(id)kCTParagraphStyleAttributeName value:(id)titlestyle range:NSMakeRange(0,[titlethex length])];
    }
    if(titlesafe==nil)
    {
        titlesafe=[[NSMutableAttributedString alloc] initWithString:@"Private,\nattendee access only."];
        [titlesafe addAttribute:(NSString*)kCTFontAttributeName value:(id)titlefont18ref range:NSMakeRange(0,[titlesafe length])];

        [titlesafe addAttribute:(NSString*)kCTForegroundColorAttributeName value:(id)FONT_COLOR_FA.CGColor range:NSMakeRange(0,[titlesafe length])];
        
        CTTextAlignment alignment = kCTCenterTextAlignment;
        CTParagraphStyleSetting titlesetting[1] = {
            {kCTParagraphStyleSpecifierAlignment, sizeof(alignment), &alignment}
        };
        CTParagraphStyleRef titlestyle = CTParagraphStyleCreate(titlesetting, 1);
        [titlesafe addAttribute:(id)kCTParagraphStyleAttributeName value:(id)titlestyle range:NSMakeRange(0,[titlesafe length])];
    }
    if(titlersvp==nil){
        titlersvp=[[NSMutableAttributedString alloc] initWithString:@"No more endless calls,\nemails, messages off-the-point."];
        [titlersvp addAttribute:(NSString*)kCTFontAttributeName value:(id)titlefont18ref range:NSMakeRange(0,[titlersvp length])];
        
        [titlersvp addAttribute:(NSString*)kCTForegroundColorAttributeName value:(id)FONT_COLOR_FA.CGColor range:NSMakeRange(0,[titlersvp length])];
        
        CTTextAlignment alignment = kCTCenterTextAlignment;
        CTParagraphStyleSetting titlesetting[1] = {
            {kCTParagraphStyleSpecifierAlignment, sizeof(alignment), &alignment}
        };
        CTParagraphStyleRef titlestyle = CTParagraphStyleCreate(titlesetting, 1);
        [titlersvp addAttribute:(id)kCTParagraphStyleAttributeName value:(id)titlestyle range:NSMakeRange(0,[titlersvp length])];
    }
    if(titlehandy==nil){
        titlehandy=[[NSMutableAttributedString alloc] initWithString:@"Connected,\nwith tools & apps you preferred."];
        [titlehandy addAttribute:(NSString*)kCTFontAttributeName value:(id)titlefont18ref range:NSMakeRange(0,[titlehandy length])];
        
        [titlehandy addAttribute:(NSString*)kCTForegroundColorAttributeName value:(id)FONT_COLOR_FA.CGColor range:NSMakeRange(0,[titlehandy length])];
        
        CTTextAlignment alignment = kCTCenterTextAlignment;
        CTParagraphStyleSetting titlesetting[1] = {
            {kCTParagraphStyleSpecifierAlignment, sizeof(alignment), &alignment}
        };
        CTParagraphStyleRef titlestyle = CTParagraphStyleCreate(titlesetting, 1);
        [titlehandy addAttribute:(id)kCTParagraphStyleAttributeName value:(id)titlestyle range:NSMakeRange(0,[titlehandy length])];
    }
    CFRelease(titlefont32ref);
    CFRelease(titlefont12ref);
    CFRelease(titlefont18ref);
 
    
        
}
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    NSSet *touchforview=[event touchesForView:self];
    for (UITouch *touch in touchforview){
        CGPoint location = [touch locationInView:self];
        NSArray *keys=[circleRects allKeys];
        for(NSString *key in keys) {
            NSValue *value=[circleRects objectForKey:key];
            CGRect rect=[value CGRectValue];
            float new_y=self.frame.size.height-rect.origin.y;
            new_y=new_y-rect.size.height;
            rect.origin.y=new_y;
            if(CGRectContainsPoint(rect, location)){
                if([key isEqualToString:@"thex"])
                    [self touch_thex];
                else if([key isEqualToString:@"rsvp"])
                    [self touch_rsvp];
                else if([key isEqualToString:@"handy"])
                    [self touch_handy];
                else if([key isEqualToString:@"safe"])
                    [self touch_safe];
                return;
            }
        }
        if(CGRectContainsPoint(logorect, location)){
            bigtitlename=@"exfe";
            [self setNeedsDisplay];
        }
    }
        
}
- (void) dealloc{
    [titleexfe release];
    [titlethex release];
    [titlersvp release];
    [titlehandy release];
    [titlesafe release];
    [circleRects release];
    [super dealloc];
}

- (void) touch_thex{
    bigtitlename=@"thex";
    [self setNeedsDisplay];
}
- (void) touch_rsvp{
    bigtitlename=@"rsvp";
    [self setNeedsDisplay];
}
- (void) touch_handy{
    bigtitlename=@"handy";
    [self setNeedsDisplay];
}
- (void) touch_safe{
    bigtitlename=@"safe";
    [self setNeedsDisplay];
}

@end
