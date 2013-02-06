//
//  DateTimeUtil.m
//  EXFE
//
//  Created by Stony Wang on 13-1-8.
//
//

#import "DateTimeUtil.h"
#import "NSDateComponents+Helper.h"

static NSDate* s_Now = nil;

@implementation DateTimeUtil

+ (NSDate*) dateNow{
    if (s_Now) {
        return s_Now;
    }else{
        return [NSDate date];
    }
}

+ (void)setNow:(NSDate*)now{
    [s_Now release];
    s_Now = now;
//    [s_Now retain];
}

+ (void)clearNow{
    [s_Now release];
    s_Now = nil;
}

+ (void)setAppDefaultTimeZone:(NSTimeZone*)tz{
    [NSTimeZone setDefaultTimeZone:tz];
}

+ (void)clearAppDefaultTimeZone{
    [NSTimeZone setDefaultTimeZone:[NSTimeZone systemTimeZone]];
}

+ (NSDictionary*)datetimeTemplate:(NSUInteger)type{
    NSDictionary *result = nil;
    switch (type) {
        case 0: // ISO 8601 
            result = [NSDictionary dictionaryWithObjectsAndKeys:@"MM-dd", @"date", @"yyyy-MM-dd", @"dateWithYear", @"HH:mm:ss", @"time", nil];
            break;
        case 1: // Long
            result = [NSDictionary dictionaryWithObjectsAndKeys:@"EEEE, MMMM d", @"date", @"EEEE, MMMM d yyyy", @"dateWithYear", @"HH:mm", @"time", nil];
            break;
        case 2: // Mid
            result = [NSDictionary dictionaryWithObjectsAndKeys:@"EEE, MMM d", @"date", @"EEE, MMM d yyyy", @"dateWithYear", @"h:mma", @"time", nil];
            break;
        case 3 : // Short
            result = [NSDictionary dictionaryWithObjectsAndKeys:@"MMM d", @"date", @"MMM d yyyy", @"dateWithYear", @"h:mm", @"time", nil];
            break;
        default:
            break;
    }
    return result;
}

+ (NSInteger)daysWithinEraFromDate:(NSDate *) startDate toDate:(NSDate *) endDate{
    return [DateTimeUtil daysWithinEraFromDate:startDate toDate:endDate baseTimeZone:[NSTimeZone localTimeZone]];
}

+ (NSInteger)daysWithinEraFromDate:(NSDate *) startDate toDate:(NSDate *) endDate baseTimeZone:(NSTimeZone*)tz{
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSInteger offset = tz.secondsFromGMT;
    NSDate *sDate = [NSDate dateWithTimeInterval:offset sinceDate:startDate];
    NSDate *eDate = [NSDate dateWithTimeInterval:offset sinceDate:endDate];
    NSInteger startDay = [gregorian ordinalityOfUnit:NSDayCalendarUnit inUnit: NSEraCalendarUnit forDate:sDate];
    NSInteger endDay = [gregorian ordinalityOfUnit:NSDayCalendarUnit inUnit: NSEraCalendarUnit forDate:eDate];
    [gregorian release];
    return endDay - startDay;
}

//+ (NSInteger)daysWithinEraFromDate:(NSDate *) startDate toDate:(NSDate *) endDate baseTimeZone:(NSTimeZone*)tz{
//    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
//    [gregorian setTimeZone:tz];
//    NSInteger startDay = [gregorian ordinalityOfUnit:NSDayCalendarUnit inUnit: NSEraCalendarUnit forDate:startDate];
//    NSInteger endDay = [gregorian ordinalityOfUnit:NSDayCalendarUnit inUnit: NSEraCalendarUnit forDate:endDate];
//    [gregorian release];
//    return endDay - startDay;
//}

+ (BOOL)isSameTimezone:(NSTimeZone*) timezoneA with:(NSTimeZone*)timezoneB{
    return [timezoneA secondsFromGMT] == [timezoneB secondsFromGMT];;
}

+ (NSDateComponents*) convert:(NSDateComponents*)comp toTimeZone:(NSTimeZone*)timezone{
    if ([comp hasTimeZone]) {
        if (![DateTimeUtil isSameTimezone:comp.timeZone with:timezone]) {
            if ([comp hasDate]){
                if(![comp hasTime]) {
                    NSDateComponents* result = [[[NSDateComponents alloc] init] autorelease];
                    result.year = comp.year;
                    result.month = comp.month;
                    result.day = comp.day;
                    result.timeZone = timezone;
                    return result;
                }else{
                    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
                    [gregorian setTimeZone:comp.timeZone];
                    NSDate *date = [gregorian dateFromComponents:comp];
                    [gregorian setTimeZone:timezone];
                    NSUInteger flag = NSTimeZoneCalendarUnit;
                    flag = flag | NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit;
                    flag = flag | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
                    NSDateComponents *result = [gregorian components:flag fromDate:date];
                    [gregorian release];
//                    [date release];
                    return result;
                }
            }
        }
    }
    return nil;
}

+ (NSString*) GetRelativeTime:(NSDateComponents*)targetTime format:(int)type{
    return [DateTimeUtil GetRelativeTime:targetTime baseOn:[NSTimeZone localTimeZone] format:type];
}

+ (NSString*) GetRelativeTime:(NSDateComponents*)targetTime baseOn:(NSTimeZone*)targetTimeZone format:(int)type{
    NSString* result = [DateTimeUtil GetRelativeTime:targetTime fromDate:[DateTimeUtil dateNow] baseOn:targetTimeZone format:type];
    return result;
}

+ (NSString*) GetRelativeTime:(NSDateComponents*)targetTime fromDate:(NSDate*)baseDateTime baseOn:(NSTimeZone*)targetTimeZone format:(int)type{
    
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
//    [gregorian retain];
    NSDateComponents *baseTime = [gregorian components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit | NSTimeZoneCalendarUnit) fromDate:baseDateTime];
    [gregorian release];
    NSString* result = [DateTimeUtil GetRelativeTime:targetTime from:baseTime baseOn:targetTimeZone format:type];
    return result;
}

// Type: 0 full content, 1 short content
+ (NSString*) GetRelativeTime:(NSDateComponents*)targetTime from:(NSDateComponents*)baseTime baseOn:(NSTimeZone*)targetTimeZone format:(int)type{
    
    
    // Convert Timezone:
    if (![DateTimeUtil isSameTimezone:targetTime.timeZone with:targetTimeZone]) {
        NSDateComponents* temp = [DateTimeUtil convert:targetTime toTimeZone:targetTimeZone];
        if (temp != nil) {
            targetTime = temp;
        }
    }
    
    if (![DateTimeUtil isSameTimezone:baseTime.timeZone with:targetTimeZone]) {
        NSDateComponents* temp = [DateTimeUtil convert:baseTime toTimeZone:targetTimeZone];
        if (temp != nil) {
            baseTime = temp;
        }
    }
    
    // handle missing time
    if (([targetTime hasDate] && ![targetTime hasTime]) || ([baseTime hasDate] && ![baseTime hasTime])) {
        if (targetTime.year == baseTime.year && targetTime.month == baseTime.month && targetTime.day == baseTime.day) {
            return @"Today";
        }else{
            // Normalize date time
            if ([targetTime hasTime]){
                targetTime.hour = 0;
                targetTime.minute = 0;
                targetTime.second = 0;
            }
            if ([baseTime hasTime]){
                baseTime.hour = 0;
                baseTime.minute = 0;
                baseTime.second = 0;
            }
        }
    }
    
    // get minutes
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
//    [gregorian retain];
    NSDate* target = [gregorian dateFromComponents:targetTime];
    NSDate* base = [gregorian dateFromComponents:baseTime];
    [gregorian release];
    NSTimeInterval interval = [target timeIntervalSinceDate:base];
    int minutes = (int)(interval / 60);
    
    // get result string according to the table
    if (minutes <= 0) {
        NSInteger m = -minutes;
        if (m == 0){
            if (type == 1) {
                return @"Now";
            }else{
                return @"Seconds ago";
            }
        }else if (m >= 1 && m < 30){
            if (type == 1) {
                return @"Now";
            }else{
                return [NSString stringWithFormat:@"%i minutes ago", m];
            }
        }else if (m >= 30 && m < 60){
            if (type == 1) {
                return @"Just now";
            }else{
                return [NSString stringWithFormat:@"%i minutes ago", m];
            }
        }else if (m >= 60 && m < 82){
            return @"An hour ago";
        }else if (m >= 82 && m <  108){
            return @"1.5 hours ago";
        }else if (m >= 108 && m < 720){
            int h = (m + 12) / 60;
            return [NSString stringWithFormat:@"%i hours ago", h];
        }else if (m >= 720 && m < 43200){
            NSInteger dateSpan = [DateTimeUtil daysWithinEraFromDate:target toDate:base];
            if (m >= 720 && m < 1440){
                if (dateSpan == 1){
                    return @"Yesterday";
                }else{
                    int h = (m + 12) / 60;
                    return [NSString stringWithFormat:@"%i hours ago", h];
                }
            }else if (m >= 1440 && m < 2880){
                if (dateSpan == 1){
                    return @"Yesterday";
                }else{
                    return @"Two days ago";
                }
            }else /*if (m >= 2880 && m < 43200)*/{
                if (dateSpan == 2){
                    return @"Two days ago";
                }else{
                    //NSInteger dd = (m + 1439) / 1440;
                    return [NSString stringWithFormat:@"%i days ago", dateSpan];
                }
            }
        }else{
            NSInteger yy = m / 525949;
            NSInteger mm = ((m % 525949) + 8766) / 43829;
            
            NSString *years = nil;
            if (yy == 1) {// tricky for English only
                years = [NSString stringWithFormat:@"%i year", yy];
            }else{
                years = [NSString stringWithFormat:@"%i years", yy];
            }
            
            NSString *months = nil;
            if (mm == 1) {// tricky for English only
                months = [NSString stringWithFormat:@"%i month", mm];
            }else{
                months = [NSString stringWithFormat:@"%i months", mm];
            }
            
            if (yy == 0){
                if (mm == 0) {
                    return @""; //ERROR
                }else{
                    return [NSString stringWithFormat:@"%@ ago", months];
                }
            }else{
                if (mm == 0) {
                    return [NSString stringWithFormat:@"%@ ago", years];
                }else{
                    return [NSString stringWithFormat:@"%@ %@ ago", years, months];
                }
            }
        }
    }else{
        NSInteger m = minutes;
        if (m >=1 && m < 60){
            return [NSString stringWithFormat:@"In %i minutes", m];
        }else if (m >= 60 && m < 82){
            return @"In one hour";
        }else if (m >= 82 && m < 108){
            return @"In 1.5 hours";
        }else if (m >= 108 && m < 720){
            int h = (m + 12) / 60;
            return [NSString stringWithFormat:@"In %i hours", h];
        }else if (m >= 720 && m < 43200){
            NSInteger dateSpan = [DateTimeUtil daysWithinEraFromDate:base toDate:target];
            if (m >= 720 && m < 1440){
                if (dateSpan == 1){
                    return @"Tomorrow";
                }else{
                    int h = (m + 12) / 60;
                    return [NSString stringWithFormat:@"In %i hours", h];
                }
            }else if (m >= 1440 && m < 2880){
                if (dateSpan == 1){
                    return @"Tomorrow";
                }else{
                    return @"In two days";
                }
            }else /*if (m >= 2880 && m < 43200)*/{
                if (dateSpan == 2){
                    return @"In two days";
                }else{
                    //NSInteger dd = (m + 1439) / 1440;
                    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                    [dateFormatter setDateFormat:@"EEE"];
                    NSLocale *usLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
                    [dateFormatter setLocale:usLocale];
                    [usLocale release];
                    NSString *weekday = [dateFormatter stringFromDate:target];
                    [dateFormatter release];
                    return [NSString stringWithFormat:@"%@. in %i days", weekday, dateSpan];
                }
            }
        }else{
            NSInteger yy = m / 525949;
            NSInteger mm = ((m % 525949) + 8766) / 43829;
            
            NSString *years = nil;
            if (yy == 1) {// tricky for English only
                years = [NSString stringWithFormat:@"%i year", yy];
            }else{
                years = [NSString stringWithFormat:@"%i years", yy];
            }
            
            NSString *months = nil;
            if (mm == 1) {// tricky for English only
                months = [NSString stringWithFormat:@"%i month", mm];
            }else{
                months = [NSString stringWithFormat:@"%i months", mm];
            }
            
            if (yy == 0){
                if (mm == 0) {
                    return @""; //ERROR
                }else{
                    return [NSString stringWithFormat:@"In %@", months];
                }
            }else{
                if (mm == 0) {
                    return [NSString stringWithFormat:@"In %@", years];
                }else{
                    return [NSString stringWithFormat:@"In %@ %@", years, months];
                }
            }
        }
    }
    return @""; //ERROR
}

+ (NSString*) ThreeLettersAbbr:(NSTimeZone*)tz{
    NSDate* date = [NSDate date];
    NSDateFormatter* fmt = [[NSDateFormatter alloc] init];
    [fmt setTimeZone:tz];
    [fmt setDateFormat:@"z"];
    NSString * abbr = [fmt stringFromDate:date];
    [fmt release];
    return abbr;
}

+ (NSString*) timezoneString:(NSTimeZone*)tz{
    NSInteger seconds = [tz secondsFromGMT];
    NSInteger hh = seconds / 3600;
    NSInteger mm = (seconds - hh * 3600) / 60;
    return [NSString stringWithFormat:@"%+.2i:%.2i", hh, mm]; //ISO 8601
}

+ (NSInteger) secondsOffsetFromGMT:(NSString*)zoneString{
    NSError *error = NULL;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"([+-]\\d{1,2}):?(\\d{2})" options:NSRegularExpressionCaseInsensitive error:&error]; // BOth ISO 8601 and RFC 822
    
    NSTextCheckingResult* tcResult = [regex firstMatchInString:zoneString options:0 range:NSMakeRange(0, [zoneString length])];
    if (!NSEqualRanges([tcResult range], NSMakeRange(NSNotFound, 0))) {
        
        //NSString *matchedString = [zoneString substringWithRange:[tcResult range]];
        //NSLog(@"mached: %@", matchedString);
        
        NSString * hstr = [zoneString substringWithRange:[tcResult rangeAtIndex:1]];
        NSString * mstr = [zoneString substringWithRange:[tcResult rangeAtIndex:2]];
        
        NSInteger hh = [hstr integerValue];
        NSInteger mm = [mstr integerValue];
        BOOL sign = hh >= 0;
        NSInteger seconds = (ABS(hh) * 3600 + mm * 60) * (sign ? 1 : -1);
        return seconds;
    }
    return 0;
}

@end
