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
@synthesize setInset;

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
        [self setBackgroundImage:[UIImage imageNamed:@"toolbar_pressed.png"] forState:UIControlStateHighlighted];
        self.adjustsImageWhenHighlighted=NO;
        [self setBackgroundColor:[UIColor clearColor]];
        [self.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:10]];
//        -img.size.height-30
        [self setTitleEdgeInsets:UIEdgeInsetsMake(38, -img.size.width, 2, 0.0)];
        [self setTitle:buttontitle forState:UIControlStateNormal];
        int margin=(self.frame.size.width-img.size.width)/2;
        if(setInset==NO)
            [self setImageEdgeInsets:UIEdgeInsetsMake(6, margin, 14, margin)];
    }
    return self;
}
- (void) updateFrame:(CGRect)rect{
    [self setFrame:rect];
    
    [self setTitleEdgeInsets:UIEdgeInsetsMake(0.0, -self.imageView.image.size.width, -self.imageView.image.size.height-14, 0.0)];
    int margin=(self.frame.size.width-self.imageView.image.size.width)/2;
    [self setImageEdgeInsets:UIEdgeInsetsMake(0, margin, 0, margin)];
}
@end
