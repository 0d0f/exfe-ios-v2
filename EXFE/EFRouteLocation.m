//
//  EFRouteLocation.m
//  MarauderMap
//
//  Created by 0day on 13-7-16.
//  Copyright (c) 2013年 exfe. All rights reserved.
//

#import "EFRouteLocation.h"

#import "User+EXFE.h"
#import "Identity+EXFE.h"
#import "IdentityId.h"

@implementation EFRouteLocation

+ (EFRouteLocation *)generateRouteLocationWithCoordinate:(CLLocationCoordinate2D)coordinate {
    Identity *identity = [[User getDefaultUser] sortedIdentiesById][0];
    IdentityId *identityId = [identity identityIdValue];
    
    EFRouteLocation *instance = [[self alloc] init];
    instance.locationTytpe = kEFRouteLocationTypeDestination;
    instance.locationId = [NSString stringWithFormat:@"%d", rand() % 255];
    instance.coordinate = coordinate;
    instance.createdDate = [NSDate date];
    instance.createdByUid = identityId.identity_id;
    instance.updateDate = [NSDate date];
    instance.updatedByUid = identityId.identity_id;
    
    return instance;
}

- (id)initWithDictionary:(NSDictionary *)param {
    self = [super init];
    if (self) {
        __block CLLocationDegrees longitude, latitude;
        
        [param enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop){
            if ([key isEqualToString:@"id"]) {
                self.locationId = obj;
            } else if ([key isEqualToString:@"created_at"]) {
                NSDate *date = [NSDate dateWithTimeIntervalSince1970:[obj doubleValue]];
                self.createdDate = date;
            } else if ([key isEqualToString:@"created_by"]) {
                self.createdByUid = obj;
            } else if ([key isEqualToString:@"updated_at"]) {
                NSDate *date = [NSDate dateWithTimeIntervalSince1970:[obj doubleValue]];
                self.updateDate = date;
            } else if ([key isEqualToString:@"updated_by"]) {
                self.updatedByUid = obj;
            } else if ([key isEqualToString:@"tags"]) {
                NSAssert([obj isKindOfClass:[NSArray class]], @"tags should be a array");
                NSString *lastTag = [obj lastObject];
                if ([lastTag isEqualToString:@"park"]) {
                    self.locationTytpe = kEFRouteLocationTypePark;
                } else if ([lastTag isEqualToString:@"destination"]) {
                    self.locationTytpe = kEFRouteLocationTypeDestination;
                }
            } else if ([key isEqualToString:@"icon"]) {
                NSString *iconString = obj;
                self.iconUrl = [NSURL URLWithString:iconString];
            } else if ([key isEqualToString:@"title"]) {
                self.title = obj;
            } else if ([key isEqualToString:@"description"]) {
                self.subtitle = obj;
            } else if ([key isEqualToString:@"longitude"]) {
                longitude = [obj doubleValue];
            } else if ([key isEqualToString:@"latitude"]) {
                latitude = [obj doubleValue];
            }
        }];
        
        self.coordinate = CLLocationCoordinate2DMake(latitude, longitude);
    }
    
    return self;
}

- (NSDictionary *)dictionaryValue {
    NSAssert(kEFRouteLocationTypeUnknow != self.locationTytpe, @"MUST not be unknow!");
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithCapacity:12];
    [dict setValue:self.locationId forKey:@"id"];
    [dict setValue:@"location" forKey:@"type"];
    [dict setValue:[NSNumber numberWithLongLong:(long long)[self.createdDate timeIntervalSince1970]] forKey:@"created_at"];
    [dict setValue:self.createdByUid forKey:@"created_by"];
    [dict setValue:[NSNumber numberWithLongLong:(long long)[self.updateDate timeIntervalSince1970]] forKey:@"updated_at"];
    [dict setValue:self.updatedByUid forKey:@"updated_by"];
    NSArray *tags = nil;
    if (kEFRouteLocationTypePark == self.locationTytpe) {
        tags = @[@"place", @"park"];
    } else if (kEFRouteLocationTypeDestination == self.locationTytpe) {
        tags = @[@"place", @"destination"];
    }
    [dict setValue:tags forKey:@"tags"];
    [dict setValue:[self.iconUrl absoluteString] forKey:@"icon"];
    [dict setValue:self.title forKey:@"title"];
    [dict setValue:self.subtitle forKey:@"desciption"];
    [dict setValue:[NSString stringWithFormat:@"%f", self.coordinate.longitude] forKey:@"longitude"];
    [dict setValue:[NSString stringWithFormat:@"%f", self.coordinate.latitude] forKey:@"latitude"];
    
    return dict;
}

@end
