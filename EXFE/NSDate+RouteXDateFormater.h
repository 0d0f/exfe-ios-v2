//
//  NSDate+RouteXDateFormater.h
//  EXFE
//
//  Created by 0day on 13-8-19.
//
//

#import <Foundation/Foundation.h>

@interface NSDate (RouteXDateFormater)

// eg: 1.5 min
- (NSString *)formatedTimeIntervalFromNow;

// eg: 1.5
- (NSString *)formatedTimeIntervalValueFromNow;

// eg: min
- (NSString *)formatedTimeIntervalUnitFromNow;

@end
