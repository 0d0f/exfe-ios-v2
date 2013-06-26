//
//  EFLoadUserOperation.m
//  EXFE
//
//  Created by 0day on 13-6-26.
//
//

#import "EFLoadUserOperation.h"

NSString *kEFNotificationNameLoadUserSuccess = @"notification.loadUser.success";
NSString *kEFNotificationNameLoadUserFailure = @"notification.loadUser.failure";

@implementation EFLoadUserOperation

- (id)initWithModel:(EXFEModel *)model {
    NSParameterAssert(model);
    
    self = [super initWithModel:model];
    if (self) {
        self.successNotificationName = kEFNotificationNameLoadUserSuccess;
        self.failureNotificationName = kEFNotificationNameLoadUserFailure;
        
        self.token = model.userToken;
    }
    return self;
}

- (void)dealloc {
    [_token release];
    [super dealloc];
}

- (void)operationDidStart {
    [super operationDidStart];
    
    NSAssert(self.model, @"model shouldn't be nill.");
    NSAssert(self.model.apiServer, @"api shouldn't be nill.");
    NSAssert(self.token && self.token.length > 0, @"token shouldn't be nill.");
    [self.model.apiServer loadUserBy:self.userId
                           withToken:self.token
                             success:^(AFHTTPRequestOperation *operation, id responseObject){
                                 self.state = kEFNetworkOperationStateSuccess;
                                 
                                 NSMutableDictionary *userInfo = [[[NSMutableDictionary alloc] initWithDictionary:responseObject] autorelease];
                                 [userInfo setValue:self.token forKey:@"token"];
                                 
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
