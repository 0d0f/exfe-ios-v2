//
//  EXFEModel+Profile.m
//  EXFE
//
//  Created by 0day on 13-6-27.
//
//

#import "EXFEModel+Profile.h"

#import "EFKit.h"
#import "EFAPIOperations.h"

@implementation EXFEModel (Profile)

- (void)loadSuggestWithKey:(NSString *)key {
    EFLoadSuggestOperation *loadSuggestOperation = [EFLoadSuggestOperation operationWithModel:self];
    loadSuggestOperation.key = key;
    
    EFNetworkManagementOperation *managementOperation = [[EFNetworkManagementOperation alloc] initWithNetworkOperation:loadSuggestOperation];
    
    [[EFQueueManager defaultManager] addNetworkManagementOperation:managementOperation completeHandler:nil];
    
    [managementOperation release];
}

@end
