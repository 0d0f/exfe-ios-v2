//
//  EFLoadConversationOperation.m
//  EXFE
//
//  Created by 0day on 13-6-26.
//
//

#import "EFLoadConversationOperation.h"

NSString *kEFNotificationNameLoadConversationSuccess = @"notificaiton.loadConversation.success";
NSString *kEFNotificationNameLoadConversationFailure = @"notificaiton.loadConversation.failure";

@implementation EFLoadConversationOperation

- (id)initWithModel:(EXFEModel *)model {
    NSParameterAssert(model);
    
    self = [super initWithModel:model];
    if (self) {
        self.successNotificationName = kEFNotificationNameLoadConversationSuccess;
        self.failureNotificationName = kEFNotificationNameLoadConversationFailure;
    }
    return self;
}

- (void)operationDidStart {
    [super operationDidStart];
    
    NSAssert(self.model, @"model shouldn't be nill.");
    NSAssert(self.model.apiServer, @"api shouldn't be nill.");
    NSAssert(self.updatedTime, @"updated time shouldn't be nil.");
    
    [self.model.apiServer loadConversationWithExfeeId:self.exfeeId
                                          updatedtime:self.updatedTime
                                              success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult){
                                                  self.state = kEFNetworkOperationStateSuccess;
                                                  NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] initWithDictionary:[mappingResult dictionary]];
                                                  self.successUserInfo = userInfo;
                                                  
                                                  [self finish];
                                              }
                                              failure:^(RKObjectRequestOperation *operation, NSError *error){
                                                  self.state = kEFNetworkOperationStateFailure;
                                                  self.error = error;
                                                  
                                                  [self finish];
                                              }];
}

@end
