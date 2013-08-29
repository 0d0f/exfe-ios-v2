//
//  EFRoutePath.m
//  MarauderMap
//
//  Created by 0day on 13-7-16.
//  Copyright (c) 2013年 exfe. All rights reserved.
//

#import "EFRoutePath.h"

@implementation EFRoutePath

- (UIColor *)colorFromRGBA:(NSString *)rgba {
    NSArray *rgbComponents = [rgba componentsSeparatedByString:@","];
    NSAssert(rgbComponents.count == 4, @"r, g, b, a == 4");
    UIColor *color = [UIColor colorWithRed:([rgbComponents[0] doubleValue] / 255.0f)
                                     green:([rgbComponents[1] doubleValue] / 255.0f)
                                      blue:([rgbComponents[2] doubleValue] / 255.0f)
                                     alpha:[rgbComponents[3] doubleValue]];
    return color;
}

- (NSString *)RGBAStringFromColor:(UIColor *)color {
    NSParameterAssert(color);
    
    CGFloat red, green, blue, alpha;
    [color getRed:&red green:&green blue:&blue alpha:&alpha];
    NSString *rgbaString = [NSString stringWithFormat:@"%f,%f,%f,%f", red * 255.0f, green * 255.0f, blue * 255.0f, alpha];
    return rgbaString;
}

- (id)initWithDictionary:(NSDictionary *)param {
    self = [super init];
    if (self) {
        [param enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop){
            if ([key isEqualToString:@"id"]) {
                self.pathId = obj;
            } else if ([key isEqualToString:@"created_at"]) {
                NSDate *date = [NSDate dateWithTimeIntervalSince1970:[obj doubleValue]];
                self.createdDate = date;
            } else if ([key isEqualToString:@"created_by"]) {
                self.createdByUid = obj;
            } else if ([key isEqualToString:@"updated_at"]) {
                NSDate *date = [NSDate dateWithTimeIntervalSince1970:[obj doubleValue]];
                self.updatedDate = date;
            } else if ([key isEqualToString:@"updated_by"]) {
                self.updatedByUid = obj;
            } else if ([key isEqualToString:@"title"]) {
                self.title = obj;
            } else if ([key isEqualToString:@"desc"]) {
                self.description = obj;
            } else if ([key isEqualToString:@"color"]) {
                self.strokeColor = [self colorFromRGBA:obj];
            } else if ([key isEqualToString:@"positions"]) {
                NSMutableArray *positions = [[NSMutableArray alloc] initWithCapacity:[obj count]];
                NSString *action = [param valueForKey:@"action"];
                BOOL needToSave = NO;
                if (action && [action isEqualToString:@"save_to_history"]) {
                    needToSave = YES;
                }
                
                for (NSDictionary *locationParam in obj) {
                    EFLocation *location = [[EFLocation alloc] initWithDictionary:locationParam];
                    if (needToSave) {
                        location.needToSave = YES;
                    } else {
                        location.needToSave = NO;
                    }
                    
                    [positions addObject:location];
                }
                
                self.positions = positions;
            }
        }];
    }
    
    return self;
}

- (NSDictionary *)dictionaryValue {
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithCapacity:10];
    [dict setValue:self.pathId forKey:@"id"];
    [dict setValue:@"route" forKey:@"type"];
    [dict setValue:[NSNumber numberWithLong:(long)[self.createdDate timeIntervalSince1970]] forKey:@"created_at"];
    [dict setValue:self.createdByUid forKey:@"created_by"];
    [dict setValue:[NSNumber numberWithLong:(long)[self.updatedDate timeIntervalSince1970]] forKey:@"updated_at"];
    [dict setValue:self.updatedByUid forKey:@"updated_by"];
    [dict setValue:self.title forKey:@"title"];
    [dict setValue:self.description forKey:@"desc"];
    [dict setValue:[self RGBAStringFromColor:self.strokeColor] forKey:@"color"];
    NSMutableArray *positions = [[NSMutableArray alloc] initWithCapacity:self.positions.count];
    for (EFLocation *location in self.positions) {
        NSDictionary *locationDict = [location dictionaryValueWitoutAccuracy];
        [positions addObject:locationDict];
    }
    [dict setValue:positions forKey:@"positions"];
    
    return dict;
}

@end
