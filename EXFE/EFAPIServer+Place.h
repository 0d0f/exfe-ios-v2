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

// https://developers.google.com/maps/documentation/geocoding/
- (void)reverseGeocodingWithLocation:(CLLocationCoordinate2D)location
                             success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                             failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

// https://developers.google.com/places/documentation/search#PlaceSearchRequests
- (void)getPlacesNearbyWithLocation:(CLLocationCoordinate2D)location
                            success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                            failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

// https://developers.google.com/places/documentation/search#TextSearchRequests
- (void)getPlacesByTitle:(NSString *)title
                location:(CLLocationCoordinate2D)location
                 success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                 failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

// https://developers.google.com/maps/documentation/timezone/
@end
