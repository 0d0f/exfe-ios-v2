//
//  EFMarauderMapDataSource.h
//  MarauderMap
//
//  Created by 0day on 13-7-16.
//  Copyright (c) 2013年 exfe. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "EFMapData.h"

@class EFAnnotation, EFAnnotationView, EFRouteLocation, EFLocation, EFRoutePath;
@interface EFMarauderMapDataSource : NSObject

- (void)addLocation:(EFLocation *)location;

- (void)addRouteLocation:(EFRouteLocation *)routeLocation toMapView:(MKMapView *)mapView;
- (void)updateRouteLocation:(EFRouteLocation *)routeLocation inMapView:(MKMapView *)mapView;
- (EFRouteLocation *)routeLocationForAnnotation:(EFAnnotation *)annotation;
- (EFAnnotation *)annotationForRouteLocation:(EFRouteLocation *)routeLocation;
- (void)removeRouteLocation:(EFRouteLocation *)routeLocation fromMapView:(MKMapView *)mapView;

- (void)addRoutePath:(EFRoutePath *)path;
- (void)removeRoutePath:(EFRoutePath *)path;
- (void)updateRoutePath:(EFRoutePath *)path;

@end
