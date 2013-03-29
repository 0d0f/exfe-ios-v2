//
//  UserAvatarCollection.m
//  EXFE
//
//  Created by huoju on 3/29/13.
//
//

#import "EXUserAvatarCollectionView.h"

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

- (void) reloadData{
  for(UIView *view in self.subviews){
    if([view isKindOfClass:[EXCircleItemCell class]])
      [view removeFromSuperview];
//        [view release];
  }
  int count=[_dataSource numberOfAvatarCollectionView:self];
  for (int i=0;i<count;i++){
    EXCircleItemCell *cell=[_dataSource avatarCollectionView:self itemAtIndex:i];
    [cell setFrame:CGRectMake(0, 0, 20, 20)];
    [self addSubview:cell];
    [cell setNeedsDisplay];
  }
}

@end
