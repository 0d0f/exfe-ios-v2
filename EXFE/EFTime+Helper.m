//
//  EFTime+Helper.m
//  EXFE
//
//  Created by Stony Wang on 12-12-28.
//
//

#import "EFTime+Helper.h"

@implementation EFTime (Helper)

- (BOOL)hasDate{
    return self.date != nil && self.date.length > 0;
}

- (BOOL)hasTime{
    return self.time != nil && self.date.length > 0;
}

- (NSDate*)getUTCFullDate{
    if ([self hasDate]) {
        if ([self hasTime]){
            NSString* fullDateStr = [NSString stringWithFormat:@"%@ %@", self.date, self.time];
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
            [formatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
            NSDate *fullDate = [formatter dateFromString:fullDateStr];
            [formatter release];
            return fullDate;
        }else{
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"yyyy-MM-dd"];
            [formatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
            NSDate *fullDate = [formatter dateFromString:self.date];
            [formatter release];
            return fullDate;
        }
    }else {
        if ([self hasTime]) {
            return nil;
        }else{
            return nil;
        }
    }
}

- (NSDateComponents *)getUTCDate{
    if ([self hasDate]) {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd"];
        [formatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
        NSDate *datePartial = [formatter dateFromString:self.date];
        [formatter release];
        NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
        NSDateComponents *comps = [gregorian components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:datePartial];
        [gregorian release];
        [datePartial release];
        return [comps autorelease];
    }else{
        return nil;
    }
}

- (NSDateComponents *)getUTCTime{
    if ([self hasTime]){
        NSString* fullTimeStr = nil;
        if ([self hasDate]) {
            fullTimeStr = [NSString stringWithFormat:@"%@ %@", self.date, self.time];
        }else{
            fullTimeStr = [NSString stringWithFormat:@"2013-01-01 %@", self.time];
        }
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd hh:mm:ss"];
        [formatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
        NSDate *timePartial = [formatter dateFromString:fullTimeStr];
        [formatter release];
        [fullTimeStr release];
        NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
        NSDateComponents *comps = [gregorian components:(NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit) fromDate:timePartial];
        [gregorian release];
        [timePartial release];
        return [comps autorelease];
    }else{
        return nil;
    }
}

- (void) setLocalDate:(NSDateComponents*)date andTime:(NSDateComponents*)time{
    NSDateComponents * comps = [[NSDateComponents alloc] init];
    if (date != nil) {
        if (time != nil) {
            [comps setYear:[date year]];
            [comps setMonth:[date month]];
            [comps setDay:[date day]];
            [comps setHour:[time hour]];
            [comps setMinute:[time minute]];
            [comps setSecond:[time second]];
            NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
            NSDate *date = [gregorian dateFromComponents:comps];
            [gregorian release];
            
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
            [formatter setDateFormat:@"yyyy-MM-dd"];
            self.date = [formatter stringFromDate:date];
            [formatter setDateFormat:@"hh:mm:ss"];
            self.time = [formatter stringFromDate:date];
        }else{
            self.date = [NSString stringWithFormat:@"%.4i-%.2i-%.2i", date.year, date.month, date.day];
            self.time = nil;
        }
    }
    
}

- (NSDateComponents*) getLocalDate{
    if ([self hasDate]) {
        if ([self hasTime]) {
            NSString * fullDateTimeStr = [NSString stringWithFormat:@"%@ %@", self.date, self.time];
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"yyyy-MM-dd hh:mm:ss"];
            [formatter setTimeZone:[self getLocalTimeZone]];
            NSDate *datePartial = [formatter dateFromString:fullDateTimeStr];
            [formatter release];
            [fullDateTimeStr release];
            NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
            NSDateComponents *comps = [gregorian components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:datePartial];
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
            NSDateComponents *comps = [gregorian components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:datePartial];
            [gregorian release];
            [datePartial release];
            return [comps autorelease];
        }
    }else{
        return nil;
    }
}

- (NSDateComponents*) getLocalTime{
    if ([self hasTime]){
        NSString* fullTimeStr = nil;
        if ([self hasDate]) {
            fullTimeStr = [NSString stringWithFormat:@"%@ %@", self.date, self.time];
        }else{
            fullTimeStr = [NSString stringWithFormat:@"2013-01-01 %@", self.time];
        }
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd hh:mm:ss"];
        [formatter setTimeZone:[self getLocalTimeZone]];
        NSDate *timePartial = [formatter dateFromString:fullTimeStr];
        [formatter release];
        [fullTimeStr release];
        NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
        NSDateComponents *comps = [gregorian components:(NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit) fromDate:timePartial];
        [gregorian release];
        [timePartial release];
        return [comps autorelease];
    }else{
        return nil;
    }
}

- (NSTimeZone*) getTargetTimeZone{
    return nil;
}

- (NSTimeZone*) getTargetTimeZoneWithDST{
    NSError *error = NULL;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"[+-]\\d{1,2}:?\\d{2}" options:NSRegularExpressionCaseInsensitive error:&error];
//    NSUInteger numberOfMatches = [regex numberOfMatchesInString:[self timezone] options:0 range:NSMakeRange(0, [[self timezone] length])];
    NSRange rangeOfFirstMatch = [regex rangeOfFirstMatchInString:[self timezone] options:0 range:NSMakeRange(0, [[self timezone] length])];
    if (!NSEqualRanges(rangeOfFirstMatch, NSMakeRange(NSNotFound, 0))) {
        NSString *machedString = [[self timezone] substringWithRange:rangeOfFirstMatch];
        
    }
    return nil;
}

- (NSTimeZone*) getLocalTimeZone{
    return [self getLocalTimeZoneWithDST];
}

- (NSTimeZone*) getLocalTimeZoneWithDST{
    return [NSTimeZone defaultTimeZone];
}

@end
