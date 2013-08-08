//
//  EFLocationManager.h
//  EXFE
//
//  Created by 0day on 13-7-31.
//
//

#import <Foundation/Foundation.h>

#import <CoreLocation/CoreLocation.h>

@interface EFLocationManager : NSObject
<
CLLocationManagerDelegate
>

@property (nonatomic, readonly) CLLocation  *userLocation;      // KVO
@property (nonatomic, readonly) CLHeading   *userHeading;       // KVO

+ (instancetype)defaultManager;

/**
 * Check
 */
- (BOOL)isFirstTimeToPostUserLocation;

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
