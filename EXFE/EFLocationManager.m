//
//  EFLocationManager.m
//  EXFE
//
//  Created by 0day on 13-7-31.
//
//

#import "EFLocationManager.h"

#import "EFAPI.h"
#import "CCTemplate.h"
#import "Util.h"

#define kDefaultTimerTimeInterval   (5.0f)
#define kDefaultPostBackgroundTimeInterval  (5.0f)
#define kHasPostUserLocationKey     @"key.hasPostUserLocation"
#define kDefaultBackgroundDuration  (1200.0f)

NSString *EFNotificationUserLocationDidChange = @"notification.userLocation.didChange";
NSString *EFNotificationUserLocationOffsetDidGet = @"notification.offset.didGet";

@implementation EFUserLocation

- (CLLocationCoordinate2D)coordinate {
    return CLLocationCoordinate2DMake(self.location.coordinate.latitude + self.offset.x, self.location.coordinate.longitude + self.offset.y);
}

- (CLLocationCoordinate2D)coordinateWithoutOffset {
    return self.location.coordinate;
}

@end

@interface EFLocationManager ()

@property (nonatomic, strong) EFUserLocation    *userLocation;            // rewrite property
@property (nonatomic, strong) CLHeading         *userHeading;             // rewrite property
@property (nonatomic, assign) BOOL              isUpdating;               // rewrite property

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) NSTimer           *postTimer;

@property (nonatomic, strong) NSMutableDictionary     *crossMap;
@property (nonatomic, assign) UIBackgroundTaskIdentifier    bgTask;

@property (nonatomic, strong) NSDate            *enterBackgroundTimestamp;
@property (nonatomic, strong) NSDate            *lastestPostTimestamp;
@property (nonatomic, assign) BOOL              isInBackground;

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
    if (!self.userLocation.location) {
        return;
    }
    
    EFLocation *breadcrum = [[EFLocation alloc] init];
    breadcrum.coordinate = self.userLocation.coordinateWithoutOffset;
    breadcrum.accuracy = MAX(self.userLocation.location.verticalAccuracy, self.userLocation.location.horizontalAccuracy);
    breadcrum.timestamp = [NSDate date];
    
    AppDelegate *delelgate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [delelgate.model.apiServer postRouteXBreadcrumbs:@[breadcrum]
                                   isEarthCoordinate:YES
                                             success:^(CGFloat latOffset, CGFloat lngOffset){
                                                 self.userLocation.offset = (CGPoint){latOffset, lngOffset};
                                                 dispatch_async(dispatch_get_main_queue(), ^{
                                                     [[NSNotificationCenter defaultCenter] postNotificationName:EFNotificationUserLocationOffsetDidGet object:nil];
                                                 });
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
    
    if (!self.userLocation.location) {
        return;
    }
    
    NSDate *now = [NSDate date];
    if (self.lastestPostTimestamp && [now timeIntervalSinceDate:self.lastestPostTimestamp] < kDefaultPostBackgroundTimeInterval) {
        return;
    }
    self.lastestPostTimestamp = now;
    
    self.bgTask = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        [self _endBackgroundTask];
    }];
    
    __block BOOL isOver = NO;
    
    EFLocation *breadcrum = [[EFLocation alloc] init];
    breadcrum.coordinate = self.userLocation.coordinateWithoutOffset;
    breadcrum.accuracy = MAX(self.userLocation.location.verticalAccuracy, self.userLocation.location.horizontalAccuracy);
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
}

- (void)_invalideTimer {
    if (self.postTimer) {
        [self.postTimer invalidate];
        self.postTimer = nil;
    }
}

@end

@implementation EFLocationManager

+ (BOOL)locationServicesEnabled {
    return [CLLocationManager locationServicesEnabled];
}

+ (BOOL)headingServicesEnabled {
    return [CLLocationManager headingAvailable];
}

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
        self.isInBackground = NO;
        
        CLLocationManager *locationManager = [[CLLocationManager alloc] init];
        locationManager.delegate = self;
        self.locationManager = locationManager;
        
        self.userLocation = [[EFUserLocation alloc] init];
        
        self.crossMap = [[NSMutableDictionary alloc] init];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(handleNotification:)
                                                     name:UIApplicationDidEnterBackgroundNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(handleNotification:)
                                                     name:UIApplicationWillEnterForegroundNotification
                                                   object:nil];
    }
    
    return self;
}

#pragma mark - Local Notification Handler

- (void)handleNotificaiton:(UILocalNotification *)localNotification {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"RouteX in background", nil)
                                                        message:[NSLocalizedString(@"RouteX can show your location for minutes even after quitting {{PRODUCT_APP_NAME}}.", nil) templateFromDict:[Util keywordDict]]
                                                       delegate:self
                                              cancelButtonTitle:NSLocalizedString(@"Disable this feature", nil)
                                              otherButtonTitles:NSLocalizedString(@"OK", nil), nil];
    [alertView show];
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    if (buttonIndex == alertView.firstOtherButtonIndex) {
        [userDefaults setValue:[NSNumber numberWithBool:YES] forKey:EFKeyBackgroundUpdatingLocationEnabled];
    } else {
        [userDefaults setValue:[NSNumber numberWithBool:NO] forKey:EFKeyBackgroundUpdatingLocationEnabled];
    }
    
    [userDefaults synchronize];
}

#pragma mark - Notification Handler

- (void)handleNotification:(NSNotification *)notif {
    NSString *name = notif.name;
    
    if ([name isEqualToString:UIApplicationDidEnterBackgroundNotification]) {
        self.isInBackground = YES;
        
        AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        if (![appDelegate.model isLoggedIn]) {
            return;
        }
        
        if (![self isFirstTimeToPostUserLocation]) {
            if (!self.isUpdating) {
                return;
            }
            
            if (![self canPostUserLocationInBackground]) {
                [self stopUpdatingLocation];
                [self stopUpdatingHeading];
            }
        } else {
            UILocalNotification *localNotification = [[UILocalNotification alloc] init];
            localNotification.alertBody = NSLocalizedString(@"RouteX will show your location for 20 minutes, only to those who're agreed.", nil);
            localNotification.fireDate = [NSDate dateWithTimeIntervalSinceNow:2.33f];
            localNotification.userInfo = @{@"key": @"backgroudLocationUpdate"};
            [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
        }
        
        self.enterBackgroundTimestamp = [NSDate date];
        [self _invalideTimer];
    } else if ([name isEqualToString:UIApplicationWillEnterForegroundNotification]) {
        self.isInBackground = NO;
        
        [[UIApplication sharedApplication] cancelAllLocalNotifications];
        
        if ([CLLocationManager locationServicesEnabled] && ![self isFirstTimeToPostUserLocation]) {
            [self startUpdatingLocation];
        }
    }
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager
	 didUpdateLocations:(NSArray *)locations {
    CLLocation *location = [locations lastObject];
    self.userLocation.location = location;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:EFNotificationUserLocationDidChange
                                                            object:nil];
    });
    
    if (self.isInBackground) {
        NSTimeInterval timeInterval = [[NSDate date] timeIntervalSinceDate:self.enterBackgroundTimestamp];
        if (timeInterval > kDefaultBackgroundDuration) {
            // timeout
            [self stopUpdatingLocation];
            [self stopUpdatingHeading];
            return;
        } else {
            // post
            [self _postUserLocationInBackground];   
        }
    }
}

- (void)locationManager:(CLLocationManager *)manager
       didUpdateHeading:(CLHeading *)newHeading {
    self.userHeading = newHeading;
}

#pragma mark - Timer Runloop

- (void)runloop:(NSTimer *)timer {
    [self _postUserLocation];
}

#pragma mark - Update Location

- (void)startUpdatingLocation {
    if ([EFLocationManager locationServicesEnabled]) {
        self.isUpdating = YES;
        
        [self.locationManager startUpdatingLocation];
        [self _fireTimer];
    }
}

- (void)stopUpdatingLocation {
    [self _invalideTimer];
    [self.locationManager stopUpdatingLocation];
    
    self.isUpdating = NO;
}

#pragma mark - User Heading

- (void)startUpdatingHeading {
    [self.locationManager startUpdatingHeading];
}

- (void)stopUpdatingHeading {
    [self.locationManager stopUpdatingHeading];
}

#pragma mark - Check

- (BOOL)isFirstTimeToPostUserLocation {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return ![userDefaults valueForKey:EFKeyBackgroundUpdatingLocationEnabled];
}

- (BOOL)canPostUserLocationInBackground {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSNumber *flag = [userDefaults valueForKey:EFKeyBackgroundUpdatingLocationEnabled];
    return [flag boolValue];
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
