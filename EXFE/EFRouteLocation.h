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
 "desc": "Description",              -> subtitle
 "acc": a.aaa,                       -> accuracy
 "lng": "x.xxx",                    |
 "lat": "y.yyy",                    |-> coordinate
 }
 */

@interface EFRouteLocation : NSObject

@property (nonatomic, copy)     NSString                *locationId;
@property (nonatomic, strong)   NSDate                  *createdDate;
@property (nonatomic, copy)     NSString                *createdByUid;
@property (nonatomic, strong)   NSDate                  *updateDate;
@property (nonatomic, copy)     NSString                *updatedByUid;
@property (nonatomic, copy)     NSURL                   *iconUrl;
@property (nonatomic, copy)     NSString                *title;
@property (nonatomic, copy)     NSString                *subtitle;
@property (nonatomic, assign)   CGFloat                 accuracy;
@property (nonatomic, assign)   CLLocationCoordinate2D  coordinate;
@property (nonatomic, assign)   EFRouteLocationMask     locatinMask;    // for tags
@property (nonatomic, strong)   NSArray                 *tags;

@property (nonatomic, copy)     NSString                *markTitle;
@property (nonatomic, assign)   EFRouteLocationColor    markColor;

@property (nonatomic, assign)   BOOL                    isChanged;

+ (EFRouteLocation *)generateRouteLocationWithCoordinate:(CLLocationCoordinate2D)coordinate;
+ (EFRouteLocation *)generateRouteLocationFromRouteLocation:(EFRouteLocation *)routeLocation;
- (id)initWithDictionary:(NSDictionary *)param;
- (NSDictionary *)dictionaryValue;

- (void)updateIconURL;

@end
