//
//  EFMapPoint.h
//  MarauderMap
//
//  Created by 0day on 13-7-4.
//  Copyright (c) 2013年 exfe. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

@interface EFMapPoint : NSObject

@property (assign)  CLLocationCoordinate2D  coordinate2D;
@property (assign)  CGFloat                 accuracy;       // might be 0.0f
@property (strong)  NSDate                  *timestamp;

- (id)initWithDictionary:(NSDictionary *)param;
- (MKMapPoint)mapPointValue;

@end
