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

+ (NSInteger)daysWithinEraFromDate:(NSDate *) startDate toDate:(NSDate *) endDate;
+ (BOOL)isSameTimezone:(NSTimeZone*) timezoneA with:(NSTimeZone*)timezoneB;
+ (NSDateComponents*) convert:(NSDateComponents*)comp toTimeZone:(NSTimeZone*)timezone;
+ (NSString*) GetRelativeTime:(NSDateComponents*)targetTime format:(int)type;
+ (NSString*) GetRelativeTime:(NSDateComponents*)targetTime baseOn:(NSTimeZone*)targetTimeZone format:(int)type;
+ (NSString*) GetRelativeTime:(NSDateComponents*)targetTime fromDate:(NSDate*)baseDateTime baseOn:(NSTimeZone*)targetTimeZone format:(int)type;
+ (NSString*) GetRelativeTime:(NSDateComponents*)targetTime from:(NSDateComponents*)baseTime baseOn:(NSTimeZone*)targetTimeZone format:(int)type;

+ (NSString*) timezoneString:(NSTimeZone*)tz;
+ (NSInteger) secondsOffsetFromGMT:(NSString*)zoneString;

// CrossTime Helper
+ (NSString*) getTimeTitle:(CrossTime*) ct;
+ (NSString*) getTimeDescription:(CrossTime*) ct;
+ (NSString*) getTimeSingleLine:(CrossTime*) ct;

// EFTime Helper
+ (BOOL)hasDate:(EFTime*)eftime;
+ (BOOL)hasTime:(EFTime*)eftime;
+ (BOOL)hasDateWord:(EFTime*)eftime;
+ (BOOL)hasTimeWord:(EFTime*)eftime;
+ (void)setLocalDateComponents:(NSDateComponents *)datetime to:(EFTime*)eftime;
+ (NSDateComponents*)getUTCDateComponent:(EFTime*)eftime;
+ (NSDateComponents*)getLocalDateComponent:(EFTime*)eftime;
+ (NSDateComponents*)getDateComponent:(NSTimeZone*)localTimeZone from:(EFTime*)eftime;
+ (void) setLocalDate:(NSDateComponents*)date andTime:(NSDateComponents*)time to:(EFTime*)eftime;
+ (NSTimeZone*) getTargetTimeZone:(EFTime*)eftime;
+ (NSTimeZone*) getTargetTimeZoneWithDST:(EFTime*)eftime;
+ (NSTimeZone*) getLocalTimeZone:(EFTime*)eftime;
+ (NSTimeZone*) getLocalTimeZoneWithDST:(EFTime*)eftime;
+ (NSString*) getHumanReadableString:(EFTime*)eftime;
+ (NSString*) getTimeZoneString:(EFTime*)eftime;

@end
