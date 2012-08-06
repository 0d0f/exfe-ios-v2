//
//  Util.h
//  EXFE
//
//  Created by ju huo on 5/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CrossTime.h"
#import "SORelativeDateTransformer.h"

#define FONT_COLOR_100 [UIColor colorWithRed:100/255.0f green:100/255.0f blue:100/255.0f alpha:1]
#define FONT_COLOR_69 [UIColor colorWithRed:69/255.0f green:69/255.0f blue:69/255.0f alpha:1]
#define FONT_COLOR_233 [UIColor colorWithRed:233/255.0f green:233/255.0f blue:233/255.0f alpha:1]
#define FONT_COLOR_98 [UIColor colorWithRed:98/255.0f green:132/255.0f blue:159/255.0f alpha:1]
#define FONT_COLOR_88 [UIColor colorWithRed:88/255.0f green:156/255.0f blue:209/255.0f alpha:1]
#define FONT_COLOR_HL [UIColor colorWithRed:58/255.0f green:110/255.0f blue:165/255.0f alpha:1]

@interface Util : NSObject

+ (NSString*) decodeFromPercentEscapeString:(NSString*)string;
+ (NSString*) encodeToPercentEscapeString:(NSString*)string;
+ (UIColor*) getHighlightColor;
+ (UIColor*) getRegularColor;
+ (NSDictionary*) crossTimeToString:(CrossTime*)crosstime;
+ (NSDictionary*) crossTimeToStringSimple:(CrossTime*)crosstime;
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

+ (NSString*) EXRelativeFromDate:(NSDate*)date;
+ (NSString*) EXRelative:(CrossTime*)crosstime;
+ (NSString*) getTimeTitle:(CrossTime*)crosstime;
+ (NSString*) getTimeDesc:(CrossTime*)crosstime;
+ (NSDate*) beginningOfWeek:(NSDate*)date;
@end

