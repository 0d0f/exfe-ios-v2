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
@synthesize text_height;
@synthesize avatarframe;

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
//    UIGraphicsPushContext(theContext);
//    CGContextSetShouldSmoothFonts(theContext, YES);
//    CGContextSetAllowsAntialiasing(theContext, true);
//    CGContextSetShouldAntialias(theContext, true);
//    CGSize timesize=[time sizeWithFont:[UIFont fontWithName:@"HelveticaNeue" size:10] constrainedToSize:CGSizeMake(100, 13) lineBreakMode:NSLineBreakByTruncatingTail];
////    [[UIImage imageNamed:@"chat.png"] drawAtPoint:CGPointMake(0, 0)];
//    [[UIColor whiteColor] set];
//    [time drawInRect:CGRectMake(0, 3, timesize.width, timesize.height) withFont:[UIFont fontWithName:@"HelveticaNeue" size:10]];
//    [relativetime drawInRect:CGRectMake(0, 3+timesize.height+1, timesize.width, timesize.height) withFont:[UIFont fontWithName:@"HelveticaNeue" size:10]];
//    UIGraphicsPopContext();
    
}

- (void)layoutSubviews
{
	CGRect b = [self bounds];
	[contentView setFrame:b];
    [super layoutSubviews];
}

- (void)drawContentView:(CGRect)r{
    CGImageRef background_ref = CGImageRetain(background.CGImage);
    CGRect image_rect;
    image_rect.size = background.size;
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);

    CGContextDrawTiledImage(context, CGRectMake(0, 0, background.size.width, background.size.height), background_ref);
    CGImageRelease(background_ref);
    
    CGImageRef separator_ref = CGImageRetain(separator.CGImage);
    CGContextClipToRect(context, CGRectMake(AVATAR_LEFT_MERGIN+AVATAR_WIDTH, 0, r.size.width, 2));
    CGContextTranslateCTM(context, AVATAR_LEFT_MERGIN+AVATAR_WIDTH, separator.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    CGContextDrawTiledImage(context, CGRectMake(0, 0, 1, 2), separator_ref);
    CGImageRelease(separator_ref);
    CGContextRestoreGState(context);
    

    [[UIColor whiteColor] set];
    [content drawInRect:CGRectMake(AVATAR_LEFT_MERGIN+AVATAR_WIDTH+CELL_CONTENT_MARGIN_LEFT, CELL_CONTENT_MARGIN_TOP, CELL_CONTENT_WIDTH,text_height ) withFont:[UIFont fontWithName:@"HelveticaNeue" size:FONT_SIZE]];
    
    if(avatar!=nil && ![avatar isKindOfClass:[NSNull class]])
    {
        float avatar_y=1;
        if(text_height==20)
            avatar_y=10;
        
        [avatar drawInRect:CGRectMake(AVATAR_LEFT_MERGIN, avatar_y, AVATAR_WIDTH, AVATAR_HEIGHT)];
        [avatarframe drawInRect:CGRectMake(AVATAR_LEFT_MERGIN-1, avatar_y, avatarframe.size.width, avatarframe.size.height)];
    }
    CGContextSaveGState(context);
    UIImage *v_line=[UIImage imageNamed:@"conversation_line_v.png"];
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
