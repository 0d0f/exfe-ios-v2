//
//  APIExfeServer.h
//  EXFE
//
//  Created by Stony Wang on 13-3-28.
//
//

#import <Foundation/Foundation.h>

@interface APIExfeServer : NSObject

+ (void) checkAppVersionSuccess:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                       failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

@end
