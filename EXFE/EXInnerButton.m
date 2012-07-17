//
//  UIInnerButton.m
//  EXFE
//
//  Created by huoju on 7/16/12.
//
//

#import "EXInnerButton.h"

@implementation EXInnerButton
@synthesize image;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    [image drawInRect:CGRectMake(0,0,30,30)];
}


@end
