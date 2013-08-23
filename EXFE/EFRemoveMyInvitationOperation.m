//
//  EFRemoveMyInvitationOperation.m
//  EXFE
//
//  Created by Stony Wang on 13-8-23.
//
//

#import "EFRemoveMyInvitationOperation.h"

#import "Invitation+EXFE.h"

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
