//
//  EFTimestampAnnotation.m
//  EXFE
//
//  Created by 0day on 13-8-12.
//
//

#import "EFTimestampAnnotation.h"

@implementation EFTimestampAnnotation


- (id)initWithCoordinate:(CLLocationCoordinate2D)coordinate
               timestamp:(NSDate *)timestamp {
    self = [super init];
    if (self) {
        self.coordinate = coordinate;
        self.timestamp = timestamp;
    }
    
    return self;
}

@end
