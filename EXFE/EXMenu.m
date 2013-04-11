//
//  EXMenu.m
//  EXFE
//
//  Created by Stony Wang on 3/19/13.
//
//

#import "EXMenu.h"
#import "Util.h"

@implementation EXMenu

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor COLOR_WA(51, 254)];
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)setDelegate:(id<EXMenuDelegate>)delegate
{
    _delegate = delegate;
    [self setNeedsLayout];
}

- (void)layoutSubviews
{
    for (UIView* view in self.subviews) {
        [view removeFromSuperview];
    }
    
//    CGFloat startY = 0;
    UIView *header = nil;
    if (_datasource != nil) {
        if ([_datasource respondsToSelector:@selector(viewForHeaderInMenu:)])
        {
            header = [_datasource viewForHeaderInMenu:self];
        }
    }
//    if (header){
//        CGRect frame = header.frame;
//
//    }
}

@end
