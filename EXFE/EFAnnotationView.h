//
//  EFAnnotationView.h
//  MarauderMap
//
//  Created by 0day on 13-7-13.
//  Copyright (c) 2013年 exfe. All rights reserved.
//

#import <MapKit/MapKit.h>

@class EFAnnotation;
@interface EFAnnotationView : MKAnnotationView

@property (nonatomic, weak) MKMapView *mapView;

- (void)reloadWithAnnotation:(EFAnnotation *)annotatoin;

@end