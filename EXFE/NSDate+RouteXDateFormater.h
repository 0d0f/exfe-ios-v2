//
//  NSDate+RouteXDateFormater.h
//  EXFE
//
//  Created by 0day on 13-8-19.
//
//

#import <Foundation/Foundation.h>

@interface NSDate (RouteXDateFormater)

// eg: 1 min
- (NSString *)formatedTimeIntervalFromNow;

// eg: 1
- (NSUInteger)formatedTimeIntervalValueFromNow;

// eg: min
- (NSString *)formatedTimeIntervalUnitFromNow;

@end
