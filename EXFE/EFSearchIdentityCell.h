//
//  EFSearchIdentityCell.h
//  EXFE
//
//  Created by 0day on 13-4-24.
//
//

#import "EFChoosePeopleViewCell.h"
#import "Util.h"

@interface EFSearchIdentityCell : EFChoosePeopleViewCell

+ (NSString *)reuseIdentifier;

- (void)customWithIdentityString:(NSString *)string candidateProvider:(Provider)candidateProvider matchProvider:(Provider)matchProvider identity:(Identity *)identity;

@end
