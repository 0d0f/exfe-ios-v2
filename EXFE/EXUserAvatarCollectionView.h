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
- (NSInteger) numberOfAvatarCollectionView:(EXUserAvatarCollectionView *)avatarCollectionView;
- (id)avatarCollectionView:(EXUserAvatarCollectionView *)avatarCollectionView itemAtIndex:(int)index;
@end

@protocol UserAvatarCollectionDelegate<NSObject>
@required
- (void)avatarCollectionView:(EXUserAvatarCollectionView *)avatarCollectionView didSelectItemAtIndex:(int)index;
- (void)avatarCollectionView:(EXUserAvatarCollectionView *)avatarCollectionView didLongPressItemAtIndex:(int)index;
@end


@interface EXUserAvatarCollectionView : UIView{
  id <UserAvatarCollectionDataSource>  _dataSource;
  id <UserAvatarCollectionDelegate> _delegate;
  NSArray *cellPosition;
}
- (void) reloadData;
- (void) setDataSource:(id) dataSource;
- (void) setDelegate:(id) delegate;

@end
