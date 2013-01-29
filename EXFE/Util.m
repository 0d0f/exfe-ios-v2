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
    
    NSString *facebookRegex = @"[A-Z0-9a-z._%+-]+@facebook";
    NSPredicate *facebookTest = [NSPredicate predicateWithFormat:@"SELF MATCHES[c] %@", facebookRegex];
    if([facebookTest evaluateWithObject:external_id]==YES)
        return @"facebook";
    
    return @"";
}
//+ (NSTimeZone*) getTimeZoneWithCrossTime:(CrossTime*)crosstime{
//    
//    BOOL is_same_timezone=false;
//    NSDateFormatter *format = [[NSDateFormatter alloc] init];
//    NSLocale *locale=[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
//    [format setLocale:locale];
//    [format setDateFormat:@"ZZZZ"];
//    NSString *localTimezone = [format stringFromDate:[NSDate date]];
//    localTimezone=[localTimezone substringFromIndex:3];
//    [format setDateFormat:@"yyyy"];
//
//    NSString* cross_timezone=@"";
//    if(crosstime.begin_at.timezone.length>=6 )
//        cross_timezone=[crosstime.begin_at.timezone substringToIndex:6];
//    if([cross_timezone isEqualToString:localTimezone])
//        is_same_timezone=YES;
//    [locale release];
//    [format release];
//
//    if(is_same_timezone==YES)
//        return [NSTimeZone localTimeZone];
//        
//    if([crosstime.begin_at.timezone length]==6)
//    {
//        NSString *hh=[crosstime.begin_at.timezone substringWithRange:NSMakeRange(1, 2)];
//        NSString *mm=[crosstime.begin_at.timezone substringWithRange:NSMakeRange(4, 2)];
//        int second_offset=([hh intValue]*60+[mm intValue])*60;
//        NSTimeZone *timezone=[NSTimeZone timeZoneForSecondsFromGMT:second_offset];
//        return timezone;
//    }
//    return nil;
//}
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
    
    for (UIWindow* window in [UIApplication sharedApplication].windows) {
        NSArray* subviews = window.subviews;
        if ([subviews count] > 0)
            if ([[subviews objectAtIndex:0] isKindOfClass:[UIAlertView class]])
                return;
    }
    
    if([meta.code intValue]==401){
        errormsg=@"Authentication failed due to security concerns, please sign in again.";

        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:errormsg delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:@"Sign Out",nil];
        alert.tag=500;
        alert.delegate=delegate;
        [alert show];
        [alert release];
    }
}

+ (NSString*) cleanInputName:(NSString*)username provider:(NSString*)provider{
    if([provider isEqualToString:@"twitter"]){
        if([username hasPrefix:@"@"])
            username=[username stringByReplacingOccurrencesOfString:@"@" withString:@""];
    }
    if([provider isEqualToString:@"facebook"]){
        
        if([username hasSuffix:@"@facebook"])
            username=[username stringByReplacingOccurrencesOfString:@"@facebook" withString:@""];
    }
    return username;
}

+ (void) showErrorWithMetaDict:(NSDictionary*)meta delegate:(id)delegate{
    for (UIWindow* window in [UIApplication sharedApplication].windows) {
        NSArray* subviews = window.subviews;
        if ([subviews count] > 0)
            if ([[subviews objectAtIndex:0] isKindOfClass:[UIAlertView class]])
                return;
    }

    NSString *errormsg=@"";
    if([[meta objectForKey:@"code"] isKindOfClass:[NSNumber class]])
    {
        if([(NSNumber*)[meta objectForKey:@"code"] intValue]==401){
            errormsg=@"Authentication failed due to security concerns, please sign in again.";
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

@end
