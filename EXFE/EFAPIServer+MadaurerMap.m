//
//  EFAPIServer+MadaurerMap.m
//  EXFE
//
//  Created by 0day on 13-7-17.
//
//

#import "EFAPIServer+MadaurerMap.h"

@implementation EFAPIServer (MadaurerMap)

- (void)updateLocation:(EFLocation *)location
           withCrossId:(NSInteger)crossId
               success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
               failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure {
    NSParameterAssert(location);
    NSDictionary *param = [location dictionaryValue];
    
    NSString *endpoint = [NSString stringWithFormat:@"/v3/crosses/%d/routex/breadcrumbs?token=%@", crossId, self.model.userToken];
    
    RKObjectManager *manager = [RKObjectManager sharedManager];
    manager.HTTPClient.parameterEncoding = AFJSONParameterEncoding;
    
    [manager.HTTPClient postPath:endpoint
                      parameters:param
                         success:success
                         failure:failure];
}

- (void)getLocationsWithCrossId:(NSInteger)crossId
                        success:(void (^)(NSDictionary *locations))successHandler
                        failure:(void (^)(NSError *error))failureHandler {
    NSString *endpoint = [NSString stringWithFormat:@"/v3/crosses/%d/routex/breadcrumbs?token=%@", crossId, self.model.userToken];
    
    RKObjectManager *manager = [RKObjectManager sharedManager];
    manager.HTTPClient.parameterEncoding = AFJSONParameterEncoding;
    
    [manager.HTTPClient getPath:endpoint
                     parameters:nil
                        success:^(AFHTTPRequestOperation *operation, id responseObject){
                            if (200 == operation.response.statusCode) {
                                NSMutableDictionary *result = [[NSMutableDictionary alloc] initWithCapacity:[responseObject count]];
                                [responseObject enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop){
                                    EFLocation *location = [[EFLocation alloc] initWithDictionary:obj];
                                    [result setValue:location forKey:key];
                                }];
                                if (successHandler) {
                                    successHandler(result);
                                }
                            }
                        }
                        failure:^(AFHTTPRequestOperation *operation, NSError *error){
                            if (failureHandler) {
                                failureHandler(error);
                            }
                        }];
}

- (void)updateRouteWithLocations:(NSArray *)locations
                          routes:(NSArray *)routes
                         success:(void (^)(RKObjectRequestOperation *operation, RKMappingResult *mappingResult))success
                         failure:(void (^)(RKObjectRequestOperation *operation, NSError *error))failure {

}

- (void)getRouteWithCrossId:(NSInteger)crossId
                    success:(void (^)(NSArray *routeLocations, NSArray *routePaths))successHandler
                    failure:(void (^)(NSError *error))failureHandler {
    
}

@end
