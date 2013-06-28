//
//  EFLoadSuggestOperation.m
//  EXFE
//
//  Created by 0day on 13-6-27.
//
//

#import "EFLoadSuggestOperation.h"

NSString *kEFNotificationNameLoadSuggestSuccess = @"notification.loadSugget.success";
NSString *kEFNotificationNameLoadSuggestFailure = @"notification.loadSugget.failure";

@implementation EFLoadSuggestOperation

- (id)initWithModel:(EXFEModel *)model {
    NSParameterAssert(model);
    
    self = [super initWithModel:model];
    if (self) {
        self.successNotificationName = kEFNotificationNameLoadSuggestSuccess;
        self.failureNotificationName = kEFNotificationNameLoadSuggestFailure;
    }
    
    return self;
}

- (void)dealloc {
    [_key release];
    [super dealloc];
}

- (void)operationDidStart {
    [super operationDidStart];
    
    NSAssert(self.model, @"model shouldn't be nill.");
    NSAssert(self.model.apiServer, @"api shouldn't be nill.");
    NSAssert(self.key, @"key shouldn't be nil.");
    
    [self.model.apiServer loadSuggest:self.key
                              success:^(AFHTTPRequestOperation *operation, id responseObject){
                                  self.state = kEFNetworkOperationStateSuccess;
                                  NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithDictionary:responseObject];
                                  self.successUserInfo = userInfo;
                                  
                                  [self finish];
                              }
                              failure:^(AFHTTPRequestOperation *operation, NSError *error){
                                  self.state = kEFNetworkOperationStateFailure;
                                  self.error = error;
                                  
                                  [self finish];
                              }];
}


@end
