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

extern CGFloat HeadingInRadian(CLLocationCoordinate2D location1, CLLocationCoordinate2D location2);

@class EFMarauderMapDataSource, IdentityId, EFRouteLocation;
@protocol EFMarauderMapDataSourceDelegate <NSObject>

@optional
// 
- (void)mapDataSourcePeopleDidChange:(EFMarauderMapDataSource *)dataSource;

// streaming
- (void)mapDataRourceInitCompleted:(EFMarauderMapDataSource *)dataSource;
- (void)mapDataSource:(EFMarauderMapDataSource *)dataSource didGetRouteLocations:(NSArray *)location;
- (void)mapDataSource:(EFMarauderMapDataSource *)dataSource didUpdateLocations:(NSArray *)locations forUser:(EFMapPerson *)person;
- (void)mapDataSource:(EFMarauderMapDataSource *)dataSource didUpdateRouteLocations:(NSArray *)locations;   // action: update, type: location
- (void)mapDataSource:(EFMarauderMapDataSource *)dataSource didUpdateRoutePaths:(NSArray *)paths;
- (void)mapDataSource:(EFMarauderMapDataSource *)dataSource needDeleteRouteLocation:(NSString *)routeLocationId shouldPostToServer:(BOOL)shouldPost;    // action: delete, type: location

// other
- (void)mapDataSource:(EFMarauderMapDataSource *)dataSource routeLocationDidGetGeomarkInfo:(EFRouteLocation *)routeLocation;

@end

@class EFAnnotation, EFAnnotationView, EFRouteLocation, EFLocation, EFRoutePath, Cross, EFPersonAnnotation, EFCrumPath;
@interface EFMarauderMapDataSource : NSObject
<
EFHTTPStreamingDelegate
>

@property (nonatomic, weak) Cross    *cross;
@property (nonatomic, weak) id <EFMarauderMapDataSourceDelegate> delegate;
@property (nonatomic, readonly) EFRouteLocation *destinationLocation;
@property (nonatomic, assign) CGPoint   offset;                 // earth -> mars
@property (nonatomic, weak) EFMapPerson   *selectedPerson;

- (id)initWithCross:(Cross *)cross;

- (void)getPeopleBreadcrumbs;

/**
 * People
 */
- (NSUInteger)numberOfPeople;
- (EFMapPerson *)me;
- (EFMapPerson *)personAtIndex:(NSUInteger)index;
- (NSArray *)allPeople;
- (NSArray *)notificationIdentityIdsForPerson:(EFMapPerson *)person;

/**
 * Route Location
 * @note: All input must be on mars.
 */
- (void)addRouteLocation:(EFRouteLocation *)routeLocation toMapView:(MKMapView *)mapView canChangeType:(BOOL)canChangeType;
- (void)addRouteLocation:(EFRouteLocation *)routeLocation toMapView:(MKMapView *)mapView;   // canChangeType == YES
- (void)updateRouteLocation:(EFRouteLocation *)routeLocation inMapView:(MKMapView *)mapView shouldPostToServer:(BOOL)shouldPost;
- (void)updateRouteLocation:(EFRouteLocation *)routeLocation inMapView:(MKMapView *)mapView;    // shouldPost == YES

- (EFRouteLocation *)routeLocationForAnnotation:(EFAnnotation *)annotation;
- (EFRouteLocation *)routeLocationForRouteLocationId:(NSString *)routeLocationId;

- (EFAnnotation *)annotationForRouteLocation:(EFRouteLocation *)routeLocation;
- (void)removeRouteLocation:(EFRouteLocation *)routeLocation fromMapView:(MKMapView *)mapView shouldPostToServer:(BOOL)shouldPost;
- (void)removeRouteLocation:(EFRouteLocation *)routeLocation fromMapView:(MKMapView *)mapView;
- (NSArray *)allRouteLocations;
- (NSArray *)allAnnotations;

/**
 * Person
 */
- (EFPersonAnnotation *)personAnnotationForPerson:(EFMapPerson *)person;
- (void)addPersonAnnotationForPerson:(EFMapPerson *)person toMapView:(MKMapView *)mapView;
- (void)updatePersonAnnotationForPerson:(EFMapPerson *)person toMapView:(MKMapView *)mapView;

/**
 * Breadcrum Path
 */
- (void)removeBreadcrumPathForPerson:(EFMapPerson *)person toMapView:(MKMapView *)mapView;
- (void)removeAllBreadcrumPathsToMapView:(MKMapView *)mapView;
- (void)addBreadcrumPathForPerson:(EFMapPerson *)person toMapView:(MKMapView *)mapView;
- (void)updateBreadcrumPathForPerson:(EFMapPerson *)person toMapView:(MKMapView *)mapView;

/**
 * Timestamp
 */
- (void)removeAllBreadcrumTimestampToMapView:(MKMapView *)mapView;
- (void)updateBreadcrumTimestampForPerson:(EFMapPerson *)person toMapView:(MKMapView *)mapView;

- (void)removePeopleTimestampInMapView:(MKMapView *)mapView;
- (void)updatePeopleTimestampInMapView:(MKMapView *)mapView;

/**
 * Route Path
 */
- (void)addRoutePath:(EFRoutePath *)path;
- (void)removeRoutePath:(EFRoutePath *)path;
- (void)updateRoutePath:(EFRoutePath *)path;

/**
 * Streaming
 */
- (BOOL)isStreamOpened;
- (void)openStreaming;
- (void)closeStreaming;

/**
 * Register
 */
- (void)registerToUpdateLocation;
- (void)unregisterToUpdateLocation;

/**
 * Application Event
 */
- (void)applicationDidEnterBackground;
- (void)applicationDidEnterForeground;

/**
 * Factory
 */
- (EFRouteLocation *)createRouteLocationWithCoordinate:(CLLocationCoordinate2D)coordinate;
- (void)changeXPlaceRouteLocationToNormalRouteLocaiton:(EFRouteLocation *)xplace;
- (void)changeDestinationToNormalRouteLocation:(EFRouteLocation *)destination;

- (CLLocationCoordinate2D)earthCoordinateToMarsCoordinate:(CLLocationCoordinate2D)mars;
- (CLLocationCoordinate2D)marsCoordinateToEarthCoordinate:(CLLocationCoordinate2D)earth;

@end
