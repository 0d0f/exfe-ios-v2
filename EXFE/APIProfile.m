//
//  APIProfile.m
//  EXFE
//
//  Created by ju huo on 6/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "APIProfile.h"
#import "Mapping.h"

@implementation APIProfile
+(void) MappingUsers{
    RKObjectManager* manager =[RKObjectManager sharedManager];
    RKManagedObjectMapping* userMapping = [RKManagedObjectMapping mappingForEntityWithName:@"User" inManagedObjectStore:manager.objectStore];
    
    userMapping.primaryKeyAttribute=@"user_id";
    
    [userMapping mapKeyPathsToAttributes:@"id", @"user_id",
     @"avatar_filename", @"avatar_filename", 
     @"bio", @"bio",
     @"cross_quantity", @"cross_quantity",
     @"name", @"name", 
     @"timezone", @"timezone", 
     nil];
    RKManagedObjectMapping* identityMapping = [Mapping getIdentityMapping];
    [userMapping mapRelationship:@"default_identity" withMapping:identityMapping];
    [userMapping mapRelationship:@"identities" withMapping:identityMapping];
    
    [manager.mappingProvider setObjectMapping:userMapping forKeyPath:@"response.user"];    
}
+(void) MappingSuggest{
    RKObjectManager* manager =[RKObjectManager sharedManager];
    RKManagedObjectMapping* identityMapping = [Mapping getIdentityMapping];
    [manager.mappingProvider setObjectMapping:identityMapping forKeyPath:@"response.identities"];
}

+(void) LoadUsrWithUserId:(int)user_id delegate:(id)delegate {
    AppDelegate *app=(AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    NSString *endpoint = [NSString stringWithFormat:@"/users/%u?token=%@",app.userid, app.accesstoken];
    
    RKObjectManager* manager =[RKObjectManager sharedManager];
    [manager loadObjectsAtResourcePath:endpoint usingBlock:^(RKObjectLoader *loader) {
        loader.userData = [NSNumber numberWithInt:user_id];
        loader.delegate = delegate;
    }];
    
}

+ (void) LoadSuggest:(NSString*)key delegate:(id)delegate{

    AppDelegate *app=(AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    NSString *endpoint = [NSString stringWithFormat:@"/identities/complete?key=%@",key];
    RKObjectManager* manager =[RKObjectManager sharedManager];
    [manager.client setValue:app.accesstoken forHTTPHeaderField:@"token"];
    [manager loadObjectsAtResourcePath:endpoint usingBlock:^(RKObjectLoader *loader) {
        loader.userData=@"suggest";
        loader.delegate = delegate;
    }];
}

@end
