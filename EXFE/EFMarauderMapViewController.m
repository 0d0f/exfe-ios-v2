//
//  EFViewController.m
//  MarauderMap
//
//  Created by 0day on 13-7-3.
//  Copyright (c) 2013年 exfe. All rights reserved.
//

#import "EFMarauderMapViewController.h"

#import <QuartzCore/QuartzCore.h>
#import <BlocksKit/BlocksKit.h>
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
#import "EFMapPopMenu.h"
#import "EFLocationManager.h"
#import "EFUserLocationAnnotationView.h"

#define kAnnotationOffsetY  (-50.0f)
#define kShadowOffset       (3.0f)

@interface EFMarauderMapViewController ()

@property (nonatomic, strong) EFMarauderMapDataSource *mapDataSource;

@property (nonatomic, strong) NSMutableDictionary   *personDictionary;
@property (nonatomic, strong) MKAnnotationView      *meAnnotationView;
@property (nonatomic, strong) NSArray               *invitations;
@property (nonatomic, strong) NSMutableArray        *identityIds;

@property (nonatomic, strong) EFCalloutAnnotation   *currentCalloutAnnotation;

@property (nonatomic, strong) NSRecursiveLock       *lock;

@property (nonatomic) BOOL                          isEditing;
@property (nonatomic, assign) BOOL                  isInited;

@property (nonatomic, strong) EFLocation            *lastUpdatedLocation;
@property (nonatomic, strong) NSTimer               *updateLocationTimer;

@property (nonatomic, assign) BOOL                  hasGotOffset;

@property (nonatomic, weak)   UIImageView           *tableViewShadowView;

@end

@interface EFMarauderMapViewController (Private)

- (void)_hideCalloutView;

- (void)_openStreaming;
- (void)_closeStreaming;

- (void)_getRoute;
- (void)_postRoute;

- (void)_startTimer;
- (void)_stopTimer;

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
//    [self.model.apiServer getRouteWithCrossId:[self.cross.cross_id integerValue]
//                                      isEarth:NO
//                                      success:^(NSArray *routeLocations, NSArray *routePaths){
//                                          for (EFRouteLocation *routeLocation in routeLocations) {
//                                              [self.mapDataSource addRouteLocation:routeLocation toMapView:self.mapView];
//                                          }
//                                          dispatch_async(dispatch_get_main_queue(), ^{
//                                              [self.tableView reloadData];
//                                              [self.selfTableView reloadData];
//                                          });
//                                      }
//                                      failure:^(NSError *error){
//                                          NSLog(@"%@", error);
//                                      }];
}

- (void)_postRoute {
//#if 0 // test
//    [self.model.apiServer updateRouteWithCrossId:[self.cross.cross_id integerValue]
//                                       locations:nil
//                                          routes:nil
//                                         isEarth:NO
//                                         success:nil
//                                         failure:nil];
//#else
//    [self.model.apiServer updateRouteWithCrossId:[self.cross.cross_id integerValue]
//                                       locations:[self.mapDataSource allRouteLocations]
//                                          routes:@[self.demoRoutePath]
//                                         isEarth:NO
//                                         success:nil
//                                         failure:nil];
//#endif
}

- (void)_startTimer {
    [self _stopTimer];
    
    self.updateLocationTimer = [NSTimer scheduledTimerWithTimeInterval:5.0f
                                                                target:self
                                                              selector:@selector(timerRunloop:)
                                                              userInfo:nil
                                                               repeats:YES];
}

- (void)_stopTimer {
    if (self.updateLocationTimer) {
        [self.updateLocationTimer invalidate];
        self.updateLocationTimer = nil;
    }
}

@end

@implementation EFMarauderMapViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.personDictionary = [[NSMutableDictionary alloc] initWithCapacity:6];
        
        self.mapView.delegate = self;
        
        self.lock = [[NSRecursiveLock alloc] init];
        
        self.isInited = YES;
        self.hasGotOffset = NO;
    }
    
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    EFMapStrokeView *mapStrokeView = [[EFMapStrokeView alloc] initWithFrame:self.view.bounds];
    mapStrokeView.dataSource = self;
    mapStrokeView.mapView = self.mapView;
    mapStrokeView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self.view insertSubview:mapStrokeView belowSubview:self.leftBaseView];
    self.mapStrokeView = mapStrokeView;
    
    // tableView baseView
    self.leftBaseView.backgroundColor = [UIColor colorWithWhite:1.0f alpha:0.6f];
    
    // tableView gradient
    UIImageView *tableViewShadowView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"map_shadow_gap.png"]];
    tableViewShadowView.frame = (CGRect){CGPointZero, {CGRectGetWidth(self.tableView.frame), kShadowOffset}};
    tableViewShadowView.alpha = 0.0f;
    [self.tableView addSubview:tableViewShadowView];
    self.tableViewShadowView = tableViewShadowView;
    
    // long press gesture
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    longPress.delegate = self;
    [self.mapView addGestureRecognizer:longPress];
    
    self.mapDataSource = [[EFMarauderMapDataSource alloc] initWithCross:self.cross];
    self.mapDataSource.delegate = self;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(enterBackground)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(enterForeground)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];
}

- (void)enterBackground {
    [self _closeStreaming];
    [self _stopTimer];
}

- (void)enterForeground {
    [self _openStreaming];
    [self _startTimer];
}

- (void)viewDidUnload {
    [self setTableView:nil];
    [self setSelfTableView:nil];
    [self setLeftBaseView:nil];
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
    
    CGFloat height = self.invitations.count * [EFMapPersonCell defaultCellHeight];
    if (height + 100 > CGRectGetHeight(self.view.frame)) {
        height = CGRectGetHeight(self.view.frame) - 100.0f;
        self.tableView.scrollEnabled = YES;
    } else {
        self.tableView.scrollEnabled = NO;
    }
    
    self.leftBaseView.frame = (CGRect){{0.0f, 0.0f}, {50.0f, height}};
    
    [self.mapStrokeView reloadData];
    
    [self _openStreaming];
    
    [[EFLocationManager defaultManager] addObserver:self
                                         forKeyPath:@"userHeading"
                                            options:NSKeyValueObservingOptionNew
                                            context:NULL];
    
    if ([[EFLocationManager defaultManager] isFirstTimeToPostUserLocation]) {
#warning !!! 文本替换
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"第一次使用活点地图"
                                                            message:@"是否启用"
                                                           delegate:self
                                                  cancelButtonTitle:@"残忍的拒绝"
                                                  otherButtonTitles:@"欣然的接受", nil];
        [alertView show];
    } else {
        // register to update location
        [self.mapDataSource registerToUpdateLocation];
        [self.mapDataSource getPeopleBreadcrumbs];
    }
    
    [[EFLocationManager defaultManager] startUpdatingHeading];
}

- (void)viewWillDisappear:(BOOL)animated {
    [[EFLocationManager defaultManager] removeObserver:self
                                            forKeyPath:@"userHeading"];
    [[EFLocationManager defaultManager] stopUpdatingHeading];
    [self _closeStreaming];
    [self _stopTimer];
    
    [super viewDidDisappear:animated];
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (object == [EFLocationManager defaultManager] && [keyPath isEqualToString:@"userHeading"]) {
        if (self.mapView && self.mapView.userLocation) {
            EFUserLocationAnnotationView *userLocationView = (EFUserLocationAnnotationView *)[self.mapView viewForAnnotation:self.mapView.userLocation];
            if (userLocationView) {
                userLocationView.userHeading = [EFLocationManager defaultManager].userHeading;
            }
        }
    }
}

#pragma mark - UIAlertView

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == alertView.firstOtherButtonIndex) {
        // register to update location
        [self.mapDataSource registerToUpdateLocation];
        [self.mapDataSource getPeopleBreadcrumbs];
        
        // start updating location
        [[EFLocationManager defaultManager] startUpdatingLocation];
    } else {
        [self.tabBarViewController.tabBar setSelectedIndex:self.tabBarViewController.defaultIndex];
    }
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
            
            routeLocation = [self.mapDataSource createRouteLocationWithCoordinate:coordinate];
            
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
            
            routeLocation.coordinate = coordinate;
            [self.mapDataSource updateRouteLocation:routeLocation inMapView:self.mapView];
            
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

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == self.tableView) {
        return self.identityIds.count - 1;
    } else if (tableView == self.selfTableView) {
        return 1;
    }
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *Identitier = @"MapPersonCell";
    EFMapPersonCell *cell = (EFMapPersonCell *)[tableView dequeueReusableCellWithIdentifier:Identitier];
    if (!cell) {
        cell = [[EFMapPersonCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:Identitier];
    }
    
    EFMapPerson *person = nil;
    if (tableView == self.tableView) {
        person  = [self.mapDataSource personAtIndex:indexPath.row + 1];
    } else  if (tableView == self.selfTableView) {
        person = [self.mapDataSource me];
    }
    
    cell.person = person;
    return cell;
    
//    Invitation *invitation = nil;
//    NSString *identityId = nil;
//    
//    if (tableView == self.tableView) {
//        invitation = self.invitations[indexPath.row + 1];
//        identityId = self.identityIds[indexPath.row + 1];
//    } else {
//        invitation = self.invitations[0];
//        identityId = self.identityIds[0];
//    }
//    
//    Identity *identity = invitation.identity;
//    
//    EFMapPerson *person = [[EFMapPerson alloc] init];
//    person.avatarName = identity.avatar_filename;
//    
//    EFRouteLocation *destination = self.mapDataSource.destinationLocation;
//    
//    NSArray *userLocations = [self.personDictionary valueForKey:identityId];
//    if (userLocations && userLocations.count) {
//        EFLocation *latestLocation = userLocations[0];
//        NSTimeInterval timeInterval = [[NSDate date] timeIntervalSinceDate:latestLocation.timestamp];
//        
//        if (timeInterval >= 0.0f && timeInterval <= 60.0f) {
//            person.connectState = kEFMapPersonConnectStateOnline;
//        } else {
//            person.connectState = kEFMapPersonConnectStateOffline;
//        }
//        
//        if (destination) {
//            CLLocationCoordinate2D destinationCoordinate = destination.coordinate;
//            CLLocation *destinationLocation = [[CLLocation alloc] initWithLatitude:destinationCoordinate.latitude longitude:destinationCoordinate.longitude];
//            
//            CLLocationCoordinate2D latestCoordinate = latestLocation.coordinate;
//            CLLocation *latestCLLocation = [[CLLocation alloc] initWithLatitude:latestCoordinate.latitude longitude:latestCoordinate.longitude];
//            
//            CLLocationDistance distance = [destinationLocation distanceFromLocation:latestCLLocation];
//            if (distance < 30.0f) {
//                person.locationState = kEFMapPersonLocationStateArrival;
//            } else {
//                person.locationState = kEFMapPersonLocationStateOnTheWay;
//            }
//            person.distance = distance;
//            
//            CGFloat angle = HeadingInRadians(
//                                             destinationCoordinate.latitude,
//                                             destinationCoordinate.longitude,
//                                             latestCoordinate.latitude,
//                                             latestCoordinate.longitude);
//            person.angle = angle;
//        } else {
//            person.locationState = kEFMapPersonLocationStateOnTheWay;
//            person.distance = 0.0f;
//        }
//    } else {
//        person.locationState = kEFMapPersonLocationStateUnknow;
//        person.connectState = kEFMapPersonConnectStateOffline;
//    }
//    
//    cell.person = person;
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView == self.tableView) {
        CGRect originShadowFrame = self.tableViewShadowView.frame;
        originShadowFrame.origin.y = scrollView.contentOffset.y;
        self.tableViewShadowView.frame = originShadowFrame;
        
        CGFloat alpha = fabs(scrollView.contentOffset.y / 10.0f);
        self.tableViewShadowView.alpha = alpha > 1.0f ? 1.0f : alpha;
        
        [self.mapStrokeView reloadData];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.mapDataSource removeAllBreadcrumPathsToMapView:self.mapView];
    
    NSArray *locations = nil;
    EFMapPerson *person = nil;
    
    if (tableView == self.tableView) {
        person = [self.mapDataSource personAtIndex:indexPath.row + 1];
    } else if (tableView == self.selfTableView) {
        person = [self.mapDataSource me];
    }
    
    locations = person.locations;
    
    if (!locations || !locations.count) {
        return;
    }
    
    // add overlay
    [self.mapDataSource updateBreadcrumPathForPerson:person toMapView:self.mapView];
    
    EFLocation *lastLocation = (EFLocation *)locations[0];
    
    // center
    EFRouteLocation *destination = self.mapDataSource.destinationLocation;
    if (destination) {
        MKMapPoint lastMapPoint = MKMapPointForCoordinate(lastLocation.coordinate);
        MKMapPoint destinationMapPoint = MKMapPointForCoordinate(destination.coordinate);
        
        CGFloat width = fabs(lastMapPoint.x - destinationMapPoint.x);
        CGFloat height = fabsf(lastMapPoint.y - destinationMapPoint.y);
        CGFloat x = lastMapPoint.x - width * 2;
        CGFloat y = lastMapPoint.y - height * 2;
        
        MKMapRect visibleRect = MKMapRectMake(x, y, width * 4, height * 4);
        [self.mapView setVisibleMapRect:visibleRect animated:YES];
    } else {
        MKMapRect visibleMapRect = self.mapView.visibleMapRect;
        CGFloat width = visibleMapRect.size.width;
        if (fabsf(width) - 9800 >= 0 && fabsf(width) - 9800 <= 200) {
            [self.mapView setCenterCoordinate:lastLocation.coordinate animated:YES];
        } else {
            MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(lastLocation.coordinate, 5000.0f, 5000.0f);
            [self.mapView setRegion:region animated:YES];
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [EFMapPersonCell defaultCellHeight];
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager
	 didUpdateLocations:(NSArray *)locations {
    CLLocation *currentLocation = locations[0];
    
    EFLocation *position = [[EFLocation alloc] init];
    position.coordinate = currentLocation.coordinate;
    position.timestamp = [NSDate date];
    position.accuracy = currentLocation.horizontalAccuracy;
    
    self.lastUpdatedLocation = position;
    
    if (!self.updateLocationTimer) {
        [self _startTimer];
        [self timerRunloop:self.updateLocationTimer];
        
        while (!self.hasGotOffset) {
            [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                     beforeDate:[NSDate distantFuture]];
        }
        
        CLLocationCoordinate2D fixedCoordinate = [self.mapDataSource earthCoordinateToMarsCoordinate:manager.location.coordinate];
        if (self.isInited) {
            self.isInited = NO;
            
            MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(fixedCoordinate, 5000.0f, 5000.0f);
            [self.mapView setRegion:region animated:YES];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
                [self.selfTableView reloadData];
            });
        }
    }
}

#pragma mark - Timer Runloop

- (void)timerRunloop:(NSTimer *)timer {
//    [self.model.apiServer updateLocation:self.lastUpdatedLocation
//                             withCrossId:[self.cross.cross_id integerValue]
//                                 isEarth:YES
//                                 success:^(AFHTTPRequestOperation *operation, id responseObject){
//                                     CGFloat latitudeOffset = [[responseObject valueForKey:@"earth_to_mars_latitude"] doubleValue];
//                                     CGFloat longtitudeOffset = [[responseObject valueForKey:@"earth_to_mars_longitude"] doubleValue];
//                                     
//                                     CGPoint offset = (CGPoint){latitudeOffset, longtitudeOffset};
//                                     
//                                     self.mapDataSource.offset = offset;
//                                     self.hasGotOffset = YES;
//                                 }
//                                 failure:nil];
}

#pragma mark - EFMapStrokeViewDataSource

- (NSUInteger)numberOfStrokesForMapStrokeView:(EFMapStrokeView *)strokeView {
    NSInteger count = [self.mapDataSource numberOfPeople] - 1;
    count = count < 0 ? 0 : count;
    return count;
}

- (NSArray *)strokePointsForStrokeInMapStrokeView:(EFMapStrokeView *)strokeView atIndex:(NSUInteger)index {
    NSUInteger dataIndex = index + 1;
    
    EFMapPerson *person = [self.mapDataSource personAtIndex:dataIndex];
    EFLocation *lastLocation = person.lastLocation;
    
    if (lastLocation) {
        CLLocationCoordinate2D coordinate = lastLocation.coordinate;
        
        CGPoint locationInView = [self.mapView convertCoordinate:coordinate toPointToView:self.tableView];
        if (CGRectContainsPoint(self.tableView.bounds, locationInView)) {
            return nil;
        }
        
        EFLocation *location = [[EFLocation alloc] init];
        location.coordinate = coordinate;
        
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
        
        NSArray *visibleCells = [self.tableView visibleCells];
        if (NSNotFound == [visibleCells indexOfObject:cell]) {
            return nil;
        }
        
        CGPoint avatarCenter = cell.center;
        CLLocationCoordinate2D avatarCoordinate = [self.mapView convertPoint:avatarCenter toCoordinateFromView:self.tableView];
        EFLocation *avatarCenterLocation = [[EFLocation alloc] init];
        avatarCenterLocation.coordinate = avatarCoordinate;
        
        CGPoint avatarRight = (CGPoint){CGRectGetMaxX(cell.frame) + 5.0f, CGRectGetMidY(cell.frame)};
        CLLocationCoordinate2D avatarRightCoordinate = [self.mapView convertPoint:avatarRight toCoordinateFromView:self.tableView];
        EFLocation *avatarRightLocation = [[EFLocation alloc] init];
        avatarRightLocation.coordinate = avatarRightCoordinate;
        
        NSArray *points = @[avatarCenterLocation, avatarRightLocation, location];
        
        return points;
    }
    
    return nil;
}

- (UIColor *)colorForStrokeInMapStrokeView:(EFMapStrokeView *)strokeView atIndex:(NSUInteger)index {
    NSUInteger dataIndex = index + 1;
    
    EFMapPerson *person = [self.mapDataSource personAtIndex:dataIndex];
    
    if (kEFMapPersonConnectStateOnline == person.connectState) {
        return [UIColor COLOR_RGB(0xFF, 0x7E, 0x98)];
    } else {
        return [UIColor COLOR_RGB(0xB2, 0xB2, 0xB2)];
    }
}

#pragma mark - EFMarauderMapDataSourceDelegate

- (void)mapDataSource:(EFMarauderMapDataSource *)dataSource didUpdateLocations:(NSArray *)locations forUser:(EFMapPerson *)person {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.selfTableView reloadData];
        [self.tableView reloadData];
        [self.mapStrokeView reloadData];
        
        [self.mapDataSource updatePersonAnnotationForPerson:person toMapView:self.mapView];
    });
}

- (void)mapDataSource:(EFMarauderMapDataSource *)dataSource didUpdateRouteLocations:(NSArray *)locations {
    for (EFRouteLocation *routeLocation in locations) {
        [dataSource addRouteLocation:routeLocation toMapView:self.mapView];
    }
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
    }
}

- (void)mapViewHeadingButtonPressed:(EFMapView *)mapView {
    if (self.mapView.userLocation) {
        EFUserLocationAnnotationView *annotationView = (EFUserLocationAnnotationView *)[self.mapView viewForAnnotation:self.mapView.userLocation];
        if (annotationView) {
            [annotationView playAnimation];
        }
    }
}

#pragma mark - MKMapViewDelegate

- (void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated {
    self.mapStrokeView.hidden = YES;
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
    [self.mapStrokeView reloadData];
    self.mapStrokeView.hidden = NO;
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
    if (annotation ==  mapView.userLocation) {
        static NSString *Identifier = @"UserLocation";
        EFUserLocationAnnotationView *userLocationView = (EFUserLocationAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:Identifier];
        if (nil == userLocationView) {
            userLocationView = [[EFUserLocationAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:Identifier];
            userLocationView.image = [UIImage imageNamed:@"map_arrow_ring.png"];
            userLocationView.canShowCallout = NO;
        }
        
        return userLocationView;
    } else if ([annotation isKindOfClass:[EFAnnotation class]]) {
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
        } else if (view.annotation == mapView.userLocation) {
            CLHeading *userHeading = [EFLocationManager defaultManager].userHeading;
            if (userHeading) {
                CLLocationDirection direction = userHeading.trueHeading;
                view.layer.transform = CATransform3DMakeRotation((M_PI / 160.0f) * direction, 0.0f, 0.0f, 1.0f);
            }
        }
    }
}

- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id<MKOverlay>)overlay {
    EFCrumPathView *crumPathView = nil;
    
    crumPathView = [[EFCrumPathView alloc] initWithOverlay:overlay];
    
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
