//
//  APIProfile.m
//  EXFE
//
//  Created by ju huo on 6/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "APIProfile.h"
#import "ProfileCellView.h"
#import "Identity+EXFE.h"
#import "EFAPIServer.h"

@implementation APIProfile

+(void) MergeIdentities:(NSString*)browsing_identity_token Identities_ids:(NSString*)ids
                success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure {
  
  NSString *endpoint = [NSString stringWithFormat:@"%@users/%u/mergeIdentities?token=%@",API_ROOT,[EFAPIServer sharedInstance].user_id, [EFAPIServer sharedInstance].user_token];
  
  [RKObjectManager sharedManager].HTTPClient.parameterEncoding=AFFormURLParameterEncoding;
  [[RKObjectManager sharedManager].HTTPClient postPath:endpoint parameters:@{@"browsing_identity_token":browsing_identity_token,@"identity_ids":ids} success:success failure:failure];
}


+ (void) LoadSuggest:(NSString*)key success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
             failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure {
    
    NSString *endpoint = [NSString stringWithFormat:@"%@identities/complete?key=%@",API_ROOT,key];
  
  [[RKObjectManager sharedManager].HTTPClient setDefaultHeader:@"token" value:[EFAPIServer sharedInstance].user_token];
  [[RKObjectManager sharedManager].HTTPClient getPath:endpoint parameters:nil success:success failure:failure];
   
}

+(void) updateName:(NSString*)name
           success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
           failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure {
    
    AppDelegate *app=(AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSString *endpoint = [NSString stringWithFormat:@"%@users/update?token=%@",API_ROOT,[EFAPIServer sharedInstance].user_token];
    
    RKObjectManager *objectManager = [RKObjectManager sharedManager];
    [RKObjectManager sharedManager].HTTPClient.parameterEncoding = AFFormURLParameterEncoding;
    [objectManager.HTTPClient setDefaultHeader:@"token" value:[EFAPIServer sharedInstance].user_token];
    
    [objectManager.HTTPClient postPath:endpoint parameters:@{@"name":name} success:success failure:failure];
}

// should move to APIIdentity.m
+(void) updateIdentity:(Identity*)identity
                  name:(NSString*)name
                andBio:(NSString*)bio
               success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
               failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure {
    
    AppDelegate *app=(AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSString *endpoint = [NSString stringWithFormat:@"%@identities/%i/update?token=%@", API_ROOT, [identity.identity_id intValue], [EFAPIServer sharedInstance].user_token];
    
    RKObjectManager *objectManager = [RKObjectManager sharedManager];
    [RKObjectManager sharedManager].HTTPClient.parameterEncoding = AFFormURLParameterEncoding;
    [objectManager.HTTPClient setDefaultHeader:@"token" value:[EFAPIServer sharedInstance].user_token];
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:2];
    if (name) {
        [dict setObject:name forKey:@"name"];
    }
    if (bio) {
        [dict setObject:bio forKey:@"bio"];
    }
    [objectManager.HTTPClient postPath:endpoint parameters:dict success:success failure:failure];
}


@end
