//
//  EFMarauderMapDataSource.m
//  MarauderMap
//
//  Created by 0day on 13-7-16.
//  Copyright (c) 2013年 exfe. All rights reserved.
//

#import "EFMarauderMapDataSource.h"

#import <AddressBookUI/AddressBookUI.h>
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
#import "EFAPIOperations.h"
#import "EXFEModel+Crosses.h"
#import "EFMapDataDefines.h"

#define kTimestampDuration  (5.0f * 60.0f)
#define kTimestampBlank     (15.0f)

#define DegreesToRadians(x)     (M_PI * x / 180.0)
#define RadiansToDegrees(x)    (x * 180.0 / M_PI)
#define LengthBetweenPoints(point1, point2)     sqrt(fabs((point1).x - (point2).x) * fabs((point1).x - (point2).x) + fabs((point1).y - (point2).y) * fabs((point1).y - (point2).y))

NSString *EFNotificationRoutePathDidChange = @"notification.routePath.didChange";
NSString *EFNotificationRouteLocationDidChange = @"notification.routeLocation.didChange";

// cosa＝（b^2+c^2-a^2)/2bc
CGFloat RadianAWithLine(CGFloat a, CGFloat b, CGFloat c) {
    CGFloat cosa = (b * b + c * c - a * a) / (2 * b * c);
    CGFloat A = acos(cosa);
    return A;
}

CGFloat HeadingInRadian(CLLocationCoordinate2D destinationCoordinate, CLLocationCoordinate2D locationCoordinate) {
    CGFloat offset = fabs(destinationCoordinate.longitude - locationCoordinate.longitude);
    CLLocationCoordinate2D another = CLLocationCoordinate2DMake(locationCoordinate.latitude + offset, locationCoordinate.longitude);
    
    CLLocation *destinationLocation = [[CLLocation alloc] initWithLatitude:destinationCoordinate.latitude longitude:destinationCoordinate.longitude];
    CLLocation *locationLocation = [[CLLocation alloc] initWithLatitude:locationCoordinate.latitude longitude:locationCoordinate.longitude];
    CLLocation *anotherLocation = [[CLLocation alloc] initWithLatitude:another.latitude longitude:another.longitude];
    
    CGFloat a = [anotherLocation distanceFromLocation:destinationLocation];
    CGFloat b = [anotherLocation distanceFromLocation:locationLocation];
    CGFloat c = [destinationLocation distanceFromLocation:locationLocation];
    
    CGFloat angle = RadianAWithLine(a, b, c);
    
    if (destinationCoordinate.longitude <= locationCoordinate.longitude) {
        angle = 2 * M_PI - angle;
    }
    
    return angle;
}

@interface EFMarauderMapDataSource ()

@property (nonatomic, strong) NSMutableArray        *people;
@property (nonatomic, strong) NSMutableDictionary   *peopleMap;

@property (nonatomic, strong) NSMutableArray        *routeLocations;
@property (nonatomic, strong) NSMutableDictionary   *routeLocationAnnotationMap;

@property (nonatomic, strong) NSMutableDictionary   *toAddPeopleUserIdMap;
@property (nonatomic, strong) NSMutableDictionary   *breadcrumPathMap;
@property (nonatomic, strong) NSMutableDictionary   *timestampMap;
@property (nonatomic, strong) NSMutableDictionary   *personAnnotationMap;

@property (nonatomic, strong) EFHTTPStreaming       *httpStreaming;
@property (nonatomic, strong) NSMutableArray        *locationIdCharactors;
@property (nonatomic, assign) BOOL                  hasStreamInited;
@property (nonatomic, strong) NSMutableArray        *tempGeomarks;

@end

@interface EFMarauderMapDataSource (Private)

- (void)_postPathDidChangeNotification;
- (void)_postLocationDidChangeNotification;

- (void)_initLocationIdCharactors;
- (void)_initPeople;
- (void)_reloadPeople;

- (NSString *)_generateRouteLocationId;
- (NSString *)_userIdFromDirtyUserId:(NSString *)dirtyUserId;

- (void)_updatePersonState:(EFMapPerson *)person;

- (void)_registerNotification;
- (void)_unregisterNotification;

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

- (void)_initLocationIdCharactors {
    self.locationIdCharactors = [[NSMutableArray alloc] init];
    for (int i = 0; i < 10; i++) {
        [self.locationIdCharactors addObject:[NSString stringWithFormat:@"%d", i]];
    }
    for (int i = 0; i < 26; i++) {
        [self.locationIdCharactors addObject:[NSString stringWithFormat:@"%c", i + 'a']];
    }
    for (int i = 0; i < 26; i++) {
        [self.locationIdCharactors addObject:[NSString stringWithFormat:@"%c", i + 'A']];
    }
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

- (void)_reloadPeople {
    BOOL hasChanged = NO;
    NSArray *invitations = [self.cross.exfee getSortedMergedInvitations:kInvitationSortTypeMeAcceptOthers];
    
    for (NSArray *invitationList in invitations) {
        Invitation *invitation = invitationList[0];
        NSString *userIdString = [NSString stringWithFormat:@"%d", [invitation.identity.connected_user_id unsignedIntegerValue]];
        if (![self.peopleMap valueForKey:userIdString]) {
            hasChanged = YES;
            EFMapPerson *person = [[EFMapPerson alloc] initWithIdentity:invitation.identity];
            
            [self.people addObject:person];
            [self.peopleMap setValue:person forKey:person.userIdString];
        }
    }
    
    if (hasChanged && [self.delegate respondsToSelector:@selector(mapDataSourcePeopleDidChange:)]) {
        [self.delegate mapDataSourcePeopleDidChange:self];
    }
}

- (NSString *)_generateRouteLocationId {
    NSString *locationId = nil;
    
    NSInteger count = self.locationIdCharactors.count;
    
    while (YES) {
        locationId = [NSString stringWithFormat:@"location.%@%@%@%@",
                      self.locationIdCharactors[rand() % count],
                      self.locationIdCharactors[rand() % count],
                      self.locationIdCharactors[rand() % count],
                      self.locationIdCharactors[rand() % count]];
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
    NSRange exfeRange = [dirtyUserId rangeOfString:@"breadcrumbs."];
    NSAssert(exfeRange.location != NSNotFound, @"there MUST be a .breadcrumbs");
    NSString *userIdString = [dirtyUserId substringFromIndex:exfeRange.location + exfeRange.length];
    
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
        
        person.angle = HeadingInRadian(destination.coordinate, person.lastLocation.coordinate);
    } else {
        person.locationState = kEFMapPersonLocationStateUnknow;
    }
}

- (void)_registerNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleLoadCrossSuccessNotification:)
                                                 name:kEFNotificationNameLoadCrossSuccess
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleLoadCrossFailureNotification:)
                                                 name:kEFNotificationNameLoadCrossFailure
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleUserLocationChangeNotification:)
                                                 name:EFNotificationUserLocationDidChange
                                               object:nil];
}

- (void)_unregisterNotification {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end

@implementation EFMarauderMapDataSource

- (id)initWithCross:(Cross *)cross {
    self = [super init];
    if (self) {
        self.cross = cross;
        
        [self _initLocationIdCharactors];
        [self _initPeople];
        
        self.routeLocations = [[NSMutableArray alloc] init];
        self.routeLocationAnnotationMap = [[NSMutableDictionary alloc] init];
        self.personAnnotationMap = [[NSMutableDictionary alloc] init];
        self.breadcrumPathMap = [[NSMutableDictionary alloc] init];
        self.timestampMap = [[NSMutableDictionary alloc] init];
        self.toAddPeopleUserIdMap = [[NSMutableDictionary alloc] init];
        self.tempGeomarks = [[NSMutableArray alloc] init];
        
        [self _registerNotification];
    }
    
    return self;
}

- (void)dealloc {
    [self _unregisterNotification];
}

#pragma mark - Property Accessor

- (EFRouteLocation *)destinationLocation {
    EFRouteLocation *destination = nil;
    
    for (EFRouteLocation *location in self.routeLocations) {
        BOOL isDestination = !!(location.locatinMask & kEFRouteLocationMaskDestination);
        if (isDestination) {
            if (destination) {
                if ([location.updateDate timeIntervalSinceDate:destination.updateDate] > 0) {
                    destination = location;
                }
            } else {
                destination = location;
            }
        }
    }
    
    return destination;
}

- (void)setHasStreamInited:(BOOL)hasStreamInited {
    [self willChangeValueForKey:@"hasStreamInited"];
    
    _hasStreamInited = hasStreamInited;
    
    if (!hasStreamInited) {
        [self.tempGeomarks removeAllObjects];
    } else {
        NSMutableArray *toRemoveGeomarks = [[NSMutableArray alloc] init];
        
        for (EFRouteLocation *geomark in self.routeLocations) {
            BOOL needToRemove = YES;
            for (EFRouteLocation *temp in self.tempGeomarks) {
                if ([geomark.locationId isEqualToString:temp.locationId]) {
                    needToRemove = NO;
                    break;
                }
            }
            
            if (needToRemove) {
                [toRemoveGeomarks addObject:geomark];
            }
        }
        
        [self.delegate mapDataSource:self didGetRouteLocations:self.tempGeomarks];
        
        for (EFRouteLocation *toRemoveGeomark in toRemoveGeomarks) {
            [self.delegate mapDataSource:self needDeleteRouteLocation:toRemoveGeomark.locationId];
        }
    }
    
    [self didChangeValueForKey:@"hasStreamInited"];
}

#pragma mark - Notification Handler

- (void)handleLoadCrossSuccessNotification:(NSNotification *)notif {
    NSDictionary *userInfo = notif.userInfo;
    
    Meta *meta = (Meta *)[userInfo objectForKey:@"meta"];
    if ([meta.code intValue] == 403) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Privacy Control", nil)
                                                        message:NSLocalizedString(@"You have no access to this private ·X·.", nil)
                                                       delegate:self
                                              cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                              otherButtonTitles:nil];
        [alert show];
    } else if ([meta.code intValue] == 200) {
        Cross *cross = [userInfo objectForKey:@"response.cross"];
        self.cross = cross;
        
        [self _reloadPeople];
    }
}

- (void)handleLoadCrossFailureNotification:(NSNotification *)notif {
    
}

- (void)handleUserLocationChangeNotification:(NSNotification *)notif {
    EFMapPerson *me = [self me];
    me.connectState = kEFMapPersonConnectStateOnline;
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
                                                              if (path.positions.count >= 1) {
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

- (NSArray *)allPeople {
    return self.people;
}

#pragma mark - RouteLocation

- (void)addRouteLocation:(EFRouteLocation *)routeLocation toMapView:(MKMapView *)mapView canChangeType:(BOOL)canChangeType {
    NSParameterAssert(routeLocation);
    NSParameterAssert(mapView);
    
    if ([self routeLocationForRouteLocationId:routeLocation.locationId]) {
        [self updateRouteLocation:routeLocation inMapView:mapView shouldPostToServer:NO];
        return;
    }
    
    if (canChangeType) {
        EFRouteLocation *destination = self.destinationLocation;
        if (!destination) {
            routeLocation.locatinMask |= kEFRouteLocationMaskDestination;
            NSArray *tags = routeLocation.tags;
            if (tags) {
                NSMutableArray *newTags = [[NSMutableArray alloc] initWithArray:tags];
                if (NSNotFound == [tags indexOfObject:@"destination"]) {
                    [newTags addObject:@"destination"];
                }
                routeLocation.tags = newTags;
            } else {
                tags = @[@"destination"];
                routeLocation.tags = tags;
            }
        } else {
            routeLocation.locatinMask = kEFRouteLocationMaskNormal;
        }
    }
    
    EFAnnotationStyle annoationStyle = kEFAnnotationStyleMarkBlue;
    if (routeLocation.locatinMask & kEFRouteLocationMaskXPlace) {
        annoationStyle = kEFAnnotationStyleXPlace;
    } else if (routeLocation.locatinMask & kEFRouteLocationMaskDestination) {
        annoationStyle = kEFAnnotationStyleDestination;
    } else if (routeLocation.markColor == kEFRouteLocationColorRed) {
        annoationStyle = kEFAnnotationStyleMarkRed;
    }
    
    [self.routeLocations addObject:routeLocation];
    EFAnnotation *annotation = [[EFAnnotation alloc] initWithStyle:annoationStyle
                                                        coordinate:routeLocation.coordinate
                                                             title:routeLocation.title
                                                       description:routeLocation.subtitle];
    
    annotation.markTitle = routeLocation.markTitle;
    
    [self.routeLocationAnnotationMap setValue:annotation forKey:routeLocation.locationId];
    [mapView addAnnotation:annotation];
    
    for (EFMapPerson *person in self.people) {
        [self _updatePersonState:person];
    }
}

- (void)addRouteLocation:(EFRouteLocation *)routeLocation toMapView:(MKMapView *)mapView {
    [self addRouteLocation:routeLocation toMapView:mapView canChangeType:YES];
}

- (void)updateRouteLocation:(EFRouteLocation *)routeLocation inMapView:(MKMapView *)mapView shouldPostToServer:(BOOL)shouldPost {
    NSParameterAssert(routeLocation);
    NSParameterAssert(mapView);
    
    EFAnnotation *annotation = [self.routeLocationAnnotationMap objectForKey:routeLocation.locationId];
    annotation.coordinate = routeLocation.coordinate;
    annotation.title = routeLocation.title;
    annotation.subtitle = routeLocation.subtitle;
    
    EFAnnotationStyle annoationStyle = kEFAnnotationStyleMarkBlue;
    if (routeLocation.locatinMask & kEFRouteLocationMaskXPlace) {
        annoationStyle = kEFAnnotationStyleXPlace;
    } else if (routeLocation.locatinMask & kEFRouteLocationMaskDestination) {
        annoationStyle = kEFAnnotationStyleDestination;
    } else if (routeLocation.markColor == kEFRouteLocationColorRed) {
        annoationStyle = kEFAnnotationStyleMarkRed;
    }
    annotation.style = annoationStyle;
    
    EFRouteLocation *cachedRouteLocation = [self routeLocationForRouteLocationId:routeLocation.locationId];
    NSInteger cachedIndex = [self.routeLocations indexOfObject:cachedRouteLocation];
    [self.routeLocations replaceObjectAtIndex:cachedIndex withObject:routeLocation];
    
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
    
    for (EFMapPerson *person in self.people) {
        [self _updatePersonState:person];
    }
}

- (void)updateRouteLocation:(EFRouteLocation *)routeLocation inMapView:(MKMapView *)mapView {
    [self updateRouteLocation:routeLocation inMapView:mapView shouldPostToServer:YES];
}

- (EFRouteLocation *)routeLocationForAnnotation:(EFAnnotation *)annotation {
    NSParameterAssert(annotation);
    
    __block NSString *locationId = nil;
    [self.routeLocationAnnotationMap enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop){
        if (obj == annotation) {
            locationId = key;
            *stop = YES;
        }
    }];
    
    EFRouteLocation *routeLocation = nil;
    if (locationId) {
        routeLocation = [self routeLocationForRouteLocationId:locationId];
    }
    
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
    
    return [self.routeLocationAnnotationMap objectForKey:routeLocation.locationId];
}

- (void)removeRouteLocation:(EFRouteLocation *)routeLocation fromMapView:(MKMapView *)mapView {
    NSParameterAssert(routeLocation);
    NSParameterAssert(mapView);
    
    EFAnnotation *annotation = [self.routeLocationAnnotationMap valueForKey:routeLocation.locationId];
    [mapView removeAnnotation:annotation];
    [self.routeLocationAnnotationMap removeObjectForKey:routeLocation.locationId];
    [self.routeLocations removeObject:routeLocation];
    
    for (EFMapPerson *person in self.people) {
        [self _updatePersonState:person];
    }
    
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
    
    self.hasStreamInited = NO;
    
    RKObjectManager *objectManager = [RKObjectManager sharedManager];
    NSURL *baseURL = objectManager.HTTPClient.baseURL;
    
    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    NSString *userToken = delegate.model.userToken;
    
    NSInteger crossId = [self.cross.cross_id unsignedIntegerValue];
    NSURL *streamingURL = [NSURL URLWithString:[NSString stringWithFormat:@"/v3/routex/crosses/%d?_method=WATCH&coordinate=mars&token=%@", crossId, userToken] relativeToURL:baseURL];
    
#ifdef DEBUG
    NSLog(@"STREAMING: %@", streamingURL.absoluteString);
#endif
    
    self.httpStreaming = [[EFHTTPStreaming alloc] initWithURL:streamingURL];
    self.httpStreaming.delegate = self;
    [self.httpStreaming open];
}

- (void)closeStreaming {
    if (self.httpStreaming) {
        [self.httpStreaming close];
        self.httpStreaming = nil;
    }
    
    [self.toAddPeopleUserIdMap removeAllObjects];
    
    self.hasStreamInited = NO;
}

#pragma mark - Register

- (void)registerToUpdateLocation {
    EFAccessInfo *accessInfo = [[EFAccessInfo alloc] initWithCross:self.cross shouldSaveBreadcrumbs:YES];
    
    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [delegate.model.apiServer postRouteXAccessInfo:accessInfo
                                           inCross:self.cross
                                           success:nil
                                           failure:nil];
}

- (void)unregisterToUpdateLocation {
    EFAccessInfo *accessInfo = [[EFAccessInfo alloc] initWithCross:self.cross shouldSaveBreadcrumbs:NO];
    
    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [delegate.model.apiServer postRouteXAccessInfo:accessInfo
                                           inCross:self.cross
                                           success:nil
                                           failure:nil];
}

#pragma mark - Factory

- (EFRouteLocation *)createRouteLocationWithCoordinate:(CLLocationCoordinate2D)coordinate {
    EFRouteLocation *routelocation = [EFRouteLocation generateRouteLocationWithCoordinate:coordinate];
    routelocation.locationId = [self _generateRouteLocationId];
    
    routelocation.title = NSLocalizedString(@"这里", nil);
    routelocation.subtitle = @"";
    
    return routelocation;
}

- (void)changeXPlaceRouteLocationToNormalRouteLocaiton:(EFRouteLocation *)xplace {
    NSString *oldLocationId = xplace.locationId;
    NSString *newLocationId = [self _generateRouteLocationId];
    
    EFAnnotation *xplaceAnnotation = [self.routeLocationAnnotationMap valueForKey:oldLocationId];
    [self.routeLocationAnnotationMap setValue:xplaceAnnotation forKey:newLocationId];
    [self.routeLocationAnnotationMap removeObjectForKey:oldLocationId];
    
    xplace.locationId = newLocationId;
    xplace.locatinMask &= ~(kEFRouteLocationMaskXPlace | kEFRouteLocationMaskDestination);
    
    if (!xplace.markTitle || !xplace.markTitle.length) {
        xplace.markTitle = @"P";
    }
    
    NSMutableArray *tags = [[NSMutableArray alloc] initWithArray:xplace.tags];
    [tags removeObject:@"xplace"];
    [tags removeObject:@"destination"];
    xplace.tags = tags;
}

- (void)changeDestinationToNormalRouteLocation:(EFRouteLocation *)destination {
    destination.locatinMask &= ~(kEFRouteLocationMaskXPlace | kEFRouteLocationMaskDestination);
    
    if (!destination.markTitle || !destination.markTitle.length) {
        destination.markTitle = @"P";
    }
    
    NSMutableArray *tags = [[NSMutableArray alloc] initWithArray:destination.tags];
    [tags removeObject:@"xplace"];
    [tags removeObject:@"destination"];
    destination.tags = tags;
}

#pragma mark - Application Event

- (void)applicationDidEnterBackground {
    for (EFMapPerson *person in self.people) {
        [person.locations removeAllObjects];
        person.lastLocation = nil;
    }
    
    [self.toAddPeopleUserIdMap removeAllObjects];
}

- (void)applicationDidEnterForeground {
    [self registerToUpdateLocation];
    [self getPeopleBreadcrumbs];
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
                        
                        if (person) {
                            // update person last location
                            person.lastLocation = path.positions[0];
                            
                            
                            // update person connect state && location state && distance
                            [self _updatePersonState:person];
                            
                            if (person == [self me]) {
                                if ([EFLocationManager defaultManager].userLocation.location) {
                                    person.connectState = kEFMapPersonConnectStateOnline;
                                } else {
                                    person.connectState = kEFMapPersonConnectStateOffline;
                                }
                            }
                            
                            [self.delegate mapDataSource:self didUpdateLocations:path.positions forUser:person];
                        } else {
                            NSDate *timestamp = [self.toAddPeopleUserIdMap valueForKey:userIdString];
                            if (!timestamp) {
                                [self.toAddPeopleUserIdMap setValue:[NSDate date] forKey:userIdString];
                                
                                AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
                                [appDelegate.model loadCrossWithCrossId:[self.cross.cross_id intValue] updatedTime:nil];
                            }
                        }
                    }
                } else if ([tags[0] isEqualToString:@"geomarks"]) {
                    EFRoutePath *routePath = [[EFRoutePath alloc] initWithDictionary:jsonDictionary];
                    if ([self.delegate respondsToSelector:@selector(mapDataSource:didUpdateRoutePaths:)]) {
                        [self.delegate mapDataSource:self didUpdateRoutePaths:@[routePath]];
                    }
                }
            } else if ([type isEqualToString:@"location"]) {
                EFRouteLocation *routeLocation = [[EFRouteLocation alloc] initWithDictionary:jsonDictionary];
                
                if (self.hasStreamInited) {
                    if ([self.delegate respondsToSelector:@selector(mapDataSource:didUpdateRouteLocations:)]) {
                        [self.delegate mapDataSource:self didGetRouteLocations:@[routeLocation]];
                    }
                } else {
                    [self.tempGeomarks addObject:routeLocation];
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
            } else if ([action isEqualToString:@"init_end"]) {
                if ([type isEqualToString:@"command"]) {
                    self.hasStreamInited = YES;
                }
            } else if ([action isEqualToString:@"save_to_history"]) {
                if ([type isEqualToString:@"route"]) {
                    if ([tags[0] isEqualToString:@"breadcrumbs"]) {
                        EFRoutePath *path = [[EFRoutePath alloc] initWithDictionary:jsonDictionary];
                        if ([self.delegate respondsToSelector:@selector(mapDataSource:didUpdateLocations:forUser:)]) {
                            NSString *userIdString = [self _userIdFromDirtyUserId:path.pathId];
                            EFMapPerson *person = [self.peopleMap valueForKey:userIdString];
                            
                            if (person) {
                                // update person last location
                                person.lastLocation = path.positions[0];
                                
                                // update person connect state && location state && distance
                                [self _updatePersonState:person];
                                
                                [self.delegate mapDataSource:self didUpdateLocations:path.positions forUser:person];
                            } else {
                                NSDate *timestamp = [self.toAddPeopleUserIdMap valueForKey:userIdString];
                                if (!timestamp) {
                                    [self.toAddPeopleUserIdMap setValue:[NSDate date] forKey:userIdString];
                                    
                                    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
                                    [appDelegate.model loadCrossWithCrossId:[self.cross.cross_id intValue] updatedTime:nil];
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

- (void)streamingDidStartReconnecting {
    self.hasStreamInited = NO;
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
    
    EFLocation *lastLocation = person.lastLocation;
    NSArray *locations = person.locations;
    NSMutableArray *annotations = [[NSMutableArray alloc] init];
    
    EFLocation *preLocation = nil;
    
    if (kEFMapPersonConnectStateOnline != person.connectState) {
        EFTimestampAnnotation *firstTimestamp = [[EFTimestampAnnotation alloc] initWithCoordinate:lastLocation.coordinate
                                                                                        timestamp:lastLocation.timestamp];
        [annotations addObject:firstTimestamp];
    }
    
    preLocation = lastLocation;
    
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
