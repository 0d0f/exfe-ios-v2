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
    
    NSDictionary *param = @{@"token": self.user_token};
    NSString *endpoint = [NSString stringWithFormat:@"conversation/%u?updated_at=%@", exfee_id, updatedtime];
    
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

@end
