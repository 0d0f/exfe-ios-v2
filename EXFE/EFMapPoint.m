//
//  EFMapPoint.m
//  MarauderMap
//
//  Created by 0day on 13-7-4.
//  Copyright (c) 2013年 exfe. All rights reserved.
//

#import "EFMapPoint.h"
#import <MapKit/MapKit.h>

@implementation EFMapPoint

- (id)initWithDictionary:(NSDictionary *)param {
    NSParameterAssert(param);
    
    self = [super init];
    if (self) {
        __block CLLocationDegrees longitude = 0.0f;
        __block CLLocationDegrees latitude = 0.0f;
        
        [param enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop){
            if ([key isEqualToString:@"timestamp"]) {
                NSDate *timestamp = [NSDate dateWithTimeIntervalSince1970:[obj doubleValue]];
                self.timestamp = timestamp;
            } else if ([key isEqualToString:@"longitude"]) {
                longitude = [obj doubleValue];
            } else if ([key isEqualToString:@"latitude"]) {
                latitude = [obj doubleValue];
            } else if ([key isEqualToString:@"accuracy"]) {
                self.accuracy = [obj doubleValue];
            }
        }];
        
        self.coordinate2D = CLLocationCoordinate2DMake(latitude, longitude);
    }
    
    return self;
}

- (MKMapPoint)mapPointValue {
    return MKMapPointForCoordinate(self.coordinate2D);
}

@end
