//
//  EFAPIServer+Profile.h
//  EXFE
//
//  Created by 0day on 13-5-13.
//
//

#import "EFAPIServer.h"

@interface EFAPIServer (Profile)

- (void)loadSuggest:(NSString*)key
            success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
            failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

@end
