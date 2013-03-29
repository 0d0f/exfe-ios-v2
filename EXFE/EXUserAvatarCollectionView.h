//
//  UserAvatarCollection.h
//  EXFE
//
//  Created by huoju on 3/29/13.
//
//

#import <UIKit/UIKit.h>
#import "EXCircleItemCell.h"

@class EXUserAvatarCollectionView;

@protocol UserAvatarCollectionDataSource<NSObject>
@required
- (NSInteger)numberOfCircleItemInAvatarCollectionView:(EXUserAvatarCollectionView *)avatarCollectionView;
- (EXCircleItemCell *)circleItemForAvatarCollectionView:(EXUserAvatarCollectionView *)avatarCollectionView atIndex:(int)index;
@end

@protocol UserAvatarCollectionDelegate<NSObject>
@required
- (void)avatarCollectionView:(EXUserAvatarCollectionView *)avatarCollectionView didSelectCircleItemAtIndex:(int)index;
- (void)avatarCollectionView:(EXUserAvatarCollectionView *)avatarCollectionView didLongPressCircleItemAtIndex:(int)index;
@end


@interface EXUserAvatarCollectionView : UIView {
  NSArray *_cellCenterPositions;
}

@property (nonatomic, assign) id<UserAvatarCollectionDataSource> dataSource;
@property (nonatomic, assign) id<UserAvatarCollectionDelegate> delegate;

- (void)reloadData;
//- (void)setDataSource:(id)dataSource;
//- (void)setDelegate:(id)delegate;

@end
