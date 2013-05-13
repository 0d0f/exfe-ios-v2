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

+(void) LoadSuggest:(NSString*)key success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
            failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure DEPRECATED_ATTRIBUTE_MESSAGE("Use EFAPIServer (Profile)");

@end
