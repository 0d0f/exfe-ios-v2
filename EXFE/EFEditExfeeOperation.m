//
//  EFEditExfeeOperation.m
//  EXFE
//
//  Created by Stony Wang on 13-8-27.
//
//

#import "EFEditExfeeOperation.h"

#import "Invitation+EXFE.h"
#import "Exfee+EXFE.h"

NSString *kEFNotificationNameEditExfeeSuccess = @"notification.EditExfee.success";
NSString *kEFNotificationNameEditExfeeFailure = @"notification.EditExfee.failure";


@implementation EFEditExfeeOperation


- (id)initWithModel:(EXFEModel *)model {
    NSParameterAssert(model);
    
    self = [super initWithModel:model];
    if (self) {
        self.successNotificationName = kEFNotificationNameEditExfeeSuccess;
        self.failureNotificationName = kEFNotificationNameEditExfeeFailure;
    }
    
    return self;
}

- (void)operationDidStart {
    [super operationDidStart];
    
    NSAssert(self.model, @"model shouldn't be nill.");
    NSAssert(self.model.apiServer, @"api shouldn't be nill.");
    
    [self.model.apiServer editExfee:self.exfee
                         byIdentity:self.byIdentity
                            success:^(Exfee *editedExfee) {
                                self.state = kEFNetworkOperationStateSuccess;
                                NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] initWithDictionary:@{@"exfee": editedExfee}];
                                [userInfo setValue:@"exfee" forKey:@"type"];
                                [userInfo setValue:self.exfee.exfee_id forKey:@"id"];
                                self.successUserInfo = userInfo;
                                
                                [self finish];
                            }
                         apiFailure:^(Meta *meta) {
                             self.state = kEFNetworkOperationStateFailure;
                             NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] initWithDictionary:@{@"meta": meta}];
                             [userInfo setValue:@"exfee" forKey:@"type"];
                             [userInfo setValue:self.exfee.exfee_id forKey:@"id"];
                             self.failureUserInfo = userInfo;
                             
                             [self finish];
                         }
                            failure:^(NSError *error) {
                                self.state = kEFNetworkOperationStateFailure;
                                NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithCapacity:3];
                                [userInfo setValue:@"exfee" forKey:@"type"];
                                [userInfo setValue:self.exfee.exfee_id forKey:@"id"];
                                self.failureUserInfo = userInfo;
                                self.error = error;
                                
                                [self finish];
                            }];
}

@end
