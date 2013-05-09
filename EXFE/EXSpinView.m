//
//  EXSpinView.m
//  EXFE
//
//  Created by huoju on 9/9/12.
//
//

#import "EXSpinView.h"

@implementation EXSpinView

- (id)initWithPoint:(CGPoint)point size:(int)size{
    self = [super initWithFrame:CGRectMake(point.x, point.y, size, size)];
    if (self) {
//        if(size==18)
//            self.animationImages = [NSArray arrayWithObjects:
//                                             [UIImage imageNamed:@"spin_36_0.png"],
//                                             [UIImage imageNamed:@"spin_36_1.png"],
//                                             [UIImage imageNamed:@"spin_36_2.png"],
//                                             [UIImage imageNamed:@"spin_36_3.png"], nil];
//        else if(size==40)
//            self.animationImages = [NSArray arrayWithObjects:
//                                    [UIImage imageNamed:@"spin_80_0.png"],
//                                    [UIImage imageNamed:@"spin_80_1.png"],
//                                    [UIImage imageNamed:@"spin_80_2.png"],
//                                    [UIImage imageNamed:@"spin_80_3.png"], nil];

        
        
        
//        self.animationDuration = 1.5f;
//        self.animationRepeatCount = 0;
    }
    return self;
}

//- (id)initWithFrame:(CGRect)frame
//{
//    self = [super initWithFrame:frame];
//    if (self) {
//        // Initialization code
//    }
//    return self;
//}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
