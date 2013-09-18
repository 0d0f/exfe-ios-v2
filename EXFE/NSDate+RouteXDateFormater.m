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
    
    BOOL isMinitues = YES;
    if ((NSInteger)(timeInterval / 60.0f)) {
        isMinitues = NO;
        timeInterval /= 60;
    }
    
    NSString *string = nil;
    if (((NSInteger)(timeInterval * 10)) % 10 && !isMinitues) {
        string = [NSString stringWithFormat:@"%.1f", timeInterval];
    } else {
        string = [NSString stringWithFormat:@"%.0f", timeInterval];
    }
    
    return string;
}

- (NSString *)formatedTimeIntervalUnitFromNow {
    NSUInteger timeInterval = (NSUInteger)([[NSDate date] timeIntervalSinceDate:self] / 60.0f);
    NSString *time = NSLocalizedString(@"m ago", nil);
    
    if (timeInterval / 60) {
        time = NSLocalizedString(@"h ago", nil);
    }
    
    return time;
}

// eg: 1.5 min
- (NSString *)formatedTimeIntervalFromNowMinutesUpTo90 {
    NSString *timeIntervalString = [NSString stringWithFormat:@"%@%@", [self formatedTimeIntervalValueFromNowMinutesUpTo90], [self formatedTimeIntervalUnitFromNowMinutesUpTo90]];
    
    return timeIntervalString;
}

// eg: 1.5
- (NSString *)formatedTimeIntervalValueFromNowMinutesUpTo90 {
    CGFloat timeInterval = ([[NSDate date] timeIntervalSinceDate:self] / 60.0f);
    
    BOOL isMinitues = YES;
    if ((NSInteger)(timeInterval / 60.0f)) {
        if ((NSInteger)(timeInterval / 90.0f)) {
            isMinitues = NO;
            timeInterval /= 60;
        }
    }
    
    NSString *string = nil;
    if (((NSInteger)(timeInterval * 10)) % 10 && !isMinitues) {
        NSInteger h = (NSInteger)(timeInterval * 10) / 10;
        NSInteger m = ((NSInteger)(timeInterval * 10)) % 10;
        
        if (m < 3) {
            m = 0;
        } else if (m >= 3 && m < 8) {
            m = 5;
        } else {
            h += 1;
            m = 0;
        }
        
        timeInterval = h + 0.1 * m;
        
        string = [NSString stringWithFormat:@"%.1f", timeInterval];
    } else {
        string = [NSString stringWithFormat:@"%.0f", timeInterval];
    }
    
    return string;
}

// eg: min
- (NSString *)formatedTimeIntervalUnitFromNowMinutesUpTo90 {
    CGFloat timeInterval = ([[NSDate date] timeIntervalSinceDate:self] / 60.0f);
    
    BOOL isMinitues = YES;
    if ((NSInteger)(timeInterval / 60.0f)) {
        if ((NSInteger)(timeInterval / 90.0f)) {
            isMinitues = NO;
            timeInterval /= 60;
        }
    }
    
    NSString *time = nil;
    
    if (isMinitues) {
        time = NSLocalizedString(@"m ago", nil);
    } else {
        time = NSLocalizedString(@"h ago", nil);
    }
    
    return time;

}

@end
