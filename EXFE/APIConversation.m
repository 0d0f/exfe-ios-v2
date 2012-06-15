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
    RKObjectManager* manager =[RKObjectManager sharedManager];
//    RKManagedObjectMapping* metaMapping = [Mapping getMetaMapping];
//    [manager.mappingProvider setObjectMapping:metaMapping forKeyPath:@"meta"];

    RKManagedObjectMapping* postMapping = [RKManagedObjectMapping mappingForEntityWithName:@"Post" inManagedObjectStore:manager.objectStore];
    
    postMapping.primaryKeyAttribute=@"post_id";
    
    [postMapping mapKeyPathsToAttributes:@"id", @"post_id",
     @"content", @"content", 
     @"created_at", @"created_at",
     @"updated_at", @"updated_at",
     @"postable_id", @"postable_id", 
     @"postable_type", @"postable_type", 
     nil];
    RKManagedObjectMapping* identityMapping = [Mapping getIdentityMapping];
    [postMapping mapRelationship:@"by_identity" withMapping:identityMapping];
  
    [manager.mappingProvider setObjectMapping:postMapping forKeyPath:@"response.conversation"];
}

+(void) LoadConversationWithExfeeId:(int)exfee_id updatedtime:(NSString*)updatedtime delegate:(id)delegate{

    AppDelegate *app=(AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    if(updatedtime!=nil && ![updatedtime isEqualToString:@""])
        updatedtime=[Util encodeToPercentEscapeString:updatedtime];
    
    NSString *endpoint = [NSString stringWithFormat:@"/conversation/%u?updated_at=%@&token=%@",exfee_id, updatedtime,app.accesstoken];
    
    RKObjectManager* manager =[RKObjectManager sharedManager];
    [manager loadObjectsAtResourcePath:endpoint delegate:delegate];

    
}

@end
