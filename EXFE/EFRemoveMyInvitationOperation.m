//
//  EFRemoveMyInvitationOperation.m
//  EXFE
//
//  Created by Stony Wang on 13-8-23.
//
//

#import "EFRemoveMyInvitationOperation.h"

#import "Invitation+EXFE.h"
#import "Exfee+EXFE.h"

NSString *kEFNotificationNameRemoveMyInvitationSuccess = @"notification.removeMyInvitation.success";
NSString *kEFNotificationNameRemoveMyInvitationFailure = @"notification.removeMyInvitation.failure";

@implementation EFRemoveMyInvitationOperation

- (id)initWithModel:(EXFEModel *)model {
    NSParameterAssert(model);
    
    self = [super initWithModel:model];
    if (self) {
        self.successNotificationName = kEFNotificationNameRemoveMyInvitationSuccess;
        self.failureNotificationName = kEFNotificationNameRemoveMyInvitationFailure;
    }
    
    return self;
}


- (void)operationDidStart {
    [super operationDidStart];
    
    NSAssert(self.model, @"model shouldn't be nill.");
    NSAssert(self.model.apiServer, @"api shouldn't be nill.");
    
    self.invitation.rsvp_status = @"REMOVED";
    [self.model.apiServer editExfee:self.exfee
                         byIdentity:self.invitation.identity
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
