//
//  NSDate+RouteXDateFormater.m
//  EXFE
//
//  Created by 0day on 13-8-19.
//
//

#import "NSDate+RouteXDateFormater.h"

@implementation NSDate (RouteXDateFormater)

- (NSString *)formatedTimeIntervalFromNow {
    NSString *timeIntervalString = [NSString stringWithFormat:@"%u%@", [self formatedTimeIntervalValueFromNow], [self formatedTimeIntervalUnitFromNow]];
    
    return timeIntervalString;
}

- (NSUInteger)formatedTimeIntervalValueFromNow {
    NSUInteger timeInterval = (NSUInteger)([[NSDate date] timeIntervalSinceDate:self] / 60.0f);
    
    if (timeInterval / 60) {
        timeInterval /= 60;
    }
    
    return timeInterval;
}

- (NSString *)formatedTimeIntervalUnitFromNow {
    NSUInteger timeInterval = (NSUInteger)([[NSDate date] timeIntervalSinceDate:self] / 60.0f);
    NSString *time = NSLocalizedString(@"分钟前", nil);
    
    if (timeInterval / 60) {
        time = NSLocalizedString(@"小时前", nil);
    }
    
    return time;
}

@end
