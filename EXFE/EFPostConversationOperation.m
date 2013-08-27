//
//  EFPostConversationOperation.m
//  EXFE
//
//  Created by Stony Wang on 13-8-27.
//
//

#import "EFPostConversationOperation.h"

#import "Exfee+EXFE.h"
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
                                   success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                       self.state = kEFNetworkOperationStateSuccess;
                                       NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] initWithDictionary:responseObject];
                                       [userInfo setValue:@"exfee" forKey:@"type"];
                                       [userInfo setValue:self.exfee.exfee_id forKey:@"id"];
                                       self.successUserInfo = userInfo;
                                       
                                       [self finish];
                                   }
                                   failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                       self.state = kEFNetworkOperationStateFailure;
                                       self.error = error;
                                       
                                       [self finish];
                                   }];
}

@end
