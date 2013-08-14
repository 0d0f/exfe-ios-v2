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
#import "EFPersonAnnotation.h"
#import "EFPersonAnnotationView.h"
#import "EFCrumPath.h"
#import "EFTimestampAnnotation.h"

#define kTimestampDuration  (5.0f * 60.0f)
#define kTimestampBlank     (15.0f)

#define DegreesToRadians(x)     (M_PI * x / 180.0)
#define RadiandsToDegrees(x)    (x * 180.0 / M_PI)
#define LengthBetweenPoints(point1, point2)     sqrt(fabs((point1).x - (point2).x) * fabs((point1).x - (point2).x) + fabs((point1).y - (point2).y) * fabs((point1).y - (point2).y))

NSString *EFNotificationRoutePathDidChange = @"notification.routePath.didChange";
NSString *EFNotificationRouteLocationDidChange = @"notification.routeLocation.didChange";

CGFloat HeadingInAngle(CLLocationCoordinate2D destinationCoordinate, CLLocationCoordinate2D locationCoordinate) {
    float fLat = DegreesToRadians(locationCoordinate.latitude);
    float fLng = DegreesToRadians(locationCoordinate.longitude);
    float tLat = DegreesToRadians(destinationCoordinate.latitude);
    float tLng = DegreesToRadians(destinationCoordinate.longitude);
    
    float degree = RadiandsToDegrees(atan2(sin(tLng-fLng)*cos(tLat), cos(fLat)*sin(tLat)-sin(fLat)*cos(tLat)*cos(tLng-fLng)));
    
    if (degree >= 0.0f) {
        return degree;
    } else {
        return 360.0f + degree;
    }
}

@interface EFMarauderMapDataSource ()

@property (nonatomic, strong) NSMutableArray        *people;
@property (nonatomic, strong) NSMutableDictionary   *peopleMap;

@property (nonatomic, strong) NSMutableArray        *routeLocations;
@property (nonatomic, strong) NSMutableDictionary   *routeLocationAnnotationMap;

@property (nonatomic, strong) NSMutableDictionary   *breadcrumPathMap;

@property (nonatomic, strong) NSMutableDictionary   *timestampMap;

@property (nonatomic, strong) NSMutableDictionary   *personAnnotationMap;

@property (nonatomic, strong) EFHTTPStreaming       *httpStreaming;

@end

@interface EFMarauderMapDataSource (Private)

- (void)_postPathDidChangeNotification;
- (void)_postLocationDidChangeNotification;

- (void)_initPeople;

- (NSString *)_generateRouteLocationId;
- (NSString *)_userIdFromDirtyUserId:(NSString *)dirtyUserId;

- (void)_updatePersonState:(EFMapPerson *)person;

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

- (NSString *)_generateRouteLocationId {
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

- (NSString *)_userIdFromDirtyUserId:(NSString *)dirtyUserId {
    NSRange exfeRange = [dirtyUserId rangeOfString:@"@exfe"];
    NSAssert(exfeRange.location != NSNotFound, @"there MUST be a @exfe");
    NSString *userIdString = [dirtyUserId substringToIndex:exfeRange.location];
    
    return userIdString;
}

- (void)_updatePersonState:(EFMapPerson *)person {
    EFRouteLocation *destination = [self destinationLocation];
    if (destination) {
        CLLocation *destinationLocation = [[CLLocation alloc] initWithLatitude:destination.coordinate.latitude longitude:destination.coordinate.longitude];
        CLLocation *personLocation = [[CLLocation alloc] initWithLatitude:person.lastLocation.coordinate.latitude longitude:person.lastLocation.coordinate.longitude];
        CLLocationDistance distance = [destinationLocation distanceFromLocation:personLocation];
        person.distance = distance;
        if (distance < 30.0f) {
            person.locationState = kEFMapPersonLocationStateArrival;
        } else {
            person.locationState = kEFMapPersonLocationStateOnTheWay;
        }
    } else {
        person.locationState = kEFMapPersonLocationStateUnknow;
    }
    
    person.angle = HeadingInAngle(destination.coordinate, person.lastLocation.coordinate);
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
        self.personAnnotationMap = [[NSMutableDictionary alloc] init];
        self.breadcrumPathMap = [[NSMutableDictionary alloc] init];
        self.timestampMap = [[NSMutableDictionary alloc] init];
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
                                                          NSString *userIdString = [self _userIdFromDirtyUserId:path.pathId];
                                                          
                                                          EFMapPerson *person = [self.peopleMap valueForKey:userIdString];
                                                          NSAssert(person, ([NSString stringWithFormat:@"map should contain a person for userId: %@", userIdString]));
                                                          
                                                          [person.locations removeAllObjects];
                                                          
                                                          if (person.lastLocation) {
                                                              [person.locations addObjectsFromArray:path.positions];
                                                          } else {
                                                              if (path.positions.count > 1) {
                                                                  NSArray *positions = [path.positions subarrayWithRange:(NSRange){0, path.positions.count - 1}];
                                                                  [person.locations addObjectsFromArray:positions];
                                                                  person.lastLocation = path.positions[0];
                                                              } else {
                                                                  [person.locations addObjectsFromArray:path.positions];
                                                              }
                                                          }
                                                          
                                                          [self _updatePersonState:person];
                                                          
                                                          if ([self.delegate respondsToSelector:@selector(mapDataSource:didUpdateLocations:forUser:)]) {
                                                              [self.delegate mapDataSource:self
                                                                        didUpdateLocations:person.locations
                                                                                   forUser:person];
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
        [self updateRouteLocation:routeLocation inMapView:mapView shouldPostToServer:NO];
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
    
    [self.routeLocationAnnotationMap setValue:annotation forKey:routeLocation.locationId];
    [mapView addAnnotation:annotation];
}

- (void)updateRouteLocation:(EFRouteLocation *)routeLocation inMapView:(MKMapView *)mapView shouldPostToServer:(BOOL)shouldPost {
    NSParameterAssert(routeLocation);
    NSParameterAssert(mapView);
    
#ifdef DEBUG
    NSUInteger index = [self.routeLocations indexOfObject:routeLocation];
    NSAssert(index != NSNotFound, @"RouteLocation MUST in the array");
#endif
    
    EFAnnotation *annotation = [self.routeLocationAnnotationMap objectForKey:routeLocation.locationId];
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
    
    [self.routeLocationAnnotationMap setValue:annotation forKey:routeLocation.locationId];
    
    EFAnnotationView *annotationView = (EFAnnotationView *)[mapView viewForAnnotation:annotation];
    [annotationView reloadWithAnnotation:annotation];
    
    if (shouldPost) {
        AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        [delegate.model.apiServer putRouteXUpdateGeomark:routeLocation
                                                 inCross:self.cross
                                                    type:@"location"
                                       isEarthCoordinate:NO
                                                 success:^{}
                                                 failure:^(NSError *error){}];
    }
}

- (void)updateRouteLocation:(EFRouteLocation *)routeLocation inMapView:(MKMapView *)mapView {
    [self updateRouteLocation:routeLocation inMapView:mapView shouldPostToServer:YES];
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

- (EFRouteLocation *)routeLocationForRouteLocationId:(NSString *)routeLocationId {
    NSParameterAssert(routeLocationId);
    
    EFRouteLocation *routeLocation = nil;
    for (EFRouteLocation *location in self.routeLocations) {
        if ([location.locationId isEqualToString:routeLocationId]) {
            routeLocation = location;
            break;
        }
    }
    
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
    routelocation.locationId = [self _generateRouteLocationId];
    
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
                    EFRoutePath *path = [[EFRoutePath alloc] initWithDictionary:jsonDictionary];
                    if ([self.delegate respondsToSelector:@selector(mapDataSource:didUpdateLocations:forUser:)]) {
                        NSString *userIdString = [self _userIdFromDirtyUserId:path.pathId];
                        EFMapPerson *person = [self.peopleMap valueForKey:userIdString];
                        
                        // update person last location
                        person.lastLocation = path.positions[0];
                        
                        // update person connect state && location state && distance
                        [self _updatePersonState:person];
                        
                        [self.delegate mapDataSource:self didUpdateLocations:path.positions forUser:person];
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
            NSString *action = [jsonDictionary valueForKey:@"action"];
            if ([action isEqualToString:@"delete"]) {
                if ([type isEqualToString:@"location"]) {
                    NSString *routeLocationId = [jsonDictionary valueForKey:@"id"];
                    if ([self.delegate respondsToSelector:@selector(mapDataSource:needDeleteRouteLocation:)]) {
                        [self.delegate mapDataSource:self needDeleteRouteLocation:routeLocationId];
                    }
                }
            } else if ([action isEqualToString:@"update"]) {
                if ([type isEqualToString:@"location"]) {
                    EFRouteLocation *routeLocation = [[EFRouteLocation alloc] initWithDictionary:jsonDictionary];
                    if ([self.delegate respondsToSelector:@selector(mapDataSource:didUpdateRouteLocations:)]) {
                        [self.delegate mapDataSource:self didUpdateRouteLocations:@[routeLocation]];
                    }
                }
            }
        }
    }
}

#pragma mark - Person

- (EFPersonAnnotation *)personAnnotationForPerson:(EFMapPerson *)person {
    NSParameterAssert(person);
    return [self.personAnnotationMap valueForKey:person.userIdString];
}

- (void)addPersonAnnotationForPerson:(EFMapPerson *)person toMapView:(MKMapView *)mapView {
    if ([self personAnnotationForPerson:person]) {
        [self updatePersonAnnotationForPerson:person toMapView:mapView];
    } else {
        EFPersonAnnotation *personAnnotation = [[EFPersonAnnotation alloc] init];
        personAnnotation.coordinate = person.lastLocation.coordinate;
        personAnnotation.isOnline = (person.connectState == kEFMapPersonConnectStateOnline) ? YES : NO;
        
        [self.personAnnotationMap setValue:personAnnotation forKey:person.userIdString];
        [mapView addAnnotation:personAnnotation];
    }
}

- (void)updatePersonAnnotationForPerson:(EFMapPerson *)person toMapView:(MKMapView *)mapView {
    EFPersonAnnotation *personAnnotation = [self.personAnnotationMap valueForKey:person.userIdString];
    if (personAnnotation) {
        EFPersonAnnotationView *personAnnotationView = (EFPersonAnnotationView *)[mapView viewForAnnotation:personAnnotation];
        
        personAnnotation.coordinate = person.lastLocation.coordinate;
        personAnnotation.isOnline = (person.connectState == kEFMapPersonConnectStateOnline) ? YES : NO;
        
        personAnnotationView.annotation = personAnnotation;
    } else {
        [self addPersonAnnotationForPerson:person toMapView:mapView];
    }
}

#pragma mark - Breadcrum Path

- (void)removeBreadcrumPathForPerson:(EFMapPerson *)person toMapView:(MKMapView *)mapView {
    NSParameterAssert(person);
    NSParameterAssert(mapView);
    
    id key = [NSValue valueWithNonretainedObject:person];
    EFCrumPath *crumPath = [self.breadcrumPathMap objectForKey:key];
    [mapView removeOverlay:crumPath];
    [self.breadcrumPathMap removeObjectForKey:key];
}

- (void)removeAllBreadcrumPathsToMapView:(MKMapView *)mapView {
    NSParameterAssert(mapView);
    
    for (EFMapPerson *person in self.people) {
        [self removeBreadcrumPathForPerson:person toMapView:mapView];
    }
}

- (void)addBreadcrumPathForPerson:(EFMapPerson *)person toMapView:(MKMapView *)mapView {
    NSParameterAssert(person);
    NSParameterAssert(mapView);
    
    EFCrumPath *path = [[EFCrumPath alloc] initWithMapPoints:person.locations];
    
    EFCrumPathView *pathView = (EFCrumPathView *)[mapView viewForOverlay:path];
    if (pathView) {
        [self updateBreadcrumPathForPerson:person toMapView:mapView];
    } else {
        if (kEFMapPersonConnectStateOnline == person.connectState) {
            path.linecolor = [UIColor COLOR_RGB(0xFF, 0x7E, 0x98)];
        } else {
            path.linecolor = [UIColor COLOR_RGB(0xB2, 0xB2, 0xB2)];
        }
        path.lineStyle = kEFMapLineStyleDashedLine;
        
        [mapView addOverlay:path];
        [self.breadcrumPathMap setObject:path forKey:[NSValue valueWithNonretainedObject:person]];
    }
}

- (void)updateBreadcrumPathForPerson:(EFMapPerson *)person toMapView:(MKMapView *)mapView {
    NSParameterAssert(person);
    NSParameterAssert(mapView);
    
    EFCrumPath *path = [self.breadcrumPathMap objectForKey:[NSValue valueWithNonretainedObject:person]];
    EFCrumPathView *pathView = (EFCrumPathView *)[mapView viewForOverlay:path];
    
    if (!pathView) {
        [self addBreadcrumPathForPerson:person toMapView:mapView];
    } else {
        [path replaceAllMapPointsWithMapPoints:person.locations];
        if (kEFMapPersonConnectStateOnline == person.connectState) {
            path.linecolor = [UIColor COLOR_RGB(0xFF, 0x7E, 0x98)];
        } else {
            path.linecolor = [UIColor COLOR_RGB(0xB2, 0xB2, 0xB2)];
        }
        
        [pathView setNeedsDisplay];
    }
}

#pragma mark - Timestamp

- (void)removeAllTimestampToMapView:(MKMapView *)mapView {
    NSParameterAssert(mapView);
    
    [self.timestampMap enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop){
        NSArray *timestamps = (NSArray *)obj;
        [mapView removeAnnotations:timestamps];
    }];
    
    [self.timestampMap removeAllObjects];
}

- (void)updateTimestampForPerson:(EFMapPerson *)person toMapView:(MKMapView *)mapView {
    NSParameterAssert(person);
    NSParameterAssert(mapView);
    
    [self removeAllTimestampToMapView:mapView];
    
    if (kEFMapPersonConnectStateOffline == person.connectState) {
        EFLocation *lastLocation = person.lastLocation;
        NSArray *locations = person.locations;
        NSMutableArray *annotations = [[NSMutableArray alloc] init];
        
        EFTimestampAnnotation *firstTimestamp = [[EFTimestampAnnotation alloc] initWithCoordinate:lastLocation.coordinate
                                                                                        timestamp:lastLocation.timestamp];
        [annotations addObject:firstTimestamp];
        
        EFLocation *preLocation = lastLocation;
        
        for (EFLocation *location in locations) {
            NSTimeInterval timeInterval = [preLocation.timestamp timeIntervalSinceDate:location.timestamp];
            if (timeInterval >= kTimestampDuration) {
                CGPoint viewPoint = [mapView convertCoordinate:location.coordinate toPointToView:mapView];
                
                CGFloat length = HUGE_VALF;
                for (EFTimestampAnnotation *preTimestamp in annotations) {
                    CGPoint preViewPoint = [mapView convertCoordinate:preTimestamp.coordinate toPointToView:mapView];
                    length = MIN(length, LengthBetweenPoints(viewPoint, preViewPoint));
                }
                
                if (length > kTimestampBlank) {
                    EFTimestampAnnotation *timestamp = [[EFTimestampAnnotation alloc] initWithCoordinate:location.coordinate
                                                                                               timestamp:location.timestamp];
                    [annotations addObject:timestamp];
                    preLocation = location;
                }
            }
        }
        
        [self.timestampMap setObject:annotations forKey:[NSValue valueWithNonretainedObject:person]];
        [mapView addAnnotations:annotations];
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
