//
//  EFRemoveNotificationIdentityOperation.m
//  EXFE
//
//  Created by Stony Wang on 13-8-27.
//
//

#import "EFRemoveNotificationIdentityOperation.h"

#import "Invitation+EXFE.h"
#import "Exfee+EXFE.h"

NSString *kEFNotificationNameRemoveNotificationIdentitySuccess = @"notification.removeNotificationIdentity.success";
NSString *kEFNotificationNameRemoveNotificationIdentityFailure = @"notification.removeNotificationIdentity.failure";

@implementation EFRemoveNotificationIdentityOperation

- (id)initWithModel:(EXFEModel *)model {
    NSParameterAssert(model);
    
    self = [super initWithModel:model];
    if (self) {
        self.successNotificationName = kEFNotificationNameRemoveNotificationIdentitySuccess;
        self.failureNotificationName = kEFNotificationNameRemoveNotificationIdentityFailure;
    }
    
    return self;
}

- (void)operationDidStart {
    [super operationDidStart];
    
    NSAssert(self.model, @"model shouldn't be nill.");
    NSAssert(self.model.apiServer, @"api shouldn't be nill.");
    
    [self.model.apiServer removeNotificationIdentity:self.identityid
                                                from:self.invitation
                                             onExfee:self.exfee
                                             success:^(Exfee *editExfee) {
                                                 self.state = kEFNetworkOperationStateSuccess;
                                                 NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] initWithDictionary:@{@"exfee": editExfee}];
                                                 [userInfo setValue:@"exfee" forKey:@"type"];
                                                 [userInfo setValue:self.exfee.exfee_id forKey:@"id"];
                                                 self.successUserInfo = userInfo;
                                                 
                                                 [self finish];
                                             }
                                             failure:^(NSError *error) {
                                                 self.state = kEFNetworkOperationStateFailure;
                                                 self.error = error;
                                                 
                                                 [self finish];
                                             }];
    
}

@end
