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

@property (nonatomic, retain) UIImage *avatar;
@property (nonatomic, retain) UIImage *providerIcon;
@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSArray *providerIconSet;

- (void)customWithLocalContact:(LocalContact *)localContact;
- (void)customWithIdentity:(Identity *)identity;

@end
