//
//  APIConversation.m
//  EXFE
//
//  Created by ju huo on 5/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "APIConversation.h"
#import "Post.h"
#import "Util.h"
#import "EFAPIServer.h"

@implementation APIConversation

+(void) LoadConversationWithExfeeId:(int)exfee_id updatedtime:(NSString*)updatedtime success:(void (^)(RKObjectRequestOperation *operation, RKMappingResult *mappingResult))success failure:(void (^)(RKObjectRequestOperation *operation, NSError *error))failure{
  
  if(updatedtime!=nil && ![updatedtime isEqualToString:@""])
    updatedtime=[Util encodeToPercentEscapeString:updatedtime];
  
  NSString *endpoint = [NSString stringWithFormat:@"%@conversation/%u?updated_at=%@&token=%@",API_ROOT,exfee_id, updatedtime,[EFAPIServer sharedInstance].user_token];
  [[RKObjectManager sharedManager] getObjectsAtPath:endpoint parameters:nil success:success failure:failure];
}


@end
