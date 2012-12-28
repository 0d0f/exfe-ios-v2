//
//  MapPin.m
//  EXFE
//
//  Created by Stony Wang on 12-12-27.
//
//

#import "MapPin.h"

@implementation MapPin

@synthesize coordinate;
@synthesize title;
@synthesize subTitle;

- (id)initWithCoordinates:(CLLocationCoordinate2D)location placeName:placeName description:description {
    self = [super init];
    if (self != nil) {
        coordinate = location;
        title = placeName;
        [title retain];
        subTitle = description;
        [subTitle retain];
    }
    return self;
}

- (void)dealloc {
    [title release];
    [subTitle release];
    [super dealloc];
}


@end

