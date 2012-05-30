//
//  Util.m
//  EXFE
//
//  Created by ju huo on 5/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Util.h"

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
@end
