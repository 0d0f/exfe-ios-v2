//
//  EFLoadCrossListOperation.m
//  EXFE
//
//  Created by Stony Wang on 13-8-19.
//
//

#import "EFLoadCrossListOperation.h"

NSString *kEFNotificationNameLoadCrossListSuccess = @"notification.loadCrossList.success";
NSString *kEFNotificationNameLoadCrossListFailure = @"notification.loadCrossList.failure";

@implementation EFLoadCrossListOperation

- (id)initWithModel:(EXFEModel *)model {
    NSParameterAssert(model);
    
    self = [super initWithModel:model];
    if (self) {
        self.successNotificationName = kEFNotificationNameLoadCrossListSuccess;
        self.failureNotificationName = kEFNotificationNameLoadCrossListFailure;
    }
    
    return self;
}


- (void)operationDidStart {
    [super operationDidStart];
    
    NSAssert(self.model, @"model shouldn't be nill.");
    NSAssert(self.model.apiServer, @"api shouldn't be nill.");
    
    [self.model.apiServer loadCrossesAfter:self.updatedTime
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
