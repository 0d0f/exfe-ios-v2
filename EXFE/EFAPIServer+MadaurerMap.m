//
//  EFAPIServer+MadaurerMap.m
//  EXFE
//
//  Created by 0day on 13-7-17.
//
//

#import "EFAPIServer+MadaurerMap.h"

#import "Cross.h"

@implementation EFAPIServer (MadaurerMap)

- (void)updateLocation:(EFLocation *)location
           withCrossId:(NSInteger)crossId
               isEarth:(BOOL)isEarth
               success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
               failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure {
    NSParameterAssert(location);
    NSDictionary *param = [location dictionaryValue];
    
    NSString *endpoint = [NSString stringWithFormat:@"/v3/crosses/%d/routex/breadcrumbs?coordinate=%@&token=%@", crossId, isEarth ? @"earth" : @"mars", self.model.userToken];
    
    RKObjectManager *manager = [RKObjectManager sharedManager];
    manager.HTTPClient.parameterEncoding = AFJSONParameterEncoding;
    
    [manager.HTTPClient postPath:endpoint
                      parameters:param
                         success:success
                         failure:failure];
}

/**
 * endpoint: /routex/user/crosses
 */
- (void)postRouteXAccessInfo:(NSArray *)accessInfos
                     success:(void (^)(void))successHandler
                     failure:(void (^)(NSError *error))failureHandler {
    NSParameterAssert(accessInfos);
    NSParameterAssert(accessInfos.count);
    
    NSMutableArray *param = [[NSMutableArray alloc] init];
    for (id accessInfo in accessInfos) {
        [param addObject:[accessInfo dictionaryValue]];
    }
    
    NSString *endpoint = [NSString stringWithFormat:@"/v3/routex/user/crosses?token=%@", self.model.userToken];
    
    RKObjectManager *manager = [RKObjectManager sharedManager];
    manager.HTTPClient.parameterEncoding = AFJSONParameterEncoding;
    
    [manager.HTTPClient postPath:endpoint
                      parameters:(id)param
                         success:^(AFHTTPRequestOperation *operation, id responseObject){
                             if (200 == operation.response.statusCode) {
                                 if (successHandler) {
                                     successHandler();
                                 }
                             }
                         }
                         failure:^(AFHTTPRequestOperation *operation, NSError *error){
                             if (failureHandler) {
                                 failureHandler(error);
                             }
                         }];
}

/**
 * Breadcrumbs
 */

// endpoint: /routex/breadcrumbs?coordinate=(earth|mars)&token=xxxxxx
- (void)postRouteXBreadcrumbs:(NSArray *)breadcrumbs
            isEarthCoordinate:(BOOL)isEarthCoordinate
                      success:(void (^)(CGFloat earthToMarsLatitudeOffset, CGFloat earthToMarsLongitudeOffset))successHandler
                      failure:(void (^)(NSError *error))failureHandler {
    NSParameterAssert(breadcrumbs);
    NSParameterAssert(breadcrumbs.count);
    
    NSMutableArray *param = [[NSMutableArray alloc] init];
    for (id location in breadcrumbs) {
        [param addObject:[location dictionaryValue]];
    }
    
    NSString *endpoint = [NSString stringWithFormat:@"/v3/routex/breadcrumbs?coordinate=%@&token=%@", isEarthCoordinate ? @"earth" : @"mars", self.model.userToken];
    
    RKObjectManager *manager = [RKObjectManager sharedManager];
    manager.HTTPClient.parameterEncoding = AFJSONParameterEncoding;
    
    [manager.HTTPClient postPath:endpoint
                      parameters:(id)param
                         success:^(AFHTTPRequestOperation *operation, id responseObject){
                            if (200 == operation.response.statusCode) {
                                NSAssert([responseObject isKindOfClass:[NSDictionary class]], @"responseObject SHOULD be a dictionary.");
                                
                                NSDictionary *result = (NSDictionary *)responseObject;
                                CGFloat earthToMarsLatitudeOffset = [[result valueForKey:@"earth_to_mars_latitude"] doubleValue];
                                CGFloat earthToMarsLongitudeOffset = [[result valueForKey:@"earth_to_mars_longitude"] doubleValue];
                                
                                if (successHandler) {
                                    successHandler(earthToMarsLatitudeOffset, earthToMarsLongitudeOffset);
                                }
                            }
                        }
                         failure:^(AFHTTPRequestOperation *operation, NSError *error){
                             if (failureHandler) {
                                 failureHandler(error);
                             }
                         }];
}

// endpoint: /routex/crosses/:cross_id/breadcrumbs?coordinate=(earth|mars)&token=xxxxxx
- (void)getRouteXBreadcrumbsInCross:(Cross *)cross
                  isEarthCoordinate:(BOOL)isEarthCoordinate
                            success:(void (^)(NSArray *breadcrumbs))successHandler
                            failure:(void (^)(NSError *error))failureHandler {
    NSString *endpoint = [NSString stringWithFormat:@"/v3/routex/crosses/%d/breadcrumbs?coordinate=%@&token=%@", [cross.cross_id integerValue], isEarthCoordinate ? @"earth" : @"mars", self.model.userToken];
    
    RKObjectManager *manager = [RKObjectManager sharedManager];
    manager.HTTPClient.parameterEncoding = AFJSONParameterEncoding;
    
    [manager.HTTPClient getPath:endpoint
                     parameters:nil
                        success:^(AFHTTPRequestOperation *operation, id responseObject){
                             if (200 == operation.response.statusCode) {
                                 NSAssert([responseObject isKindOfClass:[NSArray class]], @"responseObject SHOULD be a array.");
                                 
                                 NSArray *result = (NSArray *)responseObject;
                                 
                                 NSMutableArray *routeObjects = [[NSMutableArray alloc] initWithCapacity:result.count];
                                 for (NSDictionary *routeDictionary in result) {
                                     EFRoutePath *routePath = [[EFRoutePath alloc] initWithDictionary:routeDictionary];
                                     [routeObjects addObject:routePath];
                                 }
                                 
                                 if (successHandler) {
                                     successHandler(routeObjects);
                                 }
                             }
                         }
                        failure:^(AFHTTPRequestOperation *operation, NSError *error){
                             if (failureHandler) {
                                 failureHandler(error);
                             }
                         }];
}

// endpoint: /routex/crosses/:cross_id/breadcrumbs/users/:user_id?coordinate=(earth|mars)&token=xxxxxx&start=100
- (void)getRouteXBreadcrumbsInCross:(Cross *)cross
                      forIdentityId:(NSString *)identityIdString
                         startIndex:(NSUInteger)startIndex
                  isEarthCoordinate:(BOOL)isEarthCoordinate
                            success:(void (^)(EFRoutePath *))successHandler
                            failure:(void (^)(NSError *error))failureHandler {
    NSString *endpoint = [NSString stringWithFormat:@"/v3/routex/crosses/%d/breadcrumbs/users/%@?coordinate=%@&token=%@", [cross.cross_id integerValue], identityIdString, isEarthCoordinate ? @"earth" : @"mars", self.model.userToken];
    
    RKObjectManager *manager = [RKObjectManager sharedManager];
    manager.HTTPClient.parameterEncoding = AFJSONParameterEncoding;
    
    [manager.HTTPClient getPath:endpoint
                     parameters:nil
                        success:^(AFHTTPRequestOperation *operation, id responseObject){
                             if (200 == operation.response.statusCode) {
                                 NSAssert([responseObject isKindOfClass:[NSDictionary class]], @"responseObject SHOULD be a dictionary.");
                                 
                                 NSDictionary *result = (NSDictionary *)responseObject;
                                 
                                 EFRoutePath *routePath = [[EFRoutePath alloc] initWithDictionary:result];
                                 
                                 if (successHandler) {
                                     successHandler(routePath);
                                 }
                             }
                         }
                        failure:^(AFHTTPRequestOperation *operation, NSError *error){
                             if (failureHandler) {
                                 failureHandler(error);
                             }
                         }];
}

/**
 * Geomarks
 */

// endpoint: /routex/crosses/:cross_id/geomarks?coordinate=(earth|mars)&token=xxxxxxxx
- (void)postRouteXCreateGeomark:(id)routeLocationOrRoutePath
                        inCross:(Cross *)cross
              isEarthCoordinate:(BOOL)isEarthCoordinate
                        success:(void (^)(NSString *geomarkId))successHandler
                        failure:(void (^)(NSError *error))failureHandler {
    NSString *endpoint = [NSString stringWithFormat:@"/v3/routex/crosses/%d/geomarks?coordinate=%@&token=%@", [cross.cross_id integerValue], isEarthCoordinate ? @"earth" : @"mars", self.model.userToken];
    
    RKObjectManager *manager = [RKObjectManager sharedManager];
    manager.HTTPClient.parameterEncoding = AFJSONParameterEncoding;
    
    NSDictionary *param = [routeLocationOrRoutePath dictionaryValue];
    
    [manager.HTTPClient postPath:endpoint
                      parameters:param
                         success:^(AFHTTPRequestOperation *operation, id responseObject){
                             if (200 == operation.response.statusCode) {
                                 NSString *geomarkId = (NSString *)responseObject;
                                 
                                 if (successHandler) {
                                     successHandler(geomarkId);
                                 }
                             }
                         }
                         failure:^(AFHTTPRequestOperation *operation, NSError *error){
                             if (failureHandler) {
                                 failureHandler(error);
                             }
                         }];
}

// endpoint: /routex/crosses/:cross_id/geomarks/:geomark_id?coordinate=(earth|mars)&token=xxxxxxxx
- (void)putRouteXUpdateGeomark:(id)routeLocationOrRoutePath
                       inCross:(Cross *)cross
             isEarthCoordinate:(BOOL)isEarthCoordinate
                       success:(void (^)(void))successHandler
                       failure:(void (^)(NSError *error))failureHandler {
    NSString *endpoint = [NSString stringWithFormat:@"/v3/routex/crosses/%d/geomarks?coordinate=%@&token=%@", [cross.cross_id integerValue], isEarthCoordinate ? @"earth" : @"mars", self.model.userToken];
    
    RKObjectManager *manager = [RKObjectManager sharedManager];
    manager.HTTPClient.parameterEncoding = AFJSONParameterEncoding;
    
    NSDictionary *param = [routeLocationOrRoutePath dictionaryValue];
    
    [manager.HTTPClient putPath:endpoint
                     parameters:param
                        success:^(AFHTTPRequestOperation *operation, id responseObject){
                             if (200 == operation.response.statusCode) {
                                 if (successHandler) {
                                     successHandler();
                                 }
                             }
                         }
                        failure:^(AFHTTPRequestOperation *operation, NSError *error){
                             if (failureHandler) {
                                 failureHandler(error);
                             }
                         }];
}

// endpoint: /routex/crosses/:cross_id/geomarks/:geomark_id?token=xxxxxxxx
- (void)deleteRouteXDeleteGeomark:(id)routeLocationOrRoutePath
                          inCross:(Cross *)cross
                          success:(void (^)(void))successHandler
                          failure:(void (^)(NSError *error))failureHandler {
    NSDictionary *routeDictionary = [routeLocationOrRoutePath dictionaryValue];
    NSString *geomarkId = [routeDictionary valueForKey:@"id"];
    NSString *endpoint = [NSString stringWithFormat:@"/v3/routex/crosses/%d/geomarks/%@?token=%@", [cross.cross_id integerValue], geomarkId, self.model.userToken];
    
    RKObjectManager *manager = [RKObjectManager sharedManager];
    manager.HTTPClient.parameterEncoding = AFJSONParameterEncoding;
    
    [manager.HTTPClient deletePath:endpoint
                        parameters:nil
                           success:^(AFHTTPRequestOperation *operation, id responseObject){
                               if (200 == operation.response.statusCode) {
                                   if (successHandler) {
                                       successHandler();
                                   }
                               }
                           }
                           failure:^(AFHTTPRequestOperation *operation, NSError *error){
                               if (failureHandler) {
                                   failureHandler(error);
                               }
                           }];
}

// endpoint: /routex/crosses/:cross_id/geomarks?coordinate=(earth|mars)&token=xxxxxxxxx
- (void)getRouteXGetGeomarksInCross:(Cross *)cross
                  isEarthCoordinate:(BOOL)isEarthCoordinate
                            success:(void (^)(NSArray *locations, NSArray *paths))successHandler
                            failure:(void (^)(NSError *error))failureHandler {
    NSString *endpoint = [NSString stringWithFormat:@"/v3/routex/crosses/%d/geomarks?coordinate=%@&token=%@", [cross.cross_id integerValue], isEarthCoordinate ? @"earth" : @"mars", self.model.userToken];
    
    RKObjectManager *manager = [RKObjectManager sharedManager];
    manager.HTTPClient.parameterEncoding = AFJSONParameterEncoding;
    
    [manager.HTTPClient getPath:endpoint
                     parameters:nil
                        success:^(AFHTTPRequestOperation *operation, id responseObject){
                            if (200 == operation.response.statusCode) {
                                NSAssert([responseObject isKindOfClass:[NSArray class]], @"responseObject SHOULD be a array.");
                                
                                NSArray *result = (NSArray *)responseObject;
                                
                                NSMutableArray *locations = [[NSMutableArray alloc] init];
                                NSMutableArray *paths = [[NSMutableArray alloc] init];
                                
                                for (NSDictionary *geomarkDictionary in result) {
                                    NSString *type = [geomarkDictionary valueForKey:@"type"];
                                    if ([type isEqualToString:@"location"]) {
                                        EFRouteLocation *location = [[EFRouteLocation alloc] initWithDictionary:geomarkDictionary];
                                        [locations addObject:location];
                                    } else if ([type isEqualToString:@"route"]) {
                                        EFRoutePath *path = [[EFRoutePath alloc] initWithDictionary:geomarkDictionary];
                                        [paths addObject:path];
                                    }
                                }
                                
                                if (successHandler) {
                                    successHandler(locations, paths);
                                }
                            }
                        }
                        failure:^(AFHTTPRequestOperation *operation, NSError *error){
                            if (failureHandler) {
                                failureHandler(error);
                            }
                        }];
}

/**
 * Request
 */
- (void)postRouteXRequestIdentityId:(NSString *)identityId
                            inCross:(Cross *)cross
                            success:(void (^)(void))successHandler
                            failure:(void (^)(NSError *error))failureHandler {
    NSString *endpoint = [NSString stringWithFormat:@"/v3/routex/crosses/%d/request?token=%@&id=%@", [cross.cross_id integerValue], self.model.userToken, identityId];
    
    RKObjectManager *manager = [RKObjectManager sharedManager];
    manager.HTTPClient.parameterEncoding = AFJSONParameterEncoding;
    
    [manager.HTTPClient postPath:endpoint
                     parameters:nil
                        success:^(AFHTTPRequestOperation *operation, id responseObject){
                            if (200 == operation.response.statusCode) {
                                if (successHandler) {
                                    successHandler();
                                }
                            }
                        }
                        failure:^(AFHTTPRequestOperation *operation, NSError *error){
                            if (failureHandler) {
                                failureHandler(error);
                            }
                        }];

}


@end
