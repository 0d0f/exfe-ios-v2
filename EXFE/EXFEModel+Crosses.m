//
//  EXFEModel+Crosses.m
//  EXFE
//
//  Created by 0day on 13-6-26.
//
//

#import "EXFEModel+Crosses.h"

#import "EFKit.h"
#import "EFAPIOperations.h"

@implementation EXFEModel (Crosses)

- (void)loadCrossWithCrossId:(int)crossId updatedTime:(NSString *)updatedTime {
    EFLoadCrossOperation *loadCrossOperation = [EFLoadCrossOperation operationWithModel:self];
    loadCrossOperation.crossId = crossId;
    loadCrossOperation.updatedTime = updatedTime;
    
    EFNetworkManagementOperation *managementOperation = [[EFNetworkManagementOperation alloc] initWithNetworkOperation:loadCrossOperation];
    
    [[EFQueueManager defaultManager] addNetworkManagementOperation:managementOperation completeHandler:nil];
    
}

@end
