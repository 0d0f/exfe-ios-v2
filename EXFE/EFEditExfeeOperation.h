//
//  EFEditExfeeOperation.h
//  EXFE
//
//  Created by Stony Wang on 13-8-27.
//
//

#import "EFNetworkOperation.h"

@class exfee;
@interface EFEditExfeeOperation : EFNetworkOperation

@property (nonatomic, strong) Exfee *exfee;
@property (nonatomic, strong) Identity *byIdentity;

@end
