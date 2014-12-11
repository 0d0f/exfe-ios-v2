//
//  EFCalloutAnnotation.h
//  MarauderMap
//
//  Created by 0day on 13-7-15.
//  Copyright (c) 2013年 exfe. All rights reserved.
//

#import <MapKit/MapKit.h>

@interface EFCalloutAnnotation : NSObject
<
MKAnnotation
>

@property (nonatomic, assign) CLLocationCoordinate2D coordinate;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *subtitle;

- (id)initWithCoordinate:(CLLocationCoordinate2D)coordinate
                   title:(NSString *)title
                subtitle:(NSString *)subtitle;

@end
