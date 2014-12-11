//
//  EFNetworkManagementOperation.m
//  EXFE
//
//  Created by 0day on 13-6-20.
//
//

#import "EFNetworkManagementOperation.h"

#import "EFKit.h"

@interface EFNetworkManagementOperation ()

@property (nonatomic, strong) EFNetworkOperation *networkOperation;

@end

@implementation EFNetworkManagementOperation

- (id)init {
    return [self initWithNetworkOperation:nil];
}

- (id)initWithNetworkOperation:(EFNetworkOperation *)operation {
    self = [super init];
    if (self) {
        self.networkOperation = operation;
    }
    
    return self;
}


- (void)operationDidStart {
    [super operationDidStart];
    
    NSAssert(self.networkOperation, @"network operation shouldn't be nill.");
    
    [[EFQueueManager defaultManager] addNetworkOperation:self.networkOperation
                                         completeHandler:^{
                                             [self finish];
                                         }];
}

- (void)operationWillFinish {
    [super operationWillFinish];
}

@end
