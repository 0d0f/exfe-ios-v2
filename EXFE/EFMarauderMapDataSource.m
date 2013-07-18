//
//  EFMarauderMapDataSource.m
//  MarauderMap
//
//  Created by 0day on 13-7-16.
//  Copyright (c) 2013年 exfe. All rights reserved.
//

#import "EFMarauderMapDataSource.h"

#import "EFAnnotation.h"
#import "EFAnnotationView.h"
#import "Util.h"

NSString *EFNotificationRoutePathDidChange = @"notification.routePath.didChange";
NSString *EFNotificationRouteLocationDidChange = @"notification.routeLocation.didChange";

@interface EFMarauderMapDataSource ()

@property (nonatomic, strong) NSMutableArray        *routeLocations;
@property (nonatomic, strong) NSMutableDictionary   *routeLocationAnnotationMap;

@end

@interface EFMarauderMapDataSource (Private)

- (void)_postPathDidChangeNotification;
- (void)_postLocationDidChangeNotification;

@end

@implementation EFMarauderMapDataSource (Private)

- (void)_postPathDidChangeNotification {
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:EFNotificationRoutePathDidChange object:nil];
    });
}

- (void)_postLocationDidChangeNotification {
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:EFNotificationRouteLocationDidChange object:nil];
    });
}

@end

@implementation EFMarauderMapDataSource

- (id)init {
    self = [super init];
    if (self) {
        self.routeLocations = [[NSMutableArray alloc] init];
        self.routeLocationAnnotationMap = [[NSMutableDictionary alloc] init];
    }
    
    return self;
}

- (void)addLocation:(EFLocation *)location {
}

#pragma mark - RouteLocation

- (void)addRouteLocation:(EFRouteLocation *)routeLocation toMapView:(MKMapView *)mapView {
    NSParameterAssert(routeLocation);
    NSParameterAssert(mapView);
    
    if (kEFRouteLocationTypeUnknow == routeLocation.locationTytpe) {
        BOOL hasDestination = NO;
        for (EFRouteLocation *location in self.routeLocations) {
            if (kEFRouteLocationTypeDestination == location.locationTytpe) {
                hasDestination = YES;
                break;
            }
        }
        
        if (!hasDestination) {
            routeLocation.locationTytpe = kEFRouteLocationTypeDestination;
        } else {
            routeLocation.locationTytpe = kEFRouteLocationTypePark;
        }
    }
    
    [self.routeLocations addObject:routeLocation];
    EFAnnotation *annotation = [[EFAnnotation alloc] initWithStyle:(routeLocation.locationTytpe == kEFRouteLocationTypeDestination) ? kEFAnnotationStyleDestination : ((routeLocation.markColor == kEFRouteLocationColorRed) ? kEFAnnotationStyleParkRed : kEFAnnotationStyleParkBlue)
                                                        coordinate:[Util earthLocationFromMarsLocation:routeLocation.coordinate]
                                                             title:routeLocation.title
                                                       description:routeLocation.subtitle];
    
    annotation.markTitle = routeLocation.markTitle;
    
    [self.routeLocationAnnotationMap setObject:annotation forKey:[NSValue valueWithNonretainedObject:routeLocation]];
    [mapView addAnnotation:annotation];
}

- (void)updateRouteLocation:(EFRouteLocation *)routeLocation inMapView:(MKMapView *)mapView {
    NSParameterAssert(routeLocation);
    NSParameterAssert(mapView);
    
#ifdef DEBUG
    NSUInteger index = [self.routeLocations indexOfObject:routeLocation];
    NSAssert(index != NSNotFound, @"RouteLocation MUST in the array");
#endif
    
    EFAnnotation *annotation = [self.routeLocationAnnotationMap objectForKey:[NSValue valueWithNonretainedObject:routeLocation]];
    annotation.coordinate = [Util earthLocationFromMarsLocation:routeLocation.coordinate];
    annotation.title = routeLocation.title;
    annotation.subtitle = routeLocation.subtitle;
    
    if (kEFRouteLocationTypeDestination == routeLocation.locationTytpe) {
        annotation.style = kEFAnnotationStyleDestination;
    } else {
        if (routeLocation.markColor == kEFRouteLocationColorRed) {
            annotation.style = kEFAnnotationStyleParkRed;
        } else {
            annotation.style = kEFAnnotationStyleParkBlue;
        }
    }
    
    annotation.markTitle = routeLocation.markTitle;
    
    [self.routeLocationAnnotationMap setObject:annotation forKey:[NSValue valueWithNonretainedObject:routeLocation]];
    
    [mapView addAnnotation:annotation];
    
    EFAnnotationView *annotationView = (EFAnnotationView *)[mapView viewForAnnotation:annotation];
    [annotationView reloadWithAnnotation:annotation];
}

- (EFRouteLocation *)routeLocationForAnnotation:(EFAnnotation *)annotation {
    NSParameterAssert(annotation);
    
    __block EFRouteLocation *routeLocation = nil;
    [self.routeLocationAnnotationMap enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop){
        if (obj == annotation) {
            routeLocation = [key nonretainedObjectValue];
            *stop = YES;
        }
    }];
    
    return routeLocation;
}

- (EFAnnotation *)annotationForRouteLocation:(EFRouteLocation *)routeLocation {
    NSParameterAssert(routeLocation);
    
    return [self.routeLocationAnnotationMap objectForKey:[NSValue valueWithNonretainedObject:routeLocation]];
}

- (void)removeRouteLocation:(EFRouteLocation *)routeLocation fromMapView:(MKMapView *)mapView {
    NSParameterAssert(routeLocation);
    NSParameterAssert(mapView);
    
    EFAnnotation *annotation = [self.routeLocationAnnotationMap objectForKey:[NSValue valueWithNonretainedObject:routeLocation]];
    [mapView removeAnnotation:annotation];
    [self.routeLocationAnnotationMap removeObjectForKey:[NSValue valueWithNonretainedObject:routeLocation]];
    [self.routeLocations removeObject:routeLocation];
}

- (NSArray *)allRouteLocations {
    return self.routeLocations;
}

#pragma mark - RoutePath
- (void)addRoutePath:(EFRoutePath *)path {
    [self _postPathDidChangeNotification];
}

- (void)removeRoutePath:(EFRoutePath *)path {
    [self _postPathDidChangeNotification];
}

- (void)updateRoutePath:(EFRoutePath *)path {
    [self _postPathDidChangeNotification];
}

@end
