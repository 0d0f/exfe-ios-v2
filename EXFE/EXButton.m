//
//  EXButton.m
//  EXFE
//
//  Created by huoju on 7/11/12.
//
//

#import "EXButton.h"

@implementation EXButton
@synthesize buttonName;
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}
- (id)initWithName:(NSString*)name title:(NSString*)buttontitle image:(UIImage*)  img inFrame:(CGRect) frame{

    self = [super initWithFrame:frame];
    if (self) {
        [self setFrame:frame];
        buttonName=name;
        [self setImage:img forState:UIControlStateNormal];
        [self setBackgroundImage:[UIImage imageNamed:@"toolbar_btndown_bg.png"] forState:UIControlStateHighlighted];
        self.adjustsImageWhenHighlighted=NO;
        [self setBackgroundColor:[UIColor clearColor]];
        [self setTitleEdgeInsets:UIEdgeInsetsMake(0.0, -img.size.width, -img.size.height-14, 0.0)];
        [self setTitle:buttontitle forState:UIControlStateNormal];
        int margin=(self.frame.size.width-img.size.width)/2;
        [self setImageEdgeInsets:UIEdgeInsetsMake(0, margin, 0, margin)];
    }
    return self;
}

@end
