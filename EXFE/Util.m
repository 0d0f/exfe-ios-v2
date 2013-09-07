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
#import <RestKit/RestKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <CoreTelephony/CTCarrier.h>
#import "CCTemplate.h"
#import "UIApplication+EXFE.h"
#import "EFAPI.h"
#import "NBPhoneNumberUtil.h"
#import "NBPhoneNumber.h"
#import "NBPhoneNumberDefines.h"
#import "CSqlite.h"
#import "EFKit.h"

// Notification Definition
NSString *const EXCrossListDidChangeNotification = @"EX_CROSS_LIST_DID_CHANGE";


static NSDictionary * _keywordDict = nil;

@implementation Util
{}
+ (NSDictionary *) keywordDict
{
    if (!_keywordDict) {
        _keywordDict = @{
                         @"PRODUCT_NAME":[NSLocalizedString(@"EXFE", @"Name for Product, eg: Shuady") stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]],
                         @"APP_NAME":[NSLocalizedString(@"EXFE ", @"Name for App, eg: ·X·") stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]],
                         @"PRODUCT_APP_NAME":[NSLocalizedString(@"EXFE  ", @"Name for Product and App, eg: Shuady ·X·") stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]],
                         @"X_NOUN":[NSLocalizedString(@"·X· ", @"·X· as noun") stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]],
                         @"X_VERB":[NSLocalizedString(@"·X·  ", @"·X· as verb") stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]],
                         @"X_FOR_GATHER":[NSLocalizedString(@"·X·   ", @"·X· for Gahter") stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]],
                         };
    }
    return _keywordDict;
}

#pragma mark URL query param tool
+ (NSString*) decodeFromPercentEscapeString:(NSString*)string {
    CFStringRef sref = CFURLCreateStringByReplacingPercentEscapesUsingEncoding(NULL,(CFStringRef) string,CFSTR(""),kCFStringEncodingUTF8);
    NSString *s=[NSString stringWithFormat:@"%@", (__bridge NSString *)sref];
    CFRelease(sref);
    return s;
}

+ (NSString*) encodeToPercentEscapeString:(NSString*)string {
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

+ (NSString *) concatenateQuery:(NSDictionary *)parameters {
    if (!parameters || [parameters count] == 0){
        return nil;
    }
    NSMutableString *query = [NSMutableString string];
    for (NSString *parameter in [parameters allKeys]){
        [query appendFormat:@"&%@=%@", [parameter stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding], [[parameters valueForKey:parameter] stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding]];
    }
    return [query substringFromIndex:1];
}

+ (NSDictionary *)splitQuery:(NSString *)query {
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

#pragma mark provider
+ (NSString *) findProvider:(NSString *)external_id
{
    Provider p = [self matchedProvider:external_id];
    return [Identity getProviderString:p];
}

// Possible
+ (Provider) candidateProvider:(NSString *)raw
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

+ (Provider) matchedProvider:(NSString *)raw
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

+ (NSDictionary *) parseIdentityString:(NSString *)raw
{
    Provider p = [self matchedProvider:raw];
    return [self parseIdentityString:raw byProvider:p];
}

+ (NSDictionary *) parseIdentityString:(NSString *)raw byProvider:(Provider)p
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

#pragma mark Telephone number helper
+ (NSString *) getDeviceCountryCode
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

+ (BOOL) isAcceptedPhoneNumber:(NSString *)phonenumber{
    
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

+ (NSString *) getTelephoneCountryCode:(NSString *)isocode
{
    NSString *uppercaseIsoCC = [isocode uppercaseString];
    NBPhoneNumberUtil *phoneUtil = [NBPhoneNumberUtil sharedInstance];
    UInt32 cc = [phoneUtil getCountryCodeForRegion:uppercaseIsoCC];
    if (cc > 0) {
        return [NSString stringWithFormat:@"%u", (unsigned int)cc];
    }
    return @"";
}

+ (NSString*) getTelephoneCountryCode
{
    NSString *isoCC = [self getDeviceCountryCode];
    return [self getTelephoneCountryCode:isoCC];
}

+ (BOOL) isValidPhoneNumber:(NSString *)phonenumber
{
    NBPhoneNumberUtil *phoneUtil = [NBPhoneNumberUtil sharedInstance];
    return [phoneUtil isViablePhoneNumber:phonenumber];
}

+ (NSString *) formatPhoneNumber:(NSString *)phonenumber
{
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

#pragma mark deprecated time date helper

+ (int) daysBetween:(NSDate *)dt1 and:(NSDate *)dt2
{
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

#pragma mark sign out. should move to another place
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

#pragma mark error handler
+ (void) showErrorWithMetaObject:(Meta*)meta delegate:(id)delegate{
    
    for (UIWindow* window in [UIApplication sharedApplication].windows) {
        NSArray* subviews = window.subviews;
        if ([subviews count] > 0)
            if ([[subviews objectAtIndex:0] isKindOfClass:[UIAlertView class]])
                return;
    }
    NSString *errormsg = @"";
    if ([meta.code intValue] == 401) {
        errormsg = NSLocalizedString(@"Authentication failed due to security concerns, please sign in again.", nil);
        
#ifdef WWW
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:errormsg delegate:delegate cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"OK", nil),nil];
#else
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:errormsg delegate:delegate cancelButtonTitle:NSLocalizedString(@"Cancel", nil) otherButtonTitles:NSLocalizedString(@"OK", nil),nil];
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
        errorTitle = NSLocalizedString(@"Server Error", nil);
        errormsg = NSLocalizedString(@"Sorry, something is technically wrong in the \"cloud\", we’re fixing it up.", nil);
    } else { //NSURLError.h
        errorTitle = NSLocalizedString(@"Network error", nil);
        errormsg = NSLocalizedString(@"Failed to connect to server.\nPlease retry or wait awhile.", nil);
    }
    if (![errormsg isEqualToString:@""]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:errorTitle message:errormsg delegate:delegate cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
        [alert show];
    }
}

+ (void) handleDefaultBannerTitle:(NSString *)title andMessage:(NSString *)message
{
    EFErrorMessage *errorMessage = [[EFErrorMessage alloc] initBannerMessageWithTitle:title message:message bannerPressedHandler:nil buttonPressedHandler:nil needRetry:NO];
    [[EFErrorHandlerCenter defaultCenter] presentErrorMessage:errorMessage];
}

+ (void) handleRetryBannerFor:(EFNetworkOperation *)operation withTitle:(NSString *)title andMessage:(NSString *)message andRetry:(BOOL)retry
{
    EFNetworkOperation *op = [[operation class] operationWithModel:((EFNetworkOperation * )operation).model dupelicatedFrom:operation];

    if (op.retryCount < op.maxRetry || op.maxRetry == 0) {
        EFErrorMessage *errorMessage = [[EFErrorMessage alloc] initBannerMessageWithTitle:title
                                                                                  message:message
                                                                     bannerPressedHandler:^{
                                                                         if (retry) {
                                                                             EFNetworkManagementOperation *managementOperation = [[EFNetworkManagementOperation alloc] initWithNetworkOperation:op];
                                                                             
                                                                             [[EFQueueManager defaultManager] addNetworkManagementOperation:managementOperation completeHandler:nil];
                                                                         } else {
                                                                             [op operationDidRetryFail];
                                                                         }
                                                                     }
                                                                     buttonPressedHandler:^{
                                                                         [op operationDidRetryFail];
                                                                     }
                                                                                needRetry:retry];
        
        [[EFErrorHandlerCenter defaultCenter] presentErrorMessage:errorMessage];
    } else {
        // tryCount upto max limited
//        EFErrorMessage *errorMessage = [[EFErrorMessage alloc] initBannerMessageWithTitle:NSLocalizedString(@"##Alert Title##", nil)
//                                                                                  message:[NSString stringWithFormat:NSLocalizedString(@"##Alert content content content content content content ##", nil)]
//                                                                     bannerPressedHandler:nil
//                                                                     buttonPressedHandler:nil
//                                                                                needRetry:NO];
//        
//        [[EFErrorHandlerCenter defaultCenter] presentErrorMessage:errorMessage];
    }
}

+ (void) handleDefaultRetryBannerFor:(EFNetworkOperation *)operation withError:(NSError *)error {
    if ([NSURLErrorDomain isEqualToString:error.domain] || [AFNetworkingErrorDomain isEqualToString:error.domain]) {
        switch (error.code) {
            case NSURLErrorCancelled: // -999
            case NSURLErrorTimedOut: //-1001
            case NSURLErrorCannotFindHost: //-1003
            case NSURLErrorCannotConnectToHost: //-1004
            case NSURLErrorNetworkConnectionLost: //-1005
            case NSURLErrorDNSLookupFailed: //-1006
//            case NSURLErrorNotConnectedToInternet: //-1009
//            {// Retry
//                NSString *title = NSLocalizedString(@"##Alert Title##", nil);
//                NSString *message = [NSString stringWithFormat:NSLocalizedString(@"##Alert content content content content content content ##", nil)];
//                
//                [Util handleRetryBannerFor:self withTitle:title andMessage:message];
//                
//            }   break;
                
            case NSURLErrorHTTPTooManyRedirects: //-1007
            case NSURLErrorResourceUnavailable: //-1008
            case NSURLErrorRedirectToNonExistentLocation: //-1010
            case NSURLErrorBadServerResponse: // -1011
            case NSURLErrorServerCertificateUntrusted: //-1202
                
                
                break;
                
            default:
                break;
        }
    }
}

#pragma mark Rect Expander
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

#pragma mark others
+ (NSString*) getBackgroundLink:(NSString*)imgname
{
    //    https://exfe.com/static/img/xbg/westlake.jpg
    return [NSString stringWithFormat:@"%@/xbg/%@",IMG_ROOT,imgname];
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
            NSString *description __attribute__((unused)) = [iosVersionObject valueForKey:@"description"];
            NSString *url = [iosVersionObject valueForKey:@"url"];
            
            NSString *localVersion = [UIApplication appVersion];
            if ([UIApplication isNewVersion:version]) {
                
                NSString *message = [NSString stringWithFormat:[NSLocalizedString(@"{{PRODUCT_APP_NAME}} %@ is available. You’re using version %@. Update now?", nil) templateFromDict:[Util keywordDict]], version, localVersion];
                
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
            RKLogInfo(@"check version fail");
        }];
    }
}

#pragma mark other
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
