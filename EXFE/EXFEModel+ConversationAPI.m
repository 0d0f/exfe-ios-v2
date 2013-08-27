//
//  EXFEModel+ConversationAPI.m
//  EXFE
//
//  Created by 0day on 13-6-26.
//
//

#import "EXFEModel+ConversationAPI.h"

#import "EFKit.h"
#import "EFAPIOperations.h"

@implementation EXFEModel (ConversationAPI)

- (void)loadConversationWithExfee:(Exfee *)exfee updatedTime:(NSDate *)updatedTime {
    EFLoadConversationOperation *operation = [EFLoadConversationOperation operationWithModel:self];
    operation.exfee = exfee;
    operation.updatedTime = updatedTime;
    
    EFNetworkManagementOperation *managementOperation = [[EFNetworkManagementOperation alloc] initWithNetworkOperation:operation];
    
    [[EFQueueManager defaultManager] addNetworkManagementOperation:managementOperation completeHandler:nil];
    
}

- (void)postConversation:(NSString *)content by:(Identity *)myIdentity on:(Exfee *)exfee
{
    EFPostConversationOperation *operation = [EFPostConversationOperation operationWithModel:self];
    operation.exfee = exfee;
    operation.content = content;
    operation.byIdentity = myIdentity;
    
    EFNetworkManagementOperation *managementOperation = [[EFNetworkManagementOperation alloc] initWithNetworkOperation:operation];
    
    [[EFQueueManager defaultManager] addNetworkManagementOperation:managementOperation completeHandler:nil];
}

@end
