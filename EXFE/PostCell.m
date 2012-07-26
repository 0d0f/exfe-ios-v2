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
@synthesize text_height;


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
    [content drawInRect:CGRectMake(35, 8, CELL_CONTENT_WIDTH-CELL_CONTENT_MARGIN_LEFT-CELL_CONTENT_MARGIN_RIGHT-20-5, text_height) withFont:[UIFont fontWithName:@"HelveticaNeue" size:FONT_SIZE]];

    if(avatar!=nil && ![avatar isKindOfClass:[NSNull class]])
        [avatar drawInRect:CGRectMake(10, 8, 20, 20)];
    [time drawInRect:CGRectMake(CELL_CONTENT_WIDTH-CELL_CONTENT_MARGIN_RIGHT, r.size.height-CELL_CONTENT_MARGIN_BOTTOM-14 , 20, 14) withFont:[UIFont fontWithName:@"HelveticaNeue" size:14] lineBreakMode:UILineBreakModeClip alignment:UITextAlignmentRight];
    
}
@end
