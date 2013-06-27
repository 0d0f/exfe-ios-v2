//
//  EXFEModel+Place.h
//  EXFE
//
//  Created by 0day on 13-6-27.
//
//

#import "EXFEModel.h"

#import <CoreLocation/CoreLocation.h>

@interface EXFEModel (Place)

- (void)reverseGeocodingWithLocation:(CLLocationCoordinate2D)location;

// This has not been replaced, because the complete callback do diffrent things now.
- (void)getPlacesNearbyWithLocation:(CLLocationCoordinate2D)location;

- (void)getPlacesByTitle:(NSString *)title location:(CLLocationCoordinate2D)location;

@end
