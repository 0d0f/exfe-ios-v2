//
//  Mapping.m
//  EXFE
//
//  Created by ju huo on 5/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Mapping.h"

@implementation Mapping
+ (RKManagedObjectMapping*) getMetaMapping{
    RKObjectManager* manager =[RKObjectManager sharedManager];
    RKManagedObjectMapping* metaMapping = [RKManagedObjectMapping mappingForEntityWithName:@"Meta" inManagedObjectStore:manager.objectStore];
    
    [metaMapping mapKeyPathsToAttributes:@"code", @"code",
     @"errorDetail", @"errorDetail", 
     @"errorType", @"errorType",
     nil];
    return metaMapping;
}

+ (RKManagedObjectMapping*) getIdentityMapping{
    
    RKObjectManager* manager =[RKObjectManager sharedManager];
    RKManagedObjectMapping* identityMapping = [RKManagedObjectMapping mappingForEntityWithName:@"Identity" inManagedObjectStore:manager.objectStore];
    
    identityMapping.primaryKeyAttribute=@"identity_id";
    [identityMapping mapKeyPathsToAttributes:@"id", @"identity_id",
     @"name", @"name", 
     @"nickname", @"nickname",
     @"provider", @"provider", 
     @"external_id", @"external_id", 
     @"external_username", @"external_username", 
     @"connected_user_id", @"connected_user_id",
     @"bio", @"bio", 
     @"avatar_filename", @"avatar_filename",
     @"avatar_updated_at", @"avatar_updated_at", 
     @"created_at", @"created_at", 
     @"updated_at", @"updated_at", 
     nil];
    return identityMapping;
}
@end
