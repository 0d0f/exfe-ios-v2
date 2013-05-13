//
//  APIPlace.h
//  EXFE
//
//  Created by huoju on 6/28/12.
//
//

#import <Foundation/Foundation.h>
#import <RestKit/RestKit.h>
#import "AppDelegate.h"
#import "PlaceViewController.h"

@interface APIPlace : NSObject{
//  NSOperationQueue *queue;
//    RKRequestQueue *queue;
}
+ (id) sharedManager;
-(void) GetTopPlaceFromGoogleNearby:(double)lat lng:(double)lng success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure DEPRECATED_ATTRIBUTE_MESSAGE("Use EFAPIServer (Place)");

-(void) GetPlacesFromGoogleNearby:(double)lat lng:(double)lng success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure DEPRECATED_ATTRIBUTE_MESSAGE("Use EFAPIServer (Place)");

-(void) GetPlacesFromGoogleByTitle:(NSString*) title lat:(double)lat lng:(double)lng success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure DEPRECATED_ATTRIBUTE_MESSAGE("Use EFAPIServer (Place)");

@end
