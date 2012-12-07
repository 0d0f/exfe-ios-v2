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
//@synthesize subtitle;
@synthesize providerIcon;


- (void)setTitle:(NSString *)s {
	[title release];
	title = [s copy];
	[self setNeedsDisplay]; 
}
//- (void)setSubtitle:(NSString *)s {
//	[subtitle release];
//	subtitle = [s copy];
//	[self setNeedsDisplay]; 
//}

- (void)setAvatar:(UIImage *)a {
	[avatar release];
	avatar = [a copy];
	[self setNeedsDisplay]; 
}

- (void) setProviderIcon:(UIImage *)a{
	[providerIcon release];
	providerIcon = [a copy];
	[self setNeedsDisplay]; 
}

- (void) setProviderIconSet:(NSArray *)s{
    if(providerIconSet!=nil)
        [providerIconSet release];
    providerIconSet = [s copy];
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
    
    [title drawInRect:CGRectMake(5+30+5, 11, self.frame.size.width-(5+30+5+5), 20) withFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:18] lineBreakMode:UILineBreakModeClip alignment:UITextAlignmentLeft ];
//    [subtitle drawInRect:CGRectMake(5+30+5, 6+22, self.frame.size.width-(5+30+5+5), 18) withFont:[UIFont fontWithName:@"HelveticaNeue" size:12] lineBreakMode:UILineBreakModeClip alignment:UITextAlignmentLeft ];
    [avatar drawInRect:CGRectMake(5, 5, 30, 30)];
    if(providerIconSet!=nil)
    {
        [providerIcon drawInRect:CGRectMake(self.frame.size.width-18-10, 13, 18, 18)];
        int i=1;
        for(UIImage *icon in providerIconSet){
            [icon drawInRect:CGRectMake(self.frame.size.width-(18+10)*i, 13, 18, 18)];
            i++;
        }
    }
    else if(providerIcon!=nil){
        [providerIcon drawInRect:CGRectMake(self.frame.size.width-18-10, 13, 18, 18)];
        
        [[UIImage imageWithData:nil] drawInRect:CGRectMake(self.frame.size.width-(18+10)*3, 13, 18*3, 18)];
    }
}
@end
