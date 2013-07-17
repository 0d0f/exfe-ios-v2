//
//  EFChangeUserBasicProfileOperation.m
//  EXFE
//
//  Created by Stony Wang on 13-7-17.
//
//

#import "EFChangeUserBasicProfileOperation.h"

NSString *kEFNotificationChangeUserBasicProfileSuccess = @"notification.changeUserBasicProfile.success";
NSString *kEFNotificationChangeUserBasicProfileFailure = @"notification.changeUserBasicProfile.failure";

@implementation EFChangeUserBasicProfileOperation

- (id)initWithModel:(EXFEModel *)model {
    NSParameterAssert(model);
    
    self = [super initWithModel:model];
    if (self) {
        self.successNotificationName = kEFNotificationChangeUserBasicProfileSuccess;
        self.failureNotificationName = kEFNotificationChangeUserBasicProfileFailure;
    }
    return self;
}


- (void)operationDidStart {
    [super operationDidStart];
    
    NSAssert(self.model, @"model shouldn't be nill.");
    NSAssert(self.model.apiServer, @"api shouldn't be nill.");
    
    [self.model.apiServer updateName:self.name
                              andBio:self.bio
                             success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                 self.state = kEFNetworkOperationStateSuccess;
                                 
                                 NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] initWithDictionary:responseObject];
                                 
                                 self.successUserInfo = userInfo;
                                 
                                 [self finish];
                             }
                             failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                 self.state = kEFNetworkOperationStateFailure;
                                 self.error = error;
                                 
                                 [self finish];
                             }];
}


@end
