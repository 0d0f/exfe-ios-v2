//
//  EFGetPlacesByTitleOperation.m
//  EXFE
//
//  Created by 0day on 13-6-27.
//
//

#import "EFGetPlacesByTitleOperation.h"

#import <MapKit/MapKit.h>

NSString *kEFNotificationNameGetPlacesByTitleSuccess = @"notification.getPlacesByTitle.success";
NSString *kEFNotificationNameGetPlacesByTitleFailure = @"notification.getPlacesByTitle.failure";

@implementation EFGetPlacesByTitleOperation

- (id)initWithModel:(EXFEModel *)model {
    NSParameterAssert(model);
    
    self = [super initWithModel:model];
    if (self) {
        self.successNotificationName = kEFNotificationNameGetPlacesByTitleSuccess;
        self.failureNotificationName = kEFNotificationNameGetPlacesByTitleFailure;
    }
    
    return self;
}

- (void)dealloc {
    [_title release];
    [super dealloc];
}

- (void)operationDidStart {
    [super operationDidStart];
    
    NSAssert(self.model, @"model shouldn't be nill.");
    NSAssert(self.model.apiServer, @"api shouldn't be nill.");
    NSAssert(self.title, @"updated time shouldn't be nil.");
    
    [self.model.apiServer getPlacesByTitle:self.title
                                  location:self.location
                                   success:^(AFHTTPRequestOperation *operation, id responseObject){
                                       self.state = kEFNetworkOperationStateSuccess;
                                       NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithDictionary:responseObject];
                                       [userInfo setValue:self.title forKey:@"title"];
                                       [userInfo setValue:[NSValue valueWithMKCoordinate:self.location] forKey:@"location"];
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
