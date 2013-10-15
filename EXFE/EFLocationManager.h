//
//  EFLocationManager.h
//  EXFE
//
//  Created by 0day on 13-7-31.
//
//

#import <Foundation/Foundation.h>

#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

@interface EFUserLocation : NSObject
<
MKAnnotation
>

@property (nonatomic, strong) CLLocation    *location;
@property (nonatomic, assign) CGPoint       offset;     // x -> latitudeOffset, y -> longitudeOffset
@property (nonatomic, readonly) CLLocationCoordinate2D coordinateWithoutOffset;

@end

@interface EFLocationManager : NSObject
<
CLLocationManagerDelegate
>

@property (nonatomic, readonly) EFUserLocation  *userLocation;
@property (nonatomic, readonly) CLHeading       *userHeading;       // KVO
@property (nonatomic, readonly) BOOL            isUpdating;

+ (instancetype)defaultManager;

+ (BOOL)isLocationServicesDetermined;
+ (BOOL)isLocationServicesAuthored;
+ (BOOL)locationServicesEnabled;
+ (BOOL)headingServicesEnabled;

/**
 * Location Notification
 */
- (void)handleNotificaiton:(UILocalNotification *)localNotification;

/**
 * Check
 */
- (BOOL)isFirstTimeToPostUserLocation;
- (BOOL)canPostUserLocationInBackground;

/**
 * Update Location
 */
- (void)startUpdatingLocation;
- (void)stopUpdatingLocation;

/**
 * User Heading
 */
- (void)startUpdatingHeading;
- (void)stopUpdatingHeading;

/**
 * Cross Register
 */
- (void)registerCrossToSaveLocation:(NSUInteger)crossId;
- (void)unregisterCrossToSaveLocation:(NSUInteger)crossId;

@end
