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

+ (NSString*) crossTimeToString:(CrossTime*)crosstime{
  
    EFTime *begin_at=crosstime.begin_at;
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateFormat:@"zzz"];
    NSString *localTimezone = [format stringFromDate:[NSDate date]];
    localTimezone=[localTimezone substringFromIndex:3];
    [format setDateFormat:@"yyyy"];
    NSString *localYear = [format stringFromDate:[NSDate date]];
    [format release];
    NSString* cross_timezone=[crosstime.begin_at.timezone substringToIndex:6];
    BOOL is_same_timezone=false;
    if([cross_timezone isEqualToString:localTimezone])
        is_same_timezone=true;
    
    
    if( [crosstime.outputformat intValue]==1) {
        NSString *datestr=@"";
        datestr=[datestr stringByAppendingString:crosstime.origin];
        if(is_same_timezone == false)
            datestr=[datestr stringByAppendingString:crosstime.begin_at.timezone];
        return datestr;
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
 
        if([timestr isEqualToString:@""])
            return datestr;
        else
            return [timestr stringByAppendingFormat:@" on %@",datestr];

    }
//        Time_word (at) Time (Timezone) Date_word (on) Date
        
}
@end
