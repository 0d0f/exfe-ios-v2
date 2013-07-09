//
//  EFAPIServer+Conversation.h
//  EXFE
//
//  Created by 0day on 13-5-13.
//
//

#import "EFAPIServer.h"

@interface EFAPIServer (Conversation)

- (void)loadConversationWithExfeeId:(int)exfee_id
                        updatedtime:(NSDate*)updatedtime
                            success:(void (^)(RKObjectRequestOperation *operation, RKMappingResult *mappingResult))success
                            failure:(void (^)(RKObjectRequestOperation *operation, NSError *error))failure;


- (void)postConversation:(NSString*)content
                      by:(Identity*)myIdentity
                      on:(int)exfee_id
                 success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                 failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

@end
