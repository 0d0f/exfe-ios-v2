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
            [[Util getHighlightColor] set];    
        else 
            [FONT_COLOR_69 set];
        
        [title drawInRect:CGRectMake(10, 8, 270, 16) withFont:[UIFont fontWithName:@"HelveticaNeue" size:21] lineBreakMode:NSLineBreakByClipping alignment:NSTextAlignmentLeft ];

//        if(avatar!=nil && ![avatar isKindOfClass:[NSNull class]])
//            [avatar drawInRect:CGRectMake(10, 11, 40, 40)];
    
        NSString *acceptedstr=[NSString stringWithFormat:@"%u",accepted];
        NSString *totalstr=[NSString stringWithFormat:@"%u",total];
        
        [FONT_COLOR_98 set];
        [acceptedstr drawInRect:CGRectMake(278, 9, 19, 12) withFont:[UIFont fontWithName:@"TeluguSangamMN-Bold" size:15] lineBreakMode:NSLineBreakByClipping alignment:NSTextAlignmentRight];
        [totalstr drawInRect:CGRectMake(300, 18, 19, 12) withFont:[UIFont fontWithName:@"TeluguSangamMN" size:13] lineBreakMode:NSLineBreakByClipping alignment:NSTextAlignmentLeft];
        [[UIImage imageNamed:@"slash.png"] drawInRect:CGRectMake(296, 13, 7, 14)]; 
        [[UIImage imageNamed:@"location.png"] drawInRect:CGRectMake(12, 43, 24, 24)];

        if(hlPlace)
            [[Util getHighlightColor] set];
        else
            [FONT_COLOR_69 set];
        [place drawInRect:CGRectMake(42, 49, 200, 16) withFont:[UIFont fontWithName:@"MalayalamSangamMN" size:13] lineBreakMode:UILineBreakModeTailTruncation alignment:NSTextAlignmentLeft];
        
        if(showDetailTime==YES){
            [[UIImage imageNamed:@"cal_badge.png"]drawInRect:CGRectMake(12, 70, 24, 24)];
            [FONT_COLOR_100 set];
            [time_month drawInRect:CGRectMake(14, 70, 20, 8) withFont:[UIFont fontWithName:@"HelveticaNeue-CondensedBold" size:9] lineBreakMode:NSLineBreakByClipping alignment:NSTextAlignmentCenter];
            [time_day drawInRect:CGRectMake(14, 79, 20, 18) withFont:[UIFont fontWithName:@"HelveticaNeue-CondensedBold" size:13] lineBreakMode:NSLineBreakByClipping alignment:NSTextAlignmentCenter ];
        }
        else
            [[UIImage imageNamed:@"time_icon.png"]drawInRect:CGRectMake(12, 70, 24, 24)];
        
        
        if(hlTime)
            [[Util getHighlightColor] set];
        else 
            [FONT_COLOR_69 set];
        [time drawInRect:CGRectMake(42, 76, 200, 16) withFont:[UIFont fontWithName:@"MalayalamSangamMN" size:13] lineBreakMode:UILineBreakModeClip alignment:UITextAlignmentLeft];
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
