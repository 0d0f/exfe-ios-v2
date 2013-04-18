//
//  EFChoosePeopleViewCell.h
//  EXFE
//
//  Created by 0day on 13-4-17.
//
//

#import <UIKit/UIKit.h>

@class EFChoosePeopleViewCell;
@protocol EFChoosePeopleViewCellDelegate <NSObject>
@required
- (void)choosePeopleViewCellButtonPressed:(EFChoosePeopleViewCell *)cell;
@end

@class LocalContact, Identity;
@interface EFChoosePeopleViewCell : UITableViewCell

@property (retain, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (retain, nonatomic) IBOutlet UILabel *userNameLabel;
@property (nonatomic, retain) UIImage *providerIcon;
@property (nonatomic, retain) NSArray *providerIconSet;
@property (nonatomic, assign) id<EFChoosePeopleViewCellDelegate> delegate;

+ (NSString *)reuseIdentifier;

- (void)customWithLocalContact:(LocalContact *)localContact;
- (void)customWithIdentity:(Identity *)identity;

@end
