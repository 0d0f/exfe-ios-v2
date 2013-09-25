//
//  EFRemoveCrossOperation.m
//  EXFE
//
//  Created by Stony Wang on 13-9-23.
//
//

#import "EFRemoveCrossOperation.h"

NSString *kEFNotificationNameRemoveCrossSuccess = @"notification.removeCross.success";
NSString *kEFNotificationNameRemoveCrossFailure = @"notification.removeCross.failure";

@implementation EFRemoveCrossOperation

- (id)initWithModel:(EXFEModel *)model {
    NSParameterAssert(model);
    
    self = [super initWithModel:model];
    if (self) {
        self.successNotificationName = kEFNotificationNameRemoveCrossSuccess;
        self.failureNotificationName = kEFNotificationNameRemoveCrossFailure;
    }
    
    return self;
}

- (id)initWithModel:(EXFEModel *)model dupelicateFrom:(EFEditCrossOperation *)operation
{
    self = [super initWithModel:model dupelicateFrom:operation];
    if (self) {
        self.cross = operation.cross;
    }
    return self;
}


- (void)operationDidStart {
    [super operationDidStart];
    
    NSAssert(self.model, @"model shouldn't be nill.");
    NSAssert(self.model.apiServer, @"api shouldn't be nill.");
    
    [self.model.apiServer removeCross:self.cross
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
                                        
                                        [self.model deleteCross:self.cross];
                                        
                                        self.successUserInfo = userInfo;
                                        [self finish];
                                    } break;
                                        
//                                        400, 'no_cross_id'
//                                        401, 'invalid_auth'
//                                        403, 'not_authorized'
//                                        400, 'param_error'
                                        
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
