//
//  EFChangeCrossTimeOperation.h
//  EXFE
//
//  Created by Stony Wang on 13-9-2.
//
//

#import "EFNetworkOperation.h"

@class CrossTime;
@class Cross;

@interface EFChangeCrossTimeOperation : EFNetworkOperation

@property (nonatomic, strong) CrossTime *crossTime;
@property (nonatomic, strong) Cross     *cross;


@end
