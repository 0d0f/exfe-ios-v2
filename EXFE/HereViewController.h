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

@interface HereViewController : UIViewController
<
NSStreamDelegate,
UserAvatarCollectionDataSource,
UserAvatarCollectionDelegate,
EXCardViewControllerDelegate
> {
    NSMutableData *_data;
    int byteIndex;
    uint8_t buff[1024];
    
    EXUserAvatarCollectionView  *_avatarlistview;
}

- (void)close;
- (void)start;

@end
