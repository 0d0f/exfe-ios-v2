//
//  UserAvatarCollection.h
//  EXFE
//
//  Created by huoju on 3/29/13.
//
//

#import "EXCircleScrollView.h"
#import "EXCircleItemCell.h"

@class EXUserAvatarCollectionView;

@protocol UserAvatarCollectionDataSource<NSObject>
@required
- (NSInteger)numberOfCircleItemInAvatarCollectionView:(EXUserAvatarCollectionView *)avatarCollectionView;
- (EXCircleItemCell *)circleItemForAvatarCollectionView:(EXUserAvatarCollectionView *)avatarCollectionView atIndexPath:(NSIndexPath *)indexPath;
- (BOOL)shouldCircleItemCell:(EXCircleItemCell *)cell removeFromAvatarCollectionView:(EXUserAvatarCollectionView *)collectionView;
- (void)circleItemCellsNeedReload:(NSSet *)cells;
@end

@protocol UserAvatarCollectionDelegate<NSObject, EXCircleScrollViewDelegate>
@required
- (void)avatarCollectionView:(EXUserAvatarCollectionView *)avatarCollectionView didSelectCircleItemAtIndexPath:(NSIndexPath *)indexPath;
- (void)avatarCollectionView:(EXUserAvatarCollectionView *)avatarCollectionView didBeginLongPressCircleItemAtIndexPath:(NSIndexPath *)indexPath;
- (void)avatarCollectionView:(EXUserAvatarCollectionView *)avatarCollectionView didEndLongPressCircleItemAtIndexPath:(NSIndexPath *)indexPath;
@end


@interface EXUserAvatarCollectionView : EXCircleScrollView
<
EXCircleScrollViewDelegate
>

@property (nonatomic, assign) id<UserAvatarCollectionDataSource> dataSource;
@property (nonatomic, assign) id<UserAvatarCollectionDelegate> delegate;

- (NSSet *)unselectedCircleItemCells;
- (NSSet *)selectedCircleItemCells;
- (NSSet *)visibleCircleItemCells;

- (EXCircleItemCell *)circleItemCellAtIndexPath:(NSIndexPath *)indexPath;
- (EXCircleItemCell *)dequeueReusableCircleItemCell;
- (void)reloadData;

@end
