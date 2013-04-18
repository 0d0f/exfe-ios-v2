//
//  EFChoosePeopleViewCell.h
//  EXFE
//
//  Created by 0day on 13-4-17.
//
//

#import <UIKit/UIKit.h>

@class LocalContact, Identity;
@interface EFChoosePeopleViewCell : UITableViewCell

@property (retain, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (retain, nonatomic) IBOutlet UILabel *userNameLabel;
@property (nonatomic, retain) UIImage *providerIcon;
@property (nonatomic, retain) NSArray *providerIconSet;

- (void)customWithLocalContact:(LocalContact *)localContact;
- (void)customWithIdentity:(Identity *)identity;

@end
