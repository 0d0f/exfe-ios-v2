//
//  EFChoosePeopleViewCell.h
//  EXFE
//
//  Created by 0day on 13-4-17.
//
//

#import <UIKit/UIKit.h>

#import "EFLabel.h"

@class EFChoosePeopleViewCell;
@protocol EFChoosePeopleViewCellDelegate <NSObject>
@required
- (void)choosePeopleViewCellButtonPressed:(EFChoosePeopleViewCell *)cell;
@end

@protocol EFChoosePeopleViewCellDataSource <NSObject>
@required
- (BOOL)shouldChoosePeopleViewCellSelected:(EFChoosePeopleViewCell *)cell;
@end

@class EFContactObject;
@interface EFChoosePeopleViewCell : UITableViewCell

@property (strong, nonatomic) UIImageView *avatarImageView;
@property (strong, nonatomic) EFLabel *userNameLabel;
@property (nonatomic, strong) UIImage *providerIcon;
@property (nonatomic, strong) NSArray *providerIconList;
@property (nonatomic, weak) id<EFChoosePeopleViewCellDelegate> delegate;
@property (nonatomic, weak) id<EFChoosePeopleViewCellDataSource> dataSource;
@property (nonatomic, strong) UIButton *accessButton;

@property (nonatomic, strong) EFContactObject *contactObject;

+ (NSString *)reuseIdentifier;

@end
