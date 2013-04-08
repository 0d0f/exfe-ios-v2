//
//  DateTimeUtil.h
//  EXFE
//
//  Created by Stony Wang on 13-1-8.
//
//

#import <Foundation/Foundation.h>
#import "CrossTime.h"
#import "EFTime.h"

@interface DateTimeUtil : NSObject

+ (NSDate*) dateNow;
+ (void)setNow:(NSDate*)now;
+ (void)clearNow;
+ (void)setAppDefaultTimeZone:(NSTimeZone*)tz;
+ (void)clearAppDefaultTimeZone;

+ (NSDictionary*)datetimeTemplate:(NSUInteger)type;

+ (NSInteger)daysWithinEraFromDate:(NSDate *) startDate toDate:(NSDate *) endDate;
+ (NSInteger)daysWithinEraFromDate:(NSDate *) startDate toDate:(NSDate *) endDate baseTimeZone:(NSTimeZone*)tz;
+ (BOOL)isSameTimezone:(NSTimeZone*) timezoneA with:(NSTimeZone*)timezoneB;
+ (NSDateComponents*) convert:(NSDateComponents*)comp toTimeZone:(NSTimeZone*)timezone;
+ (NSString*) GetRelativeTime:(NSDateComponents*)targetTime format:(int)type;
+ (NSString*) GetRelativeTime:(NSDateComponents*)targetTime baseOn:(NSTimeZone*)targetTimeZone format:(int)type;
+ (NSString*) GetRelativeTime:(NSDateComponents*)targetTime fromDate:(NSDate*)baseDateTime baseOn:(NSTimeZone*)targetTimeZone format:(int)type;
+ (NSString*) GetRelativeTime:(NSDateComponents*)targetTime from:(NSDateComponents*)baseTime baseOn:(NSTimeZone*)targetTimeZone format:(int)type;

+ (NSString*) timezoneString:(NSTimeZone*)tz;
+ (NSInteger) secondsOffsetFromGMT:(NSString*)zoneString;
+ (NSString*) ThreeLettersAbbr:(NSTimeZone*)tz;


+ (NSTimeInterval)secondsBetween:(NSString*)date1 with:(NSString*)date2;

@end
