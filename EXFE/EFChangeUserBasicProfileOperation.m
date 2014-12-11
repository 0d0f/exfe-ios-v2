//
//  EFChangeUserBasicProfileOperation.m
//  EXFE
//
//  Created by Stony Wang on 13-7-17.
//
//

#import "EFChangeUserBasicProfileOperation.h"
#import "Util.h"

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

- (id)initWithModel:(EXFEModel *)model dupelicateFrom:(EFChangeUserBasicProfileOperation *)operation {
    self = [super initWithModel:model dupelicateFrom:operation];
    if (self) {
        self.name = operation.name;
        self.bio = operation.bio;
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
                                                         
                                                         NSString *title = NSLocalizedString(@"Failed to update profile.", nil);
                                                         NSString *message = nil;
                                                         if (self.name) {
                                                             message = [NSString stringWithFormat:NSLocalizedString(@"\"%@\"", nil), self.name];
                                                         } else {
                                                             message = [NSString stringWithFormat:NSLocalizedString(@"\"%@\"", nil), self.bio];
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
                                             NSString *title = NSLocalizedString(@"Failed to update profile.", nil);
                                             NSString *message = nil;
                                             if (self.name) {
                                                 message = [NSString stringWithFormat:NSLocalizedString(@"\"%@\"", nil), self.name];
                                             } else {
                                                 message = [NSString stringWithFormat:NSLocalizedString(@"\"%@\"", nil), self.bio];
                                             }
                                             
                                             [Util handleRetryBannerFor:self withTitle:title andMessage:message andRetry:YES];
                                             
                                         }   break;
                                             
                                         default:
                                             break;
                                     }
                                 }
                                 // op: self
                                 // Error title: depends on error code/type
                                 // Error Description: depends on error code/type
                                 // ? Error Handler: retry/done
                                 
                                 
                                 
                                 [self finish];
                             }];
}


@end
