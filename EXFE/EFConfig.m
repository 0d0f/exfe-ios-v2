//
//  EFConfig.m
//  EXFE
//
//  Created by Stony Wang on 13-9-10.
//
//

#import "EFConfig.h"

#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <CoreTelephony/CTCarrier.h>


static NSDictionary * Config = nil;

@implementation EFConfig

+ (instancetype)sharedInstance
{
    static EFConfig *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[EFConfig alloc] init];
        // Do any other initialisation stuff here
        Config = @{EFServerKeyPanda: @{EFServerScopeINT:
                                           @{@"api": @"http://api.panda.0d0f.com/v2/"
                                             ,@"img": @"http://panda.0d0f.com/static/img"
                                             ,@"oauth": @"http://panda.0d0f.com/oAuth"
                                             }
                                       ,EFServerScopeCN:
                                           @{@"api": @"http://api.panda.0d0f.com/v2/"
                                             ,@"img": @"http://panda.0d0f.com/static/img"
                                             ,@"oauth": @"http://panda.0d0f.com/oAuth"
                                             }
                                       }
                   ,EFServerKeyBlack: @{EFServerScopeINT:
                                            @{@"api": @"http://api.0d0f.com/v2/"
                                              ,@"img": @"http://0d0f.com/static/img"
                                              ,@"oauth": @"http://0d0f.com/OAuth"
                                              }
                                        ,EFServerScopeCN:
                                            @{@"api": @"http://api.0d0f.com/v2/"
                                              ,@"img": @"http://0d0f.com/static/img"
                                              ,@"oauth": @"http://0d0f.com/OAuth"
                                              }
                                        }
                   ,EFServerKeyShuady:@{EFServerScopeINT:
                                            @{@"api": @"https://api.exfe.com/v2/"
                                              ,@"img": @"https://exfe.com/static/img"
                                              ,@"oauth": @"https://exfe.com/OAuth"
                                              }
                                        ,EFServerScopeCN: @{@"api": @"https://api.shuady.cn/v2/"
                                                          ,@"img": @"https://shuady.cn/static/img"
                                                          ,@"oauth": @"https://shuady.cn/OAuth"
                                                          }
                                        }
                   };
    });
    return sharedInstance;
}

- (NSString *)server
{
#ifdef DEV
    return EFServerKeyBlack;
#elif (defined PANDA) || (defined PILOT)
    return EFServerKeyPanda;
#else
    return EFServerKeyShuady;
#endif
}

- (NSString *)scope
{
#ifdef SHUADY
    return EFServerScopeCN;
#else
    NSString *scope = [self loadScope];
    if ([scope length] > 0) {
        return scope;
    } else {
        return [self suggestScope];
    }
#endif
}

- (NSString *)API_ROOT
{
    NSDictionary * dict = Config[self.server][self.scope];
    if (!dict) {
        dict = Config[self.server][EFServerScopeDEF];
    }
    return dict[@"api"];
}

- (NSString *)IMG_ROOT
{
    NSDictionary * dict = Config[self.server][self.scope];
    if (!dict) {
        dict = Config[self.server][EFServerScopeDEF];
    }
    return dict[@"img"];
}

- (NSString *)OAUTH_ROOT
{
    NSDictionary * dict = Config[self.server][self.scope];
    if (!dict) {
        dict = Config[self.server][EFServerScopeDEF];
    }
    return dict[@"oauth"];
}

- (BOOL)avalableForScope:(NSString *)scope
{
    return Config[self.server][scope] != nil;
}

- (NSString *)suggestScope
{
    CTTelephonyNetworkInfo *netInfo = [[CTTelephonyNetworkInfo alloc] init];
    CTCarrier *carrier = [netInfo subscriberCellularProvider];
    NSString *isocode;
    if (carrier) {
        isocode = [carrier isoCountryCode];
    } else {
        NSLocale *locale = [NSLocale autoupdatingCurrentLocale];
        isocode = [locale objectForKey:NSLocaleCountryCode];
    }
    if ([@"CN" compare:isocode options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        return EFServerScopeCN;
    } else {
        return EFServerScopeINT;
    }
}

- (NSString *)alias:(NSString *)scope
{
    if (scope.length == 0) {
        return EFServerScopeDEF;
    }
    if ([@"COM" compare:scope options:NSCaseInsensitiveSearch] == NSOrderedSame){
        return EFServerScopeINT;
    }
    return [scope uppercaseString];
}

- (BOOL)sameServerScope:(NSString *)scope
{
    NSString *s = [self alias:scope];
    if (![self avalableForScope:s]) {
        s = EFServerScopeDEF;
    }
    return [s isEqualToString:self.scope];
}

- (void)saveScope:(NSString *)scope
{
    [[NSUserDefaults standardUserDefaults] setObject:[scope uppercaseString] forKey:EFKeyServerScope];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSString *)loadScope
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:EFKeyServerScope];
}

- (void)clearScope
{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:EFKeyServerScope];
}
@end
