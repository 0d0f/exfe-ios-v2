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
    return self.time != nil && self.date.length > 0;
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
            //self.timezone = @"";
            [formatter release];
        }else{
            self.date = [NSString stringWithFormat:@"%.4i-%.2i-%.2i", datetime.year, datetime.month, datetime.day];
            self.time = @"";
            //self.timezone = @"";
        }
    }else{
        if ([datetime hasTime]) {
            self.time = [NSString stringWithFormat:@"%.2i:%.2i:%.2i", datetime.hour, datetime.minute, datetime.second];
            self.date = @"";
            //self.timezone = @"";
        }else{
            self.date = @"";
            self.time = @"";
            //self.timezone = @"";
        }
    }

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
            NSDate *datePartial = [formatter dateFromString:self.date];
            [formatter release];
            NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
            NSDateComponents *comps = [gregorian components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSTimeZoneCalendarUnit) fromDate:datePartial];
            [gregorian release];
            [datePartial release];
            return [comps autorelease];
        }
    }else{
        if ([self hasTime]){
            NSString* fullTimeStr = [NSString stringWithFormat:@"2013-01-01 %@", self.time];
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
    
    NSString * dateFmt = @"EEEE, MMMM d"; // "EEE, MMM d" // "MMM d"
    NSString * timeFmt = @"H:mma"; // HH:mm // H:mm
    
    NSString * datestr = [self date];
    NSString * timestr = [self time];
    
    if ([self hasTime]){
        NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
        NSDateComponents *comps = [self getLocalDateComponent];
        [comps retain];
        NSDate* localDate = [gregorian dateFromComponents:comps];
        [comps release];
        [gregorian release];
        if ([self hasDate]) {
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
        NSDateComponents *comps = [self getUTCDateComponent];
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
    if ([self hasDate]) {
        if ([self hasDateWord]) {
            if ([self hasTime]) {
                if ([self hasTimeWord]) {
                    return [NSString stringWithFormat:@"%@ %@ %@ %@", self.time_word, timestr, datestr, self.date_word];
                }else{
                    return [NSString stringWithFormat:@"%@ %@ %@", timestr, datestr, self.date_word];
                }
            }else{
                if ([self hasTimeWord]) {
                    return [NSString stringWithFormat:@"%@, %@ %@", self.time_word, datestr, self.date_word];
                }else{
                    return [NSString stringWithFormat:@"%@ %@", datestr, self.date_word];
                }
            }
        }else{
            if ([self hasTime]) {
                if ([self hasTimeWord]) {
                    return [NSString stringWithFormat:@"%@ %@ %@", self.time_word, timestr, datestr];
                }else{
                    return [NSString stringWithFormat:@"%@ %@", timestr, datestr];
                }
            }else{
                if ([self hasTimeWord]) {
                    return [NSString stringWithFormat:@"%@, %@", self.time_word, datestr];
                }else{
                    return [NSString stringWithFormat:@"%@", datestr];
                }
            }
        }
    }else{
        if ([self hasDateWord]) {
            if ([self hasTime]) {
                if ([self hasTimeWord]) {
                    return [NSString stringWithFormat:@"%@ %@, %@", self.time_word, timestr, self.date_word];
                }else{
                    return [NSString stringWithFormat:@"%@, %@", timestr, self.date_word];
                }
            }else{
                if ([self hasTimeWord]) {
                    return [NSString stringWithFormat:@"%@, %@", self.time_word, self.date_word];
                }else{
                    return [NSString stringWithFormat:@"%@", self.date_word];
                }
            }
        }else{
            if ([self hasTime]) {
                if ([self hasTimeWord]) {
                    return [NSString stringWithFormat:@"%@ %@", self.time_word, timestr];
                }else{
                    return [NSString stringWithFormat:@"%@", timestr];
                }
            }else{
                if ([self hasTimeWord]) {
                    return [NSString stringWithFormat:@"%@", self.time_word];
                }else{
                    return [NSString stringWithFormat:@""];
                }
            }
        }
    }
}

- (NSString*) getTimeZoneString{
    if (![DateTimeUtil isSameTimezone:[self getTargetTimeZone] with:[self getLocalTimeZone]]) {
        return self.timezone;
    }else{
        return @"";
    }
}

@end
