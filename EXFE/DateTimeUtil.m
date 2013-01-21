//
//  DateTimeUtil.m
//  EXFE
//
//  Created by Stony Wang on 13-1-8.
//
//

#import "DateTimeUtil.h"
#import "NSDateComponents+Helper.h"

@implementation DateTimeUtil

+ (NSInteger)daysWithinEraFromDate:(NSDate *) startDate toDate:(NSDate *) endDate{
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSInteger startDay = [gregorian ordinalityOfUnit:NSDayCalendarUnit inUnit: NSEraCalendarUnit forDate:startDate];
    NSInteger endDay = [gregorian ordinalityOfUnit:NSDayCalendarUnit inUnit: NSEraCalendarUnit forDate:endDate];
    [gregorian release];
    return endDay - startDay;
}

+ (BOOL)isSameTimezone:(NSTimeZone*) timezoneA with:(NSTimeZone*)timezoneB{
    return [timezoneA secondsFromGMT] == [timezoneB secondsFromGMT];;
}

+ (NSDateComponents*) convert:(NSDateComponents*)comp toTimeZone:(NSTimeZone*)timezone{
    if ([comp hasTimeZone]) {
        if (![DateTimeUtil isSameTimezone:comp.timeZone with:timezone]) {
            if ([comp hasDate]){
                if(![comp hasTime]) {
                    NSDateComponents* result = [[NSDateComponents alloc] init];
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
                    [date release];
                    return [result autorelease];
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
    NSDate *today = [[NSDate alloc] init];
    NSString* result = [DateTimeUtil GetRelativeTime:targetTime fromDate:today baseOn:targetTimeZone format:type];
    [today release];
    return result;
}

+ (NSString*) GetRelativeTime:(NSDateComponents*)targetTime fromDate:(NSDate*)baseDateTime baseOn:(NSTimeZone*)targetTimeZone format:(int)type{
    
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *baseTime = [gregorian components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit) fromDate:baseDateTime];
    [gregorian release];
    NSString* result = [DateTimeUtil GetRelativeTime:targetTime from:baseTime baseOn:targetTimeZone format:type];
    [baseTime release];
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
            if (![targetTime hasTime]){
                targetTime.hour = 0;
                targetTime.minute = 0;
                targetTime.second = 0;
            }
            if (![baseTime hasTime]){
                baseTime.hour = 0;
                baseTime.minute = 0;
                baseTime.second = 0;
            }
            
        }
    }
    
    // get minutes
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
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
            return @"1.5 hour ago";
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
        }else if (m >= 108 && m < 43200){
            NSInteger dateSpan = [DateTimeUtil daysWithinEraFromDate:target toDate:base];
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
                    return [NSString stringWithFormat:@"%@., in %i days", weekday, dateSpan];
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


+ (NSString*) timezoneString:(NSTimeZone*)tz{
    NSInteger seconds = [tz secondsFromGMT];
    NSInteger hh = seconds / 3600;
    NSInteger mm = (seconds - hh * 3600) / 60;
    NSString* abbrviation = [tz abbreviation];
    NSRange range = [abbrviation rangeOfString:@"GMT"];
    NSString* abbr = nil;
    if (NSEqualRanges(range, NSMakeRange(0, 3))) {
        abbr = [NSString stringWithFormat:@"%+.2i:%.2i", hh, mm];
    }else{
        abbr = [NSString stringWithFormat:@"%+.2i:%.2i %@", hh, mm, abbr];
    }
    return abbr;
}

+ (NSInteger) secondsOffsetFromGMT:(NSString*)zoneString{
    NSError *error = NULL;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"([+-]\\d{1,2}):?(\\d{2})" options:NSRegularExpressionCaseInsensitive error:&error];
    
    NSTextCheckingResult* tcResult = [regex firstMatchInString:zoneString options:0 range:NSMakeRange(0, [zoneString length])];
    if (!NSEqualRanges([tcResult range], NSMakeRange(NSNotFound, 0))) {
        
        NSString *matchedString = [zoneString substringWithRange:[tcResult range]];
        NSLog(@"mached: %@", matchedString);
        
        NSString * hstr = [zoneString substringWithRange:[tcResult rangeAtIndex:1]];
        NSString * mstr = [zoneString substringWithRange:[tcResult rangeAtIndex:2]];
        NSLog(@"parsed: %@ %@", hstr, mstr);
        
        NSInteger hh = [hstr integerValue];
        NSInteger mm = [mstr integerValue];
        BOOL sign = hh >= 0;
        NSInteger seconds = (ABS(hh) * 3600 + mm * 60) * (sign ? 1 : -1);
        return seconds;
    }
    return 0;
}



+ (NSString*) getTimeTitle:(CrossTime*) ct{
    if( [ct.outputformat intValue] == 1) { //use origin
        return ct.origin;
    }else{
        if ([DateTimeUtil hasDate:ct.begin_at]){
            return @"Relative Time";
            //return [DateTimeUtil GetRelativeTime:[self.begin_at getLocalDateComponent] format:0];
        }else{
            if ([DateTimeUtil hasTime:ct.begin_at]) {
                return [DateTimeUtil getHumanReadableString:ct.begin_at];
            }else{
                if ([DateTimeUtil hasTimeWord:ct.begin_at]  || [DateTimeUtil hasDateWord:ct.begin_at]) {
                    return [DateTimeUtil getHumanReadableString:ct.begin_at];
                }else{
                    return @"";
                }
            }
        }
    }
}

+ (NSString*) getTimeDescription:(CrossTime*) ct{
    if( [ct.outputformat intValue] == 1) { //use origin
        if ([DateTimeUtil hasDate:ct.begin_at] && [DateTimeUtil hasTime:ct.begin_at]) {
            return [DateTimeUtil GetRelativeTime:[DateTimeUtil getLocalDateComponent:ct.begin_at] format:0];
        }else{
            return @"";
        }
    }else{
        if ([DateTimeUtil hasDate:ct.begin_at]){
            return [DateTimeUtil getHumanReadableString:ct.begin_at];
        }else{
            return @"";
        }
    }
}

+ (NSString*) getTimeSingleLine:(CrossTime*) ct{
    if( [ct.outputformat intValue] == 1) { //use origin
        return ct.origin;
    }else{
        return [DateTimeUtil getHumanReadableString:ct.begin_at];
    }
}

+ (BOOL)hasDate:(EFTime*)eftime{
    return eftime.date != nil && eftime.date.length > 0;
}

+ (BOOL)hasTime:(EFTime*)eftime{
    return eftime.time != nil && eftime.time.length > 0;
}

+ (BOOL)hasDateWord:(EFTime*)eftime{
    return eftime.date_word != nil && eftime.date_word.length > 0;
}

+ (BOOL)hasTimeWord:(EFTime*)eftime{
    return eftime.time_word != nil && eftime.time_word.length > 0;
}

+ (void)setLocalDateComponents:(NSDateComponents *)datetime to:(EFTime*)eftime{
    
    if ([datetime hasDate]) {
        if ([datetime hasTime]) {
            // convert to UTC
            NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
            NSDate *date = [gregorian dateFromComponents:datetime];
            [gregorian release];
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
            [formatter setDateFormat:@"yyyy-MM-dd"];
            eftime.date = [formatter stringFromDate:date];
            [formatter setDateFormat:@"hh:mm:ss"];
            eftime.time = [formatter stringFromDate:date];
            //self.timezone = @"";
            [formatter release];
        }else{
            eftime.date = [NSString stringWithFormat:@"%.4i-%.2i-%.2i", datetime.year, datetime.month, datetime.day];
            eftime.time = @"";
            //self.timezone = @"";
        }
    }else{
        if ([datetime hasTime]) {
            eftime.time = [NSString stringWithFormat:@"%.2i:%.2i:%.2i", datetime.hour, datetime.minute, datetime.second];
            eftime.date = @"";
            //self.timezone = @"";
        }else{
            eftime.date = @"";
            eftime.time = @"";
            //self.timezone = @"";
        }
    }
    
}

+ (NSDateComponents*)getUTCDateComponent:(EFTime*)eftime{
    return [DateTimeUtil getDateComponent:[NSTimeZone timeZoneWithName:@"UTC"] from:eftime];
}

+ (NSDateComponents*)getLocalDateComponent:(EFTime*)eftime{
    return [DateTimeUtil getDateComponent:[NSTimeZone localTimeZone] from:eftime];
}

+ (NSDateComponents*)getDateComponent:(NSTimeZone*)localTimeZone from:(EFTime*)eftime{
    if ([DateTimeUtil hasDate:eftime]) {
        if ([DateTimeUtil hasTime:eftime]) {
            NSString * fullDateTimeStr = [NSString stringWithFormat:@"%@ %@", eftime.date, eftime.time];
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"yyyy-MM-dd hh:mm:ss"];
            [formatter setTimeZone:localTimeZone];
            NSDate *datePartial = [formatter dateFromString:fullDateTimeStr];
            [formatter release];
            [fullDateTimeStr release];
            NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
            NSDateComponents *comps = [gregorian components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit |NSTimeZoneCalendarUnit) fromDate:datePartial];
            [gregorian release];
            [datePartial release];
            return [comps autorelease];
        }else{
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"yyyy-MM-dd"];
            [formatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
            NSDate *datePartial = [formatter dateFromString:eftime.date];
            [formatter release];
            NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
            NSDateComponents *comps = [gregorian components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSTimeZoneCalendarUnit) fromDate:datePartial];
            [gregorian release];
            [datePartial release];
            return [comps autorelease];
        }
    }else{
        if ([DateTimeUtil hasTime:eftime]){
            NSString* fullTimeStr = [NSString stringWithFormat:@"2013-01-01 %@", eftime.time];
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"yyyy-MM-dd hh:mm:ss"];
            [formatter setTimeZone:localTimeZone];
            NSDate *timePartial = [formatter dateFromString:fullTimeStr];
            [formatter release];
            [fullTimeStr release];
            NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
            NSDateComponents *comps = [gregorian components:(NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit | NSTimeZoneCalendarUnit) fromDate:timePartial];
            [gregorian release];
            [timePartial release];
            return [comps autorelease];
        }else{
            return nil;
        }
    }
}

+ (void) setLocalDate:(NSDateComponents*)date andTime:(NSDateComponents*)time to:(EFTime*)eftime{
    if (date == nil && time == nil){
        return;
    }
    
    NSDateComponents * comps = [[NSDateComponents alloc] init];
    if (date != nil) {
        [comps setYear:[date year]];
        [comps setMonth:[date month]];
        [comps setDay:[date day]];
    }
    
    if (time != nil) {
        [comps setHour:[time hour]];
        [comps setMinute:[time minute]];
        [comps setSecond:[time second]];
    }
    [DateTimeUtil setLocalDateComponents:comps to:eftime];
    [comps release];
}

+ (NSTimeZone*) getTargetTimeZone:(EFTime*)eftime{
    NSInteger seconds = [DateTimeUtil secondsOffsetFromGMT:[eftime timezone]];
    return [NSTimeZone timeZoneForSecondsFromGMT:seconds];
}

+ (NSTimeZone*) getTargetTimeZoneWithDST:(EFTime*)eftime{
    return nil;
}

+ (NSTimeZone*) getLocalTimeZone:(EFTime*)eftime{
    return [DateTimeUtil getLocalTimeZoneWithDST:eftime];
}

+ (NSTimeZone*) getLocalTimeZoneWithDST:(EFTime*)eftime{
    return [NSTimeZone localTimeZone];
}

+ (NSString*) getHumanReadableString:(EFTime*)eftime{
    
    NSString * dateFmt = @"EEEE, MMMM d"; // "EEE, MMM d" // "MMM d"
    NSString * timeFmt = @"H:mma"; // HH:mm // H:mm
    
    NSString * datestr = eftime.date;
    NSString * timestr = eftime.time;
    
    if ([DateTimeUtil hasTime:eftime]){
        NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
        NSDateComponents *comps = [DateTimeUtil getLocalDateComponent:eftime];
        [comps retain];
        NSDate* localDate = [gregorian dateFromComponents:comps];
        [comps release];
        [gregorian release];
        if ([DateTimeUtil hasDate:eftime]) {
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:dateFmt];
            datestr = [formatter stringFromDate:localDate];
            [formatter setDateFormat:timeFmt];
            timestr = [formatter stringFromDate:localDate];
            [formatter release];
        }else{
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:timeFmt];
            timestr = [formatter stringFromDate:localDate];
            [formatter release];
        }
    } else {
        NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
        NSDateComponents *comps = [DateTimeUtil getUTCDateComponent:eftime];
        [comps retain];
        NSDate *date = [gregorian dateFromComponents:comps];
        [gregorian release];
        [comps release];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:dateFmt];
        datestr = [formatter stringFromDate:date];
        [formatter release];
    }
    NSLog(@"getHumanReadableString");
    if ([DateTimeUtil hasDate:eftime]) {
        if ([DateTimeUtil hasDateWord:eftime]) {
            if ([DateTimeUtil hasTime:eftime]) {
                if ([DateTimeUtil hasTimeWord:eftime]) {
                    return [NSString stringWithFormat:@"%@ %@ %@ %@", eftime.time_word, timestr, datestr, eftime.date_word];
                }else{
                    return [NSString stringWithFormat:@"%@ %@ %@", timestr, datestr, eftime.date_word];
                }
            }else{
                if ([DateTimeUtil hasTimeWord:eftime]) {
                    return [NSString stringWithFormat:@"%@, %@ %@", eftime.time_word, datestr, eftime.date_word];
                }else{
                    return [NSString stringWithFormat:@"%@ %@", datestr, eftime.date_word];
                }
            }
        }else{
            if ([DateTimeUtil hasTime:eftime]) {
                if ([DateTimeUtil hasTimeWord:eftime]) {
                    return [NSString stringWithFormat:@"%@ %@ %@", eftime.time_word, timestr, datestr];
                }else{
                    return [NSString stringWithFormat:@"%@ %@", timestr, datestr];
                }
            }else{
                if ([DateTimeUtil hasTimeWord:eftime]) {
                    return [NSString stringWithFormat:@"%@, %@", eftime.time_word, datestr];
                }else{
                    return [NSString stringWithFormat:@"%@", datestr];
                }
            }
        }
    }else{
        if ([DateTimeUtil hasDateWord:eftime]) {
            if ([DateTimeUtil hasTime:eftime]) {
                if ([DateTimeUtil hasTimeWord:eftime]) {
                    return [NSString stringWithFormat:@"%@ %@, %@", eftime.time_word, timestr, eftime.date_word];
                }else{
                    return [NSString stringWithFormat:@"%@, %@", timestr, eftime.date_word];
                }
            }else{
                if ([DateTimeUtil hasTimeWord:eftime]) {
                    return [NSString stringWithFormat:@"%@, %@", eftime.time_word, eftime.date_word];
                }else{
                    return [NSString stringWithFormat:@"%@", eftime.date_word];
                }
            }
        }else{
            if ([DateTimeUtil hasTime:eftime]) {
                if ([DateTimeUtil hasTimeWord:eftime]) {
                    return [NSString stringWithFormat:@"%@ %@", eftime.time_word, timestr];
                }else{
                    return [NSString stringWithFormat:@"%@", timestr];
                }
            }else{
                if ([DateTimeUtil hasTimeWord:eftime]) {
                    return [NSString stringWithFormat:@"%@", eftime.time_word];
                }else{
                    return [NSString stringWithFormat:@""];
                }
            }
        }
    }
}

+ (NSString*) getTimeZoneString:(EFTime*)eftime{
    if (![DateTimeUtil isSameTimezone:[DateTimeUtil getTargetTimeZone:eftime] with:[DateTimeUtil getLocalTimeZone:eftime]]) {
        return eftime.timezone;
    }else{
        return @"";
    }
}

@end
