//
//  EFAPIServer+Place.m
//  EXFE
//
//  Created by 0day on 13-5-13.
//
//

#import "EFAPIServer+Place.h"

#import "AppDelegate.h"

@implementation EFAPIServer (Place)

- (void)getTopPlaceNearbyWithLocation:(CLLocationCoordinate2D)location
                              success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                              failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure {
    NSString *language = [[NSLocale preferredLanguages] objectAtIndex:0];
    NSString *endpoint = [NSString stringWithFormat:@"%@/maps/api/place/search/json?location=%g,%g&radius=100&language=%@&sensor=true&key=%@",@"https://maps.googleapis.com", location.latitude, location.longitude, language, GOOGLE_API_KEY];
    
    RKObjectManager *manager = [RKObjectManager sharedManager];
    [manager.HTTPClient.operationQueue cancelAllOperations];
    
    [manager.HTTPClient getPath:endpoint
                     parameters:nil
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
    NSString *endpoint = [NSString stringWithFormat:@"%@/maps/api/place/search/json?location=%g,%g&radius=1000&language=%@&sensor=true&key=%@",@"https://maps.googleapis.com", location.latitude, location.longitude, language, GOOGLE_API_KEY];
    
    RKObjectManager *manager = [RKObjectManager sharedManager];
    [manager.HTTPClient.operationQueue cancelAllOperations];
    
    [manager.HTTPClient getPath:endpoint
                     parameters:nil
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
    NSString *endpoint = nil;
    
    if (location.longitude == 0 && location.latitude == 0) {
        endpoint = [NSString stringWithFormat:@"%@//maps/api/place/textsearch/json?query=%@&language=%@&sensor=true&key=%@", @"https://maps.googleapis.com", title, language, GOOGLE_API_KEY];
    } else {
        endpoint = [NSString stringWithFormat:@"%@/maps/api/place/textsearch/json?query=%@&location=%g,%g&radius=1000&language=%@&sensor=true&key=%@", @"https://maps.googleapis.com", title, location.latitude, location.longitude, language, GOOGLE_API_KEY];
    }
    
    RKObjectManager *manager = [RKObjectManager sharedManager];
    [manager.HTTPClient.operationQueue cancelAllOperations];
    
    [manager.HTTPClient getPath:endpoint
                     parameters:nil
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
