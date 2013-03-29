//
//  UserAvatarCollection.m
//  EXFE
//
//  Created by huoju on 3/29/13.
//
//

#import "EXUserAvatarCollectionView.h"

#import <QuartzCore/QuartzCore.h>

@interface EXUserAvatarCollectionView ()

@end

@implementation EXUserAvatarCollectionView

- (id)initWithFrame:(CGRect)frame
{
  self = [super initWithFrame:frame];
  if (self) {
  }
//  [self initData];
//  itemsCache=[[NSMutableDictionary alloc] initWithCapacity:12];
  self.userInteractionEnabled = YES;
//  CGPointMake(<#CGFloat x#>, <#CGFloat y#>)
  cellPosition=@[];
  return self;
}

- (void) awakeFromNib
{
  [super awakeFromNib];
//  [self initData];
}

- (void) setDataSource:(id) dataSource{
  _dataSource=dataSource;
}
- (void) setDelegate:(id) delegate{
  _delegate=delegate;
}

- (void)reloadData {
    for (UIView *view in self.subviews) {
        if ([view isKindOfClass:[EXCircleItemCell class]])
            [view removeFromSuperview];
//        [view release];
    }
    
    int count=[_dataSource numberOfAvatarCollectionView:self];
    for (int i = 0; i < count; i++) {
        EXCircleItemCell *cell=[_dataSource avatarCollectionView:self itemAtIndex:i];
        [cell setFrame:CGRectMake(0, 0, 20, 20)];
        
        // block 
        cell.tapBlock = ^{
            [cell setSelected:cell.isSelected animated:YES complete:nil];
            [_delegate avatarCollectionView:self didSelectItemAtIndex:cell.idx];
        };
        
        cell.longPressBlock = ^{
            [_delegate avatarCollectionView:self didLongPressItemAtIndex:cell.idx];
        };
        
        // animation
        CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
        
        CATransform3D scale1 = CATransform3DMakeScale(0.3, 0.3, 1);
        CATransform3D scale2 = CATransform3DMakeScale(1.2, 1.2, 1);
        CATransform3D scale3 = CATransform3DMakeScale(0.9, 0.9, 1);
        CATransform3D scale4 = CATransform3DMakeScale(1.0, 1.0, 1);

        NSArray *frameValues = [NSArray arrayWithObjects:
                              [NSValue valueWithCATransform3D:scale1],
                              [NSValue valueWithCATransform3D:scale2],
                              [NSValue valueWithCATransform3D:scale3],
                              [NSValue valueWithCATransform3D:scale4],
                              nil];
        [animation setValues:frameValues];

        NSArray *frameTimes = [NSArray arrayWithObjects:
                             [NSNumber numberWithFloat:0.0],
                             [NSNumber numberWithFloat:0.5],
                             [NSNumber numberWithFloat:0.9],
                             [NSNumber numberWithFloat:1.0],
                             nil];
        [animation setKeyTimes:frameTimes];

        animation.fillMode = kCAFillModeForwards;
        animation.duration = .2;

        [cell.layer addAnimation:animation forKey:nil];

        [self addSubview:cell];
        [cell setNeedsDisplay];
    }
}

@end
