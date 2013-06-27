//
//  EFReverseGeocodingOperation.m
//  EXFE
//
//  Created by 0day on 13-6-27.
//
//

#import "EFReverseGeocodingOperation.h"

NSString *kEFNotificationNameReverseGeocodingSuccess = @"notification.reverseGeocoding.success";
NSString *kEFNotificationNameReverseGeocodingFailure = @"notification.reverseGeocoding.failure";

@implementation EFReverseGeocodingOperation

- (id)initWithModel:(EXFEModel *)model {
    NSParameterAssert(model);
    
    self = [super initWithModel:model];
    if (self) {
        self.successNotificationName = kEFNotificationNameReverseGeocodingSuccess;
        self.failureNotificationName = kEFNotificationNameReverseGeocodingFailure;
    }
    
    return self;
}

- (void)operationDidStart {
    [super operationDidStart];
    
    NSAssert(self.model, @"model shouldn't be nill.");
    NSAssert(self.model.apiServer, @"api shouldn't be nill.");
    
    [self.model.apiServer reverseGeocodingWithLocation:self.location
                                               success:^(AFHTTPRequestOperation *operation, id responseObject){
                                                   self.state = kEFNetworkOperationStateSuccess;
                                                   self.successUserInfo = responseObject;
                                                   
                                                   [self finish];
                                               }
                                               failure:^(AFHTTPRequestOperation *operation, NSError *error){
                                                   self.state = kEFNetworkOperationStateFailure;
                                                   self.error = error;
                                                   
                                                   [self finish];
                                               }];
}

@end
