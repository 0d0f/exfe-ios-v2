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
        self.ext = operation.ext;
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
                                       withExt:self.ext
                                           for:self.identity
                                       success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                           
                                           if ([responseObject isKindOfClass:[NSDictionary class]]) {
                                               NSDictionary *body = responseObject;
                                               NSNumber *code = [body valueForKeyPath:@"meta.code"];
                                               if(code){
                                                   NSInteger c = [code integerValue];
                                                   NSInteger t = c / 100;
                                                   switch (t) {
                                                       case 2:{
                                                           self.state = kEFNetworkOperationStateSuccess;
                                                           NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] initWithDictionary:[body valueForKeyPath:@"response"]];
                                                           self.successUserInfo = userInfo;
                                                           
                                                           [self finish];
                                                           return;
                                                       }  break;
                                                           
                                                       case 4:{
                                                           self.state = kEFNetworkOperationStateFailure;
                                                           
                                                           if (c == 401) {
                                                               NSString *errorType = [body valueForKeyPath:@"meta.errorType"];
                                                               if ([@"not_allowed" isEqualToString:errorType]) {
                                                                   
                                                                   NSString *title = NSLocalizedString(@"Failed to update portrait.", nil);
                                                                   NSString *message = nil;
                                                                   if (!self.original) {
                                                                       //title = NSLocalizedString(@"###Failed to remove Identity Avatar###", nil);
                                                                   }
                                                                   [Util handleRetryBannerFor:self withTitle:title andMessage:message andRetry:NO];
                                                               }
                                                           }
                                                           
                                                           NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] initWithDictionary:[body valueForKeyPath:@"meta"]];
                                                           self.failureUserInfo = userInfo;
                                                           [self finish];
                                                           return;
                                                       }
                                                       default:{
                                                           self.state = kEFNetworkOperationStateFailure;
                                                           NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] initWithDictionary:[body valueForKeyPath:@"meta"]];
                                                           self.failureUserInfo = userInfo;
                                                           [self finish];
                                                           return;
                                                       }  break;
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
                                                   case NSURLErrorCancelled:
                                                   case NSURLErrorTimedOut:
                                                   case NSURLErrorCannotFindHost:
                                                   case NSURLErrorCannotConnectToHost:
                                                   case NSURLErrorNetworkConnectionLost:
                                                   case NSURLErrorDNSLookupFailed:
                                                   case NSURLErrorNotConnectedToInternet:
                                                   case NSURLErrorHTTPTooManyRedirects:
                                                   case NSURLErrorResourceUnavailable:
                                                   case NSURLErrorRedirectToNonExistentLocation:
                                                   case NSURLErrorBadServerResponse:
                                                   case NSURLErrorZeroByteResource:
                                                   case NSURLErrorServerCertificateUntrusted:
                                                   {// Retry
                                                       NSString *title = NSLocalizedString(@"Failed to update portrait.", nil);
                                                       NSString *message = nil;
                                                       if (!self.original) {
                                                            //title = NSLocalizedString(@"###Failed to remove Identity Avatar###", nil);
                                                       }
                                                       
                                                       [Util handleRetryBannerFor:self withTitle:title andMessage:message andRetry:YES];
                                                       
                                                   }   break;
                                                       
                                                   default:
                                                       break;
                                               }
                                           }
                                           
                                           [self finish];
                                       }];
}

@end
