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

#define EFKeyServerScope      @"key.config.server.scope"

#define EFServerKeyPanda          @"panda"
#define EFServerKeyBlack          @"black"
#define EFServerKeyShuady         @"shuady"
#define EFServerScopeINT          @"ZZ"
#define EFServerScopeCN           @"CN"


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
                   //                                ,@"share":   @{@"": @"",
                   //                                              @"": @"",
                   //                                              @"": @"",
                   //                                              @"": @"",
                   //                                              @"": @""}
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
    NSString *scope = [self loadScope];
    if ([scope length] > 0) {
        return scope;
    } else {
        return [self suggestScope];
    }
}

- (NSString *)API_ROOT
{
    return Config[self.server][self.scope][@"api"];
}

- (NSString *)IMG_ROOT
{
    return Config[self.server][self.scope][@"img"];
}

- (NSString *)OAUTH_ROOT
{
    return Config[self.server][self.scope][@"oauth"];
}

- (NSString *)suggestScope
{
    CTTelephonyNetworkInfo *netInfo = [[CTTelephonyNetworkInfo alloc] init];
    CTCarrier *carrier = [netInfo subscriberCellularProvider];
    NSString *isocode;
    if (carrier) {
        isocode = [[carrier isoCountryCode] uppercaseString];
    } else {
        NSLocale *locale = [NSLocale currentLocale];
        isocode = [[locale objectForKey:NSLocaleCountryCode] uppercaseString];
    }
    if ([@"CN" isEqualToString:isocode]) {
        return EFServerScopeCN;
    } else {
        return EFServerScopeINT;
    }
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
