//
//  CrossCard.m
//  EXFE
//
//  Created by Stony on 12/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CrossCard.h"
#import "Util.h"

#define CARD_VERTICAL_MARGIN      (15)

@implementation CrossCard
@synthesize title;
@synthesize avatar;
@synthesize time;
@synthesize place;
@synthesize bannerimg;
@synthesize conversationCount;
@synthesize hlTitle;
@synthesize hlTime;
@synthesize hlPlace;
@synthesize hlConversation;
@synthesize cross_id;
@synthesize delegate;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if(self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]){
        UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
        gestureRecognizer.delegate = self;
        [self addGestureRecognizer:gestureRecognizer];
        [gestureRecognizer release];
        
        barnnerRect = CGRectZero;
        textbarRect = CGRectZero;
        titleRect = CGRectZero;
        avatarRect = CGRectZero;
        timeRect = CGRectZero;
        convRect = CGRectZero;
        placeRect = CGRectZero;
        timeFadingRect = CGRectZero;
        placeFadingRect = CGRectZero;
        CGRect b = [self bounds];
        
        barnnerRect = CGRectMake(b.origin.x + CARD_VERTICAL_MARGIN, b.origin.y + 8, b.size.width - CARD_VERTICAL_MARGIN * 2, 45);
        textbarRect = CGRectMake(b.origin.x + CARD_VERTICAL_MARGIN, barnnerRect.origin.y + barnnerRect.size.height, b.size.width - CARD_VERTICAL_MARGIN * 2, 28);
//        CGFloat fh = CGRectGetWidth(barnnerRect) * 495 / 880.0f;
//        bannerImgRect = CGRectMake(CGRectGetMinX(barnnerRect), CGRectGetMinY(barnnerRect) - fh * 0.4, CGRectGetWidth(barnnerRect), fh);
        CGFloat paddingH = 8;
        CGFloat paddingHM = 6;
        CGFloat avatarWidth = 22;
        CGFloat avatarHeight = 22;
        CGFloat titlePaddingV = 12;
        CGFloat convw = 0;
        CGFloat conv_width = 36;
        CGFloat conv_height = 33;
        CGFloat titlePaddingRight = 4;
        convRect = CGRectMake(CGRectGetMaxX(barnnerRect) - conv_width - titlePaddingRight, CGRectGetMidY(barnnerRect) - conv_height / 2 + 1, conv_width, conv_height );
        if (conversationCount > 0) {
            convw = conv_width + titlePaddingRight;
        }
        titleRect = CGRectMake(CGRectGetMinX(barnnerRect) + paddingH, CGRectGetMinY(barnnerRect) + titlePaddingV, CGRectGetWidth(barnnerRect) - convw - paddingH, CGRectGetHeight(barnnerRect) );
        CGFloat textPaddingV = 4.5;
        timeRect = CGRectMake(textbarRect.origin.x + paddingH, textbarRect.origin.y + textPaddingV, 112, textbarRect.size.height - textPaddingV * 2);
        timeFadingRect = CGRectMake(CGRectGetMaxX(timeRect) - 12, CGRectGetMidY(timeRect) - 11, 20, 22);

        avatarRect = CGRectMake(CGRectGetMaxX(textbarRect) - avatarWidth - 3, CGRectGetMinY(textbarRect) + (CGRectGetHeight(textbarRect) - avatarHeight) / 2, avatarWidth, avatarHeight);

        placeRect = CGRectMake(CGRectGetMaxX(timeRect) + paddingHM, textbarRect.origin.y + textPaddingV, 140, textbarRect.size.height - textPaddingV * 2);
        placeFadingRect = CGRectMake(CGRectGetMaxX(placeRect) - 20, CGRectGetMidY(placeRect) - 11, 20, 22);
        
    }
    return self;
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer{
    CGPoint location = [gestureRecognizer locationInView:gestureRecognizer.view];
    
    if (conversationCount > 0) {
        if (CGRectContainsPoint(convRect, location)) {
            return YES;
        }
    }
    return NO;
}

- (void)handleTap:(UITapGestureRecognizer*)gestureRecognizer{
    if (gestureRecognizer.state == UIGestureRecognizerStateEnded) {
        CGPoint location = [gestureRecognizer locationInView:gestureRecognizer.view];
        
        if (conversationCount > 0) {
            if (CGRectContainsPoint(convRect, location)) {
                NSLog(@"CrossCard hit conversation");
                if (delegate) {
                    [delegate onClickConversation:self];
                }
            }
        }
    }
}

- (void)dealloc {
	[title release];
    [avatar release];
    [time release];
    [place release];
    [super dealloc];
    
}
- (void)setTitle:(NSString *)s {
	[title release];
	title = [s copy];
	[self setNeedsDisplay]; 
}
- (void)setTime:(NSString *)s {
	[time release];
        time = [s copy];
	[self setNeedsDisplay];
}
- (void)setPlace:(NSString *)s {
	[place release];
    place = [s copy];
	[self setNeedsDisplay];
}

- (void)setAvatar:(UIImage *)a {
	[avatar release];
	avatar = [a copy];
	[self setNeedsDisplay];
}

- (void)setBannerimg:(UIImage *)image {
    if (bannerimg == image){
        return;
    }
    if (bannerimg != nil){
        [bannerimg release];
        bannerimg = nil;
        [self setNeedsDisplay];
    }
    
    bannerimg = image;
    [bannerimg retain];
    if (image != nil) {
        [self setNeedsDisplay];
    }
}

- (void)layoutSubviews{
	CGRect b = [self bounds];
	[contentView setFrame:b];
    [super layoutSubviews];
  
}

- (void)drawContentView:(CGRect)rect{
    CGRect b = [self bounds];
    // Rect caculation
    
    if (bannerimg != nil){
        [bannerimg drawInRect:barnnerRect];
    }
    
    if (avatar != nil) {
        [avatar drawInRect:avatarRect];
    }else{
        [[UIImage imageNamed:@"portrait_default.png"] drawInRect:avatarRect];
    }
    
    // card cover
    [[UIImage imageNamed:@"xlist_cell.png"] drawInRect:b];
    
    UIColor * color = [UIColor clearColor];
    if (hlTitle){
        color = [UIColor COLOR_BLUE_SEA];
    }else{
        color = [UIColor COLOR_WHITE];
    }
    [color set];
//    {
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextSaveGState(context);
        CGContextSetTextMatrix(context, CGAffineTransformIdentity);
        CGContextTranslateCTM(context, 0, CGRectGetMidY(titleRect));
        CGContextScaleCTM(context, 1.0, -1.0);
        CGContextTranslateCTM(context, 0, 0 - CGRectGetMidY(titleRect));
    
        CGContextSetShadowWithColor(context, CGSizeMake(0, 1.0f), 1.0f, [UIColor COLOR_WA(0x00, 0x5A)].CGColor);
        
        CTFontRef textfontref= CTFontCreateWithName(CFSTR("HelveticaNeue"), 21.0, NULL);
        if(title==nil)
            title=@"";
        NSMutableAttributedString *textstring=[[NSMutableAttributedString alloc] initWithString:title];
        [textstring addAttribute:(NSString*)kCTFontAttributeName value:(id)textfontref range:NSMakeRange(0,[textstring length])];
        [textstring addAttribute:(NSString*)kCTForegroundColorAttributeName value:(id)color.CGColor range:NSMakeRange(0,[textstring length])];
        CTLineBreakMode lineBreakMode = kCTLineBreakByCharWrapping;
        CTParagraphStyleSetting gathersetting[3] = {
            {kCTParagraphStyleSpecifierLineBreakMode, sizeof(lineBreakMode), &lineBreakMode}
        };
        CTParagraphStyleRef pstyle = CTParagraphStyleCreate(gathersetting, 3);
        [textstring addAttribute:(id)kCTParagraphStyleAttributeName value:(id)pstyle range:NSMakeRange(0,[textstring length])];
        
        CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)textstring);
        CGMutablePathRef path = CGPathCreateMutable();
        CGPathAddRect(path, NULL, titleRect);
        CTFrameRef theFrame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, [title length]), path, NULL);
        CFRelease(framesetter);
        CFRelease(path);
        CTFrameDraw(theFrame, context);
        CFRelease(theFrame);
        CGContextRestoreGState(context);
//    }
    
    UIFont *font17 = [UIFont fontWithName:@"HelveticaNeue-Light" size:15];
    // text info
    
    if (time == nil || time.length == 0) {
        [[UIColor COLOR_ALUMINUM] set];
        [@"Sometime" drawInRect:timeRect withFont:font17 lineBreakMode:UILineBreakModeTailTruncation alignment:UITextAlignmentLeft];
    }else{
        if (hlTime){
            [[UIColor COLOR_BLUE_SEA] set];
        }else{
            [[UIColor COLOR_BLACK] set];
        }
        [time drawInRect:timeRect withFont:font17 lineBreakMode:UILineBreakModeCharacterWrap alignment:UITextAlignmentLeft];
    }
    [[UIImage imageNamed:@"xlist_fadeout.png"] drawInRect:timeFadingRect];
    
    if (place == nil || place.length == 0) {
        [[UIColor COLOR_ALUMINUM] set];
        [@"Somewhere" drawInRect:placeRect withFont:font17 lineBreakMode:UILineBreakModeTailTruncation alignment:UITextAlignmentLeft];
    }else{
        if (hlPlace){
            [[UIColor COLOR_BLUE_SEA] set];
        }else{
            [[UIColor COLOR_BLACK] set];
        }
        [place drawInRect:placeRect withFont:font17 lineBreakMode:UILineBreakModeCharacterWrap alignment:UITextAlignmentLeft];
    }
    [[UIImage imageNamed:@"xlist_fadeout.png"] drawInRect:placeFadingRect];
    
    if (conversationCount > 0){
        if (conversationCount <= 64) {
            [[UIImage imageNamed:@"xlist_conv_badge.png"] drawInRect:convRect];
            
            [[UIColor COLOR_WHITE] set];
            NSString * convCount = [NSString stringWithFormat:@"%u", conversationCount];
            CGSize numSize = [convCount sizeWithFont:[UIFont fontWithName:@"HelveticaNeue-Medium" size:13]];
            CGRect numRect = CGRectMake(CGRectGetMidX(convRect) - numSize.width / 2 - 3.5, CGRectGetMidY(convRect) - numSize.height / 2, numSize.width, numSize.height);
            
            {
                CGContextRef context = UIGraphicsGetCurrentContext();
                CGContextSaveGState(context);
                CGContextSetTextMatrix(context, CGAffineTransformIdentity);
                CGContextTranslateCTM(context, 0, CGRectGetMidY(numRect));
                CGContextScaleCTM(context, 1.0, -1.0);
                CGContextTranslateCTM(context, 0, 0 - CGRectGetMidY(numRect));
                
                CGContextSetShadowWithColor(context, CGSizeMake(0, 1.0f), 1.0f, [UIColor COLOR_WA(0x00, 0x5A)].CGColor);
                
                CTFontRef textfontref= CTFontCreateWithName(CFSTR("HelveticaNeue-Medium"), 13.0, NULL);
                NSMutableAttributedString *textstring=[[NSMutableAttributedString alloc] initWithString:convCount];
                [textstring addAttribute:(NSString*)kCTFontAttributeName value:(id)textfontref range:NSMakeRange(0,[textstring length])];
                [textstring addAttribute:(NSString*)kCTForegroundColorAttributeName value:(id)[UIColor COLOR_WA(0xFF, 0xFF)].CGColor range:NSMakeRange(0,[textstring length])];
                
                CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)textstring);
                CGMutablePathRef path = CGPathCreateMutable();
                CGPathAddRect(path, NULL, numRect);
                CTFrameRef theFrame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, [textstring length]), path, NULL);
                CFRelease(framesetter);
                CFRelease(path);
                CTFrameDraw(theFrame, context);
                CFRelease(theFrame);
                CGContextRestoreGState(context);
            }
            //[convCount drawInRect:numRect withFont:[UIFont fontWithName:@"HelveticaNeue-CondensedBold" size:13] lineBreakMode:UILineBreakModeClip alignment:UITextAlignmentCenter];
        } else {
            [[UIImage imageNamed:@"xlist_conv_badge_many.png"]drawInRect:convRect];
        }
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    UIView *view = [[UIView alloc] initWithFrame:self.frame];
    view.backgroundColor = [UIColor colorWithRed:.9 green:.0 blue:.125 alpha:1.0];

    self.selectedBackgroundView = view;
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
