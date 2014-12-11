//
//  EFMapPerson.h
//  MarauderMap
//
//  Created by 0day on 13-7-5.
//  Copyright (c) 2013年 exfe. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "EFEntity.h"
#import "EFMapDataDefines.h"

@class EFLocation;
@interface EFMapPerson : NSObject

@property (nonatomic, strong) NSString                  *avatarName;
@property (nonatomic, strong) NSString                  *name;
@property (nonatomic, strong) NSString                  *identityString;
@property (nonatomic, strong) NSString                  *userIdString;
@property (nonatomic, assign) CGFloat                   distance;
@property (nonatomic, assign) CGFloat                   angle;          // 0 ~ 2Pi
@property (nonatomic, assign) EFMapPersonConnectState   connectState;
@property (nonatomic, assign) EFMapPersonLocationState  locationState;

@property (nonatomic, strong) NSMutableArray            *locations;     // from get
@property (nonatomic, strong) EFLocation                *lastLocation;  // from streaming, needToSave default as YES

- (id)initWithIdentity:(Identity *)identity;

@end