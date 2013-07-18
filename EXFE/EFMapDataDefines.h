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
    EFMapPersonConnectStateOffline,
} EFMapPersonConnectState;

typedef enum {
    kEFMapPersonLocationStateUnknow = 0,
    kEFMapPersonLocationStateOnTheWay,
    kEFMapPersonLocationStateArrival,
} EFMapPersonLocationState;

typedef enum {
    kEFRouteLocationTypeUnknow = 0,
    kEFRouteLocationTypePark,
    kEFRouteLocationTypeDestination
} EFRouteLocationType;

typedef enum {
    kEFRouteLocationColorBlue = 0,
    kEFRouteLocationColorRed
} EFRouteLocationColor;

extern NSString *EFNotificationRoutePathDidChange;
extern NSString *EFNotificationRouteLocationDidChange;

#endif
