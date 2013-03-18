//
//  APIProfile.m
//  EXFE
//
//  Created by ju huo on 6/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "APIProfile.h"
#import "ProfileCellView.h"

@implementation APIProfile
+(void) MappingUsers{
//    RKObjectManager* manager =[RKObjectManager sharedManager];
//    RKManagedObjectMapping* userMapping = [RKManagedObjectMapping mappingForEntityWithName:@"User" inManagedObjectStore:manager.objectStore];
//    
//    userMapping.primaryKeyAttribute=@"user_id";
//    
//    [userMapping mapKeyPathsToAttributes:@"id", @"user_id",
//     @"avatar_filename", @"avatar_filename", 
//     @"bio", @"bio",
//     @"cross_quantity", @"cross_quantity",
//     @"name", @"name", 
//     @"timezone", @"timezone", 
//     nil];
//    RKManagedObjectMapping* identityMapping = [Mapping getIdentityMapping];
//    [userMapping mapRelationship:@"identities" withMapping:identityMapping];
//    
//    [manager.mappingProvider setObjectMapping:userMapping forKeyPath:@"response.user"];    
}

+(void) MappingSuggest{
//    RKObjectManager* manager =[RKObjectManager sharedManager];
//    RKManagedObjectMapping* identityMapping = [Mapping getIdentityMapping];
//    [manager.mappingProvider setObjectMapping:identityMapping forKeyPath:@"response.identities"];
}

+(void) LoadUsrWithUserId:(int)user_id success:(void (^)(RKObjectRequestOperation *operation, RKMappingResult *mappingResult))success failure:(void (^)(RKObjectRequestOperation *operation, NSError *error))failure{
  
  AppDelegate *app=(AppDelegate *)[[UIApplication sharedApplication] delegate];
  NSString *endpoint = [NSString stringWithFormat:@"%@/users/%u?token=%@",API_ROOT,user_id, app.accesstoken];
  [[RKObjectManager sharedManager] getObjectsAtPath:endpoint parameters:nil success:success failure:failure];
}

+(void) LoadUsrWithUserId:(int)user_id withToken:(NSString*)token success:(void (^)(RKObjectRequestOperation *operation, RKMappingResult *mappingResult))success failure:(void (^)(RKObjectRequestOperation *operation, NSError *error))failure{
  NSString *endpoint = [NSString stringWithFormat:@"%@/users/%u?token=%@",API_ROOT,user_id, token];
  [[RKObjectManager sharedManager] getObjectsAtPath:endpoint parameters:nil success:success failure:failure];
  
}

+(void) MergeIdentities:(NSString*)browsing_identity_token Identities_ids:(NSString*)ids success:(void (^)(RKObjectRequestOperation *operation, RKMappingResult *mappingResult))success failure:(void (^)(RKObjectRequestOperation *operation, NSError *error))failure{
  
  AppDelegate *app=(AppDelegate *)[[UIApplication sharedApplication] delegate];
  NSString *endpoint = [NSString stringWithFormat:@"%@/users/%u/mergeIdentities?token=%@",API_ROOT,app.userid, app.accesstoken];

  [[RKObjectManager sharedManager] getObjectsAtPath:endpoint parameters:@{@"browsing_identity_token":browsing_identity_token,@"identity_ids":ids} success:success failure:failure];
}


+ (void) LoadSuggest:(NSString*)key delegate:(id)delegate{

    AppDelegate *app=(AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    NSString *endpoint = [NSString stringWithFormat:@"/identities/complete?key=%@",key];
//    RKObjectManager* manager =[RKObjectManager sharedManager];
//    [manager.requestQueue cancelAllRequests];
//    [manager.client setBaseURL:[RKURL URLWithBaseURLString:API_V2_ROOT]];
//
//    [manager.client setValue:app.accesstoken forHTTPHeaderField:@"token"];
//    [manager loadObjectsAtResourcePath:endpoint usingBlock:^(RKObjectLoader *loader) {
//        loader.userData=@"suggest";
//        loader.delegate = delegate;
//    }];
}

//+(void) getIdentity:(NSString*)identity_json{
//    
//}

@end
