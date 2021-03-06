//
//  UIApplication+EXFE.m
//  EXFE
//
//  Created by Stony Wang on 13-3-29.
//
//

#import "UIApplication+EXFE.h"

@implementation UIApplication (EXFE)

+ (NSString *) appVersion
{
    return [[NSBundle mainBundle] objectForInfoDictionaryKey: @"CFBundleShortVersionString"];
    
//    NSString *appDisplayName = [[NSBundle mainBundle] objectForKey:@"CFBundleDisplayName"];
//    NSString *majorVersion = [[NSBundle mainBundle] objectForKey:@"CFBundleShortVersionString"];
//    NSString *minorVersion = [[NSBundle mainBundle] objectForKey:@"CFBundleVersion"];
}

+ (BOOL) isNewVersion:(NSString *)checkVersion
{
    NSString *nowVer = [self appVersion];
    if ([nowVer isEqualToString:checkVersion]) {
        return NO;
    }
    
    // if ([nowVer compare:checkVersion options:NSNumericSearch] != NSOrderedAscending)
    NSArray *nowVerComps = [nowVer componentsSeparatedByString:@"."];
    NSArray *checkVerComps = [checkVersion componentsSeparatedByString:@"."];
    for (NSUInteger i = 0; i < checkVerComps.count; i ++) {
        NSUInteger check = [[checkVerComps objectAtIndex:i] integerValue];
        NSUInteger now = 0;
        if (i < nowVerComps.count) {
            now = [[nowVerComps objectAtIndex:i] integerValue];
        }
        if (check != now) {
            return check > now;
        }
    }
 
    return NO;
}

+ (NSString *) build
{
    return [[NSBundle mainBundle] objectForInfoDictionaryKey: (NSString *)kCFBundleVersionKey];
}

+ (NSString *) versionBuild
{
    NSString * version = [self appVersion];
    NSString * build = [self build];
    
    NSString * versionBuild = [NSString stringWithFormat: @"v%@", version];
    
    if (![version isEqualToString: build]) {
        versionBuild = [NSString stringWithFormat: @"%@(%@)", versionBuild, build];
    }
    
    return versionBuild;
}

- (NSString *)defaultScheme {
    NSArray * schemes = [[[NSBundle mainBundle] infoDictionary] valueForKeyPath:@"CFBundleURLTypes.@distinctUnionOfArrays.CFBundleURLSchemes"];
    NSAssert(schemes.count > 0, @"Missing url sheme in main bundle.");

    NSString *result = nil;
    for (NSString *scheme in schemes) {
        if (result == nil || scheme.length < result.length) {
            result = scheme;
        }
    }
    return result;
}

@end
