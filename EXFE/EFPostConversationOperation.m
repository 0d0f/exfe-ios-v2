//
//  EFPostConversationOperation.m
//  EXFE
//
//  Created by Stony Wang on 13-8-27.
//
//

#import "EFPostConversationOperation.h"

#import "EFEntity.h"
NSString *kEFNotificationNamePostConversationSuccess = @"notification.postConversation.success";
NSString *kEFNotificationNamePostConversationFailure = @"notification.postConversation.failure";

@implementation EFPostConversationOperation

- (id)initWithModel:(EXFEModel *)model {
    NSParameterAssert(model);
    
    self = [super initWithModel:model];
    if (self) {
        self.successNotificationName = kEFNotificationNamePostConversationSuccess;
        self.failureNotificationName = kEFNotificationNamePostConversationFailure;
    }
    
    return self;
}


- (void)operationDidStart {
    [super operationDidStart];
    
    NSAssert(self.model, @"model shouldn't be nill.");
    NSAssert(self.model.apiServer, @"api shouldn't be nill.");
    
    [self.model.apiServer postConversation:self.content
                                        by:self.byIdentity
                                        on:self.exfee
                                   success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
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
                                                       [userInfo setValue:self.exfee.exfee_id forKey:@"id"];
                                                       self.successUserInfo = userInfo;
                                                       
                                                       [self finish];
                                                   }
                                                       break;
                                                   default:{
                                                       
                                                       self.state = kEFNetworkOperationStateFailure;
                                                       NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] initWithDictionary:[mappingResult dictionary]];
                                                       [userInfo setValue:@"post" forKey:@"type"];
                                                       [userInfo setValue:self.exfee.exfee_id forKey:@"id"];
                                                       self.failureUserInfo = userInfo;
                                                       
                                                       [self finish];
                                                   }
                                                       break;
                                               }
                                           }
                                       }
                                   }
                                   failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                       self.state = kEFNetworkOperationStateFailure;
                                       NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithCapacity:3];
                                       [userInfo setValue:@"post" forKey:@"type"];
                                       [userInfo setValue:self.exfee.exfee_id forKey:@"id"];
                                       self.failureUserInfo = userInfo;
                                       self.error = error;
                                       
                                       [self finish];
                                   }];
}

@end
