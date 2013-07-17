//
//  EFUpdateIdentityOperation.m
//  EXFE
//
//  Created by Stony Wang on 13-7-17.
//
//

#import "EFUpdateIdentityOperation.h"

NSString *kEFNotificationUpdateIdentitySuccess = @"notification.updateIdentity.success";
NSString *kEFNotificationUpdateIdentityFailure = @"notification.updateIdentity.failure";

@implementation EFUpdateIdentityOperation

- (id)initWithModel:(EXFEModel *)model {
    NSParameterAssert(model);
    
    self = [super initWithModel:model];
    if (self) {
        self.successNotificationName = kEFNotificationUpdateIdentitySuccess;
        self.failureNotificationName = kEFNotificationUpdateIdentityFailure;
    }
    return self;
}


- (void)operationDidStart {
    [super operationDidStart];
    
    NSAssert(self.model, @"model shouldn't be nill.");
    NSAssert(self.model.apiServer, @"api shouldn't be nill.");
    
    [self.model.apiServer updateIdentity:self.identity
                                    name:self.name
                                  andBio:self.bio
                                 success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                     self.state = kEFNetworkOperationStateSuccess;
                                     
                                     NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] initWithDictionary:responseObject];
                                     
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
