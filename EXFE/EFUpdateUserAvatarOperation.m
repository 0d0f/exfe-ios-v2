//
//  EFUpdateUserAvatarOperation.m
//  EXFE
//
//  Created by Stony Wang on 13-7-17.
//
//

#import "EFUpdateUserAvatarOperation.h"

NSString *kEFNotificationUpdateUserAvatarSuccess = @"notification.updateUserAvatar.success";
NSString *kEFNotificationUpdateUserAvatarFailure = @"notification.updateUserAvatar.failure";

@implementation EFUpdateUserAvatarOperation

- (id)initWithModel:(EXFEModel *)model {
    NSParameterAssert(model);
    
    self = [super initWithModel:model];
    if (self) {
        self.successNotificationName = kEFNotificationUpdateUserAvatarSuccess;
        self.failureNotificationName = kEFNotificationUpdateUserAvatarFailure;
    }
    return self;
}


- (void)operationDidStart {
    [super operationDidStart];
    
    NSAssert(self.model, @"model shouldn't be nill.");
    NSAssert(self.model.apiServer, @"api shouldn't be nill.");
    
    [self.model.apiServer updateUserAvatar:self.original
                           withLargeAvatar:self.avatar_2x
                           withSmallAvatar:self.avatar
                                   success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                      
                                       if ([responseObject isKindOfClass:[NSDictionary class]]) {
                                           NSDictionary *body = responseObject;
                                           NSNumber *code = [body valueForKeyPath:@"meta.code"];
                                           if(code){
                                               NSInteger c = [code integerValue];
                                               NSInteger t = c / 100;
                                               if (t == 2) {
                                                   self.state = kEFNetworkOperationStateSuccess;
                                                   
                                                   NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] initWithDictionary:[body valueForKeyPath:@"response"]];
                                                   
                                                   self.successUserInfo = userInfo;
                                                   
                                                   [self finish];
                                                   return;
                                               } else {
                                                   self.state = kEFNetworkOperationStateFailure;
                                                   NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] initWithDictionary:[body valueForKeyPath:@"meta"]];
                                                   self.failureUserInfo = userInfo;
                                                   [self finish];
                                                   return;
                                               }
                                           }
                                       }
                                       
                                       self.state = kEFNetworkOperationStateFailure;
                                       [self finish];
                                   }
                                   failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                       self.state = kEFNetworkOperationStateFailure;
                                       self.error = error;
                                       
                                       [self finish];
                                   }];
    
}

@end
