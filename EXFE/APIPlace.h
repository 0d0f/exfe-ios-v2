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
//RESTKIT0.2
//    RKRequestQueue *queue;
}
+ (id) sharedManager;
+(void) GetPlaces:(NSString*)keyword lat:(double)lat lng:(double)lng delegate:(id)delegate;
-(void) GetPlacesFromGoogleNearby:(double)lat lng:(double)lng delegate:(id)delegate;
-(void) GetTopPlaceFromGoogleNearby:(double)lat lng:(double)lng delegate:(id)delegate;
-(void) GetPlacesFromGoogleByTitle:(NSString*) title lat:(double)lat lng:(double)lng delegate:(id)delegate;
@end
