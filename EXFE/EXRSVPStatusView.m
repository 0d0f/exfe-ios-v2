//
//  EXRSVPStatusView.m
//  EXFE
//
//  Created by huoju on 12/26/12.
//
//

#import "EXRSVPStatusView.h"

@implementation EXRSVPStatusView
@synthesize invitation;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor=[UIColor blueColor];
        // Initialization code
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    NSLog(@"%@",invitation);
    // Drawing code
}

@end
