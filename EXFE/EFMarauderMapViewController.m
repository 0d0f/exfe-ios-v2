//
//  EFViewController.m
//  MarauderMap
//
//  Created by 0day on 13-7-3.
//  Copyright (c) 2013年 exfe. All rights reserved.
//

#import "EFMarauderMapViewController.h"

#import <QuartzCore/QuartzCore.h>
#import "EFMapPersonCell.h"
#import "EFMapColorButton.h"
#import "EFMapKit.h"
#import "EFAPI.h"
#import "Cross.h"
#import "Exfee+EXFE.h"
#import "Invitation+EXFE.h"
#import "EFDataManager+Image.h"
#import "IdentityId.h"
#import "Util.h"
#import "EFPersonAnnotation.h"
#import "EFPersonAnnotationView.h"

#define kAnnotationOffsetY  (-50.0f)

@interface EFMarauderMapViewController ()

@property (nonatomic, strong) EFMarauderMapDataSource *mapDataSource;

@property (nonatomic, strong) NSMutableDictionary   *personAnnotationDictionary;
@property (nonatomic, strong) NSMutableDictionary   *personDictionary;
@property (nonatomic, strong) MKAnnotationView      *meAnnotationView;
@property (nonatomic, strong) NSArray               *invitations;
@property (nonatomic, strong) NSMutableArray        *identityIds;

@property (nonatomic, strong) NSMutableDictionary   *personOverlayMap;
@property (nonatomic, strong) EFCrumPathView        *personPathOverlayView;

@property (nonatomic, strong) NSMutableDictionary   *personPositionOverlayMap;
@property (nonatomic, strong) NSMutableDictionary   *personPositionOverlayViewMap;

@property (nonatomic, strong) EFCalloutAnnotation   *currentCalloutAnnotation;

@property (nonatomic, strong) NSRecursiveLock       *lock;

@property (nonatomic) BOOL                          isEditing;
@property (nonatomic, assign) BOOL                  isInited;

@property (nonatomic, strong) EFLocation            *lastUpdatedLocation;
@property (nonatomic, strong) NSTimer               *updateLocationTimer;

@property (nonatomic, strong) NSTimer               *updateUITimer;

@end

@interface EFMarauderMapViewController (Private)

- (void)_hideCalloutView;

- (void)_openStreaming;
- (void)_closeStreaming;

- (void)_getRoute;
- (void)_postRoute;

- (void)_zoomWithLocations:(NSArray *)locations;

@end

@implementation EFMarauderMapViewController (Private)

- (void)_hideCalloutView {
    if (self.currentCalloutAnnotation) {
        [self.mapView removeAnnotation:self.currentCalloutAnnotation];
        self.currentCalloutAnnotation = nil;
    }
}

- (void)_openStreaming {
    [self.mapDataSource openStreaming];
}

- (void)_closeStreaming {
    [self.mapDataSource closeStreaming];
}

- (void)_getRoute {
    [self.model.apiServer getRouteWithCrossId:[self.cross.cross_id integerValue]
                                      success:^(NSArray *routeLocations, NSArray *routePaths){
                                          for (EFRouteLocation *routeLocation in routeLocations) {
                                              [self.mapDataSource addRouteLocation:routeLocation toMapView:self.mapView];
                                          }
                                          dispatch_async(dispatch_get_main_queue(), ^{
                                              [self.tableView reloadData];
                                          });
                                      }
                                      failure:^(NSError *error){
                                          NSLog(@"%@", error);
                                      }];
}

- (void)_postRoute {
#if 0 // test
    [self.model.apiServer updateRouteWithCrossId:[self.cross.cross_id integerValue]
                                       locations:nil
                                          routes:nil
                                         success:nil
                                         failure:nil];
#else
    [self.model.apiServer updateRouteWithCrossId:[self.cross.cross_id integerValue]
                                       locations:[self.mapDataSource allRouteLocations]
                                          routes:nil
                                         success:nil
                                         failure:nil];
#endif
}

- (void)_zoomWithLocations:(NSArray *)locations {
    
}

@end

@implementation EFMarauderMapViewController

double HeadingInRadians(double lat1, double lon1, double lat2, double lon2) {
	double dLon = lon2 - lon1;
	double y = sin(dLon) * cos(lat2);
	double x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon);
    
	return atan2(y, x);
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.personPositionOverlayMap = [[NSMutableDictionary alloc] initWithCapacity:6];
        self.personPositionOverlayViewMap = [[NSMutableDictionary alloc] initWithCapacity:6];
        self.personOverlayMap = [[NSMutableDictionary alloc] initWithCapacity:6];
        
        self.personAnnotationDictionary = [[NSMutableDictionary alloc] initWithCapacity:6];
        self.personDictionary = [[NSMutableDictionary alloc] initWithCapacity:6];
        
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
        self.locationManager.delegate = self;
        
        self.mapView.delegate = self;
        
        self.lock = [[NSRecursiveLock alloc] init];
        self.isInited = YES;
    }
    
    return self;
}

- (void)dealloc {
    if (self.updateLocationTimer) {
        [self.updateLocationTimer invalidate];
        self.updateLocationTimer = nil;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    EFMapStrokeView *mapStrokeView = [[EFMapStrokeView alloc] initWithFrame:self.view.bounds];
    mapStrokeView.dataSource = self;
    mapStrokeView.mapView = self.mapView;
    mapStrokeView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self.view insertSubview:mapStrokeView belowSubview:self.tableView];
    self.mapStrokeView = mapStrokeView;
    
    // tableView
    self.tableView.backgroundColor = [UIColor colorWithWhite:1.0f alpha:0.6f];
    
    // long press gesture
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    longPress.delegate = self;
    [self.mapView addGestureRecognizer:longPress];
    
    self.mapDataSource = [[EFMarauderMapDataSource alloc] initWithCrossId:[self.cross.cross_id integerValue]];
    self.mapDataSource.delegate = self;
    
    self.updateUITimer = [NSTimer scheduledTimerWithTimeInterval:0.02f
                                                          target:self
                                                        selector:@selector(uiTimerRunloop:)
                                                        userInfo:nil
                                                         repeats:YES];
}

- (void)viewDidUnload {
    [self setTableView:nil];
    
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.invitations = [self.cross.exfee getSortedInvitations:kInvitationSortTypeMeAcceptOthers];
    
    NSMutableArray *identityIds = [[NSMutableArray alloc] initWithCapacity:self.invitations.count];
    for (Invitation *invitation in self.invitations) {
        Identity *identity = invitation.identity;
        [identityIds addObject:[identity identityIdValue].identity_id];
    }
    
    self.identityIds = identityIds;
    
    self.tableView.frame = (CGRect){{0.0f, 0.0f}, {50.0f, self.invitations.count * [EFMapPersonCell defaultCellHeight]}};
    
    [self _getRoute];
    [self _openStreaming];
    
    [self.locationManager startUpdatingLocation];
}

- (void)viewDidDisappear:(BOOL)animated {
    [self.locationManager stopUpdatingLocation];
    [self _closeStreaming];
    
    [super viewDidDisappear:animated];
}

#pragma mark - Gesture

- (void)handleLongPress:(UILongPressGestureRecognizer *)gesture
{
    UIGestureRecognizerState state = gesture.state;
    
    CGPoint location = [gesture locationInView:self.mapView];
    location.y += kAnnotationOffsetY;
    CLLocationCoordinate2D coordinate = [self.mapView convertPoint:location toCoordinateFromView:self.mapView];
    
    static EFRouteLocation *routeLocation = nil;
    static EFAnnotation *annotation = nil;
    static CGPoint      startLocation;
    static CGPoint      lastLocation;
    
    switch (state) {
        case UIGestureRecognizerStateBegan:
        {
            startLocation = location;
            lastLocation = location;
            
            coordinate = [Util marsLocationFromEarthLocation:coordinate];
            
            routeLocation = [EFRouteLocation generateRouteLocationWithCoordinate:coordinate];
            routeLocation.title = @"子时正刻";
            routeLocation.subtitle = @"233 233";
            
            [self.mapDataSource addRouteLocation:routeLocation toMapView:self.mapView];
        }
            break;
        case UIGestureRecognizerStateChanged:
        {
            lastLocation = location;
            
            annotation = [self.mapDataSource annotationForRouteLocation:routeLocation];
            EFAnnotationView *view = (EFAnnotationView *)[self.mapView viewForAnnotation:annotation];
            CATransform3D newTransform = CATransform3DMakeTranslation(location.x - startLocation.x, location.y - startLocation.y, 0.0f);
            view.layer.transform = newTransform;
        }
            break;
        case UIGestureRecognizerStateEnded:
        {
            annotation = [self.mapDataSource annotationForRouteLocation:routeLocation];
            EFAnnotationView *view = (EFAnnotationView *)[self.mapView viewForAnnotation:annotation];
            view.layer.transform = CATransform3DIdentity;
            
            coordinate = [self.mapView convertPoint:lastLocation toCoordinateFromView:self.mapView];
            
            routeLocation.coordinate = [Util marsLocationFromEarthLocation:coordinate];
            [self.mapDataSource updateRouteLocation:routeLocation inMapView:self.mapView];
            [self _postRoute];
            
            [self.mapView selectAnnotation:annotation animated:NO];
        }
            break;
        default:
            break;
    }
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    CGPoint location = [touch locationInView:self.mapView];
    if (CGRectContainsPoint(self.mapView.operationBaseView.frame, location)) {
        return NO;
    }
    
    return YES;
}

#pragma mark -

MKMapRect MKMapRectForCoordinateRegion(MKCoordinateRegion region) {
    MKMapPoint a = MKMapPointForCoordinate(CLLocationCoordinate2DMake(
                                                                      region.center.latitude + region.span.latitudeDelta / 2,
                                                                      region.center.longitude - region.span.longitudeDelta / 2));
    MKMapPoint b = MKMapPointForCoordinate(CLLocationCoordinate2DMake(
                                                                      region.center.latitude - region.span.latitudeDelta / 2,
                                                                      region.center.longitude + region.span.longitudeDelta / 2));
    return MKMapRectMake(MIN(a.x, b.x), MIN(a.y, b.y), ABS(a.x - b.x), ABS(a.y - b.y));
}

#pragma mark - Update

//- (void)updateOverlay {
//    return;
//    
//    static BOOL isUpdating = NO;
//    if (isUpdating)
//        return;
//    isUpdating = YES;
//    
//    [self.lock lock];
//    
//    NSUInteger count = self.dataSource.peopleCount;
//    for (int i = 0; i < count; i++) {
//        EFMapPerson *person = [self.dataSource personAtIndex:i];
//        EFCrumPathView *overlayView = [self.personPositionOverlayViewMap objectForKey:[NSValue valueWithNonretainedObject:person]];
//        
//        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
//        CGRect cellFrame = cell.frame;
//        CGPoint rightPoint = (CGPoint){CGRectGetMaxX(cellFrame) + 10.0f, CGRectGetMidY(cellFrame)};
//        
//        CLLocationCoordinate2D coordinate = [self.mapView convertPoint:rightPoint toCoordinateFromView:self.tableView];
//        EFMapPoint *point = [[EFMapPoint alloc] init];
//        point.coordinate2D = coordinate;
//        
//        if (!overlayView) {
//            EFMapPoint *positionPoint = [person.pathMapPoints lastObject];
//            EFCrumPath *overlay = [[EFCrumPath alloc] initWithMapPoints:@[point, positionPoint]];
//            [self.personPositionOverlayMap setObject:[NSValue valueWithNonretainedObject:person] forKey:[NSValue valueWithNonretainedObject:overlay]];
//            [self.mapView addOverlay:overlay];
//        } else {
//            [((EFCrumPath *)overlayView.overlay) replaceMapPointAtIndex:0 withMapPoint:point];
//            [overlayView setNeedsDisplayInMapRect:MKMapRectWorld];
//        }
//    }
//    
//    [self.lock unlock];
//    
//    isUpdating = NO;
//}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.invitations.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *Identitier = @"MapPersonCell";
    EFMapPersonCell *cell = (EFMapPersonCell *)[tableView dequeueReusableCellWithIdentifier:Identitier];
    if (!cell) {
        cell = [[EFMapPersonCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:Identitier];
    }
    
    Invitation *invitation = self.invitations[indexPath.row];
    Identity *identity = invitation.identity;
    
    UIImage *avatar = [[EFDataManager imageManager] cachedImageInMemoryForKey:identity.avatar_filename];
    if (!avatar) {
        avatar = [UIImage imageNamed:@"portrait_default.png"];
        
        [[EFDataManager imageManager] cachedImageForKey:identity.avatar_filename
                                        completeHandler:^(UIImage *image){
                                            if (image) {
                                                [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
                                            }
                                        }];
    }
    
    EFMapPerson *person = [[EFMapPerson alloc] init];
    person.avatarImage = avatar;
    
    EFRouteLocation *destination = self.mapDataSource.destinationLocation;
    
    NSArray *userLocations = [self.personDictionary valueForKey:self.identityIds[indexPath.row]];
    if (userLocations && userLocations.count) {
        EFLocation *latestLocation = userLocations[0];
        NSTimeInterval timeInterval = [[NSDate date] timeIntervalSinceDate:latestLocation.timestamp];
        
        if (timeInterval >= 0.0f && timeInterval <= 60.0f) {
            person.connectState = kEFMapPersonConnectStateOnline;
        } else {
            person.connectState = kEFMapPersonConnectStateOffline;
        }
        
        if (destination) {
            CLLocationCoordinate2D destinationCoordinate = destination.coordinate;
            CLLocation *destinationLocation = [[CLLocation alloc] initWithLatitude:destinationCoordinate.latitude longitude:destinationCoordinate.longitude];
            
            CLLocationCoordinate2D latestCoordinate = latestLocation.coordinate;
            CLLocation *latestCLLocation = [[CLLocation alloc] initWithLatitude:latestCoordinate.latitude longitude:latestCoordinate.longitude];
            
            CLLocationDistance distance = [destinationLocation distanceFromLocation:latestCLLocation];
            if (distance < 50.0f) {
                person.locationState = kEFMapPersonLocationStateArrival;
            } else {
                person.locationState = kEFMapPersonLocationStateOnTheWay;
            }
            person.distance = distance;
            
            CGFloat angle = HeadingInRadians(
                                             destinationCoordinate.latitude,
                                             destinationCoordinate.longitude,
                                             latestCoordinate.latitude,
                                             latestCoordinate.longitude);
            person.angle = angle;
        } else {
            person.locationState = kEFMapPersonLocationStateOnTheWay;
            person.distance = 0.0f;
        }
    } else {
        person.locationState = kEFMapPersonLocationStateUnknow;
        person.connectState = kEFMapPersonConnectStateOffline;
    }
    
    cell.person = person;
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.personPathOverlayView.overlay) {
        [self.mapView removeOverlay:self.personPathOverlayView.overlay];
    }
    
    NSArray *locations = [self.personDictionary valueForKey:self.identityIds[indexPath.row]];
    if (!locations || !locations.count)
        return;
    EFCrumPath *path = [[EFCrumPath alloc] initWithMapPoints:locations];
    path.linecolor = [UIColor colorWithRed:1.0f
                                     green:(127.0f / 255.0f)
                                      blue:(153.0f / 255.0f)
                                     alpha:1.0f];
    path.lineStyle = kEFMapLineStyleDashedLine;
    [self.personOverlayMap setObject:@"YES" forKey:[NSValue valueWithNonretainedObject:path]];
    
    [self.mapView addOverlay:path];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [EFMapPersonCell defaultCellHeight];
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager
	 didUpdateLocations:(NSArray *)locations {
    CLLocation *currentLocation = locations[0];
    
    CLLocationCoordinate2D fixedCoordinate = [Util earthLocationFromMarsLocation:currentLocation.coordinate];
    if (self.isInited) {
        self.isInited = NO;
        
        MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(fixedCoordinate, 5000.0f, 5000.0f);
        [self.mapView setRegion:region animated:YES];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
    }
    
    EFLocation *position = [[EFLocation alloc] init];
    position.coordinate = fixedCoordinate;
    position.timestamp = [NSDate date];
    position.accuracy = currentLocation.horizontalAccuracy;
    
    self.lastUpdatedLocation = position;
    
    if (!self.updateLocationTimer) {
        self.updateLocationTimer = [NSTimer scheduledTimerWithTimeInterval:5.0f
                                                      target:self
                                                    selector:@selector(timerRunloop:)
                                                    userInfo:nil
                                                     repeats:YES];
        [self timerRunloop:self.updateLocationTimer];
    }
}

#pragma mark - Timer Runloop

- (void)timerRunloop:(NSTimer *)timer {
    [self.model.apiServer updateLocation:self.lastUpdatedLocation
                             withCrossId:[self.cross.cross_id integerValue]
                                 success:nil
                                 failure:nil];
}

- (void)uiTimerRunloop:(NSTimer *)timer {
    static MKMapRect preMapRect;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        preMapRect = self.mapView.visibleMapRect;
    });
    
    if (!MKMapRectEqualToRect(preMapRect, self.mapView.visibleMapRect)) {
        preMapRect = self.mapView.visibleMapRect;
        [self.mapStrokeView reloadData];
    }
}

#pragma mark - EFMapStrokeViewDataSource

- (NSUInteger)numberOfStrokesForMapStrokeView:(EFMapStrokeView *)strokeView {
    return self.invitations.count;
}

- (NSArray *)strokePointsForStrokeInMapStrokeView:(EFMapStrokeView *)strokeView atIndex:(NSUInteger)index {
    NSString *key = self.identityIds[index];
    NSArray *locations = [self.personDictionary valueForKey:key];
    
    if (locations) {
        EFLocation *lastestLocation = locations[0];
        
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
        CGPoint avatarCenter = cell.center;
        CLLocationCoordinate2D avatarCoordinate = [self.mapView convertPoint:avatarCenter toCoordinateFromView:self.tableView];
        EFLocation *avatarCenterLocation = [[EFLocation alloc] init];
        avatarCenterLocation.coordinate = avatarCoordinate;
        
        CGPoint avatarRight = (CGPoint){CGRectGetMaxX(cell.frame) + 5.0f, CGRectGetMidY(cell.frame)};
        CLLocationCoordinate2D avatarRightCoordinate = [self.mapView convertPoint:avatarRight toCoordinateFromView:self.tableView];
        EFLocation *avatarRightLocation = [[EFLocation alloc] init];
        avatarRightLocation.coordinate = avatarRightCoordinate;
        
        NSArray *points = @[avatarCenterLocation, avatarRightLocation, lastestLocation];
        
        return points;
    }
    
    return nil;
}

#pragma mark - EFMarauderMapDataSourceDelegate

- (void)mapDataSource:(EFMarauderMapDataSource *)dataSource didUpdateLocations:(NSArray *)locations forUser:(IdentityId *)identityId {
    [self.personDictionary setValue:locations forKey:identityId.identity_id];
    
    if (locations && locations.count) {
        EFPersonAnnotation *personAnnotation = [self.personAnnotationDictionary valueForKey:identityId.identity_id];
        if (!personAnnotation) {
            personAnnotation = [[EFPersonAnnotation alloc] init];
            [self.personAnnotationDictionary setValue:personAnnotation forKey:identityId.identity_id];
        }

        EFLocation *lastesLocation = locations[0];
        personAnnotation.coordinate = lastesLocation.coordinate;
        NSTimeInterval timeInterval = [[NSDate date] timeIntervalSinceDate:lastesLocation.timestamp];
        if (timeInterval >= 0 && timeInterval <= 60) {
            personAnnotation.isOnline = YES;
        } else {
            personAnnotation.isOnline = NO;
        }

        dispatch_async(dispatch_get_main_queue(), ^{
            [self.mapView addAnnotation:personAnnotation];
            [self.tableView reloadData];
        });
    }
}

- (void)mapDataSource:(EFMarauderMapDataSource *)dataSource didUpdateRouteLocations:(NSArray *)locations {
    
}

- (void)mapDataSource:(EFMarauderMapDataSource *)dataSource didUpdateRoutePaths:(NSArray *)paths {

}

#pragma mark - EFMapViewDelegate

- (void)mapView:(EFMapView *)mapView isChangingSelectedAnnotationTitle:(NSString *)title {
    EFCalloutAnnotationView *calloutView = (EFCalloutAnnotationView *)[self.mapView viewForAnnotation:self.currentCalloutAnnotation];
    EFAnnotation *annotation = calloutView.parentAnnotationView.annotation;
    EFRouteLocation *routeLocation = [self.mapDataSource routeLocationForAnnotation:annotation];
    routeLocation.markTitle = title;
    
    [self.mapDataSource updateRouteLocation:routeLocation inMapView:self.mapView];
}

- (void)mapView:(EFMapView *)mapView didChangeSelectedAnnotationTitle:(NSString *)title {
    EFCalloutAnnotationView *calloutView = (EFCalloutAnnotationView *)[self.mapView viewForAnnotation:self.currentCalloutAnnotation];
    EFAnnotation *annotation = calloutView.parentAnnotationView.annotation;
    EFRouteLocation *routeLocation = [self.mapDataSource routeLocationForAnnotation:annotation];
    routeLocation.markTitle = title;
    [routeLocation updateIconURL];
    
    [self.mapDataSource updateRouteLocation:routeLocation inMapView:self.mapView];
    [self _postRoute];
}

- (void)mapView:(EFMapView *)mapView didChangeSelectedAnnotationStyle:(EFAnnotationStyle)style {
    EFCalloutAnnotationView *calloutView = (EFCalloutAnnotationView *)[self.mapView viewForAnnotation:self.currentCalloutAnnotation];
    EFAnnotation *annotation = calloutView.parentAnnotationView.annotation;
    EFRouteLocation *routeLocation = [self.mapDataSource routeLocationForAnnotation:annotation];
    
    if (kEFAnnotationStyleDestination) {
        routeLocation.locationTytpe = kEFRouteLocationTypeDestination;
    } else {
        routeLocation.locationTytpe = kEFRouteLocationTypePark;
        if (kEFAnnotationStyleParkRed == style) {
            routeLocation.markColor = kEFRouteLocationColorRed;
        } else {
            routeLocation.markColor = kEFRouteLocationColorBlue;
        }
    }
    
    [routeLocation updateIconURL];
    
    [self.mapDataSource updateRouteLocation:routeLocation inMapView:self.mapView];
    [self _postRoute];
}

- (void)mapViewCancelButtonPressed:(EFMapView *)mapView {
    if (mapView.editingState == kEFMapViewEditingStateEditingAnnotation) {
        EFCalloutAnnotationView *calloutView = (EFCalloutAnnotationView *)[self.mapView viewForAnnotation:self.currentCalloutAnnotation];
        EFAnnotation *annotation = calloutView.parentAnnotationView.annotation;
        EFRouteLocation *routeLocation = [self.mapDataSource routeLocationForAnnotation:annotation];
        
        [self.mapDataSource removeRouteLocation:routeLocation fromMapView:self.mapView];
        [self _postRoute];
    }
}

#pragma mark - MKMapViewDelegate

- (void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated {
//    if (self.updateUITimer) {
//        [self.updateUITimer invalidate];
//        self.updateUITimer = nil;
//    }
//    self.updateUITimer = [NSTimer scheduledTimerWithTimeInterval:0.02f
//                                                          target:self
//                                                        selector:@selector(uiTimerRunloop:)
//                                                        userInfo:nil
//                                                         repeats:YES];
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
//    if (self.updateUITimer) {
//        [self.updateUITimer invalidate];
//        self.updateUITimer = nil;
//    }
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
    if ([view isKindOfClass:[EFAnnotationView class]]) {
        [mapView setCenterCoordinate:view.annotation.coordinate animated:YES];
        
        [self _hideCalloutView];
        
        EFCalloutAnnotation *calloutAnnotation = [[EFCalloutAnnotation alloc] initWithCoordinate:view.annotation.coordinate
                                                                                           title:view.annotation.title
                                                                                        subtitle:view.annotation.subtitle];
        [mapView addAnnotation:calloutAnnotation];
        
        self.currentCalloutAnnotation = calloutAnnotation;
        self.mapView.editingState = kEFMapViewEditingStateEditingAnnotation;
    }
}

- (void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view {
    [self _hideCalloutView];
    self.mapView.editingState = kEFMapViewEditingStateNormal;
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    if ([annotation isKindOfClass:[EFAnnotation class]]) {
        static NSString *Identifier = @"Location";
        
        EFAnnotationView *annotationView = (EFAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:Identifier];
        if (nil == annotationView) {
            annotationView = [[EFAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:Identifier];
            annotationView.canShowCallout = NO;
            annotationView.mapView = self.mapView;
        }
        
        [annotationView reloadWithAnnotation:annotation];
        
        return annotationView;
    } else if ([annotation isKindOfClass:[EFCalloutAnnotation class]]) {
        static NSString *Identifier = @"Callout";
        
        EFCalloutAnnotationView *callout = (EFCalloutAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:Identifier];
        if (nil == callout) {
            callout = [[EFCalloutAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:Identifier];
            callout.mapView = mapView;
        }
        
        callout.parentAnnotationView = [mapView viewForAnnotation:mapView.selectedAnnotations[0]];
        
        __weak typeof(callout) weakCallout = callout;
        callout.titlePressedHandler = ^{
            [weakCallout setEditing:!weakCallout.isEditing animated:YES];
        };
        
        callout.subtitlePressedHandler = ^{
            [weakCallout setEditing:!weakCallout.isEditing animated:YES];
        };
        
        callout.editingDidEndHandler = ^(EFCalloutAnnotationView *calloutView){
            EFAnnotation *annotation = (EFAnnotation *)calloutView.parentAnnotationView.annotation;
            EFRouteLocation *routeLocation = [self.mapDataSource routeLocationForAnnotation:annotation];
            routeLocation.title = calloutView.annotation.title;
            routeLocation.subtitle = calloutView.annotation.subtitle;
            [routeLocation updateIconURL];
            
            [self.mapDataSource updateRouteLocation:routeLocation inMapView:self.mapView];
            [self _postRoute];
        };
        
        return callout;
    } else if ([annotation isKindOfClass:[EFPersonAnnotation class]]) {
        static NSString *Identifier = @"Person";
        
        EFPersonAnnotationView *personAnnotationView = (EFPersonAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:Identifier];
        if (nil == personAnnotationView) {
            personAnnotationView = [[EFPersonAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:Identifier];
            personAnnotationView.canShowCallout = NO;
        }
        personAnnotationView.annotation = annotation;
        
        return personAnnotationView;
    }
    
    return nil;
}

- (void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)annotationViews {
    for (MKAnnotationView *view in annotationViews) {
        if ([view isKindOfClass:[EFAnnotationView class]]) {
            CATransform3D newTransform = CATransform3DMakeTranslation(0.0f, -CGRectGetHeight(self.view.frame), 0.0f);
            CABasicAnimation *dropAnimation = [CABasicAnimation animationWithKeyPath:@"transform"];
            dropAnimation.fromValue = [NSValue valueWithCATransform3D:newTransform];
            dropAnimation.toValue = [NSValue valueWithCATransform3D:CATransform3DIdentity];
            dropAnimation.duration = 0.233f;
            dropAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
            [view.layer addAnimation:dropAnimation forKey:nil];
        }
    }
}

- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id<MKOverlay>)overlay {
    EFCrumPathView *crumPathView = nil;
    
    if ([self.personOverlayMap objectForKey:[NSValue valueWithNonretainedObject:overlay]]) {
        self.personPathOverlayView = [[EFCrumPathView alloc] initWithOverlay:overlay];
        crumPathView = self.personPathOverlayView;
    } else if ([self.personPositionOverlayMap objectForKey:[NSValue valueWithNonretainedObject:overlay]]) {
        NSValue *value = [self.personPositionOverlayMap objectForKey:[NSValue valueWithNonretainedObject:overlay]];
        crumPathView = [self.personPositionOverlayViewMap objectForKey:value];
        if (!crumPathView) {
            crumPathView = [[EFCrumPathView alloc] initWithOverlay:overlay];
            [self.personPositionOverlayViewMap setObject:crumPathView forKey:value];
        }
    }
    
    return crumPathView;
}

#pragma mark - Private

#pragma mark - Action

- (IBAction)parkButtonPressed:(id)sender {
    if (kEFMapViewEditingStateEditingPath != self.mapView.editingState) {
        self.mapView.editingState = kEFMapViewEditingStateEditingPath;
    } else {
        self.mapView.editingState = kEFMapViewEditingStateNormal;
    }
}

- (IBAction)headingButtonPressed:(id)sender {
    if (self.mapView.userTrackingMode == MKUserTrackingModeFollowWithHeading) {
        [self.mapView setUserTrackingMode:MKUserTrackingModeNone animated:YES];
    } else {
        [self.mapView setUserTrackingMode:MKUserTrackingModeFollowWithHeading animated:YES];
    }
}

- (IBAction)cleanButtonPressed:(id)sender {
//    [self.mapEditView clean];
}

@end
