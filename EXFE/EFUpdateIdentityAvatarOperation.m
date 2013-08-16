//
//  EFUpdateIdentityAvatarOperation.m
//  EXFE
//
//  Created by Stony Wang on 13-7-17.
//
//

#import "EFUpdateIdentityAvatarOperation.h"

#import "Util.h"

NSString *kEFNotificationUpdateIdentityAvatarSuccess = @"notification.updateIdentityAvatar.success";
NSString *kEFNotificationUpdateIdentityAvatarFailure = @"notification.updateIdentityAvatar.failure";

@implementation EFUpdateIdentityAvatarOperation

- (id)initWithModel:(EXFEModel *)model {
    NSParameterAssert(model);
    
    self = [super initWithModel:model];
    if (self) {
        self.successNotificationName = kEFNotificationUpdateIdentityAvatarSuccess;
        self.failureNotificationName = kEFNotificationUpdateIdentityAvatarFailure;
    }
    return self;
}

- (id)initWithModel:(EXFEModel *)model dupelicateFrom:(EFUpdateIdentityAvatarOperation *)operation {
    self = [super initWithModel:model dupelicateFrom:operation];
    if (self) {
        self.original = operation.original;
        self.avatar_2x = operation.avatar_2x;
        self.avatar = operation.avatar;
        self.identity = operation.identity;
    }
    
    return self;
}

- (void)operationDidStart {
    [super operationDidStart];
    
    NSAssert(self.model, @"model shouldn't be nill.");
    NSAssert(self.model.apiServer, @"api shouldn't be nill.");
    
    [self.model.apiServer updateIdentityAvatar:self.original
                               withLargeAvatar:self.avatar_2x
                               withSmallAvatar:self.avatar
                                           for:self.identity
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
                                                       NSString *title = NSLocalizedString(@"###Failed to update Identity Avatar###", nil);
                                                       NSString *message = [NSString stringWithFormat:NSLocalizedString(@"###????###", nil)];
                                                       if (!self.original) {
                                                            title = NSLocalizedString(@"###Failed to remove Identity Avatar###", nil);
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
