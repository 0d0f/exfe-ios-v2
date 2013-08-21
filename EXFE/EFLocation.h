//
//  EFLocation.h
//  MarauderMap
//
//  Created by 0day on 13-7-11.
//  Copyright (c) 2013年 exfe. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

@class EFRouteLocation;
@interface EFLocation : NSObject

@property (assign)  CLLocationCoordinate2D  coordinate;
@property (assign)  CGFloat                 accuracy;       // might be 0.0f
@property (strong)  NSDate                  *timestamp;

- (id)initWithDictionary:(NSDictionary *)param;
- (MKMapPoint)mapPointValue;

- (NSDictionary *)dictionaryValue;
- (NSDictionary *)dictionaryValueWitoutAccuracy;

- (CLLocationDistance)distanceFromLocation:(EFLocation *)locatoin;
- (CLLocationDistance)distanceFromRouteLocation:(EFRouteLocation *)routeLocatoin;

@end
