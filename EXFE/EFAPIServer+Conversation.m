//
//  EFAPIServer+Conversation.m
//  EXFE
//
//  Created by 0day on 13-5-13.
//
//

#import "EFAPIServer+Conversation.h"

#import "Util.h"

@implementation EFAPIServer (Conversation)

- (void)loadConversationWithExfeeId:(int)exfee_id
                        updatedtime:(NSString*)updatedtime
                            success:(void (^)(RKObjectRequestOperation *operation, RKMappingResult *mappingResult))success
                            failure:(void (^)(RKObjectRequestOperation *operation, NSError *error))failure {
    if (updatedtime!=nil && ![updatedtime isEqualToString:@""]) {
        updatedtime = [Util encodeToPercentEscapeString:updatedtime];
    }
    
    NSMutableDictionary *param = [NSMutableDictionary dictionaryWithDictionary:@{@"token": self.model.userToken}];
    if (updatedtime.length > 0) {
        [param addEntriesFromDictionary:@{ @"updated_at": updatedtime}];
    }
    NSString *endpoint = [NSString stringWithFormat:@"conversation/%u", exfee_id];
    
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
                      on:(int)exfee_id
                 success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                 failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    NSDictionary *postdict = @{@"by_identity_id": myIdentity.identity_id,
                               @"content": content ,
                               @"relative": [NSArray arrayWithObjects:nil],
                               @"type": @"post",
                               @"via": @"iOS"};
    
    NSString *endpoint = [NSString stringWithFormat:@"conversation/%u/add?token=%@", exfee_id, self.model.userToken];
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
