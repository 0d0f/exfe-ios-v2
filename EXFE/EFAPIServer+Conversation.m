//
//  EFAPIServer+Conversation.m
//  EXFE
//
//  Created by 0day on 13-5-13.
//
//

#import "EFAPIServer+Conversation.h"

#import "Util.h"
#import "DateTimeUtil.h"
#import "Exfee+EXFE.h"

@implementation EFAPIServer (Conversation)

- (void)loadConversationWithExfee:(Exfee*)exfee
                        updatedtime:(NSDate*)updatedtime
                            success:(void (^)(RKObjectRequestOperation *operation, RKMappingResult *mappingResult))success
                            failure:(void (^)(RKObjectRequestOperation *operation, NSError *error))failure {
    NSString *endpoint = [NSString stringWithFormat:@"conversation/%u", [exfee.exfee_id integerValue]];
    
    NSDictionary *param = nil;
    if (updatedtime != nil) {
        NSDateFormatter *fmt = [DateTimeUtil defaultDateTimeFormatter];
        param = @{@"token": self.model.userToken, @"updated_at": [fmt stringFromDate:updatedtime]};
    } else {
        param = @{@"token": self.model.userToken};
    }
    
    [[RKObjectManager sharedManager] getObjectsAtPath:endpoint
                                           parameters:param
                                              success:^(RKObjectRequestOperation *operation, id responseObject){
                                                  [self performSelector:@selector(_handleSuccessWithRequestOperation:andResponseObject:)
                                                             withObject:operation
                                                             withObject:responseObject];
                                                  
                                                  if (success) {
                                                      dispatch_async(dispatch_get_main_queue(), ^{
                                                          success(operation, responseObject);
                                                      });
                                                  }
                                              }
                                              failure:^(RKObjectRequestOperation *operation, NSError *error){
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

- (void)postConversation:(NSString*)content
                      by:(Identity*)myIdentity
                      on:(Exfee*)exfee
                 success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                 failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    NSDictionary *postdict = @{@"by_identity_id": myIdentity.identity_id,
                               @"content": content ,
                               @"relative": [NSArray arrayWithObjects:nil],
                               @"type": @"post",
                               @"via": @"iOS"};
    
    NSString *endpoint = [NSString stringWithFormat:@"conversation/%u/add?token=%@", [exfee.exfee_id integerValue], self.model.userToken];
    RKObjectManager *manager=[RKObjectManager sharedManager];
    manager.HTTPClient.parameterEncoding = AFJSONParameterEncoding;
    
    [manager.HTTPClient postPath:endpoint parameters:postdict success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [self performSelector:@selector(_handleSuccessWithRequestOperation:andResponseObject:)
                   withObject:operation
                   withObject:responseObject];
        
        if (success) {
            dispatch_async(dispatch_get_main_queue(), ^{
                success(operation, responseObject);
            });
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
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
