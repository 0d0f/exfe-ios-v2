//
//  APIExfeServer.m
//  EXFE
//
//  Created by Stony Wang on 13-3-28.
//
//

#import <RestKit/RestKit.h>
#import "APIExfeServer.h"
#import "AppDelegate.h"

@implementation APIExfeServer

+ (void) checkAppVersionSuccess:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                       failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure{
    
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    RKObjectManager *manager = [RKObjectManager sharedManager];
    NSString *endpoint = [NSString stringWithFormat:@"%@/versions/",API_SERVER];
    
//    manager.HTTPClient.parameterEncoding = AFJSONParameterEncoding;
//    manager.requestSerializationMIMEType = RKMIMETypeJSON;
    // Accept HTTP Header; see http://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html#sec14.1
	[manager.HTTPClient setDefaultHeader:@"Accept" value:@"application/json"];
    [manager.HTTPClient setDefaultHeader:@"token" value:app.accesstoken];
    [manager.HTTPClient getPath:endpoint parameters:nil success:success failure:failure];
}

@end
