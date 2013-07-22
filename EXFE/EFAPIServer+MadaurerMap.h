//
//  EFAPIServer+MadaurerMap.h
//  EXFE
//
//  Created by 0day on 13-7-17.
//
//

#import "EFAPIServer.h"

#import "EFMapKit.h"

@interface EFAPIServer (MadaurerMap)

- (void)updateLocation:(EFLocation *)location
           withCrossId:(NSInteger)crossId
               isEarth:(BOOL)isEarth
               success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
               failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

- (void)getLocationsWithCrossId:(NSInteger)crossId
                        isEarth:(BOOL)isEarth
                        success:(void (^)(NSDictionary *locations))successHandler
                        failure:(void (^)(NSError *error))failureHandler;

- (void)updateRouteWithCrossId:(NSInteger)crossId
                     locations:(NSArray *)locations
                        routes:(NSArray *)routes
                       isEarth:(BOOL)isEarth
                       success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                       failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

- (void)getRouteWithCrossId:(NSInteger)crossId
                    isEarth:(BOOL)isEarth
                    success:(void (^)(NSArray *routeLocations, NSArray *routePaths))successHandler
                    failure:(void (^)(NSError *error))failureHandler;

@end
