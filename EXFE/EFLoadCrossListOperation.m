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
                                       if ([[mappingResult dictionary] isKindOfClass:[NSDictionary class]]){
                                           Meta *meta = (Meta *)[[mappingResult dictionary] objectForKey:@"meta"];
                                           NSInteger code = [meta.code integerValue];
                                           NSInteger type = code / 100;
                                           switch (type) {
                                               case 2:
                                               {
                                                   self.state = kEFNetworkOperationStateSuccess;
                                                   NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] initWithDictionary:[mappingResult dictionary]];
                                                   [userInfo setValue:@"cross" forKey:@"type"];
                                                   [userInfo setValue:[NSNull null] forKey:@"id"];
                                                   self.successUserInfo = userInfo;
                                                   
                                                   [self finish];
                                               } break;
                                               default:{
                                                   self.state = kEFNetworkOperationStateFailure;
                                                   NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] initWithDictionary:[mappingResult dictionary]];
                                                   [userInfo setValue:@"cross" forKey:@"type"];
                                                   [userInfo setValue:[NSNull null] forKey:@"id"];
                                                   self.failureUserInfo = userInfo;
                                                   
                                                   [self finish];
                                               } break;
                                           }
                                       }
                                   }
                                   failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                       self.state = kEFNetworkOperationStateFailure;
                                       NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithCapacity:3];
                                       userInfo[@"type"] = @"cross";
                                       [userInfo setValue:[NSNull null] forKey:@"id"];
                                       self.failureUserInfo = userInfo;
                                       self.error = error;
                                       
                                       [self finish];
                                   }];
}


@end
