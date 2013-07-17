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

#define kAnnotationOffsetY  (-50.0f)

@interface EFMarauderMapViewController ()

@property (nonatomic, strong) EFMarauderMapDataSource *mapDataSource;
@property (nonatomic, strong) EFMapPeopleDataSource *dataSource;
@property (nonatomic, strong) MKAnnotationView      *meAnnotationView;
@property (nonatomic, strong) NSArray               *invitations;

@property (nonatomic, strong) NSMutableDictionary   *personOverlayMap;
@property (nonatomic, strong) EFCrumPathView        *personPathOverlayView;

@property (nonatomic, strong) NSMutableDictionary   *personPositionOverlayMap;
@property (nonatomic, strong) NSMutableDictionary   *personPositionOverlayViewMap;

@property (nonatomic, strong) EFCalloutAnnotation   *currentCalloutAnnotation;

@property (nonatomic, strong) NSRecursiveLock       *lock;

@property (nonatomic) BOOL                          isEditing;

@end

@interface EFMarauderMapViewController (Test)
- (void)initTestData;
@end

@implementation EFMarauderMapViewController (Test)

- (void)initTestData {
    for (int i = 0; i < 6; i++) {
        CLLocation *nowLocation = self.mapView.userLocation.location;
        NSUInteger pointCount = 5;
        NSMutableArray *points = [[NSMutableArray alloc] initWithCapacity:pointCount];
        
        CLLocationCoordinate2D nowLocationCoordinate = nowLocation.coordinate;
        for (int i = 0; i < pointCount - 1; i++) {
            EFMapPoint *point = [[EFMapPoint alloc] init];
            point.coordinate2D = CLLocationCoordinate2DMake(nowLocationCoordinate.latitude + (rand() % 2 ? 1 : -1) * (rand() % 300) * 0.001, nowLocationCoordinate.longitude + (rand() % 2 ? 1 : -1) * (rand() % 300) * 0.001);
            [points addObject:point];
        }
        EFMapPoint *point = [[EFMapPoint alloc] init];
        point.coordinate2D = CLLocationCoordinate2DMake(nowLocationCoordinate.latitude, nowLocationCoordinate.longitude);
        [points addObject:point];
        
        EFMapPerson *person = [[EFMapPerson alloc] init];
        person.pathMapPoints = points;
        person.distence = rand() % 300;
        person.avatarImage = [UIImage imageNamed:[NSString stringWithFormat:@"%d", i % 6]];
        
        [self.dataSource addPerson:person];
    }
}

@end

@interface EFMarauderMapViewController (Private)

- (void)_hideCalloutView;
- (void)_postRoute;

@end

@implementation EFMarauderMapViewController (Private)

- (void)_hideCalloutView {
    if (self.currentCalloutAnnotation) {
        [self.mapView removeAnnotation:self.currentCalloutAnnotation];
        self.currentCalloutAnnotation = nil;
    }
}

- (void)_postRoute {
    [self.model.apiServer updateRouteWithCrossId:[self.cross.cross_id integerValue]
                                       locations:[self.mapDataSource allRouteLocations]
                                          routes:nil
                                         success:nil
                                         failure:nil];
}

@end

@implementation EFMarauderMapViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.personPositionOverlayMap = [[NSMutableDictionary alloc] initWithCapacity:6];
        self.personPositionOverlayViewMap = [[NSMutableDictionary alloc] initWithCapacity:6];
        self.personOverlayMap = [[NSMutableDictionary alloc] initWithCapacity:6];
        self.mapDataSource = [[EFMarauderMapDataSource alloc] init];
        self.dataSource = [[EFMapPeopleDataSource alloc] init];
        
        self.lock = [[NSRecursiveLock alloc] init];
        [self.dataSource addObserver:self
                          forKeyPath:@"peopleCount"
                             options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
                             context:NULL];
        self.isEditing = NO;
    }
    
    return self;
}

- (void)dealloc {
    [self.dataSource removeObserver:self
                         forKeyPath:@"peopleCount"];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //
    self.parkButton.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.parkButton.layer.borderWidth = 2.0f;
    self.parkButton.layer.cornerRadius = 8.0f;
    
    // clean button
    self.cleanButton.layer.cornerRadius = 15.0f;
    self.cleanButton.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.cleanButton.layer.borderWidth = 0.5f;
    
    
    // tableView
    self.tableView.backgroundColor = [UIColor colorWithWhite:1.0f alpha:0.6f];
    
    // long press gesture
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    [self.mapView addGestureRecognizer:longPress];
    
    // kvo
    [self addObserver:self
           forKeyPath:@"isEditing"
              options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
              context:NULL];
}

- (void)viewDidUnload {
    [self setTableView:nil];
    [self setParkButton:nil];
    [self setOperationBaseView:nil];
    [self setCleanButton:nil];
    [self setHeadingButton:nil];
    
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.invitations = [self.cross.exfee getSortedInvitations:kInvitationSortTypeMeAcceptOthers];
    self.tableView.frame = (CGRect){{0.0f, 0.0f}, {50.0f, self.invitations.count * [EFMapPersonCell defaultCellHeight]}};
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

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (object == self.dataSource && [keyPath isEqualToString:@"peopleCount"]) {
//        self.tableView.frame = (CGRect){{0.0f, 0.0f}, {50.0f, self.dataSource.peopleCount * [EFMapPersonCell defaultCellHeight]}};
    } else if (object == self && [keyPath isEqualToString:@"isEditing"]) {
        UIButton *button = self.parkButton;
        UIColor *buttonBackgroundColor = button.backgroundColor;
        UIColor *textColor = [button titleColorForState:UIControlStateNormal];
        
        button.backgroundColor = textColor;
        [button setTitleColor:buttonBackgroundColor forState:UIControlStateNormal];
        
        if (self.isEditing) {
            self.cleanButton.hidden = NO;
            self.headingButton.hidden = YES;
        } else {
            self.cleanButton.hidden = YES;
            self.headingButton.hidden = NO;
        }
    }
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
    
    cell.person = person;
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.personPathOverlayView.overlay) {
        [self.mapView removeOverlay:self.personPathOverlayView.overlay];
    }
    
    EFMapPerson *person = [self.dataSource personAtIndex:indexPath.row];
    EFCrumPath *path = [[EFCrumPath alloc] initWithMapPoints:person.pathMapPoints];
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

#pragma mark - MKMapViewDelegate

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
    if ([view isKindOfClass:[EFAnnotationView class]]) {
        [self _hideCalloutView];
        
        EFCalloutAnnotation *calloutAnnotation = [[EFCalloutAnnotation alloc] initWithCoordinate:view.annotation.coordinate
                                                                                           title:view.annotation.title
                                                                                        subtitle:view.annotation.subtitle];
        [mapView addAnnotation:calloutAnnotation];
        
        self.currentCalloutAnnotation = calloutAnnotation;
        
        self.mapView.editingState = kEFMapViewEditingStateEditingAnnotation;
        self.mapView.editing = YES;
    }
}

- (void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view {
    [self _hideCalloutView];
    self.mapView.editing = NO;
}

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation {
    CLLocation *location = userLocation.location;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(location.coordinate, 5000.0f, 5000.0f);
        [self.mapView setRegion:region animated:YES];
        
        [self initTestData];
        [self.tableView reloadData];
    });
    
    EFLocation *position = [[EFLocation alloc] init];
    position.coordinate = location.coordinate;
    position.timestamp = [NSDate date];
    position.accuracy = location.horizontalAccuracy;
    
    [self.model.apiServer updateLocation:position
                             withCrossId:[self.cross.cross_id integerValue]
                                 success:nil
                                 failure:nil];
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    if ([annotation isKindOfClass:[EFAnnotation class]]) {
        static NSString *Identitier = @"Location";
        
        EFAnnotationView *annotationView = (EFAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:Identitier];
        if (nil == annotationView) {
            annotationView = [[EFAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:Identitier];
            annotationView.canShowCallout = NO;
            annotationView.mapView = self.mapView;
        }
        
        return annotationView;
    } else if ([annotation isKindOfClass:[EFCalloutAnnotation class]]) {
        static NSString *Identitier = @"Callout";
        
        EFCalloutAnnotationView *callout = (EFCalloutAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:Identitier];
        if (nil == callout) {
            callout = [[EFCalloutAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:Identitier];
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
            
            [self.mapDataSource updateRouteLocation:routeLocation inMapView:self.mapView];
            [self _postRoute];
        };
        
        return callout;
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
    self.mapView.editing = !self.mapView.isEditing;
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
