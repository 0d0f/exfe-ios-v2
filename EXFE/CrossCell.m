//
//  CrossCell.m
//  EXFE
//
//  Created by ju huo on 5/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CrossCell.h"
#import "Util.h"

@implementation CrossCell
@synthesize title;
@synthesize avatar;
@synthesize time;
@synthesize place;
@synthesize removed;
@synthesize hlTitle;
@synthesize hlTime;
@synthesize hlPlace;    
@synthesize hlExfee;
@synthesize hlConversation;
@synthesize backgroundimg;
@synthesize isbackground;
//@synthesize updated;
//@synthesize read_at;

- (void)dealloc {
	[title release];
    [avatar release];
    [time release];
    [place release];
//    [updated release];
//    [read_at release];
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
- (void)layoutSubviews
{
	CGRect b = [self bounds];
    //	b.size.height -= 1; // leave room for the separator line
    //	b.size.width += 30; // allow extra width to slide for editing
    //	b.origin.x -= (self.editing && !self.showingDeleteConfirmation) ? 0 : 30; // start 30px left unless editing
	[contentView setFrame:b];
    [super layoutSubviews];
}
- (void)drawContentView:(CGRect)r{
    

    [backgroundimg drawInRect:r];
    if(isbackground==YES)
        return;
    if(removed==NO)
    {
    if (hlTitle)
        [[Util getHighlightColor] set];    
    else 
        [[Util getRegularColor] set];
    [title drawInRect:CGRectMake(60, 10, 250, 24) withFont:[UIFont fontWithName:@"Helvetica" size:18]];

    if(avatar!=nil && ![avatar isKindOfClass:[NSNull class]])
        [avatar drawInRect:CGRectMake(10, 11, 40, 40)];
    float place_width=140;
    
    //highlight
//    if([updated objectForKey:@"place"]!=nil && read_at!=nil)
    if(hlPlace)
        [[Util getHighlightColor] set];  
    else 
        [[Util getRegularColor] set];
    [place drawInRect:CGRectMake(60, 34, place_width, 18) withFont:[UIFont fontWithName:@"Helvetica" size:12] lineBreakMode:UILineBreakModeTailTruncation];
    float time_width=320-60-10-place_width;
    
    //highlight
//    if([updated objectForKey:@"time"]!=nil && read_at!=nil)
    if(hlTime)
        [[Util getHighlightColor] set];  
    else 
        [[Util getRegularColor] set];
    [time drawInRect:CGRectMake(60+place_width, 34, time_width, 18) withFont:[UIFont fontWithName:@"Helvetica" size:12] lineBreakMode:UILineBreakModeClip alignment:UITextAlignmentRight];
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
