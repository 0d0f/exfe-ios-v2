//
//  DateTimeUtil.h
//  EXFE
//
//  Created by Stony Wang on 13-1-8.
//
//

#import <Foundation/Foundation.h>

@interface DateTimeUtil : NSObject

+ (NSInteger)daysWithinEraFromDate:(NSDate *) startDate toDate:(NSDate *) endDate;
+ (BOOL)isSameTimezone:(NSTimeZone*) timezoneA with:(NSTimeZone*)timezoneB;
+ (NSDateComponents*) convert:(NSDateComponents*)comp toTimeZone:(NSTimeZone*)timezone;
+ (NSString*) GetRelativeTime:(NSDateComponents*)targetTime format:(int)type;
+ (NSString*) GetRelativeTime:(NSDateComponents*)targetTime baseOn:(NSTimeZone*)targetTimeZone format:(int)type;
+ (NSString*) GetRelativeTime:(NSDateComponents*)targetTime fromDate:(NSDate*)baseDateTime baseOn:(NSTimeZone*)targetTimeZone format:(int)type;
+ (NSString*) GetRelativeTime:(NSDateComponents*)targetTime from:(NSDateComponents*)baseTime baseOn:(NSTimeZone*)targetTimeZone format:(int)type;

+ (NSString*) timezoneString:(NSTimeZone*)tz;
+ (NSInteger) secondsOffsetFromGMT:(NSString*)zoneString;

@end
