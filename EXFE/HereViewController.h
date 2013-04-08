//
//  HereViewController.h
//  EXFE
//
//  Created by huoju on 3/26/13.
//
//

#import <UIKit/UIKit.h>
#import "User.h"
#import "User+EXFE.h"
#import "Identity.h"
#import "Util.h"
#import <stdint.h>
#import "EXUserAvatarCollectionView.h"
#import "EXCircleItemCell.h"
#import "EXCardViewController.h"
#import "EXLiveServiceController.h"

@interface HereViewController : UIViewController
<
UserAvatarCollectionDataSource,
UserAvatarCollectionDelegate,
EXCardViewControllerDelegate,
CLLocationManagerDelegate,
EXLiveServiceControllerDataSource,
EXLiveServiceControllerDelegate
> {
    EXUserAvatarCollectionView  *_avatarlistview;
}

- (void)close;

@end
