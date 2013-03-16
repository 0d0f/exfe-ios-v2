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


//RESTKIT0.2
//+(void) LoadUsrWithUserId:(int)user_id token:(NSString*)token usingBlock:(void (^)(RKRequest *request))block ;
//+(void) MergeIdentities:(NSString*)browsing_identity_token Identities_ids:(NSString*)ids usingBlock:(void (^)(RKRequest *request))block;
+(void) LoadSuggest:(NSString*)key delegate:(id)delegate;
//+(void) getIdentity:(NSString*)identity_json;
@end
