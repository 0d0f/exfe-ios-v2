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
                        updatedtime:(NSString*)updatedtime
                            success:(void (^)(RKObjectRequestOperation *operation, RKMappingResult *mappingResult))success
                            failure:(void (^)(RKObjectRequestOperation *operation, NSError *error))failure;

@end
