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
#import <math.h>

@implementation Util
+ (NSString*) decodeFromPercentEscapeString:(NSString*)string{
    CFStringRef sref = CFURLCreateStringByReplacingPercentEscapesUsingEncoding(NULL,(CFStringRef) string,CFSTR(""),kCFStringEncodingUTF8);
    NSString *s=[NSString stringWithFormat:@"0 Replies. %@", (NSString *)sref];
    CFRelease(sref);
    return s;
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

+ (NSString*) formattedLongDate:(CrossTime*)crosstime{
    NSString *timestr=@"";
    NSString *datestr=@"";
    if(![crosstime.begin_at.time_word isEqualToString:@""] && ![crosstime.begin_at.time isEqualToString:@""])
        timestr=crosstime.begin_at.time_word;
    else
        timestr=[timestr stringByAppendingFormat:@"%@%@",crosstime.begin_at.time_word,crosstime.begin_at.time];
    
    if(![crosstime.begin_at.date_word isEqualToString:@""] && ![crosstime.begin_at.date isEqualToString:@""])
        datestr=[datestr stringByAppendingFormat:@"%@ at %@",crosstime.begin_at.date_word,crosstime.begin_at.date];
    else
        datestr=[datestr stringByAppendingFormat:@"%@%@",crosstime.begin_at.date_word,crosstime.begin_at.date];
    
    if([timestr isEqualToString:@""]) {
        return datestr;
    }
    else{
        if(![timestr isEqualToString:@""])
            return [timestr stringByAppendingFormat:@" on %@",datestr];
        else
            return datestr;
    }
    return @"";
}
    
+ (NSString*) formattedShortDate:(CrossTime*)crosstime{
    NSString *shortdate=@"Sometime";
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    NSTimeZone *timezone=[NSTimeZone timeZoneWithName:@"UTC"];[self getTimeZoneWithCrossTime:crosstime];//[NSTimeZone timeZoneWithName:@"GMT"];
    [format setTimeZone:timezone];
    NSString *formatstr=@"";
    NSString *origin_date_str=@"";
    if(crosstime.begin_at.date!=nil && ![crosstime.begin_at.date isEqualToString:@""]) {
        formatstr=@"yyyy-MM-dd";
        origin_date_str=crosstime.begin_at.date;
    }
    if(crosstime.begin_at.time!=nil && ![crosstime.begin_at.time isEqualToString:@""]){
        formatstr=[formatstr stringByAppendingFormat:@" HH:mm:ss"];
        origin_date_str=[origin_date_str stringByAppendingFormat:@" %@", crosstime.begin_at.time] ;
    }
    [format setDateFormat:formatstr];
    NSDate *date=[format dateFromString:origin_date_str];
    
    if(date!=nil){
        [format setTimeZone:[NSTimeZone localTimeZone]];
        [format setDateFormat:@"yyyy"];
        NSString *y=[format stringFromDate:date];
        NSString *nowy=[format stringFromDate:[NSDate date]];
        
        if((crosstime.begin_at.time!=nil && ![crosstime.begin_at.time isEqualToString:@""]) && (crosstime.begin_at.date!=nil && ![crosstime.begin_at.date isEqualToString:@""]))
        {
            if([y isEqualToString:nowy])
                [format setDateFormat:@"h:mma ccc, MMM d"];
            else
                [format setDateFormat:@"h:mma ccc, MMM d, YYYY"];

        }
        else if(crosstime.begin_at.date!=nil&& ![crosstime.begin_at.date isEqualToString:@""]){
            if([y isEqualToString:nowy])
                [format setDateFormat:@"ccc, MMM d"];
            else
                [format setDateFormat:@"ccc, MMM d, YYYY"];
        }
        shortdate=[format stringFromDate:date];
    
    }
    [format release];
    return shortdate;
}

+ (NSDictionary*) crossTimeToString:(CrossTime*)crosstime{
    NSMutableDictionary *result=[[[NSMutableDictionary alloc]initWithCapacity:2] autorelease];
    if(crosstime==nil){
        [result setObject:@"" forKey:@"date_v2"];
        [result setObject:@"" forKey:@"date"];
        [result setObject:@"Sometime" forKey:@"relative"];
        [result setObject:@"Sometime" forKey:@"short"];
        return result;
    }

    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    NSLocale *locale=[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    [format setLocale:locale];
    [locale release];
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
//    [result setObject:@"" forKey:@"relative"];

//    if(![crosstime.begin_at.date isEqualToString:@""] && ![crosstime.begin_at.timezone isEqualToString:@""])
//    {
//        NSString *relative=[self formattedLongDateRelativeToNow:[crosstime.begin_at.date stringByAppendingFormat:@" %@ %@",crosstime.begin_at.time,[[crosstime.begin_at.timezone substringToIndex:3] stringByAppendingString:[crosstime.begin_at.timezone substringWithRange:NSMakeRange(4,2)]]]];
//        [result setObject:relative forKey:@"relative"];
//    }
    [result setObject:[self formattedShortDate:crosstime] forKey:@"short"];

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
        NSDateFormatter *dateformat = [[NSDateFormatter alloc] init];
        [dateformat setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
        //[self getTimeZoneWithCrossTime:crosstime]];
        [dateformat setDateFormat:@"HH:mm:ss"];
        NSString *cross_time_server=crosstime.begin_at.time;
        if(![crosstime.begin_at.date isEqualToString:@""] && ![crosstime.begin_at.time isEqualToString:@""]) {
            cross_time_server = [crosstime.begin_at.date stringByAppendingFormat:@" %@",crosstime.begin_at.time];
            [dateformat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        }
        else  if(![crosstime.begin_at.date isEqualToString:@""]) {
            cross_time_server = crosstime.begin_at.date;
            [dateformat setDateFormat:@"yyyy-MM-dd"];
        }
        NSDate *begin_at_date=[dateformat dateFromString:cross_time_server];
        if(begin_at_date!=nil)
        {
//            if([[result objectForKey:@"relative"] isEqualToString:@""])
//            {
//                NSString *relative=[self formattedDateRelativeToNow:begin_at_date];
//                [result setObject:relative forKey:@"relative"];
//            }
            NSDateFormatter *dateformat_to = [[NSDateFormatter alloc] init];
            if(![crosstime.begin_at.time isEqualToString:@""])
            {
                [dateformat_to setTimeZone:[NSTimeZone localTimeZone]];
                [dateformat_to setDateFormat:@"h:mm a"];
                crosstime_time=[dateformat_to stringFromDate:begin_at_date];
            }
            else
                crosstime_time=@"";
            
            [dateformat_to setDateFormat:@"yyyy-MM-dd"];
            crosstime_date=[dateformat_to stringFromDate:begin_at_date];

            [dateformat_to setDateFormat:@"d"];
            NSString *day_str=[dateformat_to stringFromDate:begin_at_date];
            [dateformat_to setDateFormat:@"MMM"];
            NSString *month_str=[dateformat_to stringFromDate:begin_at_date];
            [result setObject:day_str forKey:@"day"];
            [result setObject:month_str forKey:@"month"];
            
            [dateformat_to release];
        }
        [dateformat release];
        
        if([crosstime_date length]>=5 && [localYear isEqualToString:[crosstime_date substringToIndex:4]])
            crosstime_date=[crosstime_date substringFromIndex:5];

        NSString *timestr=@"";
        NSString *datestr=@"";
        if(![crosstime.begin_at.time_word isEqualToString:@""] && ![crosstime.begin_at.time isEqualToString:@""])
            timestr=crosstime.begin_at.time_word;
        else
            timestr=[timestr stringByAppendingFormat:@"%@%@",crosstime.begin_at.time_word,crosstime_time];

        if(![crosstime.begin_at.date_word isEqualToString:@""] && ![crosstime.begin_at.date isEqualToString:@""])
            datestr=[datestr stringByAppendingFormat:@"%@ at %@",crosstime.begin_at.date_word,crosstime_date];
        else
            datestr=[datestr stringByAppendingFormat:@"%@%@",crosstime.begin_at.date_word,crosstime_date];

        
        if([timestr isEqualToString:@""]) {
            [result setObject:datestr forKey:@"date"];
            return result;
        }
        else{
            if(![timestr isEqualToString:@""])
                [result setObject:[timestr stringByAppendingFormat:@" on %@",datestr] forKey:@"date"];
            else
                [result setObject:datestr forKey:@"date"];

            return result;
        }
    }
}
+ (NSString *) formattedLongDateRelativeToNowWiteDate:(NSDate*)date{
    const int SECOND = 1;
    const int MINUTE = 60 * SECOND;
    const int HOUR = 60 * MINUTE;
    const int DAY = 24 * HOUR;
    const int MONTH = 30 * DAY;
    
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
        relativeString = (components.second == 1) ? @"One second ago" : [NSString stringWithFormat:@"%d seconds ago",components.second];
//        relativeString =[NSString stringWithFormat:@"%ds",components.second];
        
    } else if (delta < 2 * MINUTE) {
        relativeString =  @"a minute ago";
//        relativeString =  @"1m";
        
    } else if (delta < 45 * MINUTE) {
        relativeString = [NSString stringWithFormat:@"%d minutes ago",components.minute];
        
    } else if (delta < 90 * MINUTE) {
        relativeString = @"an hour ago";
//        relativeString = @"1h";
        
    } else if (delta < 24 * HOUR) {
        relativeString = [NSString stringWithFormat:@"%d hours ago",components.hour];
        
    } else if (delta < 48 * HOUR) {
        relativeString = @"yesterday";
//        relativeString = @"1d";
        
    } else if (delta < 30 * DAY) {
        relativeString = [NSString stringWithFormat:@"%d days ago",components.day];
//        relativeString = [NSString stringWithFormat:@"%dd",components.day];
        
    } else if (delta < 12 * MONTH) {
        relativeString = (components.month <= 1) ? @"one month ago" : [NSString stringWithFormat:@"%d months ago",components.month];
//        relativeString = [NSString stringWithFormat:@"%dm",components.month];
        
    } else {
        relativeString = (components.year <= 1) ? @"one year ago" : [NSString stringWithFormat:@"%d years ago",components.year];
//        relativeString = [NSString stringWithFormat:@"%dy",components.year];
    }
    return relativeString;  
}
+ (NSString*) getBackgroundLink:(NSString*)imgname
{
//    https://exfe.com/static/img/xbg/westlake.jpg
    return [NSString stringWithFormat:@"%@/xbg/%@",IMG_ROOT,imgname];
}

+ (void) drawRoundRect:(CGRect) rect color:(UIColor*)color radius:(float)radius{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, color.CGColor);
    CGContextMoveToPoint(context, rect.origin.x, rect.origin.y + radius);
    CGContextAddLineToPoint(context, rect.origin.x, rect.origin.y + rect.size.height - radius);
    CGContextAddArc(context, rect.origin.x + radius, rect.origin.y + rect.size.height - radius, 
                    radius, M_PI, M_PI / 2, 1); //STS fixed
    CGContextAddLineToPoint(context, rect.origin.x + rect.size.width - radius, 
                            rect.origin.y + rect.size.height);
    CGContextAddArc(context, rect.origin.x + rect.size.width - radius, 
                    rect.origin.y + rect.size.height - radius, radius, M_PI / 2, 0.0f, 1);
    CGContextAddLineToPoint(context, rect.origin.x + rect.size.width, rect.origin.y + radius);
    CGContextAddArc(context, rect.origin.x + rect.size.width - radius, rect.origin.y + radius, 
                    radius, 0.0f, -M_PI / 2, 1);
    CGContextAddLineToPoint(context, rect.origin.x + radius, rect.origin.y);
    CGContextAddArc(context, rect.origin.x + radius, rect.origin.y + radius, radius, 
                    -M_PI / 2, M_PI, 1);
    CGContextFillPath(context);
}
+ (UIImage *)scaleImage:(UIImage*)image toResolution:(int)resolution{
    CGImageRef imgRef = [image CGImage];
    CGFloat width = CGImageGetWidth(imgRef);
    CGFloat height = CGImageGetHeight(imgRef);
    CGRect bounds = CGRectMake(0, 0, width, height);
    
    //if already at the minimum resolution, return the orginal image, otherwise scale
    if (width <= resolution && height <= resolution) {
        return image;
        
    } else {
        CGFloat ratio = width/height;
        
        if (ratio > 1) {
            bounds.size.width = resolution;
            bounds.size.height = bounds.size.width / ratio;
        } else {
            bounds.size.height = resolution;
            bounds.size.width = bounds.size.height * ratio;
        }
    }
    
    UIGraphicsBeginImageContext(bounds.size);
    [image drawInRect:CGRectMake(0.0, 0.0, bounds.size.width, bounds.size.height)];
    UIImage *imageCopy = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return imageCopy;
}

+ (NSString*) findProvider:(NSString*)external_id{
    
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"; 
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    
    if([emailTest evaluateWithObject:external_id]==YES)
        return @"email";
    
    NSString *twitterRegex = @"@[A-Za-z0-9.-]+";
    NSPredicate *twitterTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", twitterRegex];
    if([twitterTest evaluateWithObject:external_id]==YES)
        return @"twitter";
    
    return @"";
}
+ (NSTimeZone*) getTimeZoneWithCrossTime:(CrossTime*)crosstime{
    
    BOOL is_same_timezone=false;
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    NSLocale *locale=[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    [format setLocale:locale];
    [format setDateFormat:@"zzz"];
    NSString *localTimezone = [format stringFromDate:[NSDate date]];
    localTimezone=[localTimezone substringFromIndex:3];
    [format setDateFormat:@"yyyy"];

    NSString* cross_timezone=@"";
    if(crosstime.begin_at.timezone.length>=6 )
        cross_timezone=[crosstime.begin_at.timezone substringToIndex:6];
    if([cross_timezone isEqualToString:localTimezone])
        is_same_timezone=YES;
    [locale release];
    [format release];

    if(is_same_timezone==YES)
        return [NSTimeZone localTimeZone];
        
    if([crosstime.begin_at.timezone length]==6)
    {
        NSString *hh=[crosstime.begin_at.timezone substringWithRange:NSMakeRange(1, 2)];
        NSString *mm=[crosstime.begin_at.timezone substringWithRange:NSMakeRange(4, 2)];
        int second_offset=([hh intValue]*60+[mm intValue])*60;
        NSTimeZone *timezone=[NSTimeZone timeZoneForSecondsFromGMT:second_offset];
        return timezone;
    }
    return nil;
}
+ (NSDate*) beginningOfWeek:(NSDate*)date{
    NSDate *today = [NSDate date];
    NSCalendar *gregorian = [NSCalendar currentCalendar];
    NSDateComponents *weekdayComponents = [gregorian components:NSWeekdayCalendarUnit fromDate:today];
    NSDateComponents *componentsToSubtract = [[NSDateComponents alloc] init];
    [componentsToSubtract setDay: - ([weekdayComponents weekday] - [gregorian firstWeekday])];
    NSDate *beginningOfWeek = [gregorian dateByAddingComponents:componentsToSubtract toDate:today options:0];
    [componentsToSubtract release];
    NSDateComponents *components = [gregorian components: (NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate: beginningOfWeek];
    beginningOfWeek = [gregorian dateFromComponents: components];
    return beginningOfWeek;
}
+ (NSString*) getTimeTitle:(CrossTime*)crosstime localTime:(BOOL)localtime{
    if( [crosstime.outputformat intValue]==1) {
        if([crosstime.origin isEqualToString:@""])
            return @"Sometime";
        return crosstime.origin;
    }
    if(crosstime.begin_at.date && ![crosstime.begin_at.date isEqualToString:@""])
        return [self EXRelative:crosstime type:@"cross" localTime:localtime];
    return @"Sometime";
}
+ (NSString*) getTimeDesc:(CrossTime*)crosstime{
    NSString *timedesc=@"";
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    NSLocale *locale=[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    [format setLocale:locale];
    [locale release];
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
    
    if( [crosstime.outputformat intValue]==1) { //use origin
        timedesc=[timedesc stringByAppendingString:crosstime.origin];
        if(is_same_timezone == false)
            timedesc=[timedesc stringByAppendingString:crosstime.begin_at.timezone];
    }
    else {
        NSString *crosstime_date=crosstime.begin_at.date;
        NSString *crosstime_time=crosstime.begin_at.time;     
        NSDateFormatter *dateformat = [[NSDateFormatter alloc] init];
        [dateformat setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
        [dateformat setDateFormat:@"HH:mm:ss"];
        NSString *cross_time_server=crosstime.begin_at.time;
        if(![crosstime.begin_at.date isEqualToString:@""] && ![crosstime.begin_at.time isEqualToString:@""]) {
            cross_time_server = [crosstime.begin_at.date stringByAppendingFormat:@" %@",crosstime.begin_at.time];
            [dateformat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        }
        else  if(![crosstime.begin_at.date isEqualToString:@""]) {
            cross_time_server = crosstime.begin_at.date;
            [dateformat setDateFormat:@"yyyy-MM-dd"];
        }
        NSDate *begin_at_date=[dateformat dateFromString:cross_time_server];
        NSString *week=@"";
        if(begin_at_date!=nil)
        {
            NSDateFormatter *dateformat_to = [[NSDateFormatter alloc] init];
            if(![crosstime.begin_at.time isEqualToString:@""]){
                [dateformat_to setTimeZone:[NSTimeZone localTimeZone]];
                [dateformat_to setDateFormat:@"h:mma"];
                crosstime_time=[dateformat_to stringFromDate:begin_at_date];
            }
            else
                crosstime_time=@"";
            [dateformat_to setDateFormat:@"yyyy"];
            NSString *y=[dateformat_to stringFromDate:begin_at_date];

            if([y isEqualToString:localYear])
                [dateformat_to setDateFormat:@"ccc, MMM d"];
            else
                [dateformat_to setDateFormat:@"ccc, MMM d, YYYY"];
            
//            [dateformat_to setDateFormat:@"yyyy-MM-dd"];
            crosstime_date=[dateformat_to stringFromDate:begin_at_date];
//            [dateformat_to setDateFormat:@"ccc"];
//            week=[dateformat_to stringFromDate:begin_at_date];
            
            [dateformat_to release];
        }
        [dateformat release];
        
//        if([crosstime_date length]>=5 && [localYear isEqualToString:[crosstime_date substringToIndex:4]])
//            crosstime_date=[crosstime_date substringFromIndex:5];
        
        NSString *timestr=@"";
        NSString *datestr=@"";
//        Time_word (at) Time (Timezone) Date_word (on) Date
        if(![crosstime.begin_at.time_word isEqualToString:@""] && ![crosstime.begin_at.time isEqualToString:@""])
            timestr=[NSString stringWithFormat:@"%@ at %@",crosstime.begin_at.time_word,crosstime_time];
        else if(![crosstime.begin_at.time_word isEqualToString:@""] && [crosstime.begin_at.time isEqualToString:@""])
            timestr=[NSString stringWithFormat:@"%@ at",crosstime.begin_at.time_word];
        else if([crosstime.begin_at.time_word isEqualToString:@""])
            timestr=crosstime_time;
        else if([crosstime.begin_at.time isEqualToString:@""])
            timestr=crosstime.begin_at.time;
        if(is_same_timezone == false)
            timestr=[timestr stringByAppendingFormat:@" %@",crosstime.begin_at.timezone];
            
        if(![crosstime.begin_at.date_word isEqualToString:@""] && ![crosstime.begin_at.date isEqualToString:@""])
            datestr=[datestr stringByAppendingFormat:@"%@ on %@",crosstime.begin_at.date_word,crosstime_date];
        else if([crosstime.begin_at.date_word isEqualToString:@""])
            datestr=crosstime_date;
        else if([crosstime.begin_at.date isEqualToString:@""])
            datestr=crosstime.begin_at.date;
        
        if([timestr isEqualToString:@""])
            timedesc=datestr;
        else
            timedesc=[timestr stringByAppendingFormat:@" %@",datestr];
    }
    return timedesc;
}

+ (NSString*) EXRelativeFromDateStr:(NSString*)datestr TimeStr:(NSString*)timestr type:(NSString*)type localTime:(BOOL)localtime{
    NSDateFormatter *dateformat = [[NSDateFormatter alloc] init];
    if(localtime==YES)
        [dateformat setTimeZone:[NSTimeZone localTimeZone]];
    else
        [dateformat setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
    [dateformat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *begin_at_date=[dateformat dateFromString:[NSString stringWithFormat:@"%@ 00:00:00",datestr]];
    [dateformat setTimeZone:[NSTimeZone localTimeZone]];
    [dateformat setDateFormat:@"yyyy-MM-dd"];
    NSString *nowdate_str=[dateformat stringFromDate:[NSDate date]];
    [dateformat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    NSDate *now_date=[dateformat dateFromString:[NSString stringWithFormat:@"%@ 00:00:00 ",nowdate_str]];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *comps =[calendar components: NSDayCalendarUnit fromDate:now_date toDate:begin_at_date options:0];
    NSDate *beginingofweek=[self beginningOfWeek:now_date];
    
    NSDateComponents *comps_firstdayofweek =[calendar components: NSDayCalendarUnit fromDate:beginingofweek toDate:begin_at_date options:0];
    NSString *relativeTime=@"";
    int day=[comps day];
    if(abs(day)>1)
    {
        int year=floor(abs(day)/365.25);
        float f_m=fmod(day,365.25)/30;
        //round 8 away from zero, round 7 towards zero
        int moth=round(f_m+0.2);
        if(f_m<0)
            moth=round(f_m-0.2);
        NSString *m_str=@"months";
        NSString *y_str=@"years";
        if(abs(moth)==1)
            m_str=@"month";
        if(abs(year)==1)
            y_str=@"year";
        
        if(abs(year)>0) {
            if(abs(moth)>0) {
                if(moth>0)
                    relativeTime=[NSString stringWithFormat:@"In %u %@ %u %@",abs(year),y_str,abs(moth),m_str];
                else
                    relativeTime=[NSString stringWithFormat:@"%u %@ %u %@ ago",abs(year),y_str,abs(moth),m_str];
            }
            else if(abs(moth)==0){
                if(year>0)
                    relativeTime=[NSString stringWithFormat:@"In %u %@",abs(year),y_str];
                else
                    relativeTime=[NSString stringWithFormat:@"%u %@ ago",abs(year),y_str];
            }
        }
        else if(abs(year)==0){
            if(day<=-3 && day>=-30)
                relativeTime=[NSString stringWithFormat:@"%u days ago",abs(day)];
            else if(day==-2)
                relativeTime=[NSString stringWithFormat:@"The day before yesterday"];
            else if(day==2)
                relativeTime=[NSString stringWithFormat:@"The day after tomorrow"];
            else if(day>30)
                relativeTime=[NSString stringWithFormat:@"In %u %@",abs(moth),m_str];
            else if(day<-30)
                relativeTime=[NSString stringWithFormat:@"%u %@ ago",abs(moth),m_str];
            else if(day>0 && day<=30)
            {
                NSDateFormatter *weekdayformatter = [[NSDateFormatter alloc] init];
                [weekdayformatter setDateFormat: @"EEEE"];
                NSString *weekdaysymbol=[weekdayformatter stringFromDate:begin_at_date];
                [weekdayformatter release];
                
                int beginingofweek_tobegin_at_day=[comps_firstdayofweek day];
                if(beginingofweek_tobegin_at_day<=7)
                    relativeTime=[NSString stringWithFormat:@"%@",weekdaysymbol];
                if(beginingofweek_tobegin_at_day<=13)
                    relativeTime=[NSString stringWithFormat:@"Next %@",weekdaysymbol];
                if(beginingofweek_tobegin_at_day>=14)
                    relativeTime=[NSString stringWithFormat:@"In %u days",day];
            }
        }
    }
    else{
        if(day==-1)
            relativeTime=[NSString stringWithFormat:@"Yesterday"];
        else if(day==1)
            relativeTime=[NSString stringWithFormat:@"Tomorrow"];
        else if(day==0)
            relativeTime=[NSString stringWithFormat:@"Today"];
    }
    
    if(day==0)
    {
        if(timestr!=@"")
        {
            if(localtime==YES)
                [dateformat setTimeZone:[NSTimeZone localTimeZone]];
            else
                [dateformat setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
            [dateformat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
            if([timestr isEqualToString:@""])
                [dateformat setDateFormat:@"yyyy-MM-dd"];    
            begin_at_date=[dateformat dateFromString:[NSString stringWithFormat:@"%@ %@",datestr,timestr]];
            NSDate *now=[NSDate date];
            NSDateComponents *comps_in_a_day =[calendar components: NSMinuteCalendarUnit fromDate:now toDate:begin_at_date options:0];
            int minute=[comps_in_a_day minute];
            float f_h=minute/60.0;
            int hour=round(f_h-0.2);//round 8 away from zero, round 7 towards zero

            if(minute>=-1439 && minute<=-720)
                relativeTime=[NSString stringWithFormat:@"%u hours ago",abs(hour)];
            else if(minute>=-719 && minute<=-60){
                relativeTime=[NSString stringWithFormat:@"%u hours ago",abs(hour)];
            }
            else if(minute>=-59 && minute<=-31){
                if([type isEqualToString:@"cross"])
                    relativeTime=[NSString stringWithFormat:@"Just now"];
                else
                    relativeTime=[NSString stringWithFormat:@"%u minutes ago",minute];
            }
            else if(minute>=-30 && minute<-1){
                if([type isEqualToString:@"cross"])
                    relativeTime=[NSString stringWithFormat:@"Now"];
                else
                    relativeTime=[NSString stringWithFormat:@"%u minutes ago",minute];
            }
            else if(minute>=-1 && minute<=0){
                if([type isEqualToString:@"cross"])
                    relativeTime=[NSString stringWithFormat:@"Now"];
                else
                    relativeTime=[NSString stringWithFormat:@"Seconds ago"];
            }
            else if(minute>=1 && minute<=59)
                relativeTime=[NSString stringWithFormat:@"In %u minutes",minute];
            else if(minute>=60 && minute<=749){
                float f_h=minute/60.0;
                int hour=round(f_h+0.2);//round 8 away from zero, round 7 towards zero
                relativeTime=[NSString stringWithFormat:@"In %u hours",hour];
            }
        }
        
    }
    
    [dateformat release];
    return relativeTime;

}

+ (NSString*) EXRelative:(CrossTime*)crosstime type:(NSString*)type localTime:(BOOL)localtime{
    return [self EXRelativeFromDateStr:crosstime.begin_at.date TimeStr:crosstime.begin_at.time type:type localTime:localtime];
}

+ (BOOL) isCommonDomainName:(NSString*)domainname{
    NSArray *domains =[NSArray arrayWithObjects:@"biz",@"com",@"nfo",@"net",@"org",@".us",@".uk",@".jp",@".cn",@".ca",@".au",@".de", nil];
    return [domains containsObject:[domainname lowercaseString]];
}
+ (void) signout{
    AppDelegate* app=(AppDelegate*)[[UIApplication sharedApplication] delegate];
    
    NSString *udid=[[NSUserDefaults standardUserDefaults] objectForKey:@"udid"];
    RKParams* rsvpParams = [RKParams params];
    [rsvpParams setValue:udid forParam:@"udid"];
    [rsvpParams setValue:@"iOS" forParam:@"os_name"];
    
    RKClient *client = [RKClient sharedClient];
    [client setBaseURL:[RKURL URLWithBaseURLString:API_V2_ROOT]];
    NSString *endpoint = [NSString stringWithFormat:@"/users/%u/signout?token=%@",app.userid,app.accesstoken];
    [client post:endpoint usingBlock:^(RKRequest *request){
        request.method=RKRequestMethodPOST;
        request.params=rsvpParams;
        request.onDidLoadResponse=^(RKResponse *response){
            if (response.statusCode == 200) {
            }else {
                //Check Response Body to get Data!
            }
            [app SignoutDidFinish];
        };
        request.onDidFailLoadWithError=^(NSError *error){
            [app SignoutDidFinish];
        };
    }];
}
+ (void) showError:(Meta*)meta delegate:(id)delegate{
    NSString *errormsg=@"";
    if([meta.code intValue]==401){
        errormsg=@"invalid auth";
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:errormsg delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:@"Sign Out",nil];
        alert.tag=500;
        alert.delegate=delegate;
        [alert show];
        [alert release];
        
    }
}
+ (void) showErrorWithMetaDict:(NSDictionary*)meta delegate:(id)delegate{
    NSString *errormsg=@"";
    if([[meta objectForKey:@"code"] isKindOfClass:[NSNumber class]])
    {
        if([(NSNumber*)[meta objectForKey:@"code"] intValue]==401){
            errormsg=@"invalid auth";
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:errormsg delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:@"Sign Out",nil];
            alert.tag=500;
            alert.delegate=delegate;
            [alert show];
            [alert release];
        }
    }
}

+ (void) showConnectError:(NSError*)err delegate:(id)delegate{
    NSString *errormsg=@"";
    if(err.code==2)
        errormsg=@"A connection failure has occurred.";
    else
        errormsg=@"Could not connect to the server.";
    if(![errormsg isEqualToString:@""]){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:errormsg delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
        [alert release];
    }
}

@end
