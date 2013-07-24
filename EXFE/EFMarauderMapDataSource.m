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
#import "EFLocation.h"
#import "EFRouteLocation.h"
#import "EFRoutePath.h"
#import "IdentityId+EXFE.h"

#define kStreamingDataTypeLocaionts     @"/v3/crosses/routex/breadcrumbs"
#define kStreamingDataTypeRoute         @"/v3/crosses/routex/geomarks"

NSString *EFNotificationRoutePathDidChange = @"notification.routePath.didChange";
NSString *EFNotificationRouteLocationDidChange = @"notification.routeLocation.didChange";

@interface EFMarauderMapDataSource ()

@property (nonatomic, strong) NSMutableArray        *routeLocations;
@property (nonatomic, strong) NSMutableDictionary   *routeLocationAnnotationMap;
@property (nonatomic, strong) EFHTTPStreaming       *httpStreaming;

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

- (id)initWithCrossId:(NSInteger)crossId {
    self = [super init];
    if (self) {
        self.crossId = crossId;
        self.routeLocations = [[NSMutableArray alloc] init];
        self.routeLocationAnnotationMap = [[NSMutableDictionary alloc] init];
    }
    
    return self;
}

- (void)addLocation:(EFLocation *)location {
}

#pragma mark - Property Accessor

- (EFRouteLocation *)destinationLocation {
    EFRouteLocation *destination = nil;
    for (EFRouteLocation *location in self.routeLocations) {
        if (location.locationTytpe == kEFRouteLocationTypeDestination) {
            destination = location;
            break;
        }
    }
    
    return destination;
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
                                                        coordinate:routeLocation.coordinate
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
    annotation.coordinate = routeLocation.coordinate;
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

#pragma mark - Streaming

- (void)openStreaming {
    [self closeStreaming];
    
    RKObjectManager *objectManager = [RKObjectManager sharedManager];
    NSURL *baseURL = objectManager.HTTPClient.baseURL;
    
    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    NSString *userToken = delegate.model.userToken;
    
    NSURL *streamingURL = [NSURL URLWithString:[NSString stringWithFormat:@"/v3/crosses/%d/routex?_method=WATCH&coordinate=mars&token=%@", self.crossId, userToken] relativeToURL:baseURL];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:streamingURL];
    request.HTTPMethod = @"POST";
    
    self.httpStreaming = [[EFHTTPStreaming alloc] initWithURL:streamingURL];
    self.httpStreaming.delegate = self;
    [self.httpStreaming open];
}

- (void)closeStreaming {
    if (self.httpStreaming) {
        [self.httpStreaming close];
        self.httpStreaming = nil;
    }
}

#pragma mark - EFHTTPStreamingDelegate

- (void)completedRead:(NSString *)string {
    NSError *error = nil;
    NSData *data = [string dataUsingEncoding:NSASCIIStringEncoding];
    if (!data)
        return;
    
    NSDictionary *jsonDictionary = [NSJSONSerialization JSONObjectWithData:data
                                                                options:NSJSONReadingMutableContainers
                                                                  error:&error];
    if (jsonDictionary && !error) {
        NSString *type = [jsonDictionary valueForKey:@"type"];
        if ([type isEqualToString:kStreamingDataTypeLocaionts]) {
            NSDictionary *locations = [jsonDictionary valueForKey:@"data"];
            if (locations && locations.count) {
                if ([self.delegate respondsToSelector:@selector(mapDataSource:didUpdateLocations:forUser:)]) {
                    [locations enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop){
                        NSAssert([obj isKindOfClass:[NSArray class]], @"obj should be a location array");
                        
                        NSMutableArray *userLocations = [[NSMutableArray alloc] initWithCapacity:[obj count]];
                        for (NSDictionary *locationParam in obj) {
                            EFLocation *location = [[EFLocation alloc] initWithDictionary:locationParam];
                            [userLocations addObject:location];
                        }
                        
                        [self.delegate mapDataSource:self didUpdateLocations:userLocations forUser:key];
                    }];
                }
            }
        } else if ([type isEqualToString:kStreamingDataTypeRoute]) {
        
        }
    }
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

#pragma mark - Coordinate Transform

- (CLLocationCoordinate2D)earthCoordinateToMarsCoordinate:(CLLocationCoordinate2D)earth {
    CLLocationCoordinate2D mars = CLLocationCoordinate2DMake(earth.latitude + self.offset.x, earth.longitude + self.offset.y);
    return mars;
}

- (CLLocationCoordinate2D)marsCoordinateToEarthCoordinate:(CLLocationCoordinate2D)mars {
    CLLocationCoordinate2D earth = CLLocationCoordinate2DMake(mars.latitude - self.offset.x, mars.longitude - self.offset.y);
    return earth;
}

@end
