//
//  EFCalloutAnnotation.m
//  MarauderMap
//
//  Created by 0day on 13-7-15.
//  Copyright (c) 2013年 exfe. All rights reserved.
//

#import "EFCalloutAnnotation.h"

@implementation EFCalloutAnnotation

- (id)initWithCoordinate:(CLLocationCoordinate2D)coordinate
                   title:(NSString *)title
                subtitle:(NSString *)subtitle
{
    self = [super init];
    if (self) {
        self.coordinate = coordinate;
        self.title = title;
        self.subtitle = subtitle;
    }
    
    return self;
}

@end
