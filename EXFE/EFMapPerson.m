//
//  EFMapPerson.m
//  MarauderMap
//
//  Created by 0day on 13-7-5.
//  Copyright (c) 2013年 exfe. All rights reserved.
//

#import "EFMapPerson.h"

#import "Identity+EXFE.h"
#import "IdentityId.h"
#import "EFLocation.h"

@interface EFMapPerson (Private)

- (void)_lastLocationDidChange;

@end

@implementation EFMapPerson (Private)

- (void)_lastLocationDidChange {
    if (self.lastLocation) {
        NSDate *timestamp = self.lastLocation.timestamp;
        NSTimeInterval timeInterval = [[NSDate date] timeIntervalSinceDate:timestamp];
        if (timeInterval > 0.0f) {
            if (timeInterval <= 60.0f) {
                self.connectState = kEFMapPersonConnectStateOnline;
            } else {
                self.connectState = kEFMapPersonConnectStateOffline;
            }
        } else {
            self.connectState = kEFMapPersonConnectStateOffline;
        }
    }
}

@end

@implementation EFMapPerson

- (id)initWithIdentity:(Identity *)identity {
    self = [super init];
    if (self) {
        self.avatarName = identity.avatar_filename;
        self.identityString = [identity identityIdValue].identity_id;
        self.userIdString = [NSString stringWithFormat:@"%d", [identity.connected_user_id integerValue]];
        self.distance = 0.0f;
        self.angle = 0.0f;
        self.connectState = kEFMapPersonConnectStateUnknow;
        self.locationState = kEFMapPersonLocationStateUnknow;
        self.locations = [[NSMutableArray alloc] init];
    }
    
    return self;
}

- (void)setLastLocation:(EFLocation *)lastLocation {
    if (lastLocation == _lastLocation)
        return;
    
    [self willChangeValueForKey:@"lastLocation"];
    
    if (_lastLocation) {
        [self.locations addObject:_lastLocation];
    }
    
    _lastLocation = lastLocation;
    
    [self _lastLocationDidChange];
    
    [self didChangeValueForKey:@"lastLocation"];
}

@end
