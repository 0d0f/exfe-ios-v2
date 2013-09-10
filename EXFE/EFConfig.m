//
//  EFConfig.m
//  EXFE
//
//  Created by Stony Wang on 13-9-10.
//
//

#import "EFConfig.h"

static NSDictionary * Config = nil;

@implementation EFConfig

+ (instancetype)sharedInstance
{
    static EFConfig *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[EFConfig alloc] init];
        // Do any other initialisation stuff here
        Config = @{@"panda": @{@"api": @"http://api.panda.0d0f.com/v2/"
                               ,@"img": @"http://panda.0d0f.com/static/img"
                               ,@"oauth": @"http://panda.0d0f.com/oAuth"
                               }
                   ,@"black": @{@"api": @"http://api.0d0f.com/v2/"
                                ,@"img": @"http://0d0f.com/static/img"
                                ,@"oauth": @"http://0d0f.com/OAuth"
                                }
                   ,@"shuady": @{@"api": @"https://api.exfe.com/v2/"
                                 ,@"img": @"https://exfe.com/static/img"
                                 ,@"oauth": @"https://exfe.com/OAuth"
                                 }
                   ,@"shuadycn": @{@"api": @"https://api.shuady.cn/v2/"
                                   ,@"img": @"https://shuady.cn/static/img"
                                   ,@"oauth": @"https://shuady.cn/OAuth"
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

- (NSString *)key
{
    
#ifdef DEBUG
    #ifdef WWW
        #ifdef SHUADY
            return @"shuadycn";
        #else
            return @"shuady";
        #endif
    #elif (defined PANDA) || (defined PILOT)
        return @"panda";
    #else
    // DEV
        return @"black";
    #endif  // #ifdef WWW
#else
    // WWW
    #ifdef SHUADY
        return @"shuadycn";
    #else
        return @"shuady";
    #endif
#endif  // #ifdef DEBUG
}

- (NSString *)API_ROOT
{
    return Config[self.key][@"api"];
}

- (NSString *)IMG_ROOT
{
    return Config[self.key][@"img"];
}

- (NSString *)OAUTH_ROOT
{
    return Config[self.key][@"oauth"];
}
@end
