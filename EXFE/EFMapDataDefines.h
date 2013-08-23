//
//  EFMapDataDefines.h
//  MarauderMap
//
//  Created by 0day on 13-7-5.
//  Copyright (c) 2013年 exfe. All rights reserved.
//

#ifndef MarauderMap_EFMapDataDefines_h
#define MarauderMap_EFMapDataDefines_h

typedef enum {
    kEFMapPersonConnectStateUnknow = 0,
    kEFMapPersonConnectStateOnline,
    kEFMapPersonConnectStateOffline,
} EFMapPersonConnectState;

typedef enum {
    kEFMapPersonLocationStateUnknow = 0,
    kEFMapPersonLocationStateOnTheWay,
    kEFMapPersonLocationStateArrival,
} EFMapPersonLocationState;

typedef enum {
    kEFRouteLocationTypeUnknow = 0,
    kEFRouteLocationTypeNormal      = 0 << 1,
    kEFRouteLocationTypeDestination = 0 << 2,
    kEFRouteLocationTypeCrossPlace  = 0 << 3,
    kEFRouteLocationTypeBreadcrumb  = 0 << 4,
} EFRouteLocationType;

typedef enum {
    kEFRouteLocationColorBlue = 0,
    kEFRouteLocationColorRed
} EFRouteLocationColor;

extern NSString *EFNotificationRoutePathDidChange;
extern NSString *EFNotificationRouteLocationDidChange;

extern NSString *EFNotificationUserLocationDidChange;
extern NSString *EFNotificationUserLocationOffsetDidGet;

#endif
