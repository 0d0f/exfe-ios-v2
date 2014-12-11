//
//  EFUpdateIdentityOperation.h
//  EXFE
//
//  Created by Stony Wang on 13-7-17.
//
//

#import "EFNetworkOperation.h"

@interface EFUpdateIdentityOperation : EFNetworkOperation

@property (nonatomic, copy)   NSString      *name;
@property (nonatomic, copy)   NSString      *bio;
@property (nonatomic, strong) Identity      *identity;

@end
