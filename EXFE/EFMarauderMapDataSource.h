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
- (void)mapDataSource:(EFMarauderMapDataSource *)dataSource didUpdateLocations:(NSArray *)locations forUser:(NSString *)identityId;
- (void)mapDataSource:(EFMarauderMapDataSource *)dataSource didUpdateRouteLocations:(NSArray *)locations;
- (void)mapDataSource:(EFMarauderMapDataSource *)dataSource didUpdateRoutePaths:(NSArray *)paths;

@end

@class EFAnnotation, EFAnnotationView, EFRouteLocation, EFLocation, EFRoutePath;
@interface EFMarauderMapDataSource : NSObject
<
EFHTTPStreamingDelegate
>

@property (nonatomic, assign) NSInteger crossId;
@property (nonatomic, weak) id <EFMarauderMapDataSourceDelegate> delegate;
@property (nonatomic, readonly) EFRouteLocation *destinationLocation;
@property (nonatomic, assign) CGPoint   offset;                 // earth -> mars

- (id)initWithCrossId:(NSInteger)crossId;

- (void)addLocation:(EFLocation *)location;

// All input must be on earth.
- (void)addRouteLocation:(EFRouteLocation *)routeLocation toMapView:(MKMapView *)mapView;
- (void)updateRouteLocation:(EFRouteLocation *)routeLocation inMapView:(MKMapView *)mapView;
- (EFRouteLocation *)routeLocationForAnnotation:(EFAnnotation *)annotation;
- (EFAnnotation *)annotationForRouteLocation:(EFRouteLocation *)routeLocation;
- (void)removeRouteLocation:(EFRouteLocation *)routeLocation fromMapView:(MKMapView *)mapView;
- (NSArray *)allRouteLocations;

- (void)addRoutePath:(EFRoutePath *)path;
- (void)removeRoutePath:(EFRoutePath *)path;
- (void)updateRoutePath:(EFRoutePath *)path;

- (void)openStreaming;
- (void)closeStreaming;

- (CLLocationCoordinate2D)earthCoordinateToMarsCoordinate:(CLLocationCoordinate2D)mars;
- (CLLocationCoordinate2D)marsCoordinateToEarthCoordinate:(CLLocationCoordinate2D)earth;

@end
