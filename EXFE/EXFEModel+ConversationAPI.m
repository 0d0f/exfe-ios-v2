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

- (void)loadConversationWithExfeeId:(int)exfeeId updatedTime:(NSString *)updatedTime {
    EFLoadConversationOperation *loadConversationOperation = [EFLoadConversationOperation operationWithModel:self];
    loadConversationOperation.exfeeId = exfeeId;
    loadConversationOperation.updatedTime = updatedTime;
    
    EFNetworkManagementOperation *managementOperation = [[EFNetworkManagementOperation alloc] initWithNetworkOperation:loadConversationOperation];
    
    [[EFQueueManager defaultManager] addNetworkManagementOperation:managementOperation completeHandler:nil];
    
}

@end
