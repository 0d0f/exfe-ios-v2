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

@implementation APIConversation
+(void) MappingConversation{
    RKObjectManager* manager =[RKObjectManager sharedManager];
    RKManagedObjectMapping* postMapping = [RKManagedObjectMapping mappingForEntityWithName:@"Post" inManagedObjectStore:manager.objectStore];
    
    postMapping.primaryKeyAttribute=@"post_id";
    
    [postMapping mapKeyPathsToAttributes:@"id", @"post_id",
     @"content", @"content", 
     @"created_at", @"created_at",
     @"postable_id", @"postable_id", 
     @"postable_type", @"postable_type", 
     nil];
    RKManagedObjectMapping* identityMapping = [Mapping getIdentityMapping];
    [postMapping mapRelationship:@"by_identity" withMapping:identityMapping];
    
    [manager.mappingProvider setObjectMapping:postMapping forKeyPath:@"response.conversation"];

}

+(void) LoadConversationWithExfeeId:(int)userid updatedtime:(NSString*)updatedtime delegate:(id)delegate{

//    AppDelegate *app=(AppDelegate *)[[UIApplication sharedApplication] delegate];
//    if(updatedtime!=nil && ![updatedtime isEqualToString:@""])
//        updatedtime=[Util encodeToPercentEscapeString:updatedtime];
    
//    NSString *endpoint = [NSString stringWithFormat:@"/users/%u/crosses?updated_at=%@&token=%@",app.userid,updatedtime,app.accesstoken];
    NSString *endpoint = @"/conversation/110067?token=d2864ecbd97687087bbcfc62fb5c6c37";
    
//    users/131/crosses?updated_at=2012-05-20%2009:40:26&token=98eddc9c0afc48087f722ca1419c8650";   
    RKObjectManager* manager =[RKObjectManager sharedManager];
    [manager loadObjectsAtResourcePath:endpoint delegate:delegate];

    
}

@end
