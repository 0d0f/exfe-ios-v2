//
//  APIPlace.m
//  EXFE
//
//  Created by huoju on 6/28/12.
//
//

#import "APIPlace.h"

@implementation APIPlace
static id sharedManager = nil;
//static NSOperationQueue *queue;
//
+ (id)sharedManager {
    @synchronized(self)
    {
        if (sharedManager == nil) {
            sharedManager = [[self alloc] init];
//            queue = [NSOperationQueue new];
        }
    }
    return sharedManager;
}

-(void) GetPlacesFromGoogleByTitle:(NSString*) title lat:(double)lat lng:(double)lng success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure{
  NSString * language = [[NSLocale preferredLanguages] objectAtIndex:0];
  NSString *endpoint = [NSString stringWithFormat:@"%@/maps/api/place/textsearch/json?query=%@&location=%g,%g&radius=1000&language=%@&sensor=true&key=%@",@"https://maps.googleapis.com",title,lat,lng,language,GOOGLE_API_KEY];
  if(lng==0 && lat==0)
    endpoint =[NSString stringWithFormat:@"/maps/api/place/textsearch/json?query=%@&language=%@&sensor=true&key=%@",title,language,GOOGLE_API_KEY];
  
  RKObjectManager *manager=[RKObjectManager sharedManager];
  [manager.HTTPClient.operationQueue cancelAllOperations];
  manager.HTTPClient.parameterEncoding=AFFormURLParameterEncoding;
  [manager.HTTPClient getPath:endpoint parameters:nil success:success failure:failure];
}

-(void) GetTopPlaceFromGoogleNearby:(double)lat lng:(double)lng success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure{
  NSString *language = [[NSLocale preferredLanguages] objectAtIndex:0];
  NSString *endpoint = [NSString stringWithFormat:@"%@/maps/api/place/search/json?location=%g,%g&radius=100&language=%@&sensor=true&key=%@",@"https://maps.googleapis.com",lat,lng,language,GOOGLE_API_KEY];

  RKObjectManager *manager=[RKObjectManager sharedManager];
  [manager.HTTPClient.operationQueue cancelAllOperations];
  manager.HTTPClient.parameterEncoding=AFFormURLParameterEncoding;
  [manager.HTTPClient getPath:endpoint parameters:nil success:success failure:failure];
}

-(void) GetPlacesFromGoogleNearby:(double)lat lng:(double)lng success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure{
  NSString *language = [[NSLocale preferredLanguages] objectAtIndex:0];
  NSString *endpoint = [NSString stringWithFormat:@"%@/maps/api/place/search/json?location=%g,%g&radius=1000&language=%@&sensor=true&key=%@",@"https://maps.googleapis.com",lat,lng,language,GOOGLE_API_KEY];
  RKObjectManager *manager=[RKObjectManager sharedManager];
  [manager.HTTPClient.operationQueue cancelAllOperations];
  manager.HTTPClient.parameterEncoding=AFFormURLParameterEncoding;
  [manager.HTTPClient getPath:endpoint parameters:nil success:success failure:failure];
}

@end
