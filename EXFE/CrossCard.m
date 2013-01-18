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
        
    }
    if (bannerimg != nil){
        [bannerimg release];
        bannerimg = nil;
        [self setNeedsDisplay];
    }
    if (image != nil) {
        
        
        CGSize targetSize = CGSizeMake((320 - CARD_VERTICAL_MARGIN * 2) * [UIScreen mainScreen].scale, 44 * [UIScreen mainScreen].scale);
                
        //If scaleFactor is not touched, no scaling will occur
        CGFloat scaleFactor = 1.0;
        
        //Deciding which factor to use to scale the image (factor = targetSize / imageSize)
        if (image.size.width > targetSize.width || image.size.height > targetSize.height){
            scaleFactor = MAX((targetSize.width / image.size.width), (targetSize.height / image.size.height));
        }
        
        UIGraphicsBeginImageContext(targetSize);
        
        //Creating the rect where the scaled image is drawn in
        CGRect rect = CGRectMake((targetSize.width / 2 - image.size.width / 2 * scaleFactor),
                                 (0 - image.size.height * 198.0f / 495.0f * scaleFactor),
                                 image.size.width * scaleFactor, image.size.height * scaleFactor);
        
        //Draw the image into the rect
        [image drawInRect:rect];
        
        //Saving the image, ending image context
        bannerimg = UIGraphicsGetImageFromCurrentImageContext();
        [bannerimg retain];
        UIGraphicsEndImageContext();
        [self setNeedsDisplay];
    }
}

- (void)layoutSubviews{
	CGRect b = [self bounds];
	[contentView setFrame:b];
     [super layoutSubviews];
    
    barnnerRect = CGRectMake(b.origin.x + CARD_VERTICAL_MARGIN, b.origin.y + 8, b.size.width - CARD_VERTICAL_MARGIN * 2, 45);
    textbarRect = CGRectMake(b.origin.x + CARD_VERTICAL_MARGIN, barnnerRect.origin.y + barnnerRect.size.height, b.size.width - CARD_VERTICAL_MARGIN * 2, 28);
    
    int paddingH = 6;
    int avatarWidth = 22;
    int avatarHeight = 22;
    int titlePaddingV = 10;
    
    int convw = 0;
    int conv_width = 36;
    int conv_height = 33;
    convRect = CGRectMake(CGRectGetMaxX(barnnerRect) - conv_width - 4, CGRectGetMidY(barnnerRect) - conv_height / 2 - 1, conv_width, conv_height );
    if (conversationCount > 0) {
        convw = 44;
    }
    titleRect = CGRectMake(CGRectGetMinX(barnnerRect) + paddingH, CGRectGetMinY(barnnerRect) + titlePaddingV, CGRectGetWidth(barnnerRect) - convw - paddingH, CGRectGetHeight(barnnerRect) - titlePaddingV * 2);
    
    int textPaddingV = 6;
    timeRect = CGRectMake(textbarRect.origin.x + paddingH, textbarRect.origin.y + textPaddingV, 112, textbarRect.size.height - textPaddingV * 2);
    timeFadingRect = CGRectMake(CGRectGetMaxX(timeRect) - 12, CGRectGetMidY(timeRect) - 11, 20, 22);
    
    avatarRect = CGRectMake(CGRectGetMaxX(textbarRect) - avatarWidth - 3, CGRectGetMinY(textbarRect) + (CGRectGetHeight(textbarRect) - avatarHeight) / 2, avatarWidth, avatarHeight);
   
    placeRect = CGRectMake(CGRectGetMaxX(timeRect) + paddingH, textbarRect.origin.y + textPaddingV, 140, textbarRect.size.height - textPaddingV * 2);
    placeFadingRect = CGRectMake(CGRectGetMaxX(placeRect) - 20, CGRectGetMidY(placeRect) - 11, 20, 22);
    
   
}

- (void)drawContentView:(CGRect)rect{
    CGRect b = [self bounds];
    // Rect caculation
    
    // backgound
    [[UIColor blackColor] setFill];
    UIRectFill(b);
    
    // barnner
    [[UIColor grayColor] setFill];
    UIRectFill(barnnerRect);
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
    {
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextSaveGState(context);
        CGContextSetTextMatrix(context, CGAffineTransformIdentity);
        CGContextTranslateCTM(context, 0, (CGRectGetHeight(self.bounds)  - CGRectGetMidY(titleRect)));
        CGContextScaleCTM(context, 1.0, -1.0);

        CGContextSetShadowWithColor(context, CGSizeMake(0, 1.0f), 1.0f, [UIColor blackColor].CGColor);
        
        CTFontRef textfontref= CTFontCreateWithName(CFSTR("HelveticaNeue"), 21.0, NULL);
        NSMutableAttributedString *textstring=[[NSMutableAttributedString alloc] initWithString:title];
        [textstring addAttribute:(NSString*)kCTFontAttributeName value:(id)textfontref range:NSMakeRange(0,[textstring length])];
        [textstring addAttribute:(NSString*)kCTForegroundColorAttributeName value:(id)color.CGColor range:NSMakeRange(0,[textstring length])];
        CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)textstring);
        CGMutablePathRef path = CGPathCreateMutable();
        CGPathAddRect(path, NULL, titleRect);
        CTFrameRef theFrame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, [title length]), path, NULL);
        CFRelease(framesetter);
        CFRelease(path);
        CTFrameDraw(theFrame, context);
        CFRelease(theFrame);
        CGContextRestoreGState(context);
    }
    //[title drawInRect:titleRect withFont:[UIFont fontWithName:@"HelveticaNeue" size:21] lineBreakMode:UILineBreakModeCharacterWrap alignment:UITextAlignmentLeft ];
    
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
            CGSize numSize = [convCount sizeWithFont:[UIFont fontWithName:@"HelveticaNeue-CondensedBold" size:13]];
            CGRect numRect = CGRectMake(CGRectGetMidX(convRect) - numSize.width / 2 - 4, CGRectGetMidY(convRect) - numSize.height / 2, numSize.width, numSize.height);
            [convCount drawInRect:numRect withFont:[UIFont fontWithName:@"HelveticaNeue-CondensedBold" size:13] lineBreakMode:UILineBreakModeClip alignment:UITextAlignmentCenter];
        } else {
            [[UIImage imageNamed:@"conversation_badge_full.png"]drawInRect:convRect];
        }
    }
    
   
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
//    UIView *view = [[UIView alloc] initWithFrame:self.frame];
//    view.backgroundColor = [UIColor colorWithRed:.9 green:.0 blue:.125 alpha:1.0];
//
//    self.selectedBackgroundView = view;
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
