//
//  EFLoadUserOperation.h
//  EXFE
//
//  Created by 0day on 13-6-26.
//
//

#import "EFNetworkOperation.h"

@interface EFLoadUserOperation : EFNetworkOperation

@property (nonatomic, assign) NSInteger     userId;
@property (nonatomic, copy)   NSString      *token;     // Default as self.model.userToken

@end
