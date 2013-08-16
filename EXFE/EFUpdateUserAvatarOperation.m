//
//  EFUpdateUserAvatarOperation.m
//  EXFE
//
//  Created by Stony Wang on 13-7-17.
//
//

#import "EFUpdateUserAvatarOperation.h"

#import "Util.h"
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

- (id)initWithModel:(EXFEModel *)model dupelicateFrom:(EFUpdateUserAvatarOperation *)operation {
    self = [super initWithModel:model dupelicateFrom:operation];
    if (self) {
        self.original = operation.original;
        self.avatar_2x = operation.avatar_2x;
        self.avatar = operation.avatar;
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
                                       
                                       if ([NSURLErrorDomain isEqualToString:error.domain] || [AFNetworkingErrorDomain isEqualToString:error.domain]) {
                                           switch (error.code) {
                                               case NSURLErrorCancelled: // -999
                                               case NSURLErrorTimedOut: //-1001
                                               case NSURLErrorCannotFindHost: //-1003
                                               case NSURLErrorCannotConnectToHost: //-1004
                                               case NSURLErrorNetworkConnectionLost: //-1005
                                               case NSURLErrorDNSLookupFailed: //-1006
                                               case NSURLErrorNotConnectedToInternet: //-1009
                                               {// Retry
                                                   NSString *title = NSLocalizedString(@"###Failed to update User Avatar###", nil);
                                                   NSString *message = [NSString stringWithFormat:NSLocalizedString(@"###????###", nil)];
                                                   if (!self.original) {
                                                       NSString *title = NSLocalizedString(@"###Failed to remove user Avatar###", nil);
                                                   }
                                                   
                                                   [Util handleRetryBannerFor:self withTitle:title andMessage:message];
                                                   
                                               }   break;
                                                   
                                               case NSURLErrorHTTPTooManyRedirects: //-1007
                                               case NSURLErrorResourceUnavailable: //-1008
                                               case NSURLErrorRedirectToNonExistentLocation: //-1010
                                               case NSURLErrorBadServerResponse: // -1011
                                               case NSURLErrorServerCertificateUntrusted: //-1202
                                                   
                                                   
                                                   break;
                                                   
                                               default:
                                                   break;
                                           }
                                       }
                                       
                                       [self finish];
                                   }];
    
}

@end
