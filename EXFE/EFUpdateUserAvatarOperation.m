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
        self.ext = operation.ext;
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
                                   withExt:self.ext
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
