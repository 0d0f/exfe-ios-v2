//
//  EFEditCrossOperation.h
//  EXFE
//
//  Created by Stony Wang on 13-8-19.
//
//

#import "EFNetworkOperation.h"

@class Cross;
@interface EFEditCrossOperation : EFNetworkOperation

@property (nonatomic, strong) Cross *cross;

@end
