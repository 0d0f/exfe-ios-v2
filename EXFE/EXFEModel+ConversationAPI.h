//
//  EXFEModel+ConversationAPI.h
//  EXFE
//
//  Created by 0day on 13-6-26.
//
//

#import "EXFEModel.h"

@interface EXFEModel (ConversationAPI)

- (void)loadConversationWithExfeeId:(int)exfeeId updatedTime:(NSString *)updatedTime;

@end
