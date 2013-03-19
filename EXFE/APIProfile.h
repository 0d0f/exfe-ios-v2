//
//  APIProfile.h
//  EXFE
//
//  Created by ju huo on 6/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RestKit/RestKit.h>
#import "AppDelegate.h"
#import "User.h"


@interface APIProfile : NSObject
+(void) MappingUsers;
+(void) MappingSuggest;
+(void) LoadUsrWithUserId:(int)user_id success:(void (^)(RKObjectRequestOperation *operation, RKMappingResult *mappingResult))success failure:(void (^)(RKObjectRequestOperation *operation, NSError *error))failure;

+(void) LoadUsrWithUserId:(int)user_id withToken:(NSString*)token success:(void (^)(RKObjectRequestOperation *operation, RKMappingResult *mappingResult))success failure:(void (^)(RKObjectRequestOperation *operation, NSError *error))failure;

+(void) MergeIdentities:(NSString*)browsing_identity_token Identities_ids:(NSString*)ids
                success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

+(void) LoadSuggest:(NSString*)key success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
            failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

@end
