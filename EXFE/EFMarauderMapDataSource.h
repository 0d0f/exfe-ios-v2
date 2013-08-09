//
//  EFMarauderMapDataSource.h
//  MarauderMap
//
//  Created by 0day on 13-7-16.
//  Copyright (c) 2013年 exfe. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "EFMapData.h"
#import "EFHTTPStreaming.h"

@class EFMarauderMapDataSource, IdentityId;
@protocol EFMarauderMapDataSourceDelegate <NSObject>

@optional
- (void)mapDataSource:(EFMarauderMapDataSource *)dataSource didUpdateLocations:(NSArray *)locations forUser:(EFMapPerson *)person;
- (void)mapDataSource:(EFMarauderMapDataSource *)dataSource didUpdateRouteLocations:(NSArray *)locations;
- (void)mapDataSource:(EFMarauderMapDataSource *)dataSource didUpdateRoutePaths:(NSArray *)paths;

@end

@class EFAnnotation, EFAnnotationView, EFRouteLocation, EFLocation, EFRoutePath, Cross, EFPersonAnnotation;
@interface EFMarauderMapDataSource : NSObject
<
EFHTTPStreamingDelegate
>

@property (nonatomic, weak) Cross    *cross;
@property (nonatomic, weak) id <EFMarauderMapDataSourceDelegate> delegate;
@property (nonatomic, readonly) EFRouteLocation *destinationLocation;
@property (nonatomic, assign) CGPoint   offset;                 // earth -> mars

- (id)initWithCross:(Cross *)cross;

- (void)getPeopleBreadcrumbs;

/**
 * People
 */
- (NSUInteger)numberOfPeople;
- (EFMapPerson *)me;
- (EFMapPerson *)personAtIndex:(NSUInteger)index;

/**
 * Route Location
 * @note: All input must be on mars.
 */
- (void)addRouteLocation:(EFRouteLocation *)routeLocation toMapView:(MKMapView *)mapView;
- (void)updateRouteLocation:(EFRouteLocation *)routeLocation inMapView:(MKMapView *)mapView;
- (EFRouteLocation *)routeLocationForAnnotation:(EFAnnotation *)annotation;
- (EFAnnotation *)annotationForRouteLocation:(EFRouteLocation *)routeLocation;
- (void)removeRouteLocation:(EFRouteLocation *)routeLocation fromMapView:(MKMapView *)mapView;
- (NSArray *)allRouteLocations;

/**
 * Person
 */
- (EFPersonAnnotation *)personAnnotationForPerson:(EFMapPerson *)person;
- (void)addPersonAnnotationForPerson:(EFMapPerson *)person toMapView:(MKMapView *)mapView;
- (void)updatePersonAnnotationForPerson:(EFMapPerson *)person toMapView:(MKMapView *)mapView;

/**
 * Route Path
 */
- (void)addRoutePath:(EFRoutePath *)path;
- (void)removeRoutePath:(EFRoutePath *)path;
- (void)updateRoutePath:(EFRoutePath *)path;

/**
 * Streaming
 */
- (void)openStreaming;
- (void)closeStreaming;

/**
 * Register
 */
- (void)registerToUpdateLocation;
- (void)unregisterToUpdateLocation;

/**
 * Factory
 */
- (EFRouteLocation *)createRouteLocationWithCoordinate:(CLLocationCoordinate2D)coordinate;

- (CLLocationCoordinate2D)earthCoordinateToMarsCoordinate:(CLLocationCoordinate2D)mars;
- (CLLocationCoordinate2D)marsCoordinateToEarthCoordinate:(CLLocationCoordinate2D)earth;

@end
