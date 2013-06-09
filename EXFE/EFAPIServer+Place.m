//
//  EFAPIServer+Place.m
//  EXFE
//
//  Created by 0day on 13-5-13.
//
//

#import "EFAPIServer+Place.h"
#import "Util.h"

@implementation EFAPIServer (Place)

- (void)reverseGeocodingWithLocation:(CLLocationCoordinate2D)location
                              success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                              failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure {
    NSString *language = [[NSLocale preferredLanguages] objectAtIndex:0];
    NSString *endpoint = @"https://maps.googleapis.com/maps/api/geocode/json";
    
    
    NSDictionary *params = @{@"latlng": [NSString stringWithFormat:@"%g,%g", location.latitude, location.longitude],
                             @"language": language,
                             @"sensor": @"true"};
    //@"key": GOOGLE_API_KEY
    
    RKObjectManager *manager = [RKObjectManager sharedManager];
    [manager.HTTPClient.operationQueue cancelAllOperations];
    
    [manager.HTTPClient getPath:endpoint
                     parameters:params
                        success:^(AFHTTPRequestOperation *operation, id responseObject){
                            [self performSelector:@selector(_handleSuccessWithRequestOperation:andResponseObject:)
                                       withObject:operation
                                       withObject:responseObject];
                            
                            if (success) {
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    success(operation, responseObject);
                                });
                            }
                        }
                        failure:^(AFHTTPRequestOperation *operation, NSError *error){
                            [self performSelector:@selector(_handleFailureWithRequestOperation:andError:)
                                       withObject:operation
                                       withObject:error];
                            
                            if (failure) {
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    failure(operation, error);
                                });
                            }
                        }];
}

- (void)getPlacesNearbyWithLocation:(CLLocationCoordinate2D)location
                            success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                            failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure {
    NSString *language = [[NSLocale preferredLanguages] objectAtIndex:0];
    NSString *endpoint = @"https://maps.googleapis.com/maps/api/place/search/json";
    
    NSDictionary *params = @{@"location": [NSString stringWithFormat:@"%g,%g", location.latitude, location.longitude],
                             @"radius": @"1000",
                             @"language": language,
                             @"sensor": @"true",
                             @"key": GOOGLE_API_KEY};
    
    
    RKObjectManager *manager = [RKObjectManager sharedManager];
    [manager.HTTPClient.operationQueue cancelAllOperations];
    
    [manager.HTTPClient getPath:endpoint
                     parameters:params
                        success:^(AFHTTPRequestOperation *operation, id responseObject){
                            [self performSelector:@selector(_handleSuccessWithRequestOperation:andResponseObject:)
                                       withObject:operation
                                       withObject:responseObject];
                            
                            if (success) {
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    success(operation, responseObject);
                                });
                            }
                        }
                        failure:^(AFHTTPRequestOperation *operation, NSError *error){
                            [self performSelector:@selector(_handleFailureWithRequestOperation:andError:)
                                       withObject:operation
                                       withObject:error];
                            
                            if (failure) {
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    failure(operation, error);
                                });
                            }
                        }];
}

- (void)getPlacesByTitle:(NSString *)title
                location:(CLLocationCoordinate2D)location
                 success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                 failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure {
    NSString *language = [[NSLocale preferredLanguages] objectAtIndex:0];
    NSString *endpoint = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/textsearch/json"];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:6];
    
    [params addEntriesFromDictionary:@{@"query": title, @"language": language, @"sensor": @"true", @"key": GOOGLE_API_KEY}];
    
    if (location.longitude == 0 && location.latitude == 0) {
        
    } else {
        [params addEntriesFromDictionary:@{
         @"location": [NSString stringWithFormat:@"%g,%g", location.latitude, location.longitude],
         @"radius": @"1000"}];
    }
    
    RKObjectManager *manager = [RKObjectManager sharedManager];
    [manager.HTTPClient.operationQueue cancelAllOperations];
    
    [manager.HTTPClient getPath:endpoint
                     parameters:params
                        success:^(AFHTTPRequestOperation *operation, id responseObject){
                            [self performSelector:@selector(_handleSuccessWithRequestOperation:andResponseObject:)
                                       withObject:operation
                                       withObject:responseObject];
                            
                            if (success) {
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    success(operation, responseObject);
                                });
                            }
                        }
                        failure:^(AFHTTPRequestOperation *operation, NSError *error){
                            [self performSelector:@selector(_handleFailureWithRequestOperation:andError:)
                                       withObject:operation
                                       withObject:error];
                            
                            if (failure) {
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    failure(operation, error);
                                });
                            }
                        }];
}

@end
