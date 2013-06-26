//
//  EFLoadCrossOperation.h
//  EXFE
//
//  Created by 0day on 13-6-26.
//
//

#import "EFNetworkOperation.h"

@interface EFLoadCrossOperation : EFNetworkOperation

@property (nonatomic, assign)   int         crossId;
@property (nonatomic, copy)     NSString    *updatedTime;

@end
