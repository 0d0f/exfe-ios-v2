//
//  EFLocation.m
//  MarauderMap
//
//  Created by 0day on 13-7-11.
//  Copyright (c) 2013年 exfe. All rights reserved.
//

#import "EFLocation.h"

@implementation EFLocation

- (id)initWithDictionary:(NSDictionary *)param {
    NSParameterAssert(param);
    
    self = [super init];
    if (self) {
        __block CLLocationDegrees longitude = 0.0f;
        __block CLLocationDegrees latitude = 0.0f;
        
        [param enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop){
            if ([key isEqualToString:@"ts"]) {
                NSDate *timestamp = [NSDate dateWithTimeIntervalSince1970:[obj doubleValue]];
                self.timestamp = timestamp;
            } else if ([key isEqualToString:@"lng"]) {
                longitude = [obj doubleValue];
            } else if ([key isEqualToString:@"lat"]) {
                latitude = [obj doubleValue];
            } else if ([key isEqualToString:@"acc"]) {
                self.accuracy = [obj doubleValue];
            }
        }];
        
        self.coordinate = CLLocationCoordinate2DMake(latitude, longitude);
    }
    
    return self;
}

- (MKMapPoint)mapPointValue {
    return MKMapPointForCoordinate(self.coordinate);
}

- (NSDictionary *)dictionaryValue {
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithCapacity:4];
    [dict setValue:[NSNumber numberWithLongLong:(long long)[self.timestamp timeIntervalSince1970]] forKey:@"ts"];
    [dict setValue:[NSNumber numberWithDouble:self.accuracy] forKey:@"acc"];
    [dict setValue:[NSNumber numberWithDouble:self.coordinate.longitude] forKey:@"lng"];
    [dict setValue:[NSNumber numberWithDouble:self.coordinate.latitude] forKey:@"lat"];
    
    return dict;
}

- (NSDictionary *)dictionaryValueWitoutAccuracy {
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithCapacity:3];
    [dict setValue:[NSNumber numberWithLongLong:(long long)[self.timestamp timeIntervalSince1970]] forKey:@"ts"];
    [dict setValue:[NSNumber numberWithDouble:self.coordinate.longitude] forKey:@"lng"];
    [dict setValue:[NSNumber numberWithDouble:self.coordinate.latitude] forKey:@"lat"];
    
    return dict;
}

@end
