//
//  EFRemoveInvitationOperation.m
//  EXFE
//
//  Created by Stony Wang on 13-8-23.
//
//

#import "EFRemoveInvitationOperation.h"

#import "EFEntity.h"

NSString *kEFNotificationNameRemoveInvitationSuccess = @"notification.removeInvitation.success";
NSString *kEFNotificationNameRemoveInvitationFailure = @"notification.removeInvitation.failure";

@implementation EFRemoveInvitationOperation

- (id)initWithModel:(EXFEModel *)model {
    NSParameterAssert(model);
    
    self = [super initWithModel:model];
    if (self) {
        self.successNotificationName = kEFNotificationNameRemoveInvitationSuccess;
        self.failureNotificationName = kEFNotificationNameRemoveInvitationFailure;
    }
    
    return self;
}


- (void)operationDidStart {
    [super operationDidStart];
    
    NSAssert(self.model, @"model shouldn't be nill.");
    NSAssert(self.model.apiServer, @"api shouldn't be nill.");
    
//    self.invitation.rsvp_status = @"REMOVED";
    [self.model.apiServer editExfee:self.exfee
                         byIdentity:self.byIdentity
                            success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                
                                if ([operation.HTTPRequestOperation.response statusCode] == 200){
                                    if([[mappingResult dictionary] isKindOfClass:[NSDictionary class]])
                                    {
                                        Meta *meta = (Meta *)[[mappingResult dictionary] objectForKey:@"meta"];
                                        int code = [meta.code intValue];
                                        int type = code / 100;
                                        switch (type) {
                                            case 2: // HTTP OK
                                            {   
                                                self.state = kEFNetworkOperationStateSuccess;
                                                NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] initWithDictionary:[mappingResult dictionary]];
                                                [userInfo setValue:@"exfee" forKey:@"type"];
                                                [userInfo setValue:self.exfee.exfee_id forKey:@"id"];
                                                self.successUserInfo = userInfo;
                                                
                                                [self finish];
                                            }
                                                break;
                                            default:{
                                                
                                                self.state = kEFNetworkOperationStateFailure;
                                                NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] initWithDictionary:[mappingResult dictionary]];
                                                [userInfo setValue:@"exfee" forKey:@"type"];
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
                                [userInfo setValue:@"exfee" forKey:@"type"];
                                [userInfo setValue:self.exfee.exfee_id forKey:@"id"];
                                self.failureUserInfo = userInfo;
                                self.error = error;
                                
                                [self finish];
                            }];
}


@end