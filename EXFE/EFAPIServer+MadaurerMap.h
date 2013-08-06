//
//  EFAPIServer+MadaurerMap.h
//  EXFE
//
//  Created by 0day on 13-7-17.
//
//

#import "EFAPIServer.h"

#import "EFMapKit.h"

@class Cross;
@interface EFAPIServer (MadaurerMap)

/**
 * endpoint: /routex/user/crosses
 */
- (void)postRouteXAccessInfo:(NSArray *)accessInfos
                     success:(void (^)(void))successHandler
                     failure:(void (^)(NSError *error))failureHandler;

/**
 * Breadcrumbs
 */

// endpoint: /routex/breadcrumbs?coordinate=(earth|mars)&token=xxxxxx
- (void)postRouteXBreadcrumbs:(NSArray *)breadcrumbs
            isEarthCoordinate:(BOOL)isEarthCoordinate
                      success:(void (^)(CGFloat earthToMarsLatitudeOffset, CGFloat earthToMarsLongitudeOffset))successHandler
                      failure:(void (^)(NSError *error))failureHandler;

// endpoint: /routex/crosses/:cross_id/breadcrumbs?coordinate=(earth|mars)&token=xxxxxx
- (void)getRouteXBreadcrumbsInCross:(Cross *)cross
                  isEarthCoordinate:(BOOL)isEarthCoordinate
                            success:(void (^)(NSArray *breadcrumbs))successHandler
                            failure:(void (^)(NSError *error))failureHandler;

// endpoint: /routex/crosses/:cross_id/breadcrumbs/users/:user_id?coordinate=(earth|mars)&token=xxxxxx&start=100
- (void)getRouteXBreadcrumbsInCross:(Cross *)cross
                      forIdentityId:(NSString *)identityIdString
                         startIndex:(NSUInteger)startIndex
                  isEarthCoordinate:(BOOL)isEarthCoordinate
                            success:(void (^)(EFRoutePath *))successHandler
                            failure:(void (^)(NSError *error))failureHandler;

/**
 * Geomarks
 */

// endpoint: /routex/crosses/:cross_id/geomarks?coordinate=(earth|mars)&token=xxxxxxxx
- (void)postRouteXCreateGeomark:(id)routeLocationOrRoutePath
                        inCross:(Cross *)cross
              isEarthCoordinate:(BOOL)isEarthCoordinate
                        success:(void (^)(NSString *geomarkId))successHandler
                        failure:(void (^)(NSError *error))failureHandler;

// endpoint: /routex/crosses/:cross_id/geomarks/:geomark_id?coordinate=(earth|mars)&token=xxxxxxxx
- (void)putRouteXUpdateGeomark:(id)routeLocationOrRoutePath
                       inCross:(Cross *)cross
             isEarthCoordinate:(BOOL)isEarthCoordinate
                       success:(void (^)(void))successHandler
                       failure:(void (^)(NSError *error))failureHandler;

// endpoint: /routex/crosses/:cross_id/geomarks/:geomark_id?token=xxxxxxxx
- (void)deleteRouteXDeleteGeomark:(id)routeLocationOrRoutePath
                          inCross:(Cross *)cross
                          success:(void (^)(void))successHandler
                          failure:(void (^)(NSError *error))failureHandler;

// endpoint: /routex/crosses/:cross_id/geomarks?coordinate=(earth|mars)&token=xxxxxxxxx
- (void)getRouteXGetGeomarksInCross:(Cross *)cross
                  isEarthCoordinate:(BOOL)isEarthCoordinate
                            success:(void (^)(NSArray *locations, NSArray *paths))successHandler
                            failure:(void (^)(NSError *error))failureHandler;

/**
 * Request
 */
- (void)postRouteXRequestIdentityId:(NSString *)identityId
                            inCross:(Cross *)cross
                            success:(void (^)(void))successHandler
                            failure:(void (^)(NSError *error))failureHandler;

@end
