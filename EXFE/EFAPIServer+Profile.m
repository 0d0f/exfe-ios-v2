//
//  EFAPIServer+Profile.m
//  EXFE
//
//  Created by 0day on 13-5-13.
//
//

#import "EFAPIServer+Profile.h"

@implementation EFAPIServer (Profile)

- (void)loadSuggest:(NSString*)key
            success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
            failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure {
    NSDictionary *param = @{@"token": self.model.userToken};
    NSString *endpoint = [NSString stringWithFormat:@"identities/complete?key=%@", key];
    
    [[RKObjectManager sharedManager].HTTPClient getPath:endpoint
                                             parameters:param
                                                success:^(AFHTTPRequestOperation *operation, id responseObject){
                                                    [self performSelector:@selector(_handleSuccessWithRequestOperation:andResponseObject:)
                                                               withObject:operation
                                                               withObject:responseObject];
                                                    
                                                    if (success) {
                                                        dispatch_async(dispatch_get_main_queue(), ^{
                                                            success(operation, responseObject);
                                                        });
                                                    }
                                                }
                                                failure:^(AFHTTPRequestOperation *operation, NSError *error){
                                                    [self performSelector:@selector(_handleFailureWithRequestOperation:andError:)
                                                               withObject:operation
                                                               withObject:error];
                                                    
                                                    if (failure) {
                                                        dispatch_async(dispatch_get_main_queue(), ^{
                                                            failure(operation, error);
                                                        });
                                                    }
                                                }];
}

@end
