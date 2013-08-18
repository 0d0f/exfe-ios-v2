//
//  EFLocation.m
//  MarauderMap
//
//  Created by 0day on 13-7-11.
//  Copyright (c) 2013年 exfe. All rights reserved.
//

#import "EFLocation.h"

#define kDefaultAccuracy    (1.0f)

@implementation EFLocation

- (id)initWithDictionary:(NSDictionary *)param {
    NSParameterAssert(param);
    
    self = [super init];
    if (self) {
        __block CLLocationDegrees longitude = 0.0f;
        __block CLLocationDegrees latitude = 0.0f;
        
        [param enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop){
            if ([key isEqualToString:@"t"]) {
                NSDate *timestamp = [NSDate dateWithTimeIntervalSince1970:[obj doubleValue]];
                self.timestamp = timestamp;
            } else if ([key isEqualToString:@"gps"]) {
                NSArray *valueArrary = (NSArray *)obj;
                NSAssert(valueArrary.count == 3, @"gps should contain 3 params.");
                
                latitude = [valueArrary[0] doubleValue];
                longitude = [valueArrary[1] doubleValue];
                self.accuracy = [valueArrary[2] doubleValue];
                
                self.coordinate = CLLocationCoordinate2DMake(latitude, longitude);
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
    [dict setValue:[NSNumber numberWithLongLong:(long long)[self.timestamp timeIntervalSince1970]] forKey:@"t"];
    NSArray *gps = @[[NSNumber numberWithDouble:self.coordinate.latitude],
                     [NSNumber numberWithDouble:self.coordinate.longitude],
                     [NSNumber numberWithDouble:self.accuracy]];
    [dict setValue:gps forKey:@"gps"];
    
    return dict;
}

- (NSDictionary *)dictionaryValueWitoutAccuracy {
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithCapacity:4];
    [dict setValue:[NSNumber numberWithLongLong:(long long)[self.timestamp timeIntervalSince1970]] forKey:@"t"];
    NSArray *gps = @[[NSNumber numberWithDouble:self.coordinate.latitude],
                     [NSNumber numberWithDouble:self.coordinate.longitude],
                     [NSNumber numberWithDouble:kDefaultAccuracy]];
    [dict setValue:gps forKey:@"gps"];
    
    return dict;
}

@end
