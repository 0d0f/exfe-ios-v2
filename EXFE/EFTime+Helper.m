//
//  EFTime+Helper.m
//  EXFE
//
//  Created by Stony Wang on 12-12-28.
//
//

#import "EFTime+Helper.h"
#import "NSDateComponents+Helper.h"
#import "DateTimeUtil.h"

@implementation EFTime (Helper)

- (BOOL)hasDate{
    return self.date != nil && self.date.length > 0;
}

- (BOOL)hasTime{
    return self.time != nil && self.time.length > 0;
}

- (BOOL)hasDateWord{
    return self.date_word != nil && self.date_word.length > 0;
}

- (BOOL)hasTimeWord{
    return self.time_word != nil && self.time_word.length > 0;
}

- (void)setLocalDateComponents:(NSDateComponents *)datetime{
    
    if ([datetime hasDate]) {
        if ([datetime hasTime]) {
            // convert to UTC
            NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
            NSDate *date = [gregorian dateFromComponents:datetime];
            [gregorian release];
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
            [formatter setDateFormat:@"yyyy-MM-dd"];
            self.date = [formatter stringFromDate:date];
            [formatter setDateFormat:@"hh:mm:ss"];
            self.time = [formatter stringFromDate:date];
            [formatter release];
        }else{
            self.date = [NSString stringWithFormat:@"%.4i-%.2i-%.2i", datetime.year, datetime.month, datetime.day];
            self.time = @"";
        }
    }else{
        if ([datetime hasTime]) {
            self.time = [NSString stringWithFormat:@"%.2i:%.2i:%.2i", datetime.hour, datetime.minute, datetime.second];
            self.date = @"";
        }else{
            self.date = @"";
            self.time = @"";
        }
    }
    if (datetime.timeZone) {
        self.timezone = [DateTimeUtil timezoneString:datetime.timeZone];
    }else{
        self.timezone = [DateTimeUtil timezoneString:[NSTimeZone localTimeZone]];
    }
    self.time_word = @"";
    self.date_word = @"";
}

- (NSDateComponents*)getUTCDateComponent{
    return [self getDateComponent:[NSTimeZone timeZoneWithName:@"UTC"]];
}

- (NSDateComponents*)getLocalDateComponent{
    return [self getDateComponent:[NSTimeZone localTimeZone]];
}

- (NSDateComponents*)getDateComponent:(NSTimeZone*)localTimeZone{
    if ([self hasDate]) {
        if ([self hasTime]) {
            NSString * fullDateTimeStr = [NSString stringWithFormat:@"%@ %@", self.date, self.time];
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
            [formatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
            NSDate *datePartial = [formatter dateFromString:fullDateTimeStr];
            [formatter release];
            NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
            [gregorian setTimeZone:localTimeZone];
            NSDateComponents *comps = [gregorian components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit |NSTimeZoneCalendarUnit) fromDate:datePartial];
            [comps retain];
            [gregorian release];
            return [comps autorelease];

        }else{
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"yyyy-MM-dd"];
            [formatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
            NSDate *datePartial = [formatter dateFromString:self.date];
            [formatter release];
            NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
            NSDateComponents *comps = [gregorian components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSTimeZoneCalendarUnit) fromDate:datePartial];
            [comps retain];
            [gregorian release];
            return [comps autorelease];
        }
    }else{
        if ([self hasTime]){
            NSString* fullTimeStr = [NSString stringWithFormat:@"2013-01-01 %@", self.time];
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
            [formatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
            NSDate *timePartial = [formatter dateFromString:fullTimeStr];
            [formatter release];
            NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
            [gregorian setTimeZone:localTimeZone];
            NSDateComponents *comps = [gregorian components:(NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit | NSTimeZoneCalendarUnit) fromDate:timePartial];
            [comps retain];
            [gregorian release];
            return [comps autorelease];
        }else{
            return nil;
        }
    }
}

- (void) setLocalDate:(NSDateComponents*)date andTime:(NSDateComponents*)time{
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
    [self setLocalDateComponents:comps];
    [comps release];
}

- (NSTimeZone*) getTargetTimeZone{
    NSInteger seconds = [DateTimeUtil secondsOffsetFromGMT:[self timezone]];
    return [NSTimeZone timeZoneForSecondsFromGMT:seconds];
}

- (NSTimeZone*) getTargetTimeZoneWithDST{
    return nil;
}

- (NSTimeZone*) getLocalTimeZone{
    return [self getLocalTimeZoneWithDST];
}

- (NSTimeZone*) getLocalTimeZoneWithDST{
    return [NSTimeZone localTimeZone];
}

- (NSString*) getHumanReadableString{
    return [self getHumanReadableString:[self getLocalTimeZone]];
}

- (NSString*) getHumanReadableString:(NSTimeZone*)baseTimeZone{
    
    NSDictionary *dict = [DateTimeUtil datetimeTemplate:2];
    [dict retain];
    
    NSString * datestr = [[self date] copy];
    [datestr retain];
    NSString * timestr = [[self time] copy];
    [timestr retain];
    
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    [gregorian retain];
    if ([self hasTime]){
        NSDateComponents *comps = [self getLocalDateComponent];
        [comps retain];
        NSDate* localDate = [gregorian dateFromComponents:comps];
        if ([self hasDate]) {
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter retain];
            NSDateComponents *thisYear = [gregorian components:NSYearCalendarUnit fromDate:[DateTimeUtil dateNow]];
            if (thisYear.year == comps.year) {
                [formatter setDateFormat:[dict valueForKey:@"date"]];
            }else{
                [formatter setDateFormat:[dict valueForKey:@"dateWithYear"]];
            }

            [datestr release];
            datestr = [formatter stringFromDate:localDate];
            [datestr retain];
            [formatter setDateFormat:[dict valueForKey:@"time"]];
            [timestr release];
            timestr = [formatter stringFromDate:localDate];
            [timestr retain];
            [formatter release];
        }else{
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter retain];
            [formatter setDateFormat:[dict valueForKey:@"time"]];
            [timestr release];
            timestr = [formatter stringFromDate:localDate];
            [timestr retain];
            [formatter release];
        }
        [comps release];
    } else {
        if ([self hasDate]) {
            NSDateComponents *comps = [self getUTCDateComponent];
            [comps retain];
            NSDate *date = [gregorian dateFromComponents:comps];
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            NSDateComponents *thisYear = [gregorian components:NSYearCalendarUnit fromDate:[DateTimeUtil dateNow]];
            if (thisYear.year == comps.year) {
                [formatter setDateFormat:[dict valueForKey:@"date"]];
            }else{
                [formatter setDateFormat:[dict valueForKey:@"dateWithYear"]];
            }
            [datestr release];
            datestr = [formatter stringFromDate:date];
            [datestr retain];
            [formatter release];
            [comps release];
        }else{
            
        }
    }
    [gregorian release];
    [dict release];
    
    NSString* result = nil;
    if ([self hasDate]) {
        if ([self hasDateWord]) {
            if ([self hasTime]) {
                if ([self hasTimeWord]) {
                    result =  [NSString stringWithFormat:@"%@ %@ %@ %@", self.time_word, timestr, datestr, self.date_word];
                }else{
                    result =  [NSString stringWithFormat:@"%@ %@ %@", timestr, datestr, self.date_word];
                }
            }else{
                if ([self hasTimeWord]) {
                    result =  [NSString stringWithFormat:@"%@, %@ %@", self.time_word, datestr, self.date_word];
                }else{
                    result =  [NSString stringWithFormat:@"%@ %@", datestr, self.date_word];
                }
            }
        }else{
            if ([self hasTime]) {
                if ([self hasTimeWord]) {
                    result =  [NSString stringWithFormat:@"%@ %@ %@", self.time_word, timestr, datestr];
                }else{
                    result =  [NSString stringWithFormat:@"%@ %@", timestr, datestr];
                }
            }else{
                if ([self hasTimeWord]) {
                    result =  [NSString stringWithFormat:@"%@, %@", self.time_word, datestr];
                }else{
                    result =  [NSString stringWithFormat:@"%@", datestr];
                }
            }
        }
    }else{
        if ([self hasDateWord]) {
            if ([self hasTime]) {
                if ([self hasTimeWord]) {
                    result =  [NSString stringWithFormat:@"%@ %@, %@", self.time_word, timestr, self.date_word];
                }else{
                    result =  [NSString stringWithFormat:@"%@, %@", timestr, self.date_word];
                }
            }else{
                if ([self hasTimeWord]) {
                    result =  [NSString stringWithFormat:@"%@, %@", self.time_word, self.date_word];
                }else{
                    result =  [NSString stringWithFormat:@"%@", self.date_word];
                }
            }
        }else{
            if ([self hasTime]) {
                if ([self hasTimeWord]) {
                    result =  [NSString stringWithFormat:@"%@ %@", self.time_word, timestr];
                }else{
                    result =  [NSString stringWithFormat:@"%@", timestr];
                }
            }else{
                if ([self hasTimeWord]) {
                    result =  [NSString stringWithFormat:@"%@", self.time_word];
                }else{
                    result =  [NSString stringWithFormat:@""];
                }
            }
        }
    }
    [datestr release];
    [timestr release];
    return result;
}

- (NSString*) getTimeZoneString{
    if (![DateTimeUtil isSameTimezone:[self getTargetTimeZone] with:[self getLocalTimeZone]]) {
        if ([self hasDate]) {
            if ([self hasTime]) {
                return [DateTimeUtil timezoneString:[self getLocalTimeZone]];
            }else{
                return self.timezone;
            }
        }else{
            if ([self hasTime]) {
                return [DateTimeUtil timezoneString:[self getLocalTimeZone]];
            }else{
                return self.timezone;
            }
        }
    }else{
        return @"";
    }
}

@end
