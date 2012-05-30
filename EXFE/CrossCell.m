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
@synthesize updated;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
            
//        title = [[UILabel alloc]initWithFrame:CGRectMake(60, 10, 250, 24)];
//        avatar = [[UIImageView alloc] initWithFrame:CGRectMake(10, 11, 40, 40)];
//        place =[[UILabel alloc]initWithFrame:CGRectMake(60, 34, 250, 100)];
//        time =[[UILabel alloc]initWithFrame:CGRectMake(160, 34, 250, 100)];
//        [self.contentView addSubview:title];
//        [self.contentView addSubview:avatar];
//        [self.contentView addSubview:place];
//        [self.contentView addSubview:time];
        
//        timeZoneView = [[TimeZoneView alloc] initWithFrame:tzvFrame];
//        timeZoneView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
//        [self.contentView addSubview:timeZoneView];
    }
    return self;
}

- (void)dealloc {
	[title release];
    [avatar release];
    [time release];
    [place release];
    [updated release];
    [super dealloc];
}
- (void)drawRect:(CGRect)rect {
    
    if([updated objectForKey:@"title"]!=nil)
        [[Util getHighlightColor] set];    
    else 
        [[Util getRegularColor] set];
    [title drawInRect:CGRectMake(60, 10, 250, 24) withFont:[UIFont fontWithName:@"Helvetica" size:18]];

    [avatar drawInRect:CGRectMake(10, 11, 40, 40)];
    float place_width=100;

 
    if([updated objectForKey:@"place"]!=nil)
        [[Util getHighlightColor] set];  
    else 
        [[Util getRegularColor] set];
    [place drawInRect:CGRectMake(60, 34, place_width, 18) withFont:[UIFont fontWithName:@"Helvetica" size:12]];
    float time_width=320-60-10-place_width;
    
    if([updated objectForKey:@"time"]!=nil)
        [[Util getHighlightColor] set];  
    else 
        [[Util getRegularColor] set];
    [time drawInRect:CGRectMake(60+place_width, 34, time_width, 18) withFont:[UIFont fontWithName:@"Helvetica" size:12] lineBreakMode:UILineBreakModeClip alignment:UITextAlignmentRight];
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
