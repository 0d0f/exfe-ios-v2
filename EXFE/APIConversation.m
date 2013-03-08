//
//  APIConversation.m
//  EXFE
//
//  Created by ju huo on 5/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "APIConversation.h"
#import "Post.h"
#import "Mapping.h"
#import "Util.h"

@implementation APIConversation
+(void) MappingConversation{
//RESTKIT0.2
//    RKObjectManager* manager =[RKObjectManager sharedManager];
//    [manager.client setBaseURL:[RKURL URLWithBaseURLString:API_V2_ROOT]];
//
//    RKManagedObjectMapping* postMapping = [RKManagedObjectMapping mappingForEntityWithName:@"Post" inManagedObjectStore:manager.objectStore];
//    
//    postMapping.primaryKeyAttribute=@"post_id";
//    
//    [postMapping mapKeyPathsToAttributes:@"id", @"post_id",
//     @"content", @"content", 
//     @"created_at", @"created_at",
//     @"updated_at", @"updated_at",
//     @"postable_id", @"postable_id", 
//     @"postable_type", @"postable_type", 
//     nil];
//    RKManagedObjectMapping* identityMapping = [Mapping getIdentityMapping];
//    [postMapping mapRelationship:@"by_identity" withMapping:identityMapping];
//  
//    [manager.mappingProvider setObjectMapping:postMapping forKeyPath:@"response.conversation"];
}

+(void) LoadConversationWithExfeeId:(int)exfee_id updatedtime:(NSString*)updatedtime success:(void (^)(RKObjectRequestOperation *operation, RKMappingResult *mappingResult))success failure:(void (^)(RKObjectRequestOperation *operation, NSError *error))failure{
  
  AppDelegate *app=(AppDelegate *)[[UIApplication sharedApplication] delegate];
  
  if(updatedtime!=nil && ![updatedtime isEqualToString:@""])
    updatedtime=[Util encodeToPercentEscapeString:updatedtime];
  
  NSString *endpoint = [NSString stringWithFormat:@"%@/conversation/%u?updated_at=%@&token=%@",API_ROOT,exfee_id, updatedtime,app.accesstoken];
  [[RKObjectManager sharedManager] getObjectsAtPath:endpoint parameters:nil success:success failure:failure];
}


@end
