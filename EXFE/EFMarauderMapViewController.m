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
#import "EFTimestampAnnotation.h"
#import "EFTimestampAnnotationView.h"

#define kAnnotationOffsetY  (-50.0f)
#define kShadowOffset       (3.0f)

@interface EFMarauderMapViewController ()

@property (nonatomic, strong) EFMarauderMapDataSource *mapDataSource;

@property (nonatomic, strong) EFCalloutAnnotation   *currentCalloutAnnotation;

@property (nonatomic) BOOL                          isEditing;
@property (nonatomic, assign) BOOL                  isInited;

@property (nonatomic, strong) NSTimer               *breadcrumbUpdateTimer;

@property (nonatomic, assign) NSTimeInterval        annotationAnimationDelay;

@property (nonatomic, weak)   UIImageView           *tableViewShadowView;
@property (nonatomic, assign) BOOL                  isMapBeenMoved;

@property (nonatomic, assign) BOOL                  hasGotOffset;

@property (nonatomic, assign) CLLocationCoordinate2D firstUserLocationCoordinate;

@property (nonatomic, weak)   EFMapPerson           *recentZoomedPerson;
@property (nonatomic, assign) EFMapZoomType         mapZoomType;

@property (nonatomic, strong) EFGeomarkGroupViewController  *geomarkGroupViewController;

@end

@interface EFMarauderMapViewController (Private)

- (void)_hideCalloutView;

- (void)_fireBreadcrumbUpdateTimer;
- (void)_invalidBreadcrumbUpdateTimer;

- (void)_zoomToPerson:(EFMapPerson *)person;
- (void)_zoomToPersonLocation:(EFMapPerson *)person;

@end

@implementation EFMarauderMapViewController (Private)

- (void)_hideCalloutView {
    if (self.currentCalloutAnnotation) {
        [self.mapView removeAnnotation:self.currentCalloutAnnotation];
        self.currentCalloutAnnotation = nil;
    }
}

- (void)_fireBreadcrumbUpdateTimer {
    [self _invalidBreadcrumbUpdateTimer];
    self.breadcrumbUpdateTimer = [NSTimer scheduledTimerWithTimeInterval:60.0f
                                                                  target:self
                                                                selector:@selector(breadcrumbTimerRunloop:)
                                                                userInfo:nil
                                                                 repeats:YES];
}

- (void)_invalidBreadcrumbUpdateTimer {
    if (self.breadcrumbUpdateTimer) {
        if ([self.breadcrumbUpdateTimer isValid]) {
            [self.breadcrumbUpdateTimer invalidate];
        }
        self.breadcrumbUpdateTimer = nil;
    }
}

- (void)_zoomToPerson:(EFMapPerson *)person {
    self.mapZoomType = kEFMapZoomTypePersonAndDestination;
    
    // center
    EFRouteLocation *destination = self.mapDataSource.destinationLocation;
    BOOL isMe = (person == [self.mapDataSource me]);
    CLLocationCoordinate2D coordinate = isMe ? [EFLocationManager defaultManager].userLocation.coordinate : person.lastLocation.coordinate;
    
    if (destination) {
        MKMapPoint lastMapPoint = MKMapPointForCoordinate(coordinate);
        MKMapPoint destinationMapPoint = MKMapPointForCoordinate(destination.coordinate);
        
        if (isMe) {
            CGFloat width = fabs(lastMapPoint.x - destinationMapPoint.x);
            CGFloat height = fabs(lastMapPoint.y - destinationMapPoint.y);
            
            CGFloat factor = 0.45f;
            CGFloat widthOffset = width * factor;
            CGFloat heightOffset = height * factor;
            
            CGFloat x = lastMapPoint.x - (1.4f * widthOffset + width);
            CGFloat y = lastMapPoint.y - (heightOffset + height);
            
            MKMapRect visibleRect = MKMapRectMake(x, y, (width + widthOffset) * 2, (height + heightOffset) * 2);
            [self.mapView setVisibleMapRect:visibleRect animated:YES];
        } else {
            CGFloat width = fabs(lastMapPoint.x - destinationMapPoint.x);
            CGFloat height = fabs(lastMapPoint.y - destinationMapPoint.y);
            
            CGFloat factor = 0.35f;
            CGFloat widthOffset = width * factor;
            CGFloat heightOffset = height * factor;
            
            CGFloat x = MIN(lastMapPoint.x, destinationMapPoint.x) - (1.3f * widthOffset);
            CGFloat y = MIN(lastMapPoint.y, destinationMapPoint.y) - heightOffset;
            
            MKMapRect visibleRect = MKMapRectMake(x, y, width + widthOffset * 2, height + heightOffset * 2);
            [self.mapView setVisibleMapRect:visibleRect animated:YES];
        }
    } else {
        int zoomLevel = self.mapView.zoomLevel;
        
        if (zoomLevel >= 15) {
            [self.mapView setCenterCoordinate:coordinate animated:YES];
        } else {
            [self.mapView setCenterCoordinate:coordinate zoomLevel:15 animated:YES];
        }
    }
}

- (void)_zoomToPersonLocation:(EFMapPerson *)person {
    self.mapZoomType = kEFMapZoomTypePersonLocation;
    
    BOOL isMe = (person == [self.mapDataSource me]);
    CLLocationCoordinate2D coordinate = isMe ? [EFLocationManager defaultManager].userLocation.coordinate : person.lastLocation.coordinate;
    [self.mapView setCenterCoordinate:coordinate zoomLevel:17 animated:YES];
}

@end

@implementation EFMarauderMapViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.isInited = YES;
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
    
    self.mapView.delegate = self;
    
    // tableView baseView
    self.leftBaseView.backgroundColor = [UIColor colorWithWhite:1.0f alpha:0.88f];
    
    // shape layer
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    shapeLayer.path = [[UIBezierPath bezierPathWithRoundedRect:self.leftBaseView.bounds byRoundingCorners:UIRectCornerBottomRight cornerRadii:(CGSize){4.0f, 4.0f}] CGPath];
    self.leftBaseView.layer.mask = shapeLayer;
    
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
    
    self.annotationAnimationDelay = 0.233f;
    
    self.hasGotOffset = NO;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(enterBackground)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(enterForeground)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(userLocationDidChange)
                                                 name:EFNotificationUserLocationDidChange
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(userLocationOffsetDidGet)
                                                 name:EFNotificationUserLocationOffsetDidGet
                                               object:nil];
}

- (void)viewDidUnload {
    [self setTableView:nil];
    [self setSelfTableView:nil];
    [self setLeftBaseView:nil];
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    CGFloat height = [self.mapDataSource numberOfPeople] * [EFMapPersonCell defaultCellHeight];
    if (height + 100 > CGRectGetHeight(self.view.frame)) {
        height = CGRectGetHeight(self.view.frame) - 100.0f;
        self.tableView.scrollEnabled = YES;
    } else {
        self.tableView.scrollEnabled = NO;
    }
    
    self.leftBaseView.frame = (CGRect){{0.0f, 0.0f}, {50.0f, height}};
    CAShapeLayer *shapeLayer = (CAShapeLayer *)self.leftBaseView.layer.mask;
    shapeLayer.path = [[UIBezierPath bezierPathWithRoundedRect:self.leftBaseView.bounds byRoundingCorners:UIRectCornerBottomRight cornerRadii:(CGSize){4.0f, 4.0f}] CGPath];;
    
    [self.mapStrokeView reloadData];
    
    [self.mapDataSource openStreaming];
    
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
    
    [[EFLocationManager defaultManager] addObserver:self
                                         forKeyPath:@"userHeading"
                                            options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
                                            context:NULL];
    
    if ([EFLocationManager defaultManager].userLocation) {
        [self userLocationDidChange];
    }
    [self _fireBreadcrumbUpdateTimer];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self _zoomToPerson:[self.mapDataSource me]];
    self.recentZoomedPerson = [self.mapDataSource me];
}

- (void)viewWillDisappear:(BOOL)animated {
    [[EFLocationManager defaultManager] removeObserver:self
                                            forKeyPath:@"userHeading"];
    [[EFLocationManager defaultManager] stopUpdatingHeading];
    [self.mapDataSource closeStreaming];
    
    [self _invalidBreadcrumbUpdateTimer];
    
    if (self.geomarkGroupViewController) {
        [self.geomarkGroupViewController dismissAnimated:NO];
    }
    
    [super viewDidDisappear:animated];
}

#pragma mark - Notification Handler

- (void)enterBackground {
    [self _invalidBreadcrumbUpdateTimer];
    [self.mapDataSource closeStreaming];
    [self.mapDataSource applicationDidEnterBackground];
}

- (void)enterForeground {
    [self.mapDataSource openStreaming];
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
        [self.mapDataSource applicationDidEnterForeground];
    }
    
    if ([EFLocationManager defaultManager].userLocation) {
        [self userLocationDidChange];
    }
    [self _fireBreadcrumbUpdateTimer];
}

- (void)userLocationDidChange {
    EFUserLocationAnnotationView *locationView = (EFUserLocationAnnotationView *)[self.mapView viewForAnnotation:[EFLocationManager defaultManager].userLocation];
    CLLocationCoordinate2D latestCoordinate = [EFLocationManager defaultManager].userLocation.coordinate;
    CGPoint latestPoint = [self.mapView convertCoordinate:latestCoordinate toPointToView:self.mapView];
    
    if (locationView) {
        if (CLLocationCoordinate2DIsValid(self.firstUserLocationCoordinate)) {
            CGPoint firstPoint = [self.mapView convertCoordinate:self.firstUserLocationCoordinate toPointToView:self.mapView];
            
            CATransform3D newTransform = CATransform3DMakeTranslation(latestPoint.x - firstPoint.x, latestPoint.y - firstPoint.y, 0.0f);
            
            CABasicAnimation *translationAnimation = [CABasicAnimation animationWithKeyPath:@"transform"];
            translationAnimation.fromValue = [locationView.layer valueForKey:@"transform"];
            translationAnimation.toValue = [NSValue valueWithCATransform3D:newTransform];
            translationAnimation.duration = 0.233f;
            translationAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
            translationAnimation.fillMode = kCAFillModeForwards;
            
            [locationView.layer addAnimation:translationAnimation forKey:@"translation"];
            locationView.layer.transform = newTransform;
        }
    } else {
        [self.mapView addAnnotation:[EFLocationManager defaultManager].userLocation];
    }
}

- (void)userLocationOffsetDidGet {
    if (!self.hasGotOffset) {
        self.hasGotOffset = YES;
        
        CLLocationCoordinate2D userCoordinate = [EFLocationManager defaultManager].userLocation.coordinate;
        [self.mapView setCenterCoordinate:userCoordinate animated:YES];
        self.firstUserLocationCoordinate = userCoordinate;
        
        [self userLocationDidChange];
    }
}

#pragma mark - Timer

- (void)breadcrumbTimerRunloop:(NSTimer *)timer {
    if (self.mapDataSource.selectedPerson) {
        // timestamp
        [self.mapDataSource updateTimestampForPerson:self.mapDataSource.selectedPerson toMapView:self.mapView];
    }
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (object == [EFLocationManager defaultManager]) {
        if ([keyPath isEqualToString:@"userHeading"]) {
            if (self.mapView && [EFLocationManager defaultManager].userLocation) {
                EFUserLocationAnnotationView *userLocationView = (EFUserLocationAnnotationView *)[self.mapView viewForAnnotation:[EFLocationManager defaultManager].userLocation];
                if (userLocationView) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        userLocationView.userHeading = [EFLocationManager defaultManager].userHeading;
                    });
                }
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
            
            [self.mapView selectAnnotation:annotation animated:YES];
            
            CLLocation *location = [[CLLocation alloc] initWithLatitude:coordinate.latitude longitude:coordinate.longitude];
            CLGeocoder *geocoder = [[CLGeocoder alloc] init];
            [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *geomarks, NSError *error){
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (geomarks && geomarks.count) {
                        CLPlacemark *placemark = geomarks[0];
                        routeLocation.title = placemark.name;
                        routeLocation.subtitle = [placemark.addressDictionary valueForKey:@"FormattedAddressLines"][0];
                        
                        [self.mapDataSource updateRouteLocation:routeLocation inMapView:self.mapView];
                        
                        if (self.mapView.selectedAnnotations) {
                            id<MKAnnotation> selectedAnnoation = self.mapView.selectedAnnotations[0];
                            if (selectedAnnoation == annotation) {
                                [self.mapView deselectAnnotation:annotation animated:NO];
                                [self.mapView selectAnnotation:annotation animated:NO];
                            }
                        }
                    } else {
                        NSLog(@"%@", error);
                    }
                });
            }];
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
        return [self.mapDataSource numberOfPeople] - 1;
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
    self.mapDataSource.selectedPerson = person;
    
    if (!locations || !locations.count) {
        return;
    }
    
    // update overlay
    [self.mapDataSource updateBreadcrumPathForPerson:person toMapView:self.mapView];
    
    // timestamp
    [self.mapDataSource updateTimestampForPerson:person toMapView:self.mapView];
    
    if (self.recentZoomedPerson == person) {
        if (kEFMapZoomTypePersonAndDestination == self.mapZoomType) {
            [self _zoomToPersonLocation:person];
        } else {
            [self _zoomToPerson:person];
        }
    } else {
        [self _zoomToPerson:person];
        self.recentZoomedPerson = person;
    }
    
    [self _fireBreadcrumbUpdateTimer];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [EFMapPersonCell defaultCellHeight];
}

#pragma mark - EFGeomarkGroupViewControllerDelegate

- (void)geomarkGroupViewController:(EFGeomarkGroupViewController *)controller didSelectRouteLocation:(EFRouteLocation *)routeLocation {
    [controller dismissAnimated:YES];
    
    EFAnnotation *annotation = [self.mapDataSource annotationForRouteLocation:routeLocation];
    NSAssert(annotation != nil, @"The annotation MUST be there.");
    
    [self.mapView selectAnnotation:annotation animated:YES];
}

- (void)geomarkGroupViewController:(EFGeomarkGroupViewController *)controller didSelectPerson:(EFMapPerson *)person {
    [controller dismissAnimated:YES];
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

- (void)mapView:(EFMapView *)mapView tappedAtCoordinate:(CLLocationCoordinate2D)coordinate {
    CGPoint tapLocation = [mapView convertCoordinate:coordinate toPointToView:self.mapView];
    
    EFGeomarkGroupViewController *geomarkGroupViewController = [[EFGeomarkGroupViewController alloc] initWithGeomarks:[self.mapDataSource allRouteLocations]
                                                                                                            andPeople:[self.mapDataSource allPeople]];
    geomarkGroupViewController.delegate = self;
    [geomarkGroupViewController presentFromViewController:self
                                              tapLocation:tapLocation
                                                 animated:YES];
    self.geomarkGroupViewController = geomarkGroupViewController;
}

- (void)mapDataSource:(EFMarauderMapDataSource *)dataSource didGetRouteLocations:(NSArray *)locations {
    for (EFRouteLocation *routeLocation in locations) {
        double delayInSeconds = self.annotationAnimationDelay;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [dataSource addRouteLocation:routeLocation toMapView:self.mapView];
            
            if ([EFLocationManager defaultManager].userLocation) {
                EFRouteLocation *destination = self.mapDataSource.destinationLocation;
                EFUserLocationAnnotationView *userLocationView = (EFUserLocationAnnotationView *)[self.mapView viewForAnnotation:[EFLocationManager defaultManager].userLocation];
                if (userLocationView) {
                    if (destination) {
                        userLocationView.showNavigation = YES;
                        CGFloat radian = HeadingInRadian(destination.coordinate, [EFLocationManager defaultManager].userLocation.coordinate);
                        userLocationView.radianBetweenDestination = radian;
                    } else {
                        userLocationView.showNavigation = NO;
                    }
                }
            }
        });
        self.annotationAnimationDelay += 0.233f;
    }
}

- (void)mapDataSource:(EFMarauderMapDataSource *)dataSource didUpdateLocations:(NSArray *)locations forUser:(EFMapPerson *)person {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.selfTableView reloadData];
        [self.tableView reloadData];
        [self.mapStrokeView reloadData];
        
        if (person != [self.mapDataSource me]) {
            [self.mapDataSource updatePersonAnnotationForPerson:person toMapView:self.mapView];
        }
        if (person == self.mapDataSource.selectedPerson) {
            [self.mapDataSource updateBreadcrumPathForPerson:person toMapView:self.mapView];
        }
    });
}

- (void)mapDataSource:(EFMarauderMapDataSource *)dataSource didUpdateRouteLocations:(NSArray *)locations {
    for (EFRouteLocation *routeLocation in locations) {
        [dataSource addRouteLocation:routeLocation toMapView:self.mapView];
    }
    
    if ([EFLocationManager defaultManager].userLocation) {
        EFRouteLocation *destination = self.mapDataSource.destinationLocation;
        EFUserLocationAnnotationView *userLocationView = (EFUserLocationAnnotationView *)[self.mapView viewForAnnotation:[EFLocationManager defaultManager].userLocation];
        if (userLocationView) {
            if (destination) {
                userLocationView.showNavigation = YES;
                CGFloat radian = HeadingInRadian(destination.coordinate, [EFLocationManager defaultManager].userLocation.coordinate);
                userLocationView.radianBetweenDestination = radian;
            } else {
                userLocationView.showNavigation = NO;
            }
        }
    }
}

- (void)mapDataSource:(EFMarauderMapDataSource *)dataSource didUpdateRoutePaths:(NSArray *)paths {
    
}

- (void)mapDataSource:(EFMarauderMapDataSource *)dataSource needDeleteRouteLocation:(NSString *)routeLocationId {
    EFRouteLocation *routeLocation = [dataSource routeLocationForRouteLocationId:routeLocationId];
    if (routeLocation) {
        [dataSource removeRouteLocation:routeLocation fromMapView:self.mapView];
    }
    
    if ([EFLocationManager defaultManager].userLocation) {
        EFRouteLocation *destination = self.mapDataSource.destinationLocation;
        EFUserLocationAnnotationView *userLocationView = (EFUserLocationAnnotationView *)[self.mapView viewForAnnotation:[EFLocationManager defaultManager].userLocation];
        if (userLocationView) {
            if (destination) {
                userLocationView.showNavigation = YES;
                CGFloat radian = HeadingInRadian(destination.coordinate, [EFLocationManager defaultManager].userLocation.coordinate);
                userLocationView.radianBetweenDestination = radian;
            } else {
                userLocationView.showNavigation = NO;
            }
        }
    }
}

- (void)mapDataSource:(EFMarauderMapDataSource *)dataSource routeLocationDidGetGeomarkInfo:(EFRouteLocation *)routeLocation {
    [self.mapDataSource updateRouteLocation:routeLocation inMapView:self.mapView];
}

#pragma mark - EFMapViewDelegate

- (void)mapViewDidScroll:(EFMapView *)mapView {
    self.mapZoomType = kEFMapZoomTypeUnknow;
}

- (void)mapView:(EFMapView *)mapView isChangingSelectedAnnotationTitle:(NSString *)title {
    EFCalloutAnnotationView *calloutView = (EFCalloutAnnotationView *)[self.mapView viewForAnnotation:self.currentCalloutAnnotation];
    EFAnnotation *annotation = calloutView.parentAnnotationView.annotation;
    EFRouteLocation *routeLocation = [self.mapDataSource routeLocationForAnnotation:annotation];
    routeLocation.markTitle = title;
    
    [self.mapDataSource updateRouteLocation:routeLocation inMapView:self.mapView shouldPostToServer:NO];
}

- (void)mapView:(EFMapView *)mapView didChangeSelectedAnnotationTitle:(NSString *)title {
    EFCalloutAnnotationView *calloutView = (EFCalloutAnnotationView *)[self.mapView viewForAnnotation:self.currentCalloutAnnotation];
    EFAnnotation *annotation = calloutView.parentAnnotationView.annotation;
    EFRouteLocation *routeLocation = [self.mapDataSource routeLocationForAnnotation:annotation];
    routeLocation.markTitle = title;
    [routeLocation updateIconURL];
    
    [self.mapDataSource updateRouteLocation:routeLocation inMapView:self.mapView];
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
    EFMapPerson *me = [self.mapDataSource me];
    
    if (self.recentZoomedPerson == me) {
        if (kEFMapZoomTypePersonAndDestination == self.mapZoomType) {
            [self _zoomToPersonLocation:me];
        } else {
            [self _zoomToPerson:me];
        }
    } else {
        [self _zoomToPerson:me];
        self.recentZoomedPerson = me;
    }
}

#pragma mark - MKMapViewDelegate

- (void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated {
    self.mapStrokeView.hidden = YES;
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
    if (self.mapDataSource.selectedPerson) {
        [self.mapDataSource updateTimestampForPerson:self.mapDataSource.selectedPerson toMapView:mapView];
    }
    
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
    if (annotation ==  [EFLocationManager defaultManager].userLocation) {
        static NSString *Identifier = @"UserLocation";
        EFUserLocationAnnotationView *userLocationView = (EFUserLocationAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:Identifier];
        if (nil == userLocationView) {
            userLocationView = [[EFUserLocationAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:Identifier];
            userLocationView.canShowCallout = NO;
        }
        
        userLocationView.annotation = annotation;
        
        EFRouteLocation *destination = self.mapDataSource.destinationLocation;
        if (destination) {
            userLocationView.showNavigation = YES;
            CGFloat radian = HeadingInRadian(destination.coordinate, [EFLocationManager defaultManager].userLocation.coordinate);
            userLocationView.radianBetweenDestination = radian;
        } else {
            userLocationView.showNavigation = NO;
        }
        
        return userLocationView;
    } else if ([annotation isKindOfClass:[EFAnnotation class]]) {
        static NSString *Identifier = @"Location";
        
        EFAnnotationView *annotationView = (EFAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:Identifier];
        if (nil == annotationView) {
            annotationView = [[EFAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:Identifier];
            annotationView.canShowCallout = NO;
            annotationView.mapView = self.mapView;
            annotationView.mapDataSource = self.mapDataSource;
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
        callout.tapHandler = ^{
            [weakCallout setEditing:!weakCallout.isEditing animated:YES];
        };
        
        callout.editingDidEndHandler = ^(EFCalloutAnnotationView *calloutView){
            EFAnnotation *annotation = (EFAnnotation *)calloutView.parentAnnotationView.annotation;
            EFRouteLocation *routeLocation = [self.mapDataSource routeLocationForAnnotation:annotation];
            routeLocation.title = calloutView.annotation.title;
            routeLocation.subtitle = calloutView.annotation.subtitle;
            [routeLocation updateIconURL];
            
            [self.mapDataSource updateRouteLocation:routeLocation inMapView:self.mapView];
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
    } else if ([annotation isKindOfClass:[EFTimestampAnnotation class]]) {
        static NSString *Identifier = @"Timestamp";
        
        EFTimestampAnnotationView *timestampAnnotationView = (EFTimestampAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:Identifier];
        if (nil == timestampAnnotationView) {
            timestampAnnotationView = [[EFTimestampAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:Identifier];
        }
        
        timestampAnnotationView.annotation = annotation;
        
        return timestampAnnotationView;
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
            dropAnimation.fillMode = kCAFillModeForwards;
            [view.layer addAnimation:dropAnimation forKey:nil];
        } else if (view.annotation == [EFLocationManager defaultManager].userLocation) {
            CLHeading *userHeading = [EFLocationManager defaultManager].userHeading;
            if (userHeading) {
                ((EFUserLocationAnnotationView *)view).userHeading = userHeading;
            }
        }
    }
    
    EFUserLocationAnnotationView *userLocationView = (EFUserLocationAnnotationView *)[mapView viewForAnnotation:[EFLocationManager defaultManager].userLocation];
    if (userLocationView) {
        [userLocationView.superview bringSubviewToFront:userLocationView];
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
