//
//  IdentityId+EXFE.m
//  EXFE
//
//  Created by Stony Wang on 13-6-8.
//
//

#import "IdentityId+EXFE.h"
#import "Identity+EXFE.h"

@implementation IdentityId (EXFE)

- (NSString *)provider
{
    NSArray * list = [self.identity_id componentsSeparatedByString:@"@"];
    if (list.count > 1) {
        return [list objectAtIndex:list.count - 1];
    }
    return @"";
}

- (NSString *)external_username
{
    NSArray * list = [self.identity_id componentsSeparatedByString:@"@"];
    if (list.count > 1) {
        NSString *provider = [list objectAtIndex:list.count - 1];
        return [self.identity_id substringWithRange:NSMakeRange(0, self.identity_id.length - provider.length - 1)];
    }
    return @"";
}

- (NSString*)displayIdentity
{
    Provider p = [Identity getProviderCode:[self provider]];
    switch (p) {
        case kProviderEmail:
        case kProviderPhone:
            return [self external_username];
        case kProviderTwitter:
            return [NSString stringWithFormat:@"@%@", [self external_username]];
            break;
        default:
            return [NSString stringWithFormat:@"%@", self.identity_id];
            break;
    }
    
}

@end
