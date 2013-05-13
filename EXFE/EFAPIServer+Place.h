//
//  EFAPIServer+Place.h
//  EXFE
//
//  Created by 0day on 13-5-13.
//
//

#import "EFAPIServer.h"

#import <CoreLocation/CoreLocation.h>

@interface EFAPIServer (Place)

- (void)getTopPlaceNearbyWithLocation:(CLLocationCoordinate2D)location
                              success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                              failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

- (void)getPlacesNearbyWithLocation:(CLLocationCoordinate2D)location
                            success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                            failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

- (void)getPlacesByTitle:(NSString *)title
                location:(CLLocationCoordinate2D)location
                 success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                 failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

@end
