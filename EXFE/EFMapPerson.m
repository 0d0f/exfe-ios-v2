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

@implementation EFMapPerson

- (id)initWithIdentity:(Identity *)identity {
    self = [super init];
    if (self) {
        self.avatarName = identity.avatar_filename;
        self.identityString = [identity identityIdValue].identity_id;
        self.distance = 0.0f;
        self.angle = 0.0f;
        self.connectState = kEFMapPersonConnectStateUnknow;
        self.locationState = kEFMapPersonLocationStateUnknow;
        self.locations = nil;
    }
    
    return self;
}

@end
