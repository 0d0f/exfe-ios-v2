//
//  Util.m
//  EXFE
//
//  Created by ju huo on 5/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Util.h"
#import "CrossTime.h"
#import "EFTime.h"

@implementation Util
+ (NSString*) decodeFromPercentEscapeString:(NSString*)string{
    return (NSString *)
    CFURLCreateStringByReplacingPercentEscapesUsingEncoding(NULL,
                                                            (CFStringRef) string,
                                                            CFSTR(""),
                                                            kCFStringEncodingUTF8);
}

+ (NSString*) encodeToPercentEscapeString:(NSString*)string{
    CFStringRef urlString = CFURLCreateStringByAddingPercentEscapes(
                                                                    NULL,
                                                                    (CFStringRef)string,
                                                                    NULL,
                                                                    (CFStringRef)@"!*'\"();:@&=+$,/?%#[]% ",
                                                                    kCFStringEncodingUTF8 );
    return [(NSString *)urlString autorelease];
    
}
+ (UIColor*) getHighlightColor{
    return [UIColor colorWithRed:17/255.0f green:117/255.0f blue:165/255.0f alpha:1];
}
+ (UIColor*) getRegularColor{
    return [UIColor colorWithRed:19/255.0f green:19/255.0f blue:19/255.0f alpha:1];
}

+ (NSDictionary*) crossTimeToString:(CrossTime*)crosstime{
  
    NSMutableDictionary *result=[[[NSMutableDictionary alloc]initWithCapacity:2] autorelease];
//    EFTime *begin_at=crosstime.begin_at;
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateFormat:@"zzz"];
    NSString *localTimezone = [format stringFromDate:[NSDate date]];
    localTimezone=[localTimezone substringFromIndex:3];
    [format setDateFormat:@"yyyy"];
    NSString *localYear = [format stringFromDate:[NSDate date]];
    [format release];
    NSString* cross_timezone=@"";
    if(crosstime.begin_at.timezone.length>=6 )
        cross_timezone=[crosstime.begin_at.timezone substringToIndex:6];
    BOOL is_same_timezone=false;
    if([cross_timezone isEqualToString:localTimezone])
        is_same_timezone=true;
    [result setObject:@"" forKey:@"relative"];

    if(![crosstime.begin_at.date isEqualToString:@""]&&![crosstime.begin_at.time isEqualToString:@""] && ![crosstime.begin_at.timezone isEqualToString:@""])
    {
        
        NSString *relative=[self formattedLongDateRelativeToNow:[crosstime.begin_at.date stringByAppendingFormat:@" %@ %@",crosstime.begin_at.time,[[crosstime.begin_at.timezone substringToIndex:3] stringByAppendingString:[crosstime.begin_at.timezone substringWithRange:NSMakeRange(4,2)]]]];
        
        [result setObject:relative forKey:@"relative"];
//        NSLog(@"%@",relative);
    }

    
    if( [crosstime.outputformat intValue]==1) {
        NSString *datestr=@"";
        datestr=[datestr stringByAppendingString:crosstime.origin];
        if(is_same_timezone == false)
            datestr=[datestr stringByAppendingString:crosstime.begin_at.timezone];
        [result setObject:datestr forKey:@"date"];
        return result;
    }
    else {
        NSString *crosstime_date=crosstime.begin_at.date;
        NSString *crosstime_time=crosstime.begin_at.time;     
        
        if(is_same_timezone==false) {
            NSDateFormatter *dateformat = [[NSDateFormatter alloc] init];

            NSString *hh=[localTimezone substringWithRange:NSMakeRange(1, 2)];
            NSString *mm=[localTimezone substringWithRange:NSMakeRange(4, 2)];
            int second_offset=(([hh intValue]*60+[mm intValue])*60)*60;
            [dateformat setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:second_offset]];
            [dateformat setDateFormat:@"HH:mm:ss"];
            NSString *cross_time_server=crosstime.begin_at.time;
            if(![crosstime.begin_at.date isEqualToString:@""]) {
                cross_time_server = [crosstime.begin_at.date stringByAppendingFormat:@" %@",crosstime.begin_at.time];
                [dateformat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
           }
            NSDate *begin_at_date=[dateformat dateFromString:cross_time_server];
            NSDateFormatter *dateformat_to = [[NSDateFormatter alloc] init];
            [dateformat_to setTimeZone:[NSTimeZone defaultTimeZone]];
            [dateformat_to setDateFormat:@"HH:mm:ss"];
            crosstime_time=[dateformat_to stringFromDate:begin_at_date];

            [dateformat_to setDateFormat:@"yyyy-MM-dd"];
            crosstime_date=[dateformat_to stringFromDate:begin_at_date];
            [dateformat_to release];
            [dateformat release];
        }
        if([localYear isEqualToString:[crosstime_date substringToIndex:4]])
            crosstime_date=[crosstime_date substringFromIndex:5];

        NSString *timestr=@"";
        NSString *datestr=@"";
        if(![crosstime.begin_at.time_word isEqualToString:@""] && ![crosstime.begin_at.time isEqualToString:@""])
            timestr=[timestr stringByAppendingFormat:@"%@ at %@",crosstime.begin_at.time_word,crosstime.begin_at.time];
        else
            timestr=[timestr stringByAppendingFormat:@"%@%@",crosstime.begin_at.time_word,crosstime.begin_at.time];

        if(is_same_timezone==false)
            timestr=[timestr stringByAppendingFormat:@" %@",crosstime.begin_at.timezone];
        
        if(![crosstime.begin_at.date_word isEqualToString:@""] && ![crosstime.begin_at.date isEqualToString:@""])
            datestr=[datestr stringByAppendingFormat:@"%@ at %@",crosstime.begin_at.date_word,crosstime.begin_at.date];
        else
            datestr=[datestr stringByAppendingFormat:@"%@%@",crosstime.begin_at.date_word,crosstime.begin_at.date];

        
        if([timestr isEqualToString:@""]) {
            [result setObject:datestr forKey:@"date"];
            return result;
        }
        else{
            [result setObject:[timestr stringByAppendingFormat:@" on %@",datestr] forKey:@"date"];
            return result;
        }

    }
//        Time_word (at) Time (Timezone) Date_word (on) Date
        
}

+ (NSString *) formattedLongDateRelativeToNow:(NSString*)datestr {
    const int SECOND = 1;
    const int MINUTE = 60 * SECOND;
    const int HOUR = 60 * MINUTE;
    const int DAY = 24 * HOUR;
    const int MONTH = 30 * DAY;
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss Z"];
    NSDate *date = [dateFormat dateFromString:datestr]; 
    [dateFormat release];
    if(date==nil)
        return @"";
    NSDate *now = [NSDate date];
    NSTimeInterval delta = [date timeIntervalSinceDate:now] * -1.0;
    BOOL isNegative=NO;
    if (delta < 0) {
        isNegative=YES;
        delta=-delta;
    }
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSUInteger units = (NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit);
    NSDateComponents *components = [calendar components:units fromDate:date toDate:now options:0];
    
    NSString *relativeString;
    if (delta < 1 * MINUTE) {
        relativeString = (components.second == 1) ? @"One second" : [NSString stringWithFormat:@"%d seconds",abs(components.second)];
    } else if (delta < 2 * MINUTE) {
        relativeString =  @"a minute";
    } else if (delta < 45 * MINUTE) {
        relativeString = [NSString stringWithFormat:@"%d minutes",abs(components.minute)];
    } else if (delta < 90 * MINUTE) {
        relativeString = @"an hour";
    } else if (delta < 24 * HOUR) {
        relativeString = [NSString stringWithFormat:@"%d hours",abs(components.hour)];
    } else if (delta < 48 * HOUR) {
        if(isNegative==NO)
            relativeString = @"yesterday";
        else if(isNegative==YES)
            relativeString = @"tomorrow";
        return relativeString;
    } else if (delta < 30 * DAY) {
        relativeString = [NSString stringWithFormat:@"%d days",abs(components.day)];
    } else if (delta < 12 * MONTH) {
        relativeString = (components.month <= 1) ? @"one month" : [NSString stringWithFormat:@"%d months",abs(components.month)];
    } else {
        relativeString = (components.year <= 1) ? @"one year" : [NSString stringWithFormat:@"%d years",abs(components.year)];
    }
    
    if(isNegative==NO)
        relativeString = [relativeString stringByAppendingString:@" ago"];
    else if(isNegative==YES)
        relativeString = [relativeString stringByAppendingString:@" later"];
    
    return relativeString;      
}

+ (NSString *) formattedDateRelativeToNow:(NSDate*)date
{
    const int SECOND = 1;
    const int MINUTE = 60 * SECOND;
    const int HOUR = 60 * MINUTE;
    const int DAY = 24 * HOUR;
    const int MONTH = 30 * DAY;
    
//    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
//    [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss Z"];

//    [dateFormat setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
//    NSDate *date = [dateFormat dateFromString:datestr]; 
//    [dateFormat release];
    
    NSDate *now = [NSDate date];
    NSTimeInterval delta = [date timeIntervalSinceDate:now] * -1.0;
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSUInteger units = (NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit);
    NSDateComponents *components = [calendar components:units fromDate:date toDate:now options:0];
    
    NSString *relativeString;
    
    if (delta < 0) {
        delta=-delta;
        //        relativeString = @"!n the future!";
    }// else 
    
    if (delta < 1 * MINUTE) {
        //        relativeString = (components.second == 1) ? @"One second ago" : [NSString stringWithFormat:@"%d seconds ago",components.second];
        relativeString =[NSString stringWithFormat:@"%ds",components.second];
        
    } else if (delta < 2 * MINUTE) {
        //        relativeString =  @"a minute ago";
        relativeString =  @"1m";
        
    } else if (delta < 45 * MINUTE) {
        relativeString = [NSString stringWithFormat:@"%dm",components.minute];
        
    } else if (delta < 90 * MINUTE) {
        //        relativeString = @"an hour ago";
        relativeString = @"1h";
        
    } else if (delta < 24 * HOUR) {
        relativeString = [NSString stringWithFormat:@"%dh",components.hour];
        
    } else if (delta < 48 * HOUR) {
        //        relativeString = @"yesterday";
        relativeString = @"1d";
        
    } else if (delta < 30 * DAY) {
        //        relativeString = [NSString stringWithFormat:@"%d days ago",components.day];
        relativeString = [NSString stringWithFormat:@"%dd",components.day];
        
    } else if (delta < 12 * MONTH) {
        //        relativeString = (components.month <= 1) ? @"one month ago" : [NSString stringWithFormat:@"%d months ago",components.month];
        relativeString = [NSString stringWithFormat:@"%dm",components.month];
        
    } else {
        //        relativeString = (components.year <= 1) ? @"one year ago" : [NSString stringWithFormat:@"%d years ago",components.year];
        relativeString = [NSString stringWithFormat:@"%dy",components.year];
    }
    NSLog(@"%@",relativeString);
    return relativeString;  
}
+ (NSString*) getBackgroundLink:(NSString*)imgname
{
    return [NSString stringWithFormat:@"http://img.exfe.com/xbgimage/%@_ios.jpg",imgname];
}
@end
