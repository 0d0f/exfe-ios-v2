//
//  EFEditCrossOperation.m
//  EXFE
//
//  Created by Stony Wang on 13-8-19.
//
//

#import "EFEditCrossOperation.h"

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
    
    [self.model.apiServer editCross:self.cross
                            success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                self.state = kEFNetworkOperationStateSuccess;
                                NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] initWithDictionary:[mappingResult dictionary]];
                                self.successUserInfo = userInfo;
                                
                                [self finish];
                            }
                            failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                self.state = kEFNetworkOperationStateFailure;
                                self.error = error;
                                
                                [self finish];
                            }];
}

@end
