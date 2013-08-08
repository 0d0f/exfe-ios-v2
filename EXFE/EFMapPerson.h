//
//  EFMapPerson.h
//  MarauderMap
//
//  Created by 0day on 13-7-5.
//  Copyright (c) 2013年 exfe. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "EFMapDataDefines.h"

@class EFRouteLocation;
@interface EFMapPerson : NSObject

@property (nonatomic, strong) NSString                  *avatarName;
@property (nonatomic, strong) NSString                  *identityString;
@property (nonatomic, strong) NSString                  *userIdString;
@property (nonatomic, assign) CGFloat                   distance;
@property (nonatomic, assign) CGFloat                   angle;
@property (nonatomic, assign) EFMapPersonConnectState   connectState;
@property (nonatomic, assign) EFMapPersonLocationState  locationState;

@property (nonatomic, strong) NSMutableArray            *locations;     // from get
@property (nonatomic, strong) EFRouteLocation           *lastLocation;  // from streaming

- (id)initWithIdentity:(Identity *)identity;

@end
