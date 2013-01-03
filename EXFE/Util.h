//
//  Util.h
//  EXFE
//
//  Created by ju huo on 5/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CrossTime.h"
#import "AppDelegate.h"
#import "Meta.h"
#import <RestKit/RestKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import "Place.h"


#define FONT_COLOR_100 [UIColor colorWithRed:100/255.0f green:100/255.0f blue:100/255.0f alpha:1]
#define FONT_COLOR_69 [UIColor colorWithRed:69/255.0f green:69/255.0f blue:69/255.0f alpha:1]
#define FONT_COLOR_233 [UIColor colorWithRed:233/255.0f green:233/255.0f blue:233/255.0f alpha:1]
#define FONT_COLOR_FA [UIColor colorWithRed:250/255.0f green:250/255.0f blue:250/255.0f alpha:1]
#define FONT_COLOR_CCC [UIColor colorWithRed:204/255.0f green:204/255.0f blue:204/255.0f alpha:1]
#define FONT_COLOR_232737 [UIColor colorWithRed:35/255.0f green:39/255.0f blue:55/255.0f alpha:0.9]
#define FONT_COLOR_98 [UIColor colorWithRed:98/255.0f green:132/255.0f blue:159/255.0f alpha:1]
#define FONT_COLOR_88 [UIColor colorWithRed:88/255.0f green:156/255.0f blue:209/255.0f alpha:1]
#define FONT_COLOR_51 [UIColor colorWithRed:51/255.0f green:51/255.0f blue:51/255.0f alpha:1]
#define FONT_COLOR_25 [UIColor colorWithRed:25/255.0f green:25/255.0f blue:25/255.0f alpha:1]
#define FONT_COLOR_HL [UIColor colorWithRed:58/255.0f green:110/255.0f blue:165/255.0f alpha:1]

#define COLOR255(d) (d/255.0f)
#define COLOR_RGBA(r,g,b,a) colorWithRed:COLOR255(r) green:COLOR255(g) blue:COLOR255(b) alpha:COLOR255(a)
#define COLOR_RGB(r,g,b) colorWithRed:COLOR255(r) green:COLOR255(g) blue:COLOR255(b) alpha:1
#define COLOR_WA(w,a) colorWithWhite:COLOR255(w)  alpha:COLOR255(a)

#define COLOR_EXFEE_BLUE COLOR_RGB(0x37, 0x84,0xD5)


#define MERCATOR_OFFSET 268435456
#define MERCATOR_RADIUS 85445659.44705395

@interface Util : NSObject

+ (NSString*) decodeFromPercentEscapeString:(NSString*)string;
+ (NSString*) encodeToPercentEscapeString:(NSString*)string;
+ (UIColor*) getHighlightColor;
+ (UIColor*) getRegularColor;
+ (NSDictionary*) crossTimeToString:(CrossTime*)crosstime;
+ (NSString *) formattedLongDateRelativeToNow:(NSString*)datestr;
+ (NSString *) formattedLongDateRelativeToNowWiteDate:(NSDate*)date;
+ (NSString *) formattedDateRelativeToNow:(NSDate*)date;
+ (NSString*) getBackgroundLink:(NSString*)imgname;
+ (NSString*) formattedShortDate:(CrossTime*)crosstime;
+ (NSString*) formattedLongDate:(CrossTime*)crosstime;
+ (void) drawRoundRect:(CGRect) rect color:(UIColor*)color radius:(float)radius;
+ (UIImage *)scaleImage:(UIImage*)image toResolution:(int)resolution;
+ (NSString*) findProvider:(NSString*)external_id;
+ (NSTimeZone*) getTimeZoneWithCrossTime:(CrossTime*)crosstime;

+ (NSString*) EXRelativeFromDateStr:(NSString*)datestr TimeStr:(NSString*)timestr type:(NSString*)type localTime:(BOOL)localtime;
+ (NSString*) EXRelative:(CrossTime*)crosstime type:(NSString*)type localTime:(BOOL)localtime;
+ (NSString*) getTimeTitle:(CrossTime*)crosstime localTime:(BOOL)localtime;
+ (NSString*) getTimeDesc:(CrossTime*)crosstime;
+ (NSDate*) beginningOfWeek:(NSDate*)date;
+ (BOOL) isCommonDomainName:(NSString*)domainname;
+ (void) showError:(Meta*)meta delegate:(id)delegate;
+ (void) showErrorWithMetaDict:(NSDictionary*)meta delegate:(id)delegate;
+ (void) showConnectError:(NSError*)err delegate:(id)delegate;
+ (void) signout;
+ (int)daysBetween:(NSDate *)dt1 and:(NSDate *)dt2;
+ (NSString*) cleanInputName:(NSString*)username provider:(NSString*)provider ;


@end

