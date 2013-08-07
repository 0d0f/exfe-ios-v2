//
//  EFLocationManager.m
//  EXFE
//
//  Created by 0day on 13-7-31.
//
//

#import "EFLocationManager.h"

#import "EFAPI.h"

#define kDefaultTimerTimeInterval   (5.0f)
#define kHasPostUserLocationKey     @"key.hasPostUserLocation"
#define kDefaultBackgroundDuration  (1200.0f)

@interface EFLocationManager ()

@property (nonatomic, strong) CLLocation        *userLocation;            // rewrite property
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) NSTimer           *postTimer;

@property (nonatomic, strong) NSMutableDictionary     *crossMap;
@property (nonatomic, assign) UIBackgroundTaskIdentifier    bgTask;

@property (nonatomic, strong) NSDate            *enterBackgroundTimestamp;

@end

@interface EFLocationManager (Private)

- (void)_endBackgroundTask;

- (void)_postUserLocation;
- (void)_postUserLocationInBackground;
- (void)_postCrossAccessInfos;

- (void)_fireTimer;
- (void)_invalideTimer;

@end

@implementation EFLocationManager (Private)

- (void)_postUserLocation {
    EFLocation *breadcrum = [[EFLocation alloc] init];
    breadcrum.coordinate = self.userLocation.coordinate;
    breadcrum.accuracy = self.userLocation.verticalAccuracy;
    breadcrum.timestamp = [NSDate date];
    
    AppDelegate *delelgate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [delelgate.model.apiServer postRouteXBreadcrumbs:@[breadcrum]
                                   isEarthCoordinate:YES
                                             success:^(CGFloat latOffset, CGFloat lngOffset){
                                             }
                                             failure:^(NSError *error){
                                             }];
}

- (void)_endBackgroundTask {
    [[UIApplication sharedApplication] endBackgroundTask:self.bgTask];
    self.bgTask = UIBackgroundTaskInvalid;
}

- (void)_postUserLocationInBackground {
    if (UIBackgroundTaskInvalid != self.bgTask) {
        [self _endBackgroundTask];
    }
    
    self.bgTask = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        [self _endBackgroundTask];
    }];
    
    __block BOOL isOver = NO;
    
    EFLocation *breadcrum = [[EFLocation alloc] init];
    breadcrum.coordinate = self.userLocation.coordinate;
    breadcrum.accuracy = MAX(self.userLocation.verticalAccuracy, self.userLocation.horizontalAccuracy);
    breadcrum.timestamp = [NSDate date];
    
    AppDelegate *delelgate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [delelgate.model.apiServer postRouteXBreadcrumbs:@[breadcrum]
                                   isEarthCoordinate:YES
                                             success:^(CGFloat latOffset, CGFloat lngOffset){
                                                 isOver = YES;
                                             }
                                             failure:^(NSError *error){
                                                 isOver = YES;
                                             }];
    
    while (!isOver) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                 beforeDate:[NSDate distantFuture]];
    }
    
    if (UIBackgroundTaskInvalid != self.bgTask) {
        [self _endBackgroundTask];
    }
}

- (void)_postCrossAccessInfos {
    
}

- (void)_fireTimer {
    [self _invalideTimer];
    self.postTimer = [NSTimer scheduledTimerWithTimeInterval:kDefaultTimerTimeInterval
                                                      target:self
                                                    selector:@selector(runloop:)
                                                    userInfo:nil
                                            repeats:YES];
    [self.postTimer fire];
}

- (void)_invalideTimer {
    if (self.postTimer) {
        [self.postTimer invalidate];
        self.postTimer = nil;
    }
}

@end

@implementation EFLocationManager

+ (instancetype)defaultManager {
    static EFLocationManager *Manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Manager = [[self alloc] init];
    });
    
    return Manager;
}

- (id)init {
    self = [super init];
    if (self) {
        CLLocationManager *locationManager = [[CLLocationManager alloc] init];
        locationManager.delegate = self;
        locationManager.distanceFilter = 5.0f;
        self.locationManager = locationManager;
        
        self.crossMap = [[NSMutableDictionary alloc] init];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(handleNotification:)
                                                     name:UIApplicationDidEnterBackgroundNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(handleNotification:)
                                                     name:UIApplicationDidBecomeActiveNotification
                                                   object:nil];
    }
    
    return self;
}

#pragma mark - Notification Handler

- (void)handleNotification:(NSNotification *)notif {
    NSString *name = notif.name;
    
    if ([name isEqualToString:UIApplicationDidEnterBackgroundNotification]) {
        self.enterBackgroundTimestamp = [NSDate date];
        [self _invalideTimer];
    } else if ([name isEqualToString:UIApplicationDidBecomeActiveNotification]) {
        if ([CLLocationManager locationServicesEnabled] && ![self isFirstTimeToPostUserLocation]) {
            [self startUpdatingLocation];
        }
    }
}

#pragma mark - Property Accessor

- (CLLocation *)userLocation {
    return self.locationManager.location;
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager
	 didUpdateLocations:(NSArray *)locations {
    CLLocation *location = locations[0];
    self.userLocation = location;
    
    BOOL isInBackground = NO;
    
    if (UIApplicationStateBackground == [UIApplication sharedApplication].applicationState) {
        isInBackground = YES;
    }
    
    if (isInBackground) {
        NSTimeInterval timeInterval = [[NSDate date] timeIntervalSinceDate:self.enterBackgroundTimestamp];
        if (timeInterval > kDefaultBackgroundDuration) {
            // timeout
            [self stopUpdatingLocation];
            return;
        } else {
            // post
            [self _postUserLocationInBackground];
        }
    }
}

#pragma mark - Timer Runloop

- (void)runloop:(NSTimer *)timer {
    [self _postUserLocation];
}

#pragma mark - Update Location

- (void)startUpdatingLocation {
    [[NSUserDefaults standardUserDefaults] setValue:@"YES" forKey:kHasPostUserLocationKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self.locationManager startUpdatingLocation];
    [self _fireTimer];
}

- (void)stopUpdatingLocation {
    [self _invalideTimer];
    [self.locationManager stopUpdatingLocation];
}

#pragma mark - Check

- (BOOL)isFirstTimeToPostUserLocation {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return ![userDefaults valueForKey:kHasPostUserLocationKey];
}

#pragma mark - Cross Register

- (void)registerCrossToSaveLocation:(NSUInteger)crossId {
    [self.crossMap setValue:@"YES" forKey:[NSString stringWithFormat:@"%d", crossId]];
    [self _postCrossAccessInfos];
}

- (void)unregisterCrossToSaveLocation:(NSUInteger)crossId {
    [self.crossMap setValue:@"NO" forKey:[NSString stringWithFormat:@"%d", crossId]];
    [self _postCrossAccessInfos];
}

@end
