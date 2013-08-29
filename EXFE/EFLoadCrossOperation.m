//
//  EFLoadCrossOperation.m
//  EXFE
//
//  Created by 0day on 13-6-26.
//
//

#import "EFLoadCrossOperation.h"

#import "EFEntity.h"
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


- (void)operationDidStart {
    [super operationDidStart];
    
    NSAssert(self.model, @"model shouldn't be nill.");
    NSAssert(self.model.apiServer, @"api shouldn't be nill.");
    
    [self.model.apiServer loadCrossWithCrossId:self.crossId
                                   updatedtime:self.updatedTime
                                       success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                           
                                           Meta *meta = (Meta *)[[mappingResult dictionary] objectForKey:@"meta"];
                                           NSInteger c = [meta.code integerValue];
                                           NSInteger t = c / 100;
                                           
                                           switch (t) {
                                               case 2:{
                                                   self.state = kEFNetworkOperationStateSuccess;
                                                   NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] initWithDictionary:[mappingResult dictionary]];
                                                   userInfo[@"type"] = @"cross";
                                                   userInfo[@"id"] = @(self.crossId);
                                                   self.successUserInfo = userInfo;
                                                   [self finish];
                                               } break;
                                                   
                                               default:{
                                                   self.state = kEFNetworkOperationStateFailure;
                                                   NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] initWithDictionary:[mappingResult dictionary]];
                                                   userInfo[@"type"] = @"cross";
                                                   userInfo[@"id"] = @(self.crossId);
                                                   self.failureUserInfo = userInfo;
                                                   [self finish];
                                               } break;
                                           }
                                       }
                                       failure:^(RKObjectRequestOperation *operation, NSError *error){
                                           self.state = kEFNetworkOperationStateFailure;
                                           NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithCapacity:3];
                                           userInfo[@"type"] = @"cross";
                                           userInfo[@"id"] = @(self.crossId);
                                           self.failureUserInfo = userInfo;
                                           self.error = error;
                                           
                                           [self finish];
                                       }];
}


@end
