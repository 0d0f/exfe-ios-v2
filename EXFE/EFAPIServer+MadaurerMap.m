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

/**
 * endpoint: /routex/users/crosses
 */
- (void)postRouteXAccessInfo:(EFAccessInfo *)accessInfo
                     inCross:(Cross *)cross
                     success:(void (^)(void))successHandler
                     failure:(void (^)(NSError *error))failureHandler {
    NSParameterAssert(accessInfo);
    NSParameterAssert(cross);
    
    NSDictionary *param = [accessInfo dictionaryValue];
    
    NSString *endpoint = [NSString stringWithFormat:@"/v3/routex/users/crosses/%d?token=%@", [cross.cross_id integerValue], self.model.userToken];
    
    RKObjectManager *manager = [RKObjectManager sharedManager];
    manager.HTTPClient.parameterEncoding = AFJSONParameterEncoding;
    
    [manager.HTTPClient postPath:endpoint
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
                                
                                if (responseObject) {
                                    NSDictionary *result = (NSDictionary *)responseObject;
                                    CGFloat earthToMarsLatitudeOffset = [[result valueForKey:@"earth_to_mars_latitude"] doubleValue];
                                    CGFloat earthToMarsLongitudeOffset = [[result valueForKey:@"earth_to_mars_longitude"] doubleValue];
                                    
                                    if (successHandler) {
                                        successHandler(earthToMarsLatitudeOffset, earthToMarsLongitudeOffset);
                                    }
                                }
                            }
                        }
                         failure:^(AFHTTPRequestOperation *operation, NSError *error){
                             if (failureHandler) {
                                 failureHandler(error);
                             }
                         }];
}

// endpoint: /routex/breadcrumbs/crosses/:cross_id?coordinate=(earth|mars)&token=xxxxxx
- (void)getRouteXBreadcrumbsInCross:(Cross *)cross
                  isEarthCoordinate:(BOOL)isEarthCoordinate
                            success:(void (^)(NSArray *breadcrumbs))successHandler
                            failure:(void (^)(NSError *error))failureHandler {
    NSString *endpoint = [NSString stringWithFormat:@"/v3/routex/breadcrumbs/crosses/%d?coordinate=%@&token=%@", [cross.cross_id integerValue], isEarthCoordinate ? @"earth" : @"mars", self.model.userToken];
    
    RKObjectManager *manager = [RKObjectManager sharedManager];
    manager.HTTPClient.parameterEncoding = AFJSONParameterEncoding;
    
    [manager.HTTPClient getPath:endpoint
                     parameters:nil
                        success:^(AFHTTPRequestOperation *operation, id responseObject){
                             if (200 == operation.response.statusCode) {
                                 NSAssert([responseObject isKindOfClass:[NSArray class]], @"responseObject SHOULD be a array.");
                                 
                                 if (responseObject) {
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
    NSString *endpoint = [NSString stringWithFormat:@"/v3/routex/breadcrumbs/crosses/%d/users/%@?coordinate=%@&token=%@", [cross.cross_id integerValue], identityIdString, isEarthCoordinate ? @"earth" : @"mars", self.model.userToken];
    
    RKObjectManager *manager = [RKObjectManager sharedManager];
    manager.HTTPClient.parameterEncoding = AFJSONParameterEncoding;
    
    [manager.HTTPClient getPath:endpoint
                     parameters:nil
                        success:^(AFHTTPRequestOperation *operation, id responseObject){
                             if (200 == operation.response.statusCode) {
                                 NSAssert([responseObject isKindOfClass:[NSDictionary class]], @"responseObject SHOULD be a dictionary.");
                                 
                                 if (responseObject) {
                                     NSDictionary *result = (NSDictionary *)responseObject;
                                     
                                     EFRoutePath *routePath = [[EFRoutePath alloc] initWithDictionary:result];
                                     
                                     if (successHandler) {
                                         successHandler(routePath);
                                     }
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
- (void)putRouteXUpdateGeomark:(id)routeLocationOrRoutePath
                       inCross:(Cross *)cross
                          type:(NSString *)type
             isEarthCoordinate:(BOOL)isEarthCoordinate
                       success:(void (^)(void))successHandler
                       failure:(void (^)(NSError *error))failureHandler {
    NSDictionary *param = [routeLocationOrRoutePath dictionaryValue];
    NSString *geomarkId = [param valueForKey:@"id"];
    
    NSString *endpoint = [NSString stringWithFormat:@"/v3/routex/geomarks/crosses/%d/%@/%@?coordinate=%@&token=%@", [cross.cross_id integerValue], type, geomarkId, isEarthCoordinate ? @"earth" : @"mars", self.model.userToken];
    
    RKObjectManager *manager = [RKObjectManager sharedManager];
    manager.HTTPClient.parameterEncoding = AFJSONParameterEncoding;
    
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
                             type:(NSString *)type
                          success:(void (^)(void))successHandler
                          failure:(void (^)(NSError *error))failureHandler {
    NSDictionary *routeDictionary = [routeLocationOrRoutePath dictionaryValue];
    NSString *geomarkId = [routeDictionary valueForKey:@"id"];
    
    NSString *endpoint = [NSString stringWithFormat:@"/v3/routex/geomarks/crosses/%d/%@/%@?token=%@", [cross.cross_id integerValue], type, geomarkId, self.model.userToken];
    
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
    NSString *endpoint = [NSString stringWithFormat:@"/v3/routex/geomarks/crosses/%d?coordinate=%@&token=%@", [cross.cross_id integerValue], isEarthCoordinate ? @"earth" : @"mars", self.model.userToken];
    
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
 * Get RouteX URL
 */
- (void)getRouteXUrlInCross:(Cross *)cross
                    success:(void (^)(NSString *url))successHandler
                    failure:(void (^)(NSError *error))failureHandler {
    NSString *endpoint = [NSString stringWithFormat:@"/v2/crosses/%d/getroutexurl", [cross.cross_id integerValue]];
    NSDictionary *param = @{@"token": self.model.userToken};
    
    RKObjectManager *manager = [RKObjectManager sharedManager];
    manager.HTTPClient.parameterEncoding = AFJSONParameterEncoding;
    
    [manager.HTTPClient getPath:endpoint
                     parameters:param
                        success:^(AFHTTPRequestOperation *operation, id responseObject){
                            if (200 == operation.response.statusCode) {
                                NSDictionary *metaInfo = [responseObject valueForKey:@"meta"];
                                
                                if ([[metaInfo valueForKey:@"code"] integerValue] == 200) {
                                    NSDictionary *response = [responseObject valueForKey:@"response"];
                                    NSString *url = [response valueForKey:@"url"];
                                    
                                    if (successHandler) {
                                        successHandler(url);
                                    }
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
    NSString *endpoint = [NSString stringWithFormat:@"/v3/routex/notification/crosses/%d/%@?token=%@", [cross.cross_id integerValue], identityId, self.model.userToken];
    
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
