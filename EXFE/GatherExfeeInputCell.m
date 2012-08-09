//
//  GatherExfeeInputCell.m
//  EXFE
//
//  Created by huoju on 8/9/12.
//
//

#import "GatherExfeeInputCell.h"

@implementation GatherExfeeInputCell
@synthesize avatar;
@synthesize title;
@synthesize subtitle;


- (void)setTitle:(NSString *)s {
	[title release];
	title = [s copy];
	[self setNeedsDisplay]; 
}
- (void)setSubtitle:(NSString *)s {
	[subtitle release];
	subtitle = [s copy];
	[self setNeedsDisplay]; 
}

- (void)setAvatar:(UIImage *)a {
	[avatar release];
	avatar = [a copy];
	[self setNeedsDisplay]; 
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
	[contentView setFrame:b];
    [super layoutSubviews];
}

- (void)drawContentView:(CGRect)r{
}
@end
