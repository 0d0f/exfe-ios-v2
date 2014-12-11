//
//  EFRoutePath.h
//  MarauderMap
//
//  Created by 0day on 13-7-16.
//  Copyright (c) 2013年 exfe. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "EFLocation.h"

/**
 {
 "id": "id",                                                                -> pathId
 "type": "route",
 "created_at": 0,                                                           -> createdDate
 "created_by": "id@provider",                                               -> createdByUid
 "updated_at": 0,                                                           -> updatedDate
 "updated_by": "id@provider",                                               -> updatedByUid
 "title": "Title",                                                          -> title
 "description": "Description",                                              -> description
 "color": "rrggbbaa",                                                       -> strokeColor
 "positions": [                                                             -> positions
     {"ts": 9, "lng": "x.xxx", "lat": "y.yyy"},
     ...
     {"ts": 1, "lng": "x.xxx", "lat": "y.yyy"}
     ]
 }
 */

@interface EFRoutePath : NSObject

@property (nonatomic, copy) NSString *pathId;
@property (nonatomic, strong) NSDate *createdDate;
@property (nonatomic, copy) NSString *createdByUid;
@property (nonatomic, strong) NSDate *updatedDate;
@property (nonatomic, copy) NSString *updatedByUid;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *description;
@property (nonatomic, strong) UIColor *strokeColor;
@property (nonatomic, strong) NSArray *positions;

- (id)initWithDictionary:(NSDictionary *)param;
- (NSDictionary *)dictionaryValue;

@end
