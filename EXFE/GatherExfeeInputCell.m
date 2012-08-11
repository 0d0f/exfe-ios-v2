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
    [title drawInRect:CGRectMake(5+30+5, 6, self.frame.size.width-(5+30+5+5), 20) withFont:[UIFont fontWithName:@"HelveticaNeue" size:18] lineBreakMode:NSLineBreakByClipping alignment:NSTextAlignmentLeft ];
    [subtitle drawInRect:CGRectMake(5+30+5, 6+22, self.frame.size.width-(5+30+5+5), 18) withFont:[UIFont fontWithName:@"HelveticaNeue" size:12] lineBreakMode:NSLineBreakByClipping alignment:NSTextAlignmentLeft ];
    [avatar drawInRect:CGRectMake(5, 5, 30, 30)];
//    CGContextRef context = UIGraphicsGetCurrentContext();
//    CGContextSaveGState(context);
    
//    CGContextRestoreGState(context);

    
}
@end
