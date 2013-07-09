//
//  EFLoadConversationOperation.h
//  EXFE
//
//  Created by 0day on 13-6-26.
//
//

#import "EFNetworkOperation.h"

@interface EFLoadConversationOperation : EFNetworkOperation

@property (nonatomic, assign) int exfeeId;
@property (nonatomic, strong) NSDate *updatedTime;

@end
