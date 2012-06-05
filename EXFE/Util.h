//
//  Util.h
//  EXFE
//
//  Created by ju huo on 5/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CrossTime.h"

@interface Util : NSObject

+ (NSString*) decodeFromPercentEscapeString:(NSString*)string;
+ (NSString*) encodeToPercentEscapeString:(NSString*)string;
+ (UIColor*) getHighlightColor;
+ (UIColor*) getRegularColor;
+ (NSDictionary*) crossTimeToString:(CrossTime*)crosstime;
+ (NSString *) formattedLongDateRelativeToNow:(NSString*)datestr;
+ (NSString*) getBackgroundLink:(NSString*)imgname;
@end

