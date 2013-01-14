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
        CGSize targetSize = CGSizeMake(320 - CARD_VERTICAL_MARGIN * 2, 45);
                
        //If scaleFactor is not touched, no scaling will occur
        CGFloat scaleFactor = 1.0;
        
        //Deciding which factor to use to scale the image (factor = targetSize / imageSize)
        if (image.size.width > targetSize.width || image.size.height > targetSize.height)
            if (!((scaleFactor = (targetSize.width / image.size.width)) > (targetSize.height / image.size.height))) //scale to fit width, or
                scaleFactor = targetSize.height / image.size.height; // scale to fit heigth.
        
        UIGraphicsBeginImageContext(targetSize);
        
        //Creating the rect where the scaled image is drawn in
        CGRect rect = CGRectMake((targetSize.width - image.size.width * scaleFactor) / 2,
                                 (targetSize.height -  image.size.height * scaleFactor) / 2,
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
    
    int paddingH = 8;
    int avatarWidth = 22;
    int avatarHeight = 22;
    int titlePaddingV = 10;
    
    int convw = 0;
    convRect = CGRectMake(CGRectGetMaxX(barnnerRect) - 44, CGRectGetMinY(barnnerRect) , 44, CGRectGetHeight(barnnerRect));
    if (conversationCount > 0) {
        convw = convRect.size.width;
    }
    titleRect = CGRectMake(CGRectGetMinX(barnnerRect) + paddingH, CGRectGetMinY(barnnerRect) + titlePaddingV, CGRectGetWidth(barnnerRect) - convw - paddingH, CGRectGetHeight(barnnerRect) - titlePaddingV * 2);
    
    
    int textPaddingV = 6;
    timeRect = CGRectMake(textbarRect.origin.x + paddingH, textbarRect.origin.y + textPaddingV, 112, textbarRect.size.height - textPaddingV * 2);
    
    avatarRect = CGRectMake(CGRectGetMaxX(textbarRect) - avatarWidth - 3, CGRectGetMinY(textbarRect) + (CGRectGetHeight(textbarRect) - avatarHeight) / 2, avatarWidth, avatarHeight);
   
    placeRect = CGRectMake(CGRectGetMaxX(timeRect) + paddingH, textbarRect.origin.y + textPaddingV, textbarRect.size.width - (CGRectGetMaxX(timeRect) + paddingH) - avatarWidth - 3, textbarRect.size.height - textPaddingV * 2);
    
   
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
        [[UIColor redColor] setFill];
        UIRectFill(avatarRect);
        
    }
    
    // card cover
    [[UIImage imageNamed:@"xlist_cell.png"] drawInRect:b];
    
    if (hlTitle){
        [[UIColor COLOR_RGB(58, 110, 165)] set];
    }else{
        [[UIColor COLOR_RGB(0xff, 0xff,0xff)] set];
    }
    [title drawInRect:titleRect withFont:[UIFont fontWithName:@"HelveticaNeue" size:21] lineBreakMode:UILineBreakModeCharacterWrap alignment:UITextAlignmentLeft ];
    
    
    
    UIFont *font17 = [UIFont fontWithName:@"HelveticaNeue-Light" size:17];
    // text info
    if (hlTime){
        [[UIColor COLOR_RGB(58, 110, 165)] set];
    }else{
        [[UIColor COLOR_RGB(0x00, 0x00,0x00)] set];
    }
    if (time == nil || time.length == 0) {
        [@"Sometime" drawInRect:timeRect withFont:font17 lineBreakMode:UILineBreakModeTailTruncation alignment:UITextAlignmentLeft];
    }else{
        [time drawInRect:timeRect withFont:font17 lineBreakMode:UILineBreakModeCharacterWrap alignment:UITextAlignmentLeft];
    }
    if (hlPlace){
        [[UIColor COLOR_RGB(58, 110, 165)] set];
    }else{
        [[UIColor COLOR_RGB(0x00, 0x00,0x00)] set];
    }
    
    if (place == nil || place.length == 0) {
        [@"Somewhere" drawInRect:placeRect withFont:font17 lineBreakMode:UILineBreakModeTailTruncation alignment:UITextAlignmentLeft];
    }else{
        [place drawInRect:placeRect withFont:font17 lineBreakMode:UILineBreakModeTailTruncation alignment:UITextAlignmentLeft];
    }
    
    if (conversationCount > 0){
        if (conversationCount <= 64) {
            [FONT_COLOR_88 set];
            [[UIImage imageNamed:@"conversation_badge_empty.png"] drawInRect:convRect];
            
            [[UIColor COLOR_RGB(0x37, 0x84,0xD5)] set];
            NSString * convCount = [NSString stringWithFormat:@"%u",conversationCount];
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
