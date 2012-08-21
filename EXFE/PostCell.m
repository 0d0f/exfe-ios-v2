//
//  PostCell.m
//  EXFE
//
//  Created by ju huo on 6/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PostCell.h"
#import "Util.h"

@implementation PostCell
@synthesize content;
@synthesize avatar;
@synthesize time;
@synthesize relativetime;
@synthesize background;
@synthesize separator;
@synthesize avatarframe;
@synthesize identity_name;

- (void)setContent:(NSString *)s {
	[content release];
	content = [s copy];
	[self setNeedsDisplay]; 
}
- (void)setAvatar:(UIImage *)a {
	[avatar release];
	avatar = [a copy];
	[self setNeedsDisplay]; 
}

- (void)setTime:(NSString *)a {
	[time release];
	time = [a copy];
	[self setNeedsDisplay]; 
}
- (void)setRelativeTime:(NSString *)a {
	[relativetime release];
	relativetime = [a copy];
	[self setNeedsDisplay]; 
}


- (void)dealloc {
	[content release];
    [avatar release];
    [time release];
    [super dealloc];
}


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}
- (void)drawLayer:(CALayer *)theLayer
        inContext:(CGContextRef)theContext
{
    
}

- (void)layoutSubviews
{
	CGRect b = [self bounds];
	[contentView setFrame:b];
    [super layoutSubviews];
}
- (void) drawString:(CGContextRef) context  rect:(CGRect)r{
    
    CGContextSaveGState(context);
    CGFloat lineheight = 20;
    CGFloat linespacing = 0;
    CTParagraphStyleSetting setting[2] = {
        {kCTParagraphStyleSpecifierLineSpacing, sizeof(CGFloat), &linespacing},
        {kCTParagraphStyleSpecifierMinimumLineHeight, sizeof(CGFloat), &lineheight}
    };
    CTParagraphStyleRef style = CTParagraphStyleCreate(setting, 2);
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@   %@",identity_name,content]];
    
    [attributedString addAttribute:(NSString*)kCTFontAttributeName value:(id)CTFontCreateWithName(CFSTR("HelveticaNeue-Bold"), 14.0, NULL) range:NSMakeRange(0,[identity_name length])];
    
    [attributedString addAttribute:(NSString*)kCTFontAttributeName value:(id)CTFontCreateWithName(CFSTR("HelveticaNeue"), 14.0, NULL) range:NSMakeRange([identity_name length]+3,[content length])];

    [attributedString addAttribute:(id)kCTParagraphStyleAttributeName value:(id)style range:NSMakeRange(0,[content length])];
    [attributedString addAttribute:(id)kCTForegroundColorAttributeName value:(id)[FONT_COLOR_FA CGColor] range:NSMakeRange(0,[content length]+[identity_name length]+3)];

    
    CGContextSetTextMatrix(context, CGAffineTransformIdentity);
    CGContextTranslateCTM(context, 0, self.bounds.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)attributedString);
    CFRange range;
    CGSize coreTextSize = CTFramesetterSuggestFrameSizeWithConstraints(framesetter, CFRangeMake(0, [attributedString length]), nil, r.size, &range);
    CGMutablePathRef path = CGPathCreateMutable();
    int rectheight=r.size.height;
    r.origin.y=rectheight-coreTextSize.height-8;
    r.size.height=coreTextSize.height;
    CGPathAddRect(path, NULL, r);

    CTFrameRef theFrame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, [attributedString length]), path, NULL);
    CFRelease(framesetter);
    CFRelease(path);
    
    CTFrameDraw(theFrame, context);
    CFRelease(theFrame);
    [attributedString release];
    CGContextRestoreGState(context);
    
}
- (void)drawContentView:(CGRect)r{
    CGImageRef background_ref = CGImageRetain(background.CGImage);
    CGRect image_rect;
    image_rect.size = background.size;
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);

    CGContextDrawTiledImage(context, CGRectMake(0, 0, background.size.width, background.size.height), background_ref);
    CGImageRelease(background_ref);
    
    if(separator)
    {
        CGImageRef separator_ref = CGImageRetain(separator.CGImage);
        CGContextClipToRect(context, CGRectMake(AVATAR_LEFT_MERGIN+AVATAR_WIDTH, 0, r.size.width, 2));
        CGContextTranslateCTM(context, AVATAR_LEFT_MERGIN+AVATAR_WIDTH, separator.size.height);
        CGContextScaleCTM(context, 1.0, -1.0);
        CGContextDrawTiledImage(context, CGRectMake(0, 0, 1, 2), separator_ref);
        CGImageRelease(separator_ref);
        CGContextRestoreGState(context);
    }

    [[UIColor whiteColor] set];
    [self drawString:context rect:CGRectMake(AVATAR_LEFT_MERGIN+AVATAR_WIDTH+CELL_CONTENT_MARGIN_LEFT, 8, CELL_CONTENT_WIDTH,r.size.height)];
    
    if(avatar!=nil && ![avatar isKindOfClass:[NSNull class]])
    {
        float avatar_y=1;
//        if(text_height==20)
//            avatar_y=10;
        
        [avatar drawInRect:CGRectMake(AVATAR_LEFT_MERGIN, avatar_y, AVATAR_WIDTH, AVATAR_HEIGHT)];
        [avatarframe drawInRect:CGRectMake(AVATAR_LEFT_MERGIN-1, avatar_y, avatarframe.size.width, avatarframe.size.height)];
    }
    CGContextSaveGState(context);
    UIImage *v_line=[UIImage imageNamed:@"conv_line_v.png"];
    CGImageRef v_line_ref = CGImageRetain(v_line.CGImage);
    CGContextClipToRect(context, CGRectMake(AVATAR_LEFT_MERGIN+AVATAR_WIDTH-10, 0, 11, r.size.height));
    CGContextTranslateCTM(context, AVATAR_LEFT_MERGIN+AVATAR_WIDTH-10, v_line.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    CGContextDrawTiledImage(context, CGRectMake(0, 0, v_line.size.width, v_line.size.height), v_line_ref);
    CGImageRelease(v_line_ref);
    CGContextRestoreGState(context);
}
- (void) hiddenTime{
    showtime=NO;
    [self setNeedsDisplay];
}
- (void) setShowTime:(BOOL)show{
    showtime=show;
    [self setNeedsDisplay];
    if(show==YES){
//        [NSObject cancelPreviousPerformRequestsWithTarget:self];
//        [self performSelector:@selector(hiddenTime) withObject:nil afterDelay:2];
    }
}
@end
