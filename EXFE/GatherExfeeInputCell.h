//
//  GatherExfeeInputCell.h
//  EXFE
//
//  Created by huoju on 8/9/12.
//
//

#import "ABTableViewCell.h"

@class LocalContact;
@class Identity;
@interface GatherExfeeInputCell : ABTableViewCell

@property (nonatomic, strong) UIImage *avatar;
@property (nonatomic, strong) UIImage *providerIcon;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSArray *providerIconSet;

- (void)customWithLocalContact:(LocalContact *)localContact;
- (void)customWithIdentity:(Identity *)identity;

@end
