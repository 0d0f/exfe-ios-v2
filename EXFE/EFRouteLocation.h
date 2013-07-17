//
//  EFRouteLocation.h
//  MarauderMap
//
//  Created by 0day on 13-7-16.
//  Copyright (c) 2013年 exfe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

#import "EFMapDataDefines.h"

/**
 {
 "id": "id",                         -> locationId
 "type": "location",
 "created_at": 0,                    -> createDate
 "created_by": "uid",                -> createdByUid
 "updated_at": 0,                    -> updateDate
 "updated_by": "uid",                -> updatedByUid
 "tags": ["place", "park"],          -> locationType
 "icon": "http://...",               -> iconUrl
 "title": "Title",                   -> title
 "description": "Description",       -> subtitle
 "longitude": "x.xxx",              |
 "latitude": "y.yyy",               |-> coordinate
 }
 */

@interface EFRouteLocation : NSObject

@property (nonatomic, copy)     NSString                *locationId;
@property (nonatomic, strong)   NSDate                  *createdDate;
@property (nonatomic, copy)     NSString                *createdByUid;
@property (nonatomic, strong)   NSDate                  *updateDate;
@property (nonatomic, copy)     NSString                *updatedByUid;
@property (nonatomic, assign)   EFRouteLocationType     locationTytpe;
@property (nonatomic, copy)     NSURL                   *iconUrl;
@property (nonatomic, copy)     NSString                *title;
@property (nonatomic, copy)     NSString                *subtitle;
@property (nonatomic, assign)   CLLocationCoordinate2D  coordinate;

+ (EFRouteLocation *)generateRouteLocationWithCoordinate:(CLLocationCoordinate2D)coordinate;
- (id)initWithDictionary:(NSDictionary *)param;
- (NSDictionary *)dictionaryValue;

@end
