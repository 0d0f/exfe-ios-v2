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
    NSString *timeIntervalString = [NSString stringWithFormat:@"%@%@", [self formatedTimeIntervalValueFromNow], [self formatedTimeIntervalUnitFromNow]];
    
    return timeIntervalString;
}

- (NSString *)formatedTimeIntervalValueFromNow {
    CGFloat timeInterval = ([[NSDate date] timeIntervalSinceDate:self] / 60.0f);
    
    if (timeInterval / 60.0f) {
        timeInterval /= 60;
    }
    
    NSString *string = nil;
    if (((NSInteger)(timeInterval * 10)) % 10) {
        string = [NSString stringWithFormat:@"%.1f", timeInterval];
    } else {
        string = [NSString stringWithFormat:@"%.0f", timeInterval];
    }
    
    return string;
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
