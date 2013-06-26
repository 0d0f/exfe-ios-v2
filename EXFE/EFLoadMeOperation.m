//
//  EFLoadMeOperation.m
//  EXFE
//
//  Created by 0day on 13-6-20.
//
//

#import "EFLoadMeOperation.h"

NSString *kEFNotificationNameLoadMeSuccess = @"notificaiton.loadMe.success";
NSString *kEFNotificationNameLoadMeFailure = @"notification.loadMe.failure";

@implementation EFLoadMeOperation

- (id)initWithModel:(EXFEModel *)model {
    NSParameterAssert(model);
    
    self = [super initWithModel:model];
    if (self) {
        self.successNotificationName = kEFNotificationNameLoadMeSuccess;
        self.failureNotificationName = kEFNotificationNameLoadMeFailure;
    }
    return self;
}

- (void)operationDidStart {
    [super operationDidStart];
    
    NSAssert(self.model, @"model shouldn't be nill.");
    NSAssert(self.model.apiServer, @"api shouldn't be nill.");
    [self.model.apiServer loadMeSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult){
        self.state = kEFNetworkOperationStateSuccess;
        
        [self finish];
    }
                                failure:^(RKObjectRequestOperation *operation, NSError *error){
                                    self.state = kEFNetworkOperationStateFailure;
                                    self.error = error;
                                    
                                    [self finish];
                                }];
}

@end
