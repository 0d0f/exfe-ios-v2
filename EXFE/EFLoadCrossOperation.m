//
//  EFLoadCrossOperation.m
//  EXFE
//
//  Created by 0day on 13-6-26.
//
//

#import "EFLoadCrossOperation.h"

NSString *kEFNotificationNameLoadCrossSuccess = @"notification.loadCross.success";
NSString *kEFNotificationNameLoadCrossFailure = @"notification.loadCross.failure";

@implementation EFLoadCrossOperation

- (id)initWithModel:(EXFEModel *)model {
    NSParameterAssert(model);
    
    self = [super initWithModel:model];
    if (self) {
        self.successNotificationName = kEFNotificationNameLoadCrossSuccess;
        self.failureNotificationName = kEFNotificationNameLoadCrossFailure;
    }
    
    return self;
}

- (void)dealloc {
    [_updatedTime release];
    [super dealloc];
}

- (void)operationDidStart {
    [super operationDidStart];
    
    NSAssert(self.model, @"model shouldn't be nill.");
    NSAssert(self.model.apiServer, @"api shouldn't be nill.");
    
    [self.model.apiServer loadCrossWithCrossId:self.crossId
                                   updatedtime:self.updatedTime
                                       success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult){
                                           self.state = kEFNetworkOperationStateSuccess;
                                           NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] initWithDictionary:[mappingResult dictionary]];
                                           self.successUserInfo = userInfo;
                                           
                                           [self finish];
                                       }
                                       failure:^(RKObjectRequestOperation *operation, NSError *error){
                                           self.state = kEFNetworkOperationStateFailure;
                                           self.error = error;
                                           
                                           [self finish];
                                       }];
}


@end
