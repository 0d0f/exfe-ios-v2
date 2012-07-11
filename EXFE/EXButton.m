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
- (id)initWithName:(NSString*)name title:(NSString*)buttontitle image:(UIImage*) img{

    self = [super initWithFrame:CGRectMake(0, 0, 20, 20)];
    if (self) {
        buttonName=name;
        [self setImage:img forState:UIControlStateNormal];
        [self setTitleEdgeInsets:UIEdgeInsetsMake(0.0, -img.size.width, -40.0, 0.0)];
        [self setTitle:buttontitle forState:UIControlStateNormal];
    }
    return self;
}
@end
