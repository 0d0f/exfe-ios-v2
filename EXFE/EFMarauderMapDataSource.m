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
#import "Cross.h"
#import "Exfee+EXFE.h"
#import "EFAPI.h"

#define kStreamingDataTypeLocaionts     @"/v3/crosses/routex/breadcrumbs"
#define kStreamingDataTypeRoute         @"/v3/crosses/routex/geomarks"

NSString *EFNotificationRoutePathDidChange = @"notification.routePath.didChange";
NSString *EFNotificationRouteLocationDidChange = @"notification.routeLocation.didChange";

@interface EFMarauderMapDataSource ()

@property (nonatomic, strong) NSMutableArray        *people;
@property (nonatomic, strong) NSMutableDictionary   *peopleMap;

@property (nonatomic, strong) NSMutableArray        *routeLocations;
@property (nonatomic, strong) NSMutableDictionary   *routeLocationAnnotationMap;

@property (nonatomic, strong) EFHTTPStreaming       *httpStreaming;

@end

@interface EFMarauderMapDataSource (Private)

- (void)_postPathDidChangeNotification;
- (void)_postLocationDidChangeNotification;

- (void)_initPeople;

- (NSString *)generateRouteLocationId;

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

- (void)_initPeople {
    NSMutableArray *people = [[NSMutableArray alloc] init];
    NSMutableDictionary *peopleMap = [[NSMutableDictionary alloc] init];
    
    NSArray *invitations = [self.cross.exfee getSortedMergedInvitations:kInvitationSortTypeMeAcceptOthers];
    for (NSArray *invitation in invitations) {
        EFMapPerson *person = [[EFMapPerson alloc] initWithIdentity:((Invitation *)invitation[0]).identity];
        [people addObject:person];
        
        [peopleMap setValue:person forKey:person.userIdString];
    }
    
    self.people = people;
    self.peopleMap = peopleMap;
}

- (NSString *)generateRouteLocationId {
    NSString *locationId = nil;
    
    while (YES) {
        locationId = [NSString stringWithFormat:@"%ld%ld%ld%ld%ld@location", (random() % 99) + 1, random() % 100, random() % 100, random() % 100, random() % 100];
        BOOL crashed = NO;
        for (EFRouteLocation *routeLocation in self.routeLocations) {
            if ([routeLocation.locationId isEqualToString:locationId]) {
                crashed = YES;
                break;
            }
        }
        
        if (!crashed) {
            break;
        }
    }
    
    return locationId;
}

@end

@implementation EFMarauderMapDataSource

- (id)initWithCross:(Cross *)cross {
    self = [super init];
    if (self) {
        self.cross = cross;
        
        [self _initPeople];
        
        self.routeLocations = [[NSMutableArray alloc] init];
        self.routeLocationAnnotationMap = [[NSMutableDictionary alloc] init];
    }
    
    return self;
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

#pragma mark - Request

- (void)getPeopleBreadcrumbs {
    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [delegate.model.apiServer getRouteXBreadcrumbsInCross:self.cross
                                        isEarthCoordinate:NO
                                                  success:^(NSArray *breadcrumbs){
                                                      for (EFRoutePath *path in breadcrumbs) {
                                                          NSString *dirtyUserId = path.pathId;
                                                          NSRange exfeRange = [dirtyUserId rangeOfString:@"@exfe"];
                                                          NSAssert(exfeRange.location != NSNotFound, @"there MUST be a @exfe");
                                                          NSString *userIdString = [dirtyUserId substringToIndex:exfeRange.location];
                                                          
                                                          EFMapPerson *person = [self.peopleMap valueForKey:userIdString];
                                                          NSAssert(person, ([NSString stringWithFormat:@"map should contain a person for userId: %@", userIdString]));
                                                          
                                                          [person.locations removeAllObjects];
                                                          
                                                          [person.locations addObjectsFromArray:path.positions];
                                                          
                                                          if ([self.delegate respondsToSelector:@selector(mapDataSource:didUpdateLocations:forUser:)]) {
                                                              [self.delegate mapDataSource:self
                                                                        didUpdateLocations:person.locations
                                                                                   forUser:userIdString];
                                                          }
                                                      }
                                                  }
                                                  failure:^(NSError *error){
                                                  
                                                  }];
}

#pragma mark - People

- (NSUInteger)numberOfPeople {
    return self.people.count;
}

- (EFMapPerson *)me {
    return [self personAtIndex:0];
}

- (EFMapPerson *)personAtIndex:(NSUInteger)index {
    return self.people[index];
}

#pragma mark - RouteLocation

- (void)addRouteLocation:(EFRouteLocation *)routeLocation toMapView:(MKMapView *)mapView {
    NSParameterAssert(routeLocation);
    NSParameterAssert(mapView);
    
    NSInteger index = [self.routeLocations indexOfObject:routeLocation];
    if (NSNotFound != index) {
        [self updateRouteLocation:routeLocation inMapView:mapView];
        return;
    }
    
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
    
    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [delegate.model.apiServer putRouteXUpdateGeomark:routeLocation
                                             inCross:self.cross
                                                type:@"location"
                                   isEarthCoordinate:NO
                                             success:^{}
                                             failure:^(NSError *error){}];
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
    
    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [delegate.model.apiServer deleteRouteXDeleteGeomark:routeLocation
                                                inCross:self.cross
                                                   type:@"location"
                                                success:^{}
                                                failure:^(NSError *error){}];
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
    
    NSInteger crossId = [self.cross.cross_id integerValue];
    NSURL *streamingURL = [NSURL URLWithString:[NSString stringWithFormat:@"/v3/routex/crosses/%d?_method=WATCH&coordinate=mars&token=%@", crossId, userToken] relativeToURL:baseURL];
    
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

#pragma mark - Register

- (void)registerToUpdateLocation {
    EFAccessInfo *accessInfo = [[EFAccessInfo alloc] initWithCross:self.cross shouldSaveBreadcrumbs:YES];
    
    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [delegate.model.apiServer postRouteXAccessInfo:@[accessInfo]
                                           success:^{
                                           }
                                           failure:^(NSError *error){
                                           }];
}

- (void)unregisterToUpdateLocation {
    EFAccessInfo *accessInfo = [[EFAccessInfo alloc] initWithCross:self.cross shouldSaveBreadcrumbs:NO];
    
    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [delegate.model.apiServer postRouteXAccessInfo:@[accessInfo]
                                           success:^{
                                           }
                                           failure:^(NSError *error){
                                           }];
}

#pragma mark - Factory

- (EFRouteLocation *)createRouteLocationWithCoordinate:(CLLocationCoordinate2D)coordinate {
    EFRouteLocation *routelocation = [EFRouteLocation generateRouteLocationWithCoordinate:coordinate];
    routelocation.locationId = [self generateRouteLocationId];
    
#warning TEST only
    routelocation.title = @"子时正刻";
    routelocation.subtitle = @"233";
    
    return routelocation;
}

#pragma mark - EFHTTPStreamingDelegate

- (void)completedRead:(NSString *)string {
    NSError *error = nil;
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    if (!data)
        return;
    
    NSDictionary *jsonDictionary = [NSJSONSerialization JSONObjectWithData:data
                                                                options:NSJSONReadingMutableContainers
                                                                  error:&error];
    if (jsonDictionary && !error) {
        NSString *type = [jsonDictionary valueForKey:@"type"];
        BOOL isAction = !![jsonDictionary valueForKey:@"action"];
        NSArray *tags = [jsonDictionary valueForKey:@"tags"];
        
        if (!isAction) {
            // Data Update
            if ([type isEqualToString:@"route"]) {
                if ([tags[0] isEqualToString:@"breadcrumbs"]) {
                    EFRouteLocation *routeLocation = [[EFRouteLocation alloc] initWithDictionary:jsonDictionary];
                    if ([self.delegate respondsToSelector:@selector(mapDataSource:didUpdateLocations:forUser:)]) {
                        NSString *identityIdString = routeLocation.locationId;
                        [self.delegate mapDataSource:self didUpdateLocations:@[routeLocation] forUser:identityIdString];
                    }
                } else if ([tags[0] isEqualToString:@"geomarks"]) {
                    EFRoutePath *routePath = [[EFRoutePath alloc] initWithDictionary:jsonDictionary];
                    if ([self.delegate respondsToSelector:@selector(mapDataSource:didUpdateRoutePaths:)]) {
                        [self.delegate mapDataSource:self didUpdateRoutePaths:@[routePath]];
                    }
                }
            } else if ([type isEqualToString:@"location"]) {
                EFRouteLocation *routeLocation = [[EFRouteLocation alloc] initWithDictionary:jsonDictionary];
                if ([self.delegate respondsToSelector:@selector(mapDataSource:didUpdateRouteLocations:)]) {
                    [self.delegate mapDataSource:self didUpdateRouteLocations:@[routeLocation]];
                }
            }
        } else {
            // Action Commond
        }
        
//        NSString *type = [jsonDictionary valueForKey:@"type"];
//        if ([type isEqualToString:kStreamingDataTypeLocaionts]) {
//            NSDictionary *locations = [jsonDictionary valueForKey:@"data"];
//            if (locations && locations.count) {
//                if ([self.delegate respondsToSelector:@selector(mapDataSource:didUpdateLocations:forUser:)]) {
//                    [locations enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop){
//                        NSAssert([obj isKindOfClass:[NSArray class]], @"obj should be a location array");
//                        
//                        NSMutableArray *userLocations = [[NSMutableArray alloc] initWithCapacity:[obj count]];
//                        for (NSDictionary *locationParam in obj) {
//                            EFLocation *location = [[EFLocation alloc] initWithDictionary:locationParam];
//                            [userLocations addObject:location];
//                        }
//                        
//                        [self.delegate mapDataSource:self didUpdateLocations:userLocations forUser:key];
//                    }];
//                }
//            }
//        } else if ([type isEqualToString:kStreamingDataTypeRoute]) {
//        
//        }
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
