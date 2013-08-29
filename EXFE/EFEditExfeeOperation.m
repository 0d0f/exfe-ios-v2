//
//  EFEditExfeeOperation.m
//  EXFE
//
//  Created by Stony Wang on 13-8-27.
//
//

#import "EFEditExfeeOperation.h"

#import "EFEntity.h"

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
                            success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                if([[mappingResult dictionary] isKindOfClass:[NSDictionary class]])
                                {
                                    Meta *meta = (Meta *)[[mappingResult dictionary] objectForKey:@"meta"];
                                    NSInteger code = [meta.code integerValue];
                                    NSInteger type = code / 100;
                                    switch (type) {
                                        case 2: // HTTP OK
                                        {
                                            self.state = kEFNetworkOperationStateSuccess;
                                            NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] initWithDictionary:[mappingResult dictionary]];
                                            [userInfo setValue:@"exfee" forKey:@"type"];
                                            [userInfo setValue:self.exfee.exfee_id forKey:@"id"];
                                            self.successUserInfo = userInfo;
                                            
                                            [self finish];
                                        } break;
                                        default:{
                                            // RKObjectManager *objectManager = [RKObjectManager sharedManager];
                                            // [objectManager.managedObjectStore.mainQueueManagedObjectContext rollback];
                                            
                                            // 400 Over people max limited
                                            self.state = kEFNetworkOperationStateFailure;
                                            NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] initWithDictionary:[mappingResult dictionary]];
                                            [userInfo setValue:@"exfee" forKey:@"type"];
                                            [userInfo setValue:self.exfee.exfee_id forKey:@"id"];
                                            self.failureUserInfo = userInfo;
                                            
                                            [self finish];
                                        } break;
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
