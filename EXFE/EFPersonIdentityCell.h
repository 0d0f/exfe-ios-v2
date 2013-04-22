//
//  EFPersonIdentityCell.h
//  EXFE
//
//  Created by 0day on 13-4-18.
//
//

#import <UIKit/UIKit.h>

@class EFPersonIdentityCell, RoughIdentity;
@protocol EFPersonIdentityCellDelegate <NSObject>
@required
- (void )personIdentityCell:(EFPersonIdentityCell *)cell didSelectRoughIdentity:(RoughIdentity *)roughIdentity;
- (void )personIdentityCell:(EFPersonIdentityCell *)cell didDeselectRoughIdentity:(RoughIdentity *)roughIdentity;
@end

@protocol EFPersonIdentityCellDataSource <NSObject>
@required
- (BOOL)shouldPersonIdentityCell:(EFPersonIdentityCell *)cell selectRoughIdentity:(RoughIdentity *)roughtIdentity;
@end

@interface EFPersonIdentityCell : UITableViewCell

@property (nonatomic, retain) NSArray *roughIdentities;
@property (nonatomic, assign) id<EFPersonIdentityCellDelegate> delegate;
@property (nonatomic, assign) id<EFPersonIdentityCellDataSource> dataSource;

+ (CGFloat)heightWithRoughIdentities:(NSArray *)identities;

@end
