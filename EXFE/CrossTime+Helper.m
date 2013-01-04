//
//  CrossTime+Helper.m
//  EXFE
//
//  Created by Stony Wang on 13-1-4.
//
//

#import "CrossTime+Helper.h"
#import "EFTime.h"
#import "EFTime+Helper.h"
#import "Util.h"

@implementation CrossTime (Helper)

- (NSString*) getTimeTitleWithLocalTime:(BOOL)localtime{
    if( [self.outputformat intValue] == 1) {
        return self.origin;
    }
    if([self.begin_at hasDate]){
        return [self EXRelativeWithType:@"cross" localTime:localtime];
    }
    return @"";
}

- (NSString*) getTimeDesc{
    NSString *timedesc = @"";
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    NSLocale *locale=[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    [format setLocale:locale];
    [format setDateFormat:@"ZZZZ"];
    NSString *localTimezone = [format stringFromDate:[NSDate date]];
    localTimezone = [localTimezone substringFromIndex:3];
    [format setDateFormat:@"yyyy"];
    NSString *localYear = [format stringFromDate:[NSDate date]];
    [locale release];
    [format release];
    
    NSString* cross_timezone = @"";
    if(self.begin_at.timezone.length >= 6){
        cross_timezone = [self.begin_at.timezone substringToIndex:6];
    }
    BOOL is_same_timezone = false;
    if([cross_timezone isEqualToString:localTimezone]){
        is_same_timezone = true;
    }
    
    if( [self.outputformat intValue] == 1) { //use origin
        timedesc = [timedesc stringByAppendingString:self.origin];
        if(is_same_timezone == false)
            timedesc = [timedesc stringByAppendingString:self.begin_at.timezone];
    }
    else {
        NSString *crosstime_date = self.begin_at.date;
        NSString *crosstime_time = self.begin_at.time;
        NSDateFormatter *dateformat = [[NSDateFormatter alloc] init];
        NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
        [dateformat setLocale:locale];
        
        [dateformat setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
        [dateformat setDateFormat:@"HH:mm:ss"];
        NSString *cross_time_server=self.begin_at.time;
        if([self.begin_at hasDate]) {
            if ([self.begin_at hasTime]) {
                cross_time_server = [self.begin_at.date stringByAppendingFormat:@" %@",self.begin_at.time];
                [dateformat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
            }else{
                cross_time_server = self.begin_at.date;
                [dateformat setDateFormat:@"yyyy-MM-dd"];
            }
        }
        NSDate *begin_at_date=[dateformat dateFromString:cross_time_server];
        //        NSString *week=@"";
        if(begin_at_date!=nil)
        {
            NSDateFormatter *dateformat_to = [[NSDateFormatter alloc] init];
            NSLocale *locale_to=[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
            [dateformat_to setLocale:locale_to];
            
            if(![self.begin_at.time isEqualToString:@""]){
                [dateformat_to setTimeZone:[NSTimeZone localTimeZone]];
                [dateformat_to setDateFormat:@"h:mma"];
                crosstime_time = [dateformat_to stringFromDate:begin_at_date];
            }
            else{
                crosstime_time = @"";
            }
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
            [locale_to release];
            [dateformat_to release];
        }
        [locale release];
        [dateformat release];
        
        //        if([crosstime_date length]>=5 && [localYear isEqualToString:[crosstime_date substringToIndex:4]])
        //            crosstime_date=[crosstime_date substringFromIndex:5];
        
        NSString *timestr = @"";
        NSString *datestr = @"";
        //        Time_word (at) Time (Timezone) Date_word (on) Date
        if(![self.begin_at.time_word isEqualToString:@""] && ![self.begin_at.time isEqualToString:@""]){
            timestr = [NSString stringWithFormat:@"%@ at %@",self.begin_at.time_word,crosstime_time];
        }else if(![self.begin_at.time_word isEqualToString:@""] && [self.begin_at.time isEqualToString:@""]){
            timestr = [NSString stringWithFormat:@"%@ at",self.begin_at.time_word];
        }else if([self.begin_at.time_word isEqualToString:@""]){
            timestr = crosstime_time;
        }else if([self.begin_at.time isEqualToString:@""]){
            timestr = self.begin_at.time;
        }
        
        //            timestr=[timestr stringByAppendingFormat:@" %@",crosstime.begin_at.timezone];
        
        if(![self.begin_at.date_word isEqualToString:@""] && ![self.begin_at.date isEqualToString:@""]){
            datestr = [datestr stringByAppendingFormat:@"%@ on %@",self.begin_at.date_word,crosstime_date];
        }else if([self.begin_at.date_word isEqualToString:@""]){
            datestr = crosstime_date;
        }else if([self.begin_at.date isEqualToString:@""]){
            datestr = self.begin_at.date;
        }
        
        if([timestr isEqualToString:@""]){
            timedesc=datestr;
        }else{
            timedesc=[timestr stringByAppendingFormat:@" %@",datestr];
        }
        if(is_same_timezone == false){
            timedesc=[timedesc stringByAppendingFormat:@" (%@)",localTimezone];
        }
    }
    return timedesc;
}

+ (NSString*) EXRelativeFromDateStr:(NSString*)datestr TimeStr:(NSString*)timestr type:(NSString*)type localTime:(BOOL)localtime{
    NSDateFormatter *dateformat = [[NSDateFormatter alloc] init];
    if(localtime==YES)
        [dateformat setTimeZone:[NSTimeZone localTimeZone]];
    else
        [dateformat setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
    NSDate *begin_at_date;
    if(![timestr isEqualToString: @""]){
        [dateformat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        begin_at_date=[dateformat dateFromString:[NSString stringWithFormat:@"%@ %@",datestr,timestr]];
    }else{
        [dateformat setTimeZone:[NSTimeZone localTimeZone]];
        [dateformat setDateFormat:@"yyyy-MM-dd"];
        begin_at_date=[dateformat dateFromString:[NSString stringWithFormat:@"%@",datestr]];
    }
    
    [dateformat setTimeZone:[NSTimeZone localTimeZone]];
    [dateformat setDateFormat:@"yyyy-MM-dd"];
    NSString *nowdate_str=[dateformat stringFromDate:[NSDate date]];
    [dateformat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *now_date=[dateformat dateFromString:[NSString stringWithFormat:@"%@ 00:00:00 ",nowdate_str]];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    //    NSDateComponents *comps =[calendar components: NSDayCalendarUnit fromDate:now_date toDate:begin_at_date options:0];
    NSDate *beginingofweek=[Util beginningOfWeek:now_date];
    
    NSDateComponents *comps_firstdayofweek =[calendar components: NSDayCalendarUnit fromDate:beginingofweek toDate:begin_at_date options:0];
    NSString *relativeTime=@"";
    
    int day=[Util daysBetween:begin_at_date  and:now_date];
    //    int day=[comps day];
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
                relativeTime=[NSString stringWithFormat:@"Two days ago"];
            
            //                relativeTime=[NSString stringWithFormat:@"The day before yesterday"];
            else if(day==2){
                //                relativeTime=[NSString stringWithFormat:@"The day after tomorrow"];
                relativeTime=[NSString stringWithFormat:@"In two days"];
            }
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
                else if(beginingofweek_tobegin_at_day<=13)
                    relativeTime=[NSString stringWithFormat:@"Next %@",weekdaysymbol];
                else if(beginingofweek_tobegin_at_day>=14)
                    relativeTime=[NSString stringWithFormat:@"In %u days",abs(day)];
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
                    relativeTime=[NSString stringWithFormat:@"%u minutes ago",abs(minute)];
            }
            else if(minute>=-30 && minute<-1){
                if([type isEqualToString:@"cross"])
                    relativeTime=[NSString stringWithFormat:@"Now"];
                else
                    relativeTime=[NSString stringWithFormat:@"%u minutes ago",abs(minute)];
            }
            else if(minute>=-1 && minute<=0){
                if([type isEqualToString:@"cross"])
                    relativeTime=[NSString stringWithFormat:@"Now"];
                else
                    relativeTime=[NSString stringWithFormat:@"Seconds ago"];
            }
            else if(minute>=1 && minute<=59)
                relativeTime=[NSString stringWithFormat:@"In %u minutes",abs(minute)];
            else if(minute>=60 && minute<=749){
                float f_h=minute/60.0;
                int hour=round(f_h+0.2);//round 8 away from zero, round 7 towards zero
                relativeTime=[NSString stringWithFormat:@"In %u hours",abs(hour)];
            }
        }
        
    }
    
    [dateformat release];
    return relativeTime;
    
}

- (NSString*) EXRelativeWithType:(NSString*)type localTime:(BOOL)localtime{
    return [CrossTime EXRelativeFromDateStr:self.begin_at.date TimeStr:self.begin_at.time type:type localTime:localtime];
}

@end
