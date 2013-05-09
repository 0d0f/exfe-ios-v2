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

+ (void) LoadSuggest:(NSString*)key success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
             failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure {
    
    NSString *endpoint = [NSString stringWithFormat:@"%@identities/complete?key=%@?token=%@",API_ROOT,key, [EFAPIServer sharedInstance].user_token];

  [[RKObjectManager sharedManager].HTTPClient getPath:endpoint parameters:nil success:success failure:failure];
   
}


@end
