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

- (BOOL)isTimeWithTimeZone{
    if ([self hasTime]) {
        NSError *error = NULL;
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"([+-]\\d{1,2})(\\d{2})" options:NSRegularExpressionCaseInsensitive error:&error];
        
        NSTextCheckingResult* tcResult = [regex firstMatchInString:self.time options:0 range:NSMakeRange(0, [self.time length])];
        return [tcResult range].length > 0;
    }
    return NO;
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
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
            [formatter setDateFormat:@"yyyy-MM-dd"];
            self.date = [formatter stringFromDate:date];
            // TODO need "+00:00"
            [formatter setDateFormat:@"hh:mm:ss"];  
            self.time = [formatter stringFromDate:date];
        }else{
            self.date = [NSString stringWithFormat:@"%.4i-%.2i-%.2i", datetime.year, datetime.month, datetime.day];
            self.time = @"";
        }
    }else{
        if ([datetime hasTime]) {
            // TODO need "+00:00"
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
            NSString *template = nil;
            if ([self isTimeWithTimeZone]) {
                template = @"%@ %@";
            }else{
                template = @"%@ %@ +0000";
            }
            NSString * fullDateTimeStr = [NSString stringWithFormat:template, self.date, self.time];
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss Z"];
            //[formatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
            NSDate *datePartial = [formatter dateFromString:fullDateTimeStr];
            NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
            [gregorian setTimeZone:localTimeZone];
            NSDateComponents *comps = [gregorian components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit |NSTimeZoneCalendarUnit) fromDate:datePartial];
            return comps;

        }else{
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"yyyy-MM-dd"];
            [formatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
            NSDate *datePartial = [formatter dateFromString:self.date];
            NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
            NSDateComponents *comps = [gregorian components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSTimeZoneCalendarUnit) fromDate:datePartial];
            return comps;
        }
    }else{
        if ([self hasTime]){
            NSString *template = nil;
            if ([self isTimeWithTimeZone]) {
                template = @"2013-01-01 %@";
            }else{
                template = @"2013-01-01 %@ +0000";
            }
            NSString* fullTimeStr = [NSString stringWithFormat:template, self.time];
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss Z"];
            //[formatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
            NSDate *timePartial = [formatter dateFromString:fullTimeStr];
            NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
            [gregorian setTimeZone:localTimeZone];
            NSDateComponents *comps = [gregorian components:(NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit | NSTimeZoneCalendarUnit) fromDate:timePartial];
            return comps;
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
        [comps setTimeZone:[time timeZone]];
    }
    [self setLocalDateComponents:comps];
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
    
    NSString * datestr = [self date];
    NSString * timestr = [self time];
    
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    if ([self hasTime]){
        NSDateComponents *comps = [self getLocalDateComponent];
        NSDate* localDate = [gregorian dateFromComponents:comps];
        if ([self hasDate]) {
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            NSString *language = [NSLocale preferredLanguages][0];
            NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:language];
            [formatter setLocale:locale];
            NSDateComponents *thisYear = [gregorian components:NSYearCalendarUnit fromDate:[DateTimeUtil dateNow]];
            if (thisYear.year == comps.year) {
                [formatter setDateFormat:[dict valueForKey:@"date"]];
            }else{
                [formatter setDateFormat:[dict valueForKey:@"dateWithYear"]];
            }

            datestr = [formatter stringFromDate:localDate];
            [formatter setDateFormat:[dict valueForKey:@"time"]];
            timestr = [formatter stringFromDate:localDate];
        }else{
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            NSString *language = [NSLocale preferredLanguages][0];
            NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:language];
            [formatter setLocale:locale];
            [formatter setDateFormat:[dict valueForKey:@"time"]];
            timestr = [formatter stringFromDate:localDate];
        }
    } else {
        if ([self hasDate]) {
            NSDateComponents *comps = [self getUTCDateComponent];
            NSDate *date = [gregorian dateFromComponents:comps];
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            NSString *language = [NSLocale preferredLanguages][0];
            NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:language];
            [formatter setLocale:locale];
            NSDateComponents *thisYear = [gregorian components:NSYearCalendarUnit fromDate:[DateTimeUtil dateNow]];
            if (thisYear.year == comps.year) {
                [formatter setDateFormat:[dict valueForKey:@"date"]];
            }else{
                [formatter setDateFormat:[dict valueForKey:@"dateWithYear"]];
            }
            datestr = [formatter stringFromDate:date];
        }else{
            
        }
    }
    
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
