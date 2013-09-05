//
//  EFRouteXViewController.m
//
//  Created by 0day on 13-7-3.
//  Copyright (c) 2013年 exfe. All rights reserved.
//

#import "EFRouteXViewController.h"

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
#import "Util.h"
#import "WXApi.h"
#import "CCTemplate.h"

#define kAnnotationOffsetY  (-50.0f)
#define kShadowOffset       (3.0f)
#define kTapRectHalfWidth   (24.0f)

@interface EFRouteXViewController ()

@property (nonatomic, readonly)     Cross                   *cross;
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
@property (nonatomic, strong) EFMapPersonViewController     *personViewController;
@property (nonatomic, strong) EFRouteXAccessViewController  *accessViewController;

@property (nonatomic, strong) UIAlertView           *backgroundAlertView;
@property (nonatomic, strong) UIAlertView           *noGPSAlertView;

@end

@interface EFRouteXViewController (Private)

- (BOOL)_isRouteXAvalibleForThisCorss;
- (BOOL)_isUserHiddenForThisCross;
- (void)_checkRouteXStatus;
- (void)_startUpdating;

- (void)_hideCalloutView;
- (void)_layoutAnnotationView;

- (void)_fireBreadcrumbUpdateTimer;
- (void)_invalidBreadcrumbUpdateTimer;

- (void)_zoomToPerson:(EFMapPerson *)person;
- (void)_zoomToPersonLocation:(EFMapPerson *)person;

- (void)_jumpToWeixinWithURL:(NSString *)url;

- (void)_refreshTableViewFrame;

@end

@implementation EFRouteXViewController (Private)

- (BOOL)_isRouteXAvalibleForThisCorss {
    NSArray *widgets = self.cross.widget;
    for (NSDictionary *widget in widgets) {
        NSString *type = [widget valueForKey:@"type"];
        
        if ([type isEqualToString:@"routex"]) {
            NSNumber *status = [widget valueForKey:@"my_status"];
            if ((NSNull *)status == [NSNull null]) {
                return NO;
            } else {
                return YES;
            }
        }
    }
    
    return NO;
}

- (BOOL)_isUserHiddenForThisCross {
    NSArray *widgets = self.cross.widget;
    for (NSDictionary *widget in widgets) {
        NSString *type = [widget valueForKey:@"type"];
        
        if ([type isEqualToString:@"routex"]) {
            NSNumber *status = [widget valueForKey:@"my_status"];
            if ([status boolValue]) {
                return YES;
            } else {
                return NO;
            }
        }
    }
    
    return NO;
}

- (void)_addRouteXStatuesWithStatus:(BOOL)status {
    NSMutableArray *widgets = [[NSMutableArray alloc] initWithArray:self.cross.widget];
    NSDictionary *widget = @{@"type": @"routex", @"my_status": [NSNumber numberWithBool:status]};
    [widgets addObject:widget];
    self.cross.widget = widgets;
    
    __weak typeof(self) weakSelf = self;
    [self.model.objectManager.managedObjectStore.mainQueueManagedObjectContext performBlock:^{
        [weakSelf.model.objectManager.managedObjectStore.mainQueueManagedObjectContext saveToPersistentStore:nil];
    }];
}

- (void)_startUpdating {
//    [self.mapDataSource registerToUpdateLocation];
    [self.mapDataSource getPeopleBreadcrumbs];
    
    [self.mapDataSource openStreaming];
    
    // start updating location
    [[EFLocationManager defaultManager] startUpdatingLocation];
    [[EFLocationManager defaultManager] startUpdatingHeading];
    
    if ([EFLocationManager defaultManager].userLocation.location) {
        [self performSelector:@selector(userLocationDidChange)];
    }
    [self _fireBreadcrumbUpdateTimer];
}

- (void)_checkRouteXStatus {
    if (![EFLocationManager locationServicesEnabled]) {
        if (!self.noGPSAlertView) {
            self.noGPSAlertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Location unavailable", nil)
                                                             message:[NSLocalizedString(@"Please proceed to “Settings” app » Privacy » Location Service,\nthen turn it on for “{{PRODUCT_APP_NAME}}”.", nil) templateFromDict:[Util keywordDict]]
                                                            delegate:self
                                                   cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                                   otherButtonTitles:nil];
            [self.noGPSAlertView show];
        }
    } else {
        if ([self _isRouteXAvalibleForThisCorss]) {
            [self _startUpdating];
        } else {
            if (!self.backgroundAlertView) {
                self.backgroundAlertView  = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Open this RouteX page", nil)
                                                                       message:NSLocalizedString(@"This RouteX page will show your location in 1 hour.", nil)
                                                                      delegate:self
                                                             cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
                                                             otherButtonTitles:NSLocalizedString(@"OK", nil), nil];
                [self.backgroundAlertView show];
            }
        }
    }
}

- (void)_hideCalloutView {
    if (self.currentCalloutAnnotation) {
        [self.mapView removeAnnotation:self.currentCalloutAnnotation];
        self.currentCalloutAnnotation = nil;
    }
}

- (void)_layoutAnnotationView {
    for (id<MKAnnotation> annotation in self.mapView.annotations) {
        MKAnnotationView *view = [self.mapView viewForAnnotation:annotation];
        
        if ([view isKindOfClass:[EFCalloutAnnotationView class]]) {
            UIView *superView = view.superview;
            [superView bringSubviewToFront:view];
            break;
        }
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

- (void)_jumpToWeixinWithURL:(NSString *)url {
    if (url) {
        SendMessageToWXReq *message = [[SendMessageToWXReq alloc] init];
        message.bText = YES;
        message.text = [NSString stringWithFormat:NSLocalizedString(@"Where r u?\n%@", nil), url];
        message.scene = WXSceneSession;
        
        [WXApi sendReq:message];
    }
}

- (void)_refreshTableViewFrame {
    CGFloat height = [self.mapDataSource numberOfPeople] * [EFMapPersonCell defaultCellHeight] + 4.0f;
    if (height + 100 > CGRectGetHeight(self.view.frame)) {
        height = CGRectGetHeight(self.view.frame) - 100.0f;
        self.tableView.scrollEnabled = YES;
    } else {
        self.tableView.scrollEnabled = NO;
    }
    
    self.leftBaseView.frame = (CGRect){{0.0f, 0.0f}, {50.0f, height}};
    CAShapeLayer *shapeLayer = (CAShapeLayer *)self.leftBaseView.layer.mask;
    shapeLayer.path = [[UIBezierPath bezierPathWithRoundedRect:self.leftBaseView.bounds byRoundingCorners:UIRectCornerBottomRight cornerRadii:(CGSize){4.0f, 4.0f}] CGPath];;
}

@end

@implementation EFRouteXViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.isInited = YES;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
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
}

- (void)viewDidUnload {
    [self setTableView:nil];
    [self setSelfTableView:nil];
    [self setLeftBaseView:nil];
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self _refreshTableViewFrame];
    
    [self.mapStrokeView reloadData];
    
    [[EFLocationManager defaultManager] addObserver:self
                                         forKeyPath:@"userHeading"
                                            options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
                                            context:NULL];
    
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

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self _checkRouteXStatus];
}

- (void)viewWillDisappear:(BOOL)animated {
    [[EFLocationManager defaultManager] removeObserver:self
                                            forKeyPath:@"userHeading"];
    [[EFLocationManager defaultManager] stopUpdatingHeading];
    [self.mapDataSource closeStreaming];
    
    [self _invalidBreadcrumbUpdateTimer];
    
    if (![[EFLocationManager defaultManager] canPostUserLocationInBackground]) {
        [[EFLocationManager defaultManager] stopUpdatingLocation];
    }
    
    if (self.geomarkGroupViewController) {
        [self.geomarkGroupViewController dismissAnimated:NO];
    }
    
    if (self.personViewController) {
        [self.personViewController dismissAnimated:NO];
    }
    
    if (self.accessViewController) {
        [self.accessViewController.view removeFromSuperview];
    }
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [super viewWillDisappear:animated];
}

#pragma mark -

- (Cross *)cross {
    return self.tabBarViewController.cross;
}

#pragma mark - Notification Handler

- (void)enterBackground {
    [self _invalidBreadcrumbUpdateTimer];
    [self.mapDataSource closeStreaming];
    [self.mapDataSource applicationDidEnterBackground];
    
    if (self.accessViewController) {
        [self.accessViewController.view removeFromSuperview];
    }
}

- (void)enterForeground {
    [self _checkRouteXStatus];
}

- (void)userLocationDidChange {
    [self.mapView userLocationDidChange];
    
    if (!self.recentZoomedPerson) {
        [self _zoomToPerson:[self.mapDataSource me]];
        self.recentZoomedPerson = [self.mapDataSource me];
    }
    
    EFUserLocationAnnotationView *locationView = (EFUserLocationAnnotationView *)[self.mapView viewForAnnotation:[EFLocationManager defaultManager].userLocation];
    CLLocationCoordinate2D latestCoordinate = [EFLocationManager defaultManager].userLocation.coordinate;
    
    if (locationView) {
        CGFloat zoomFactor =  self.mapView.visibleMapRect.size.width / self.mapView.bounds.size.width;
        MKMapPoint mapPoint = MKMapPointForCoordinate(latestCoordinate);
        CGPoint point;
        
        point.x = mapPoint.x / zoomFactor;
        point.y = mapPoint.y / zoomFactor;
        
        [UIView animateWithDuration:0.133f
                         animations:^{
                             locationView.center = point;
                         }];
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
        [self.mapDataSource updateBreadcrumTimestampForPerson:self.mapDataSource.selectedPerson toMapView:self.mapView];
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
    if (alertView == self.backgroundAlertView) {
        if (buttonIndex == alertView.firstOtherButtonIndex) {
            [self _startUpdating];
            [self _addRouteXStatuesWithStatus:YES];
        } else {
            EFRouteXAccessViewController *routeXAccessViewController = [[EFRouteXAccessViewController alloc] initWithViewFrame:self.view.bounds];
            routeXAccessViewController.delegate = self;
            [self.view addSubview:routeXAccessViewController.view];
            self.accessViewController = routeXAccessViewController;
        }
        
        self.backgroundAlertView = nil;
    } else if (alertView == self.noGPSAlertView) {
        if (buttonIndex == alertView.cancelButtonIndex) {
#warning - DIFF action base on target
            [self.tabBarViewController.navigationController popViewControllerAnimated:YES];
            self.noGPSAlertView = nil;
        }
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
            
            __weak typeof(self) weakSelf = self;
            
            CLLocation *location = [[CLLocation alloc] initWithLatitude:coordinate.latitude longitude:coordinate.longitude];
            CLGeocoder *geocoder = [[CLGeocoder alloc] init];
            [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *geomarks, NSError *error){
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (geomarks && geomarks.count) {
                        CLPlacemark *placemark = geomarks[0];
                        
                        NSString *title = placemark.name;
                        NSString *subtitle = [placemark.addressDictionary valueForKey:@"FormattedAddressLines"][0];
                        
                        if (!title || !title.length) {
                            if (!subtitle || !subtitle.length) {
                                title = NSLocalizedString(@"Here", nil);
                            } else {
                                title = subtitle;
                                subtitle = nil;
                            }
                        }
                        
                        if (weakSelf.currentCalloutAnnotation) {
                            EFCalloutAnnotationView *calloutView = (EFCalloutAnnotationView *)[weakSelf.mapView viewForAnnotation:weakSelf.currentCalloutAnnotation];
                            if (calloutView && calloutView.parentAnnotationView == view) {
                                if (!calloutView.isEditing) {
                                    routeLocation.title = title;
                                    routeLocation.subtitle = subtitle;
                                    
                                    [weakSelf.mapDataSource updateRouteLocation:routeLocation inMapView:weakSelf.mapView];
                                    
                                    [weakSelf.mapView deselectAnnotation:annotation animated:NO];
                                    [weakSelf.mapView selectAnnotation:annotation animated:NO];
                                }
                            }
                        } else if ([routeLocation.createdDate isEqualToDate:routeLocation.updateDate]) {
                            routeLocation.title = title;
                            routeLocation.subtitle = subtitle;
                            
                            [weakSelf.mapDataSource updateRouteLocation:routeLocation inMapView:weakSelf.mapView];
                        }
                    } else {
                        RKLogError(@"%@", error);
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

#pragma mark - EFMapPersonCellDelegate
- (void)mapPersonCellSingleTapHappened:(EFMapPersonCell *)cell {
    [self.mapDataSource removeAllBreadcrumPathsToMapView:self.mapView];
    
    NSArray *locations = nil;
    EFMapPerson *person = [self.mapDataSource personAtIndex:cell.index];
    
    locations = person.locations;
    self.mapDataSource.selectedPerson = person;
    
    if (!locations || !locations.count) {
        if (!person.lastLocation) {
            EFMapPersonViewController *personViewController = [[EFMapPersonViewController alloc] initWithDataSource:self.mapDataSource
                                                                                                             person:person];
            personViewController.delegate = self;
            [personViewController presentFromViewController:self
                                                   location:self.view.center
                                                   animated:YES];
            self.personViewController = personViewController;
        }
        
        return;
    }
    
    // update overlay
    [self.mapDataSource updateBreadcrumPathForPerson:person toMapView:self.mapView];
    
    // timestamp
    [self.mapDataSource updateBreadcrumTimestampForPerson:person toMapView:self.mapView];
    
    [self _zoomToPerson:person];
    
    [self _fireBreadcrumbUpdateTimer];

}

- (void)mapPersonCellDoubleTapHappened:(EFMapPersonCell *)cell {
    EFMapPerson *person = [self.mapDataSource personAtIndex:cell.index];
    BOOL isMe = (person == [self.mapDataSource me]);
    if (isMe) {
        if (![EFLocationManager defaultManager].userLocation) {
            return;
        }
    } else {
        if (!person.lastLocation) {
            return;
        }
    }
    
    [self _zoomToPersonLocation:person];
}

#pragma mark -
#pragma mark EFRouteXAccessViewControllerDelegate

- (void)routeXAccessViewControllerButtonPressed:(EFRouteXAccessViewController *)accessViewController {
    [self.accessViewController.view removeFromSuperview];
    
    [self _startUpdating];
    [self _addRouteXStatuesWithStatus:YES];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger numberOfRows = 0;
    if (tableView == self.tableView) {
        numberOfRows = [self.mapDataSource numberOfPeople] - 1;
    } else if (tableView == self.selfTableView) {
        numberOfRows = 1;
    }
    
    return numberOfRows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *Identitier = @"MapPersonCell";
    EFMapPersonCell *cell = (EFMapPersonCell *)[tableView dequeueReusableCellWithIdentifier:Identitier];
    if (!cell) {
        cell = [[EFMapPersonCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:Identitier];
        cell.delegate = self;
    }
    
    EFMapPerson *person = nil;
    if (tableView == self.tableView) {
        person  = [self.mapDataSource personAtIndex:indexPath.row + 1];
        cell.index = indexPath.row + 1;
    } else  if (tableView == self.selfTableView) {
        person = [self.mapDataSource me];
        cell.index = 0;
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
    
    EFMapPersonViewController *personViewController = [[EFMapPersonViewController alloc] initWithDataSource:self.mapDataSource
                                                                                                     person:person];
    personViewController.delegate = self;
    [personViewController presentFromViewController:self
                                           location:self.view.center
                                           animated:YES];
    self.personViewController = personViewController;
}

#pragma mark - EFMapPersonViewControllerDelegate

- (void)mapPersonViewControllerRequestButtonPressed:(EFMapPersonViewController *)controller {
    controller.buttonEnabled = NO;
    
    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    EFMapPerson *person = controller.person;
    
    __weak typeof(controller) weakPersonViewController = controller;
    __weak typeof(self) weakSelf = self;
    
    [delegate.model.apiServer postRouteXRequestIdentityId:person.identityString
                                                  inCross:self.cross
                                                  success:^{
                                                      if (weakPersonViewController && weakPersonViewController == weakSelf.personViewController) {
                                                          weakPersonViewController.buttonEnabled = YES;
                                                      }
                                                  }
                                                  failure:^(NSInteger responseStatusCode, NSError *error){
                                                      switch (responseStatusCode) {
                                                          case 406:
                                                          {
                                                              BOOL isWechat = NO;
                                                              
                                                              // check invitation identity
                                                              NSString *identityString = person.identityString;
                                                              NSArray *components = [identityString componentsSeparatedByString:@"@"];
                                                              NSString *providerString = [components lastObject];
                                                              
                                                              if (providerString && [providerString isEqualToString:@"wechat"]) {
                                                                  isWechat = YES;
                                                              }
                                                              
                                                              if (!isWechat) {
                                                                  // check notification identities
                                                                  NSArray *identityIds = [weakSelf.mapDataSource notificationIdentityIdsForPerson:person];
                                                                  for (NSString *identityId in identityIds) {
                                                                      NSArray *components = [identityId componentsSeparatedByString:@"@"];
                                                                      NSString *providerString = [components lastObject];
                                                                      
                                                                      if (providerString && [providerString isEqualToString:@"wechat"]) {
                                                                          isWechat = YES;
                                                                          break;
                                                                      }
                                                                  }
                                                              }
                                                              
                                                              if (isWechat) {
                                                                  if ([WXApi isWXAppInstalled] &&
                                                                      [WXApi isWXAppSupportApi] &&
                                                                      [WXApi getApiVersion] <= [WXApi getWXAppSupportMaxApiVersion]) {
                                                                      [delegate.model.apiServer getRouteXUrlInCross:self.cross
                                                                                                            success:^(NSString *url){
                                                                                                                if (weakPersonViewController && weakPersonViewController == weakSelf.personViewController) {
                                                                                                                    weakPersonViewController.buttonEnabled = YES;
                                                                                                                    [weakPersonViewController dismissAnimated:YES];
                                                                                                                }
                                                                                                                [self _jumpToWeixinWithURL:url];
                                                                                                            }
                                                                                                            failure:^(NSError *error){
                                                                                                                if (weakPersonViewController && weakPersonViewController == weakSelf.personViewController) {
                                                                                                                    [weakPersonViewController dismissAnimated:YES];
                                                                                                                }
                                                                                                                
                                                                                                                [UIAlertView showAlertViewWithTitle:NSLocalizedString(@"通知失败", nil)
                                                                                                                                            message:NSLocalizedString(@"无法立刻通知对方更新方位。请尝试用其它方式联系对方。", nil)
                                                                                                                                  cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                                                                                                                  otherButtonTitles:nil
                                                                                                                                            handler:nil];
                                                                                                            }];
                                                                  }
                                                              } else {
                                                                  if (weakPersonViewController && weakPersonViewController == weakSelf.personViewController) {
                                                                      [weakPersonViewController dismissAnimated:YES];
                                                                  }
                                                                  
                                                                  [UIAlertView showAlertViewWithTitle:NSLocalizedString(@"通知失败", nil)
                                                                                              message:NSLocalizedString(@"无法立刻通知对方更新方位。请尝试用其它方式联系对方。", nil)
                                                                                    cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                                                                    otherButtonTitles:nil
                                                                                              handler:nil];
                                                              }
                                                          }
                                                              break;
                                                          case 401:
                                                          case 403:
                                                          default:
                                                              if (weakPersonViewController && weakPersonViewController == weakSelf.personViewController) {
                                                                  weakPersonViewController.buttonEnabled = YES;
                                                              }
                                                              break;
                                                      }
                                                  }];
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
        
        CGRect tableViewVisibleRect = self.tableView.bounds;
        tableViewVisibleRect.origin = self.tableView.contentOffset;
        
        if (!CGRectContainsPoint(tableViewVisibleRect, avatarCenter)) {
            return nil;
        }
        
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

- (void)mapDataRourceInitCompleted:(EFMarauderMapDataSource *)dataSource {
    if (![EFLocationManager defaultManager].userLocation.location) {
        NSArray *routeLocations = [dataSource allRouteLocations];
        NSArray *people = [dataSource allPeople];
        NSMutableDictionary *peopleLocationMap = [[NSMutableDictionary alloc] init];
        for (EFMapPerson *person in people) {
            if (person.lastLocation) {
                [peopleLocationMap setValue:person.lastLocation forKey:person.userIdString];
            }
        }
        
        if ((!routeLocations || !routeLocations.count) && (!peopleLocationMap.count)) {
            return;
        }
        
        if (1 == routeLocations.count + peopleLocationMap.count) {
            CLLocationCoordinate2D centerCoordinate;
            if (routeLocations.count) {
                centerCoordinate = ((EFRouteLocation *)routeLocations[0]).coordinate;
            } else {
                centerCoordinate = ((EFLocation *)peopleLocationMap.allValues[0]).coordinate;
            }
            
            MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(centerCoordinate, 5000.0f, 5000.0f);
            MKMapRect mapRect = MKMapRectForCoordinateRegion(region);
            [self.mapView setVisibleMapRect:mapRect animated:YES];
        } else {
            CGFloat minX = CGFLOAT_MAX, minY = CGFLOAT_MAX, maxX = CGFLOAT_MIN, maxY = CGFLOAT_MIN;
            for (EFRouteLocation *routeLocation in routeLocations) {
                MKMapPoint mapPoint = MKMapPointForCoordinate(routeLocation.coordinate);
                
                minX = MIN(minX, mapPoint.x);
                minY = MIN(minY, mapPoint.y);
                maxX = MAX(maxX, mapPoint.x);
                maxY = MAX(maxY, mapPoint.y);
            }
            
            MKMapRect mapRect = MKMapRectMake(minX, minY, maxX - minX, maxY - minY);
            [self.mapView setVisibleMapRect:mapRect animated:YES];
        }
    }
}

- (void)mapDataSourcePeopleDidChange:(EFMarauderMapDataSource *)dataSource {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self _refreshTableViewFrame];
        
        [self.selfTableView reloadData];
        [self.tableView reloadData];
        [self.mapStrokeView reloadData];
    });
}

- (void)mapDataSource:(EFMarauderMapDataSource *)dataSource didGetRouteLocations:(NSArray *)locations {
    for (EFRouteLocation *routeLocation in locations) {
        double delayInSeconds = self.annotationAnimationDelay;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [dataSource addRouteLocation:routeLocation toMapView:self.mapView canChangeType:NO];
            
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
            
            [self.selfTableView reloadData];
            [self.tableView reloadData];
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
        
        [self.mapDataSource updatePeopleTimestampInMapView:self.mapView];
    });
}

- (void)mapDataSource:(EFMarauderMapDataSource *)dataSource didUpdateRouteLocations:(NSArray *)locations {
    dispatch_async(dispatch_get_main_queue(), ^{
        for (EFRouteLocation *routeLocation in locations) {
            [dataSource addRouteLocation:routeLocation toMapView:self.mapView canChangeType:NO];
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
        
        [self.selfTableView reloadData];
        [self.tableView reloadData];
    });
}

- (void)mapDataSource:(EFMarauderMapDataSource *)dataSource didUpdateRoutePaths:(NSArray *)paths {
    
}

- (void)mapDataSource:(EFMarauderMapDataSource *)dataSource needDeleteRouteLocation:(NSString *)routeLocationId {
    dispatch_async(dispatch_get_main_queue(), ^{
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
        
        [self.selfTableView reloadData];
        [self.tableView reloadData];
    });
}

- (void)mapDataSource:(EFMarauderMapDataSource *)dataSource routeLocationDidGetGeomarkInfo:(EFRouteLocation *)routeLocation {
    [self.mapDataSource updateRouteLocation:routeLocation inMapView:self.mapView];
}

- (void)coordinateTapped:(CLLocationCoordinate2D)coordinate {
    CGPoint tapLocation = [self.mapView convertCoordinate:coordinate toPointToView:self.mapView];
    
    CGRect tapRect = (CGRect){{tapLocation.x - kTapRectHalfWidth, tapLocation.y - kTapRectHalfWidth}, {2 * kTapRectHalfWidth, 2 * kTapRectHalfWidth}};
    
    NSMutableArray *filterdRouteLocations = [[NSMutableArray alloc] init];
    NSMutableArray *filterdPeople = [[NSMutableArray alloc] init];
    
    for (EFRouteLocation *routeLocation in [self.mapDataSource allRouteLocations]) {
        CGPoint location = [self.mapView convertCoordinate:routeLocation.coordinate toPointToView:self.mapView];
        if (CGRectContainsPoint(tapRect, location)) {
            [filterdRouteLocations addObject:routeLocation];
        }
    }
    
    for (EFMapPerson *person in [self.mapDataSource allPeople]) {
        if (person != [self.mapDataSource me] && person.lastLocation) {
            CGPoint location = [self.mapView convertCoordinate:person.lastLocation.coordinate toPointToView:self.mapView];
            if (CGRectContainsPoint(tapRect, location)) {
                [filterdPeople addObject:person];
            }
        }
    }
    
    if (filterdRouteLocations.count || filterdPeople.count) {
        if (1 == filterdRouteLocations.count + filterdPeople.count) {
            if (filterdRouteLocations.count) {
                EFAnnotation *annotation = [self.mapDataSource annotationForRouteLocation:filterdRouteLocations[0]];
                [self.mapView selectAnnotation:annotation animated:YES];
            } else {
                EFMapPerson *person = filterdPeople[0];
                EFMapPersonViewController *personViewController = [[EFMapPersonViewController alloc] initWithDataSource:self.mapDataSource
                                                                                                                 person:person];
                personViewController.delegate = self;
                [personViewController presentFromViewController:self
                                                       location:self.view.center
                                                       animated:YES];
                self.personViewController = personViewController;
            }
        } else {
            EFGeomarkGroupViewController *geomarkGroupViewController = [[EFGeomarkGroupViewController alloc] initWithGeomarks:filterdRouteLocations
                                                                                                                    andPeople:filterdPeople];
            geomarkGroupViewController.mapDataSource = self.mapDataSource;
            geomarkGroupViewController.delegate = self;
            [geomarkGroupViewController presentFromViewController:self
                                                      tapLocation:tapLocation
                                                         animated:YES];
            self.geomarkGroupViewController = geomarkGroupViewController;
        }
    }
}

#pragma mark - EFAnnotationViewDelegate

- (void)annotationView:(EFAnnotationView *)view didTapAtCoordinate:(CLLocationCoordinate2D)coordinate {
    [self coordinateTapped:coordinate];
}

#pragma mark - EFMapViewDelegate

- (void)mapViewDidScroll:(EFMapView *)mapView {
    self.mapZoomType = kEFMapZoomTypeUnknow;
}

- (void)mapView:(EFMapView *)mapView tappedAtCoordinate:(CLLocationCoordinate2D)coordinate {
    [self coordinateTapped:coordinate];
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
    
    if (routeLocation.locatinMask & kEFRouteLocationMaskXPlace) {
        [self.mapDataSource changeXPlaceRouteLocationToNormalRouteLocaiton:routeLocation];
        routeLocation.markColor = kEFRouteLocationColorBlue;
    }
    
    routeLocation.markTitle = title;
    [routeLocation updateIconURL];
    
    [self.mapDataSource updateRouteLocation:routeLocation inMapView:self.mapView shouldPostToServer:NO];
    [self.mapView customEditingViewWithRouteLocation:routeLocation];
    
    routeLocation.isChanged = YES;
}

- (void)mapView:(EFMapView *)mapView didChangeSelectedAnnotationStyle:(EFAnnotationStyle)style {
    EFCalloutAnnotationView *calloutView = (EFCalloutAnnotationView *)[self.mapView viewForAnnotation:self.currentCalloutAnnotation];
    EFAnnotation *annotation = calloutView.parentAnnotationView.annotation;
    EFRouteLocation *routeLocation = [self.mapDataSource routeLocationForAnnotation:annotation];
    
    if (routeLocation.locatinMask & kEFRouteLocationMaskXPlace) {
        [self.mapDataSource changeXPlaceRouteLocationToNormalRouteLocaiton:routeLocation];
    } else if (routeLocation.locatinMask & kEFRouteLocationMaskDestination) {
        [self.mapDataSource changeDestinationToNormalRouteLocation:routeLocation];
    }
    
    if (kEFAnnotationStyleMarkRed == style) {
        routeLocation.markColor = kEFRouteLocationColorRed;
    } else {
        routeLocation.markColor = kEFRouteLocationColorBlue;
    }
    
    [routeLocation updateIconURL];
    
    [self.mapDataSource updateRouteLocation:routeLocation inMapView:self.mapView shouldPostToServer:NO];
    [self.mapView customEditingViewWithRouteLocation:routeLocation];
    
    routeLocation.isChanged = YES;
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

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view didChangeDragState:(MKAnnotationViewDragState)newState
   fromOldState:(MKAnnotationViewDragState)oldState {
    switch (newState) {
        case MKAnnotationViewDragStateStarting:
        {
            if ([view isKindOfClass:[EFAnnotationView class]]) {
                EFAnnotation *annotation = (EFAnnotation *)view.annotation;
                EFRouteLocation *routeLocation = [self.mapDataSource routeLocationForAnnotation:annotation];
                routeLocation.isChanged = YES;
            }
        }
            break;
        case MKAnnotationViewDragStateEnding:
        {
            if ([view isKindOfClass:[EFAnnotationView class]]) {
                CGPoint point = (CGPoint){CGRectGetMidX(view.frame), CGRectGetMaxY(view.frame)};   //(CGPoint){view.center.x, view.center.y + kAnnotationOffsetY};
                CLLocationCoordinate2D coordinate = [self.mapView convertPoint:point toCoordinateFromView:view.superview];
                
                EFAnnotation *annotation = (EFAnnotation *)view.annotation;
                EFRouteLocation *routeLocation = [self.mapDataSource routeLocationForAnnotation:annotation];
                routeLocation.coordinate = coordinate;
                
                if (routeLocation.isChanged) {
                    [self.mapDataSource updateRouteLocation:routeLocation inMapView:self.mapView];
                }
            }
        }
            break;
        default:
            break;
    }
}

- (void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated {
    self.mapStrokeView.hidden = YES;
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
    if (self.mapDataSource.selectedPerson) {
        [self.mapDataSource updateBreadcrumTimestampForPerson:self.mapDataSource.selectedPerson toMapView:mapView];
    }
    
    [self.mapStrokeView reloadData];
    self.mapStrokeView.hidden = NO;
    
    [self.mapDataSource updatePeopleTimestampInMapView:self.mapView];
    
    [self _layoutAnnotationView];
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
    if ([view isKindOfClass:[EFAnnotationView class]]) {
        EFAnnotation *annotation = (EFAnnotation *)view.annotation;
        EFRouteLocation *routeLocation = [self.mapDataSource routeLocationForAnnotation:annotation];
        
        [self _hideCalloutView];
        
        EFCalloutAnnotation *calloutAnnotation = [[EFCalloutAnnotation alloc] initWithCoordinate:view.annotation.coordinate
                                                                                           title:view.annotation.title
                                                                                        subtitle:view.annotation.subtitle];
        [mapView addAnnotation:calloutAnnotation];
        
        self.currentCalloutAnnotation = calloutAnnotation;
        self.mapView.editingState = kEFMapViewEditingStateEditingAnnotation;
        [self.mapView customEditingViewWithRouteLocation:routeLocation];
        
        // bring the selected view to front.
        [view.superview bringSubviewToFront:view];
    }
}

- (void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view {
    [self _hideCalloutView];
    self.mapView.editingState = kEFMapViewEditingStateNormal;
    
    if ([view isKindOfClass:[EFAnnotationView class]]) {
        EFAnnotation *annotation = (EFAnnotation *)view.annotation;
        EFRouteLocation *routeLocation = [self.mapDataSource routeLocationForAnnotation:annotation];
        
        if (routeLocation.isChanged) {
            [self.mapDataSource updateRouteLocation:routeLocation inMapView:self.mapView];
        }
    }
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
            annotationView.delegate = self;
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
            
            if (routeLocation.isChanged) {
                routeLocation.title = calloutView.annotation.title;
                routeLocation.subtitle = calloutView.annotation.subtitle;
                [routeLocation updateIconURL];
                
                [self.mapDataSource updateRouteLocation:routeLocation inMapView:self.mapView];
            }
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
    UIView *anyView = annotationViews[0];
    UIView *superView = anyView.superview;
    
    if (annotationViews.count > 0) {
        if (!self.mapStrokeView) {
            EFMapStrokeView *mapStrokeView = [[EFMapStrokeView alloc] initWithFrame:self.view.bounds];
            mapStrokeView.dataSource = self;
            mapStrokeView.mapView = self.mapView;
            mapStrokeView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
            [superView insertSubview:mapStrokeView atIndex:0];
            self.mapStrokeView = mapStrokeView;
        }
    }
    
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
        
        [superView bringSubviewToFront:view];
    }
    
    [self _layoutAnnotationView];
}

- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id<MKOverlay>)overlay {
    EFCrumPathView *crumPathView = nil;
    
    crumPathView = [[EFCrumPathView alloc] initWithOverlay:overlay];
    crumPathView.mapView = self.mapView;
    
    return crumPathView;
}

@end
