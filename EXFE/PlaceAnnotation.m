//
//  PlaceAnnotation.m
//  EXFE
//
//  Created by huoju on 6/28/12.
//
//

#import "PlaceAnnotation.h"

@implementation PlaceAnnotation
@synthesize coordinate;
@synthesize index;
//@synthesize title;
//@synthesize subtitle;

-(id)initWithCoordinate:(CLLocationCoordinate2D) c withTitle:(NSString*)title description:(NSString*)description{
    coordinate=c;
    place_title=title;
    place_description=description;
    return self;
}
- (NSString *)subtitle{
//    return @"subtitle";
    if(place_description==nil || [place_description isEqual:[NSNull null]])
        return @"";
    return place_description;
}

- (NSString *)title{
//    return @"title";
    if(place_title == nil || [place_title isEqual:[NSNull null]])
        return @"";
    return place_title;
}

@end
