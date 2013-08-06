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

@interface EFRouteLocation (Private)

- (void)_updateIconURL;

@end

@implementation EFRouteLocation (Private)

- (void)_updateIconURL {
    RKObjectManager *objectManager = [RKObjectManager sharedManager];
    NSURL *baseURl = objectManager.HTTPClient.baseURL;
    
    switch (self.locationTytpe) {
        case kEFRouteLocationTypeDestination:
        {
            NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/map_pin_blue@2x.png", IMG_ROOT]];
            self.iconUrl = url;
        }
            break;
        case kEFRouteLocationTypePark:
        {
            NSString *endPoint = nil;
            if (kEFRouteLocationColorBlue == self.markColor) {
                endPoint = [NSString stringWithFormat:@"/v3/icons/mapmark?content=%@&color=blue", self.markTitle];
            } else {
                endPoint = [NSString stringWithFormat:@"/v3/icons/mapmark?content=%@&color=red", self.markTitle];
            }
            NSURL *url = [NSURL URLWithString:endPoint
                                relativeToURL:baseURl];
            self.iconUrl = url;
        }
            break;
        default:
            break;
    }
}

@end

@implementation EFRouteLocation

+ (EFRouteLocation *)generateRouteLocationWithCoordinate:(CLLocationCoordinate2D)coordinate {
    Identity *identity = [[User getDefaultUser] sortedIdentiesById][0];
    IdentityId *identityId = [identity identityIdValue];
    
    EFRouteLocation *instance = [[self alloc] init];
    instance.locationTytpe = kEFRouteLocationTypeUnknow;
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
        
        self.markTitle = @"P";
        self.markColor = kEFRouteLocationColorBlue;
        
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
                if (iconString) {
                    NSArray *comps = [iconString componentsSeparatedByString:@"?"];
                    if (comps.count == 2) {
                        NSArray *params = [[comps lastObject] componentsSeparatedByString:@"&"];
                        for (NSString *param in params) {
                            NSArray *kv = [param componentsSeparatedByString:@"="];
                            if (kv.count == 2) {
                                if ([kv[0] isEqualToString:@"content"]) {
                                    self.markTitle = kv[1];
                                } else if ([kv[0] isEqualToString:@"color"]) {
                                    if ([kv[1] isEqualToString:@"red"]) {
                                        self.markColor = kEFRouteLocationColorRed;
                                    } else {
                                        self.markColor = kEFRouteLocationColorBlue;
                                    }
                                }
                            }
                        }
                    }
                }
                self.iconUrl = [NSURL URLWithString:iconString];
            } else if ([key isEqualToString:@"title"]) {
                self.title = obj;
            } else if ([key isEqualToString:@"desc"]) {
                self.subtitle = obj;
            } else if ([key isEqualToString:@"acc"]) {
                self.accuracy = [obj doubleValue];
            } else if ([key isEqualToString:@"lng"]) {
                longitude = [obj doubleValue];
            } else if ([key isEqualToString:@"lat"]) {
                latitude = [obj doubleValue];
            }
        }];
        
        self.coordinate = CLLocationCoordinate2DMake(latitude, longitude);
    }
    
    return self;
}

- (void)setLocationTytpe:(EFRouteLocationType)locationTytpe {
    if (_locationTytpe == locationTytpe)
        return;
    
    _locationTytpe = locationTytpe;
    
    switch (locationTytpe) {
        case kEFRouteLocationTypeDestination:
        {
            self.markTitle = @"终";
            self.markColor = kEFRouteLocationColorBlue;
            [self _updateIconURL];
        }
            break;
        case kEFRouteLocationTypePark:
        {
            self.markTitle = @"P";
            self.markColor = kEFRouteLocationColorBlue;
            [self _updateIconURL];
        }
            break;
        default:
            break;
    }
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
    [dict setValue:self.title ? self.title : @"" forKey:@"title"];
    [dict setValue:self.subtitle ? self.subtitle : @"" forKey:@"desc"];
    [dict setValue:[NSString stringWithFormat:@"%f", self.accuracy] forKey:@"acc"];
    [dict setValue:[NSString stringWithFormat:@"%f", self.coordinate.longitude] forKey:@"lng"];
    [dict setValue:[NSString stringWithFormat:@"%f", self.coordinate.latitude] forKey:@"lat"];
    
    return dict;
}

- (void)updateIconURL {
    [self _updateIconURL];
}

@end
