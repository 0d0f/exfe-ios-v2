//
//  EXFEModel+ConversationAPI.h
//  EXFE
//
//  Created by 0day on 13-6-26.
//
//

#import "EXFEModel.h"

@class Exfee;
@class Identity;
@interface EXFEModel (ConversationAPI)

- (void)loadConversationWithExfee:(Exfee *)exfee updatedTime:(NSDate *)updatedTime;
- (void)postConversation:(NSString *)content by:(Identity *)myIdentity on:(Exfee *)exfee;

@end
