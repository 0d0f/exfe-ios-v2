//
//  EFAnnotation.h
//  MarauderMap
//
//  Created by 0day on 13-7-13.
//  Copyright (c) 2013年 exfe. All rights reserved.
//

#import <MapKit/MapKit.h>

#import "EFAnnotationDataDefines.h"

@interface EFAnnotation : NSObject
<
MKAnnotation
>

@property (nonatomic, assign) CLLocationCoordinate2D    coordinate;
@property (nonatomic, copy)   NSString                  *title;
@property (nonatomic, copy)   NSString                  *subtitle;

@property (nonatomic, readwrite, assign)    EFAnnotationStyle   style;
@property (nonatomic, readwrite, strong)    NSString            *markTitle;
@property (nonatomic, readonly, strong)     UIImage             *markImage;

- (id)initWithStyle:(EFAnnotationStyle)style
         coordinate:(CLLocationCoordinate2D)location
              title:(NSString *)title
        description:(NSString *)description;

@end
