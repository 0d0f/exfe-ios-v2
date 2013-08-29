//
//  EFAPIServer+Conversation.h
//  EXFE
//
//  Created by 0day on 13-5-13.
//
//

#import "EFAPIServer.h"

@class Exfee;
@class Identity;
@interface EFAPIServer (Conversation)

- (void)loadConversationWithExfee:(Exfee*)exfee_id
                        updatedtime:(NSDate*)updatedtime
                            success:(void (^)(RKObjectRequestOperation *operation, RKMappingResult *mappingResult))success
                            failure:(void (^)(RKObjectRequestOperation *operation, NSError *error))failure;


- (void)postConversation:(NSString*)content
                      by:(Identity*)myIdentity
                      on:(Exfee*)exfee
                 success:(void (^)(RKObjectRequestOperation *operation, RKMappingResult *mappingResult))success
                 failure:(void (^)(RKObjectRequestOperation *operation, NSError *error))failure;

@end
