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
@synthesize total;
@synthesize accepted;
@synthesize showDetailTime;
@synthesize time_day;
@synthesize time_month;
@synthesize conversationCount;

- (void)dealloc {
	[title release];
    [avatar release];
    [time release];
    [place release];
    [super dealloc];
    
}

- (void)setTotal:(int)s{
    total=s;
    [self setNeedsDisplay];
}
- (void)setAccepted:(int)s{
    accepted=s;
    [self setNeedsDisplay];
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
            [FONT_COLOR_HL set];    
        else 
            [FONT_COLOR_69 set];
        
        [title drawInRect:CGRectMake(10, 8, 270, 16) withFont:[UIFont fontWithName:@"HelveticaNeue" size:21] lineBreakMode:UILineBreakModeClip alignment:UITextAlignmentLeft ];
        [[UIImage imageNamed:@"title_fadeout.png"] drawInRect:CGRectMake(10+270-32,3,32,33)];

//        if(avatar!=nil && ![avatar isKindOfClass:[NSNull class]])
//            [avatar drawInRect:CGRectMake(10, 11, 40, 40)];
    
        NSString *acceptedstr=[NSString stringWithFormat:@"%u",accepted];
        NSString *totalstr=[NSString stringWithFormat:@"%u",total];
        
        [FONT_COLOR_98 set];
        [acceptedstr drawInRect:CGRectMake(282, 4, 23, 18) withFont:[UIFont fontWithName:@"Futura-CondensedMedium" size:18] lineBreakMode:UILineBreakModeClip alignment:UITextAlignmentCenter];
        [totalstr drawInRect:CGRectMake(300, 20, 13, 13) withFont:[UIFont fontWithName:@"Futura-CondensedMedium" size:13] lineBreakMode:UILineBreakModeClip alignment:UITextAlignmentCenter];
        [[UIImage imageNamed:@"xlist_slash"] drawInRect:CGRectMake(297,13, 10, 16)];
        [[UIImage imageNamed:@"location.png"] drawInRect:CGRectMake(10, 43, 24, 24)];

        if(hlPlace)
            [FONT_COLOR_HL set];
        else
            [FONT_COLOR_69 set];
        [place drawInRect:CGRectMake(40, 49, 320-40-10, 16) withFont:[UIFont fontWithName:@"MalayalamSangamMN" size:13] lineBreakMode:UILineBreakModeTailTruncation alignment:UITextAlignmentLeft];
        
        if(showDetailTime==YES){
            [[UIImage imageNamed:@"cal_badge.png"]drawInRect:CGRectMake(10, 70, 24, 24)];
            [FONT_COLOR_100 set];
            [time_month drawInRect:CGRectMake(12, 70, 20, 8) withFont:[UIFont fontWithName:@"HelveticaNeue-CondensedBold" size:9] lineBreakMode:UILineBreakModeClip alignment:UITextAlignmentCenter];
            [time_day drawInRect:CGRectMake(12, 79, 20, 18) withFont:[UIFont fontWithName:@"HelveticaNeue-CondensedBold" size:13] lineBreakMode:UILineBreakModeClip alignment:UITextAlignmentCenter ];
        }
        else
            [[UIImage imageNamed:@"time_icon.png"]drawInRect:CGRectMake(10, 70, 24, 24)];
        
        if(hlTime)
            [FONT_COLOR_HL set];
        else 
            [FONT_COLOR_69 set];
        int timefield_width=320-40-10;
        if(conversationCount>0)
            timefield_width-=26;
        [time drawInRect:CGRectMake(40, 76, timefield_width, 16) withFont:[UIFont fontWithName:@"MalayalamSangamMN" size:13] lineBreakMode:UILineBreakModeClip alignment:UITextAlignmentLeft];
        if(conversationCount>0 && conversationCount<9){
            [FONT_COLOR_88 set];
            [[UIImage imageNamed:@"conversation_badge_empty.png"]drawInRect:CGRectMake(279, 70, 30, 26)];
            [[NSString stringWithFormat:@"%u",conversationCount] drawInRect:CGRectMake(280, 74, 20, 15) withFont:[UIFont fontWithName:@"HelveticaNeue-CondensedBold" size:13] lineBreakMode:UILineBreakModeClip alignment:UITextAlignmentCenter];
            
        }
        else if(conversationCount>9)
            [[UIImage imageNamed:@"conversation_badge_full.png"]drawInRect:CGRectMake(279, 70, 30, 26)];
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
