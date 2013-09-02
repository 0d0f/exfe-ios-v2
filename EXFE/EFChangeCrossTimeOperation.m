//
//  EFChangeCrossTimeOperation.m
//  EXFE
//
//  Created by Stony Wang on 13-9-2.
//
//

#import "EFChangeCrossTimeOperation.h"

#import "EFEntity.h"

NSString *kEFNotificationNameChangeCrossTimeSuccess = @"notification.changeCrossTime.success";
NSString *kEFNotificationNameChangeCrossTimeFailure = @"notification.changeCrossTime.failure";

@implementation EFChangeCrossTimeOperation

- (id)initWithModel:(EXFEModel *)model {
    NSParameterAssert(model);
    
    self = [super initWithModel:model];
    if (self) {
        self.successNotificationName = kEFNotificationNameChangeCrossTimeSuccess;
        self.failureNotificationName = kEFNotificationNameChangeCrossTimeFailure;
    }
    
    return self;
}

- (id)initWithModel:(EXFEModel *)model dupelicateFrom:(EFChangeCrossTimeOperation *)operation
{
    self = [super initWithModel:model dupelicateFrom:operation];
    if (self) {
        self.cross = operation.cross;
        self.crossTime = operation.crossTime;
    }
    return self;
}


- (void)operationDidStart {
    [super operationDidStart];
    
    NSAssert(self.model, @"model shouldn't be nill.");
    NSAssert(self.model.apiServer, @"api shouldn't be nill.");
    
    [self.model.apiServer editCross:self.cross
                            success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                Meta *meta = (Meta *)[[mappingResult dictionary] objectForKey:@"meta"];
                                NSInteger c = [meta.code integerValue];
                                NSInteger t = c / 100;
                                
                                switch (t) {
                                    case 2:{
                                        self.state = kEFNetworkOperationStateSuccess;
                                        NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] initWithDictionary:[mappingResult dictionary]];
                                        [userInfo setValue:@"cross" forKey:@"type"];
                                        [userInfo setValue:self.cross.cross_id forKey:@"id"];
                                        
                                        self.successUserInfo = userInfo;
                                        [self finish];
                                    } break;
                                        
                                    default:{
                                        self.state = kEFNetworkOperationStateFailure;
                                        NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] initWithDictionary:[mappingResult dictionary]];
                                        [userInfo setValue:@"cross" forKey:@"type"];
                                        [userInfo setValue:self.cross.cross_id forKey:@"id"];
                                        self.failureUserInfo = userInfo;
                                        [self finish];
                                    } break;
                                }
                            }
                            failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                self.state = kEFNetworkOperationStateFailure;
                                NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithCapacity:2];
                                [userInfo setValue:@"cross" forKey:@"type"];
                                [userInfo setValue:self.cross.cross_id forKey:@"id"];
                                self.failureUserInfo = userInfo;
                                self.error = error;
                                
                                [self finish];
                            }];
}

@end
