//
//  EFEditCrossOperation.m
//  EXFE
//
//  Created by Stony Wang on 13-8-19.
//
//

#import "EFEditCrossOperation.h"

#import "EFEntity.h"

NSString *kEFNotificationNameEditCrossSuccess = @"notification.editCross.success";
NSString *kEFNotificationNameEditCrossFailure = @"notification.editCross.failure";

@implementation EFEditCrossOperation

- (id)initWithModel:(EXFEModel *)model {
    NSParameterAssert(model);
    
    self = [super initWithModel:model];
    if (self) {
        self.successNotificationName = kEFNotificationNameEditCrossSuccess;
        self.failureNotificationName = kEFNotificationNameEditCrossFailure;
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
    
//    [self.cross addToContext:self.model.objectManager.managedObjectStore.mainQueueManagedObjectContext];
    
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
//                                        [self.cross.managedObjectContext deleteObject:self.cross];
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
