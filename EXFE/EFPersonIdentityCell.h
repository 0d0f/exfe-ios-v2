//
//  EFPersonIdentityCell.h
//  EXFE
//
//  Created by 0day on 13-4-18.
//
//

#import <UIKit/UIKit.h>

@interface EFPersonIdentityCell : UITableViewCell

@property (nonatomic, retain) NSArray *idntities;

+ (CGFloat)heightWithIdentities:(NSArray *)identities;

@end
