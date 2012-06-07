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
//    if([updated objectForKey:@"title"]!=nil)
//        [[Util getHighlightColor] set];    
//    else 
//        [[Util getRegularColor] set];
    [content drawInRect:CGRectMake(60, 10, 250, 24) withFont:[UIFont fontWithName:@"Helvetica" size:18]];
    //    
    if(avatar!=nil && ![avatar isKindOfClass:[NSNull class]])
        [avatar drawInRect:CGRectMake(10, 11, 40, 40)];
    float place_width=100;
    
    
//    if([updated objectForKey:@"place"]!=nil)
//        [[Util getHighlightColor] set];  
//    else 
//        [[Util getRegularColor] set];
//    [place drawInRect:CGRectMake(60, 34, place_width, 18) withFont:[UIFont fontWithName:@"Helvetica" size:12]];
    float time_width=320-60-10-place_width;
//    
//    if([updated objectForKey:@"time"]!=nil)
//        [[Util getHighlightColor] set];  
//    else 
//        [[Util getRegularColor] set];
    [time drawInRect:CGRectMake(60+place_width, 34, time_width, 18) withFont:[UIFont fontWithName:@"Helvetica" size:12] lineBreakMode:UILineBreakModeClip alignment:UITextAlignmentRight];
    
}
@end
