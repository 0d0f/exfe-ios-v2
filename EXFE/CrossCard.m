//
//  CrossCard.m
//  EXFE
//
//  Created by Stony on 12/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CrossCard.h"
#import "Util.h"

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
        CGSize targetSize = CGSizeMake(320 - 13 * 2, 45);
                
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
}
- (void)drawContentView:(CGRect)rect{
    CGRect b = [self bounds];
    // Rect caculation
    int cardMargin = 13;
    CGRect barnnerRect = CGRectMake(b.origin.x + cardMargin, b.origin.y + 8, b.size.width - cardMargin * 2, 45);
    CGRect textbarRect = CGRectMake(b.origin.x + cardMargin, barnnerRect.origin.y + barnnerRect.size.height, b.size.width - cardMargin * 2, 28);
    
    int paddingH = 8;
    int avatarWidth = 45;
    int titlePaddingV = 10;
    CGRect titleRect = CGRectMake(barnnerRect.origin.x + paddingH, barnnerRect.origin.y + titlePaddingV, barnnerRect.size.width - avatarWidth - paddingH, barnnerRect.size.height - titlePaddingV * 2);
    CGRect avatarRect = CGRectMake(titleRect.origin.x + titleRect.size.width, barnnerRect.origin.y, avatarWidth, barnnerRect.size.height);
    
    int convw = 0;
    int textPaddingV = 4;
    CGRect timeRect = CGRectMake(textbarRect.origin.x + paddingH, textbarRect.origin.y + textPaddingV, 102, textbarRect.size.height - textPaddingV * 2);
    CGRect convRect = CGRectMake(textbarRect.origin.x + textbarRect.size.width - 33, textbarRect.origin.y , 33, textbarRect.size.height);
    if (conversationCount > 0) {
        convw = convRect.size.width;
    }
    CGRect placeRect = CGRectMake(timeRect.origin.x + timeRect.size.width + paddingH * 2, textbarRect.origin.y + textPaddingV, textbarRect.size.width - ( timeRect.size.width + paddingH * 3) - convw, textbarRect.size.height - textPaddingV * 2);
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
    }
    
    if (hlTitle){
        [[UIColor COLOR_RGB(0xff, 0xff,0xff)] set];
    }else{
        [[UIColor COLOR_RGB(0xff, 0xff,0xff)] set];
    }
    [title drawInRect:titleRect withFont:[UIFont fontWithName:@"HelveticaNeue" size:21] lineBreakMode:UILineBreakModeClip alignment:UITextAlignmentLeft ];
    
    // card cover
    [[UIImage imageNamed:@"xlist_mask.png"] drawInRect:b];
    
    UIFont *font17 = [UIFont fontWithName:@"HelveticaNeue-Light" size:17];
    // text info
    if (hlTime){
        [[UIColor COLOR_RGB(0x00, 0x00,0x00)] set];
    }else{
        [[UIColor COLOR_RGB(0x00, 0x00,0x00)] set];
    }
    if (time == nil || time.length == 0) {
        [@"Sometime" drawInRect:timeRect withFont:font17 lineBreakMode:UILineBreakModeTailTruncation alignment:UITextAlignmentLeft];
    }else{
        [time drawInRect:timeRect withFont:font17 lineBreakMode:UILineBreakModeTailTruncation alignment:UITextAlignmentLeft];
    }
    if (hlPlace){
        [[UIColor COLOR_RGB(0x00, 0x00,0x00)] set];
    }else{
        [[UIColor COLOR_RGB(0x00, 0x00,0x00)] set];
    }
    if (place == nil || place.length == 0) {
        [@"Somewhere" drawInRect:placeRect withFont:font17 lineBreakMode:UILineBreakModeTailTruncation alignment:UITextAlignmentLeft];
    }else{
        [place drawInRect:placeRect withFont:font17 lineBreakMode:UILineBreakModeTailTruncation alignment:UITextAlignmentLeft];
    }
    
    if(conversationCount > 0){
        if( conversationCount <= 64){
            [FONT_COLOR_88 set];
            [[UIImage imageNamed:@"conversation_badge_empty.png"] drawInRect:convRect];
            [[UIColor COLOR_RGB(0x00, 0x00,0xFF)] set];
            [[NSString stringWithFormat:@"%u",conversationCount] drawInRect:convRect withFont:[UIFont fontWithName:@"HelveticaNeue-CondensedBold" size:13] lineBreakMode:UILineBreakModeClip alignment:UITextAlignmentCenter];
            
        } else
            [[UIImage imageNamed:@"conversation_badge_full.png"]drawInRect:convRect];
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
