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

#define kAnnotationOffsetY  (-50.0f)
#define kShadowOffset       (3.0f)

@interface EFMarauderMapViewController ()

@property (nonatomic, strong) EFMarauderMapDataSource *mapDataSource;

@property (nonatomic, strong) NSMutableDictionary   *personAnnotationDictionary;
@property (nonatomic, strong) NSMutableDictionary   *personDictionary;
@property (nonatomic, strong) MKAnnotationView      *meAnnotationView;
@property (nonatomic, strong) NSArray               *invitations;
@property (nonatomic, strong) NSMutableArray        *identityIds;

@property (nonatomic, strong) NSMutableArray        *demoPathPoints;
@property (nonatomic, strong) EFCrumPath            *demoOverlay;
@property (nonatomic, strong) EFRoutePath           *demoRoutePath;

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

- (BOOL)_isPersonOnline:(NSString *)identityId;

- (void)_initDemo;

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

- (BOOL)_isPersonOnline:(NSString *)identityId {
    NSArray *locations = [self.personDictionary valueForKey:identityId];
    
    if (locations) {
        EFLocation *lastestLocation = locations[0];
        NSDate *lastestingUpdateTime = lastestLocation.timestamp;
        NSTimeInterval timeInterval = [[NSDate date] timeIntervalSinceDate:lastestingUpdateTime];
        if (timeInterval <= 60.0f) {
            return YES;
        } else {
            return NO;
        }
    }
    
    return NO;
}

- (void)_initDemo {
    self.demoPathPoints = [[NSMutableArray alloc] init];
    EFLocation *destination = [[EFLocation alloc] init];
    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(23.114921, 113.328212);
    destination.coordinate = coordinate;
    [self.demoPathPoints addObject:destination];
    
    EFLocation *loction1 = [[EFLocation alloc] init];
    coordinate = CLLocationCoordinate2DMake(23.118915,113.328017);
    loction1.coordinate = coordinate;
    [self.demoPathPoints addObject:loction1];
    
    EFLocation *loction2 = [[EFLocation alloc] init];
    coordinate = CLLocationCoordinate2DMake(23.118602,113.332745);
    loction2.coordinate = coordinate;
    [self.demoPathPoints addObject:loction2];
    
    EFLocation *loction3 = [[EFLocation alloc] init];
    coordinate = CLLocationCoordinate2DMake(23.118511,113.333832);
    loction3.coordinate = coordinate;
    [self.demoPathPoints addObject:loction3];
    
    EFLocation *loction4 = [[EFLocation alloc] init];
    coordinate = CLLocationCoordinate2DMake(23.120837,113.333759);
    loction4.coordinate = coordinate;
    [self.demoPathPoints addObject:loction4];
    
    EFCrumPath *crumPath = [[EFCrumPath alloc] initWithMapPoints:self.demoPathPoints];
    crumPath.linecolor = [UIColor COLOR_RGB(0x00, 0x7B, 0xFF)];
    crumPath.lineWidth = 4.0f;
    crumPath.lineStyle = kEFMapLineStyleLine;
    
    self.demoOverlay = crumPath;
    
    self.demoRoutePath = [[EFRoutePath alloc] init];
    self.demoRoutePath.pathId = @"233";
    self.demoRoutePath.createdDate = [NSDate date];
    self.demoRoutePath.updatedDate = [NSDate date];
    self.demoRoutePath.createdByUid = @"cfddream@wechat";
    self.demoRoutePath.updatedByUid = @"cfddream@wechat";
    self.demoRoutePath.title = @"";
    self.demoRoutePath.description = @"";
    self.demoRoutePath.strokeColor = [UIColor COLOR_RGB(0x00, 0x7B, 0xFF)];
    self.demoRoutePath.positions = self.demoPathPoints;
    
    [self.mapView addOverlay:crumPath];
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
        
//        self.locationManager = [[CLLocationManager alloc] init];
//        self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
//        self.locationManager.delegate = self;
        
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
//    [self.locationManager stopUpdatingLocation];
}

- (void)enterForeground {
//    [self.locationManager startUpdatingLocation];
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
    [self _getRoute];
    
    if ([[EFLocationManager defaultManager] isFirstTimeToPostUserLocation]) {
#warning !!! 文本替换
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"第一次使用活点地图"
                                                            message:@"是否启用"
                                                           delegate:self
                                                  cancelButtonTitle:@"残忍的拒绝"
                                                  otherButtonTitles:@"欣然接受", nil];
        [alertView show];
    } else {
        // register to update location
        [self.mapDataSource registerToUpdateLocation];
    }
}

- (void)viewDidDisappear:(BOOL)animated {
//    [self.locationManager stopUpdatingLocation];
    [self _closeStreaming];
    [self _stopTimer];
    
    [super viewDidDisappear:animated];
}

#pragma mark - UIAlertView

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == alertView.firstOtherButtonIndex) {
        // register to update location
        [self.mapDataSource registerToUpdateLocation];
        
        // start updating location
        [[EFLocationManager defaultManager] startUpdatingLocation];
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
            
            routeLocation.coordinate = coordinate;
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
    
    Invitation *invitation = nil;
    NSString *identityId = nil;
    
    if (tableView == self.tableView) {
        invitation = self.invitations[indexPath.row + 1];
        identityId = self.identityIds[indexPath.row + 1];
    } else {
        invitation = self.invitations[0];
        identityId = self.identityIds[0];
    }
    
    Identity *identity = invitation.identity;
    
    EFMapPerson *person = [[EFMapPerson alloc] init];
    person.avatarName = identity.avatar_filename;
    
    EFRouteLocation *destination = self.mapDataSource.destinationLocation;
    
    NSArray *userLocations = [self.personDictionary valueForKey:identityId];
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
            if (distance < 30.0f) {
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
    if (self.personPathOverlayView.overlay) {
        [self.mapView removeOverlay:self.personPathOverlayView.overlay];
    }
    
    NSArray *locations = nil;
    
    if (tableView == self.tableView) {
        locations = [self.personDictionary valueForKey:self.identityIds[indexPath.row + 1]];
        
        /**
        EFMapPopMenu *popMenu = [[EFMapPopMenu alloc] initWithName:((Invitation *)self.invitations[indexPath.row + 1]).identity.name
                                                     pressedHanler:^(EFMapPopMenu *menu){
                                                         [self.model.apiServer getRouteXURLWithCrossId:[self.cross.cross_id integerValue]
                                                                                               success:^(NSString *url){
//                                                                                                   WXWebpageObject *webpageObject = [WXWebpageObject object];
//                                                                                                   webpageObject.webpageUrl = url;
//                                                                                                   
//                                                                                                   WXMediaMessage *mediaMessage = [WXMediaMessage message];
//                                                                                                   mediaMessage.title = @"请求更新方位";
//                                                                                                   mediaMessage.description = @"点我点我点我";
//                                                                                                   [mediaMessage setThumbImage:[UIImage imageNamed:@"Icon@2x.png"]];
//                                                                                                   mediaMessage.mediaObject = webpageObject;
//                                                                                                   
//                                                                                                   SendMessageToWXReq *message = [[SendMessageToWXReq alloc] init];
//                                                                                                   message.bText = YES;
//                                                                                                   message.text = url;
////                                                                                                   message.bText = NO;
////                                                                                                   message.message = mediaMessage;
//                                                                                                   [WXApi sendReq:message];
                                                                                                   
                                                                                                   [menu dismiss];
                                                                                               }
                                                                                               failure:^(NSError *error){
                                                                                                   [menu dismiss];
                                                                                               }];
                                                     }];
        [popMenu show];
         */
    } else if (tableView == self.selfTableView) {
        locations = [self.personDictionary valueForKey:self.identityIds[0]];
    }
    
    if (!locations || !locations.count)
        return;
    
    // add overlay
    
    EFCrumPath *path = [[EFCrumPath alloc] initWithMapPoints:locations];
    path.linecolor = [UIColor colorWithRed:1.0f
                                     green:(127.0f / 255.0f)
                                      blue:(153.0f / 255.0f)
                                     alpha:1.0f];
    path.lineStyle = kEFMapLineStyleDashedLine;
    [self.personOverlayMap setObject:@"YES" forKey:[NSValue valueWithNonretainedObject:path]];
    
    [self.mapView addOverlay:path];
    
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
    NSInteger count = self.identityIds.count - 1;
    count = count < 0 ? 0 : count;
    return count;
}

- (NSArray *)strokePointsForStrokeInMapStrokeView:(EFMapStrokeView *)strokeView atIndex:(NSUInteger)index {
    NSUInteger dataIndex = index + 1;
    
    NSString *key = self.identityIds[dataIndex];
    NSArray *locations = [self.personDictionary valueForKey:key];
    
    if (locations) {
        EFLocation *lastestLocation = locations[0];
        
        CLLocationCoordinate2D coordinate = lastestLocation.coordinate;
        
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
    
    NSString *key = self.identityIds[dataIndex];
    if ([self _isPersonOnline:key]) {
        return [UIColor COLOR_RGB(0xFF, 0x7E, 0x98)];
    } else {
        return [UIColor COLOR_RGB(0xB2, 0xB2, 0xB2)];
    }
}

#pragma mark - EFMarauderMapDataSourceDelegate

- (void)mapDataSource:(EFMarauderMapDataSource *)dataSource didUpdateLocations:(NSArray *)locations forUser:(NSString *)identityId {
    [self.personDictionary setValue:locations forKey:identityId];
    
    NSString *userIdentityId = self.identityIds[0];
    if ([identityId isEqualToString:userIdentityId]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
            [self.selfTableView reloadData];
        });
        return;
    }
    
    if (locations && locations.count) {
        @synchronized (self.personAnnotationDictionary) {
            EFPersonAnnotation *personAnnotation = [self.personAnnotationDictionary valueForKey:identityId];
            if (!personAnnotation) {
                personAnnotation = [[EFPersonAnnotation alloc] init];
                [self.personAnnotationDictionary setValue:personAnnotation forKey:identityId];
            }
            
            EFLocation *lastesLocation = locations[0];
            personAnnotation.coordinate = lastesLocation.coordinate;
            personAnnotation.isOnline = [self _isPersonOnline:identityId];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.mapView addAnnotation:personAnnotation];
                [self.tableView reloadData];
                [self.selfTableView reloadData];
            });
        }
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
    } else if (self.demoOverlay == overlay) {
        crumPathView = [[EFCrumPathView alloc] initWithOverlay:overlay];
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
