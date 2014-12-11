//
//  EFNetworkManagementOperation.h
//  EXFE
//
//  Created by 0day on 13-6-20.
//
//

#import "EFRunLoopOperation.h"

#import "EFNetworkOperation.h"

@interface EFNetworkManagementOperation : EFRunLoopOperation

- (id)initWithNetworkOperation:(EFNetworkOperation *)operation;

@end
