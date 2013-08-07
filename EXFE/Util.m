//
//  Util.m
//  EXFE
//
//  Created by ju huo on 5/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Util.h"

#import <CoreLocation/CoreLocation.h>
#import <math.h>
#import <BlocksKit/BlocksKit.h>
#import "UIApplication+EXFE.h"
#import "CrossTime.h"
#import "EFTime.h"
#import "EFAPIServer.h"
#import "NBPhoneNumberUtil.h"
#import "NBPhoneNumber.h"
#import "NBPhoneNumberDefines.h"
#import "CSqlite.h"

// Notification Definition
NSString *const EXCrossListDidChangeNotification = @"EX_CROSS_LIST_DID_CHANGE";



@implementation Util
+ (NSString*) decodeFromPercentEscapeString:(NSString*)string{
    CFStringRef sref = CFURLCreateStringByReplacingPercentEscapesUsingEncoding(NULL,(CFStringRef) string,CFSTR(""),kCFStringEncodingUTF8);
    NSString *s=[NSString stringWithFormat:@"%@", (__bridge NSString *)sref];
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
    return (__bridge NSString *)urlString;
    
}

+ (NSString *) EFPercentEscapedQueryStringPairMemberFromString:(NSString *)string {
    static NSString * const kEFCharactersToBeEscaped = @":/?&=;+!@#$()~";
    static NSString * const kEFCharactersToLeaveUnescaped = @"[].";
    
	CFStringRef urlString = CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                                   (CFStringRef)string,
                                                                   (CFStringRef)kEFCharactersToLeaveUnescaped,
                                                                   (CFStringRef)kEFCharactersToBeEscaped,
                                                                   kCFStringEncodingUTF8);
    return (__bridge NSString *)urlString;
}

+ (NSString*) getBackgroundLink:(NSString*)imgname
{
    //    https://exfe.com/static/img/xbg/westlake.jpg
    return [NSString stringWithFormat:@"%@/xbg/%@",IMG_ROOT,imgname];
}

+ (NSString*) findProvider:(NSString*)external_id{
    Provider p = [self matchedProvider:external_id];
    return [Identity getProviderString:p];
}

// Possible
+ (Provider)candidateProvider:(NSString*)raw
{
    NSString *lowercase = [raw lowercaseString];
    
    NSString *twitterRegex1 = @"^@[a-z0-9-]{1,15}$";
    NSPredicate *twitterTest1 = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", twitterRegex1];
    if ([twitterTest1 evaluateWithObject:lowercase] == YES){
        return kProviderTwitter;
    }
    NSString *twitterRegex2 = @"^[a-z0-9-]{1,15}@twitter$";
    NSPredicate *twitterTest2 = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", twitterRegex2];
    if ([twitterTest2 evaluateWithObject:lowercase] == YES){
        return kProviderTwitter;
    }
    
    NSString *facebookRegex = @"[0-9a-z.]+@facebook";
    NSPredicate *facebookTest = [NSPredicate predicateWithFormat:@"SELF MATCHES[c] %@", facebookRegex];
    if ([facebookTest evaluateWithObject:lowercase] == YES){
        return kProviderFacebook;
    }
    
    NSString *emailRegex = @"^[_a-z0-9-\\+]+(\\.[_a-z0-9-]+)*@[a-z0-9-]+(\\.[a-z0-9]+)*(\\.[a-z]{2,})$";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    if ([emailTest evaluateWithObject:lowercase] == YES){
        return kProviderEmail;
    }
    
    if ([lowercase rangeOfString:@"@"].length == 0 && [Util isValidPhoneNumber:lowercase]) {
        return kProviderPhone;
    }
    
    return kProviderUnknown;
}

+ (Provider)matchedProvider:(NSString*)raw
{
    NSString *lowercase = [raw lowercaseString];
    NSString *emailRegex = @"^[_a-z0-9-\\+]+(\\.[_a-z0-9-]+)*@[a-z0-9-]+(\\.[a-z0-9]+)*(\\.[a-z]{2,})$";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    if ([emailTest evaluateWithObject:lowercase] == YES){
        return kProviderEmail;
    }
    
    NSString *twitterRegex1 = @"^@[a-z0-9-]{1,15}$";
    NSPredicate *twitterTest1 = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", twitterRegex1];
    if ([twitterTest1 evaluateWithObject:lowercase] == YES){
        return kProviderTwitter;
    }
    NSString *twitterRegex2 = @"^[a-z0-9-]{1,15}@twitter$";
    NSPredicate *twitterTest2 = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", twitterRegex2];
    if ([twitterTest2 evaluateWithObject:lowercase] == YES){
        return kProviderTwitter;
    }
    
    NSString *facebookRegex = @"[0-9a-z.]+@facebook";
    NSPredicate *facebookTest = [NSPredicate predicateWithFormat:@"SELF MATCHES[c] %@", facebookRegex];
    if ([facebookTest evaluateWithObject:lowercase] == YES){
        return kProviderFacebook;
    }
    
    NSString *phoneRegex = @"^[+][0-9]{5,15}$";
    NSPredicate *phoneTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", phoneRegex];
    if ([phoneTest evaluateWithObject:lowercase] == YES){
        return kProviderPhone;
    }
    
    return kProviderUnknown;
}

+ (NSDictionary*)parseIdentityString:(NSString*)raw
{
    Provider p = [self matchedProvider:raw];
    return [self parseIdentityString:raw byProvider:p];
}

+ (NSDictionary*)parseIdentityString:(NSString*)raw byProvider:(Provider)p
{
    NSString *provider = [Identity getProviderString:p];
    switch (p) {
        case kProviderEmail:{
            return @{@"external_username": raw, @"external_id": raw, @"provider": provider};
        } break;
        case kProviderPhone:{
            return @{@"external_username":[self formatPhoneNumber:raw], @"external_id": [self formatPhoneNumber:raw], @"provider": provider};
        } break;
        case kProviderFacebook:{
            if ([raw hasSuffix:@"@facebook"]) {
                NSString *name = [raw substringToIndex:raw.length - @"@facebook".length];
                return @{@"external_username":name, @"external_id": @"", @"provider": provider};
            }
        } break;
        case kProviderTwitter:{
            if ([raw hasPrefix:@"@"]) {
                return @{@"external_username":[raw substringFromIndex:1], @"external_id": @"", @"provider": provider};
            } else {
                if ([raw hasSuffix:@"@twitter"]) {
                    NSString *name = [raw substringToIndex:raw.length - @"@twitter".length];
                    return @{@"external_username":name, @"external_id": @"", @"provider": provider};
                }
            }
        } break;
        default:
            break;
    }
    
    return @{@"external_username":raw, @"external_id": @"", @"provider": provider};
}

+ (NSString *)getDeviceCountryCode
{
    CTTelephonyNetworkInfo *netInfo = [[CTTelephonyNetworkInfo alloc] init];
    CTCarrier *carrier = [netInfo subscriberCellularProvider];
    NSString *isocode;
    if (carrier) {
        isocode = [[carrier isoCountryCode] uppercaseString];
    } else {
        NSLocale *locale = [NSLocale currentLocale];
        isocode = [locale objectForKey:NSLocaleCountryCode];
    }
    return isocode;
}

+ (BOOL)isAcceptedPhoneNumber:(NSString*)phonenumber{
    
    NSString *isoCC = [self getDeviceCountryCode];
    NBPhoneNumberUtil *phoneUtil = [NBPhoneNumberUtil sharedInstance];
    
    NSError *aError = nil;
    NSString *normalized = [phoneUtil normalizePhoneNumber:phonenumber];
    if ([normalized hasPrefix:@"+"]) {
        return YES;
    }
    
    NBPhoneNumber *myNumber = [phoneUtil parse:normalized defaultRegion:isoCC error:&aError];
    if (aError != nil) {
        if ([phoneUtil isValidNumber:myNumber]) {
            NSString *rc = [phoneUtil getRegionCodeForNumber:myNumber];
            NBEPhoneNumberType type = [phoneUtil getNumberType:myNumber];
            
            if ([@"CN" isEqualToString:rc] && type == NBEPhoneNumberTypeMOBILE) {
                return YES;
            }
            if ([phoneUtil isNANPACountry:rc] && type == NBEPhoneNumberTypeFIXED_LINE_OR_MOBILE) {
                return YES;
            }
        }
    }
    return NO;
}

+ (NSString*)getTelephoneCountryCode:(NSString*)isocode
{
    NSString *uppercaseIsoCC = [isocode uppercaseString];
    NBPhoneNumberUtil *phoneUtil = [NBPhoneNumberUtil sharedInstance];
    UInt32 cc = [phoneUtil getCountryCodeForRegion:uppercaseIsoCC];
    if (cc > 0) {
        return [NSString stringWithFormat:@"%u", (unsigned int)cc];
    }
    return @"";
}

+ (NSString*)getTelephoneCountryCode
{
    NSString *isoCC = [self getDeviceCountryCode];
    return [self getTelephoneCountryCode:isoCC];
}

+ (BOOL) isValidPhoneNumber:(NSString*)phonenumber{
    NBPhoneNumberUtil *phoneUtil = [NBPhoneNumberUtil sharedInstance];
    return [phoneUtil isViablePhoneNumber:phonenumber];
}

+ (NSString*) formatPhoneNumber:(NSString*)phonenumber{
    NSString *isoCC = [self getDeviceCountryCode];
    NBPhoneNumberUtil *phoneUtil = [NBPhoneNumberUtil sharedInstance];
    
    NSError *aError = nil;
    BOOL plus = [phonenumber hasPrefix:@"+"];
    NSString *normalized = [phoneUtil normalizePhoneNumber:phonenumber];
    if (plus) {
        normalized = [NSString stringWithFormat:@"+%@", normalized];
    }
    
    NBPhoneNumber *myNumber = [phoneUtil parse:normalized defaultRegion:isoCC error:&aError];
    if (aError == nil) {
        if ([phoneUtil isValidNumber:myNumber]) {
            NSString *formatted = [phoneUtil format:myNumber numberFormat:NBEPhoneNumberFormatE164 error:&aError];
            if (aError == nil) {
                return formatted;
            }
        }
    }
    return normalized;
}

+ (NSDate*) beginningOfWeek:(NSDate*)date{
    NSDate *today = [NSDate date];
    NSCalendar *gregorian = [NSCalendar currentCalendar];
    NSDateComponents *weekdayComponents = [gregorian components:NSWeekdayCalendarUnit fromDate:today];
    NSDateComponents *componentsToSubtract = [[NSDateComponents alloc] init];
    [componentsToSubtract setDay: - ([weekdayComponents weekday] - [gregorian firstWeekday])];
    NSDate *beginningOfWeek = [gregorian dateByAddingComponents:componentsToSubtract toDate:today options:0];
    NSDateComponents *components = [gregorian components: (NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate: beginningOfWeek];
    beginningOfWeek = [gregorian dateFromComponents: components];
    return beginningOfWeek;
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
    NSDate *beginingofweek=[self beginningOfWeek:now_date];
    
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
        if(timestr.length > 0)
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
    
    return relativeTime;
    
}

+ (int)daysBetween:(NSDate *)dt1 and:(NSDate *)dt2{
    
    NSDateFormatter *dateformat = [[NSDateFormatter alloc] init];
    
    [dateformat setDateFormat:@"yyyy-MM-dd"];
    NSString *date1=[dateformat stringFromDate:dt1];
    NSString *date2=[dateformat stringFromDate:dt2];
    
    NSDate *dt1_n=[dateformat dateFromString:date1];
    NSDate *dt2_n=[dateformat dateFromString:date2];
    
    
    NSCalendar* calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:NSDayCalendarUnit fromDate:dt2_n toDate:dt1_n options:0];
    return [components day];
}

+ (void) signout{
    AppDelegate* app = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    
    NSString *udid = [[NSUserDefaults standardUserDefaults] objectForKey:@"udid"];
    if (udid == nil){
        udid = @"";
    }
    [app.model.apiServer signOutUsingUdid:udid success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ([operation.response statusCode] == 200 && [responseObject isKindOfClass:[NSDictionary class]]){
        }
        [app signoutDidFinish];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [app signoutDidFinish];
    }];
    
}

+ (void) showErrorWithMetaObject:(Meta*)meta delegate:(id)delegate{
    
    for (UIWindow* window in [UIApplication sharedApplication].windows) {
        NSArray* subviews = window.subviews;
        if ([subviews count] > 0)
            if ([[subviews objectAtIndex:0] isKindOfClass:[UIAlertView class]])
                return;
    }
    NSString *errormsg = @"";
    if ([meta.code intValue] == 401) {
        errormsg = @"Authentication failed due to security concerns, please sign in again.";
        
#ifdef WWW
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:errormsg delegate:delegate cancelButtonTitle:nil otherButtonTitles:@"OK",nil];
#else
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:errormsg delegate:delegate cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK",nil];
#endif
        
        alertView.tag = 500;
        [alertView show];
    }
}

+ (void) showConnectError:(NSError*)err delegate:(id)delegate{

    NSString *errormsg = @"";
    NSString *errorTitle = @"";
    if (err.code == NSURLErrorBadServerResponse) {
        // http://stackoverflow.com/questions/16759630/afnetworking-returning-reponse-in-nserror-object
        errorTitle = @"Server Error";
        errormsg = @"Sorry, something is technically wrong in the \"cloud\", we’re fixing it up.";
    } else { //NSURLError.h
        errorTitle = @"Network Error";
        errormsg = @"Failed to connect to server. Please retry or wait awhile.";
    }
    if (![errormsg isEqualToString:@""]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:errorTitle message:errormsg delegate:delegate cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
}
+ (CGRect)expandRect:(CGRect)rect{
    return [Util expandRect:rect with:CGRectNull];
}

+ (CGRect)expandRect:(CGRect)rect1 with:(CGRect)rect2{
    CGFloat minY = 0;
    CGFloat maxY = 0;
    if (CGRectIsNull(rect1)) {
        if (CGRectIsNull(rect2)) {
            return CGRectNull;
        }else{
            minY = CGRectGetMinY(rect2);
            maxY = CGRectGetMaxY(rect2);
        }
    }else{
        if (CGRectIsNull(rect2)) {
            minY = CGRectGetMinY(rect1);
            maxY = CGRectGetMaxY(rect1);
        }else{
            minY = MIN(CGRectGetMinY(rect1), CGRectGetMinY(rect2));
            maxY = MAX(CGRectGetMaxY(rect1), CGRectGetMaxY(rect2));
        }
    }
    return CGRectMake(0, minY, 320, maxY - minY);
}

+ (CGRect)expandRect:(CGRect)rect1 with:(CGRect)rect2  with:(CGRect)rect3{
    return [Util expandRect:rect1 with:[Util expandRect:rect2 with:rect3]];
}

+ (void)checkUpdate
{
    //    http://api.exfe.com/versions/
    //    {
    //        "ios" => {"version" => "", "description" => "", "url" => ""}
    //        "andriod" => {"version" => "", "description" => "", "url" => ""}
    //    }
    
    // https://itunes.apple.com/cn/app/exfe/id514026604
    
    NSString *last_string = [[NSUserDefaults standardUserDefaults] stringForKey:@"version_last_check_time"];
    NSDate *last_time = nil;
    if (last_string) {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateStyle:NSDateFormatterFullStyle];
        
        last_time = [formatter dateFromString:last_string];
    }
    if (last_time == nil || ABS([Util daysBetween:last_time and:[NSDate date]]) > 3){
        AppDelegate * app = (AppDelegate*)[UIApplication sharedApplication].delegate;
        [app.model.apiServer checkAppVersionSuccess:^(AFHTTPRequestOperation *operation, id JSON) {
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setDateStyle:NSDateFormatterFullStyle];
            NSString *now_string = [formatter stringFromDate:[NSDate date]];
            [[NSUserDefaults standardUserDefaults] setValue:now_string forKey:@"version_last_check_time"];
            
            NSDictionary *iosVersionObject = [JSON valueForKeyPath:@"response.ios"];
            NSString *version = [iosVersionObject valueForKey:@"version"];
            NSString *description = [iosVersionObject valueForKey:@"description"];
            NSString *url = [iosVersionObject valueForKey:@"url"];
            
            NSString *localVersion = [UIApplication appVersion];
            if ([UIApplication isNewVersion:version]) {
                
                NSString *message = [NSString stringWithFormat:NSLocalizedString(@"EXFE %@ is available. You’re using version %@. Update now?", nil), version, localVersion];
                
                [UIAlertView showAlertViewWithTitle:NSLocalizedString(@"Update available", nil)
                                            message:message
                                  cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
                                  otherButtonTitles:@[NSLocalizedString(@"Update", nil)]
                                            handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
                                                if (buttonIndex == alertView.firstOtherButtonIndex) {
                                                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
                                                }
                                            }];
            }
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//            NSLog(@"check version fail");
        }];
    }
}


// URL query param tool
+ (NSString*)concatenateQuery:(NSDictionary*)parameters {
    if (!parameters || [parameters count] == 0){
       return nil; 
    }
    NSMutableString *query = [NSMutableString string];
    for (NSString *parameter in [parameters allKeys]){
        [query appendFormat:@"&%@=%@", [parameter stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding], [[parameters valueForKey:parameter] stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding]];
    }
    return [query substringFromIndex:1];
}

+ (NSDictionary*)splitQuery:(NSString*)query {
    if ([query length] == 0){
        return nil;
    }
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    for(NSString *parameter in [query componentsSeparatedByString:@"&"]) {
        NSRange range = [parameter rangeOfString:@"="];
        if(range.location != NSNotFound){
            [parameters setValue:[[parameter substringFromIndex:range.location+range.length] stringByReplacingPercentEscapesUsingEncoding:NSASCIIStringEncoding]
                          forKey:[[parameter substringToIndex:range.location] stringByReplacingPercentEscapesUsingEncoding:NSASCIIStringEncoding]];
        } else {
            [parameters setValue:[[NSString alloc] init] forKey:[parameter stringByReplacingPercentEscapesUsingEncoding:NSASCIIStringEncoding]];
        }
    }
    return parameters;
}

+ (CSqlite *)gpsSqlite {
    static CSqlite *Sqlite = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Sqlite = [[CSqlite alloc] init];
        [Sqlite openSqlite];
    });
    
    return Sqlite;
}

@end
