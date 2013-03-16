//
//  Identity+EXFE.m
//  EXFE
//
//  Created by Stony Wang on 3/15/13.
//
//

#import "Identity+EXFE.h"

@implementation Identity (EXFE)


+ (Provider)getProviderCode:(NSString*)str{
    if ([@"email" isEqualToString:str]) {
        return kProviderEmail;
    } else if ([@"phone" isEqualToString:str]) {
        return kProviderPhone;
    } else if ([@"twitter" isEqualToString:str]) {
        return kProviderTwitter;
    } else if ([@"facebook" isEqualToString:str]) {
        return kProviderFacebook;
    } else if ([@"instagram" isEqualToString:str]) {
        return kProviderInstagram;
    } else if ([@"flickr" isEqualToString:str]) {
        return kProviderFlickr;
    } else if ([@"dropbox" isEqualToString:str]) {
        return kProviderDropbox;
    } else {
        return kProviderUnknown;
    }
}

+ (NSString*)getProviderString:(Provider)code{
    switch (code) {
        case kProviderEmail:
            return @"email";
            //break;
        case kProviderPhone:
            return @"phone";
            //break;
        case kProviderTwitter:
            return @"twitter";
            //break;
        case kProviderFacebook:
            return @"facebook";
            //break;
        case kProviderInstagram:
            return @"instagram";
            //break;
        case kProviderFlickr:
            return @"flickr";
            //break;
        case kProviderDropbox:
            return @"dropbox";
        default:
            return @"";
            break;
    }
}

- (NSString*)getDisplayName
{
    if (self.nickname && [self.nickname length] > 0) {
        return self.nickname;
    }
    return self.name;
}

- (NSString*)getDisplayIdentity
{
    Provider p = [Identity getProviderCode:self.provider];
    switch (p) {
        case kProviderTwitter:
            return [NSString stringWithFormat:@"@%@", self.external_username];
            break;
        default:
            return self.external_username;
            break;
    }
    
}

@end
