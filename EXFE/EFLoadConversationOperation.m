//
//  EFLoadConversationOperation.m
//  EXFE
//
//  Created by 0day on 13-6-26.
//
//

#import "EFLoadConversationOperation.h"

#import "EFEntity.h"

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
    
    [self.model.apiServer loadConversationWithExfee:self.exfee
                                          updatedtime:self.updatedTime
                                              success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult){
                                                  
                                                  if ([operation.HTTPRequestOperation.response statusCode] == 200) {
                                                      if([[mappingResult dictionary] isKindOfClass:[NSDictionary class]]) {
                                                          Meta *meta = (Meta *)[[mappingResult dictionary] objectForKey:@"meta"];
                                                          int code = [meta.code intValue];
                                                          int type = code / 100;
                                                          switch (type) {
                                                              case 2: // HTTP OK
                                                              {
                                                                  self.state = kEFNetworkOperationStateSuccess;
                                                                  NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] initWithDictionary:[mappingResult dictionary]];
                                                                  [userInfo setValue:@"post" forKey:@"type"];
                                                                  self.successUserInfo = userInfo;
                                                                  
                                                                  [self finish];
                                                              }
                                                                  break;
                                                              default:{
                                                                  
                                                                  self.state = kEFNetworkOperationStateFailure;
                                                                  NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] initWithDictionary:[mappingResult dictionary]];
                                                                  [userInfo setValue:@"post" forKey:@"type"];
                                                                  self.failureUserInfo = userInfo;
                                                                  
                                                                  [self finish];
                                                              }
                                                                  break;
                                                          }
                                                      }
                                                  }
                                              }
                                              failure:^(RKObjectRequestOperation *operation, NSError *error){
                                                  self.state = kEFNetworkOperationStateFailure;
                                                  NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithCapacity:3];
                                                  [userInfo setValue:@"post" forKey:@"type"];
                                                  self.failureUserInfo = userInfo;
                                                  self.error = error;
                                                  
                                                  [self finish];
                                              }];
}

@end
