//
//  EFLocation.h
//  MarauderMap
//
//  Created by 0day on 13-7-11.
//  Copyright (c) 2013年 exfe. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

@interface EFLocation : NSObject

@property (assign)  CLLocationCoordinate2D  coordinate2D;
@property (assign)  CGFloat                 accuracy;       // might be 0.0f
@property (strong)  NSDate                  *timestamp;

- (id)initWithDictionary:(NSDictionary *)param;
- (MKMapPoint)mapPointValue;

- (NSDictionary *)dictionaryValue;
- (NSDictionary *)dictionaryValueWitoutAccuracy;

@end
