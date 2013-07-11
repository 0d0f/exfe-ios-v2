//
//  Identity+EXFE.m
//  EXFE
//
//  Created by Stony Wang on 3/15/13.
//
//

#import "Identity+EXFE.h"

#import <RestKit/RestKit.h>
#import "RoughIdentity.h"
#import "IdentityId.h"
#import "NBPhoneNumberUtil.h"
#import "NBPhoneNumber.h"
#import "NBPhoneNumberDefines.h"
#import "Util.h"

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
            //break;
        default:
            return @"";
            break;
    }
}

+ (ProviderType)getProviderTypeByString:(NSString*)str
{
    return [self getProviderTypeByCode:[self getProviderCode:str]];
}

+ (ProviderType)getProviderTypeByCode:(Provider)code
{
    switch (code) {
        case kProviderEmail:
            return kProviderTypeVerification;
            //break;
        case kProviderPhone:
            return kProviderTypeVerification;
            //break;
        case kProviderTwitter:
            return kProviderTyperAuthorization;
            //break;
        case kProviderFacebook:
            return kProviderTyperAuthorization;
            //break;
        case kProviderInstagram:
            return kProviderTyperAuthorization;
            //break;
        case kProviderFlickr:
            return kProviderTyperAuthorization;
            //break;
        case kProviderDropbox:
            return kProviderTyperAuthorization;
            //break;
        default:
            return kProviderTypeUnknown;
            break;
    }
}

- (NSString*)getDisplayName
{
    if (self.nickname && [self.nickname length] > 0) {
        return self.nickname;
    }
    if (self.name && [self.name length] > 0) {
        return self.name;
    }
    return self.external_id;
}

- (NSString*)getDisplayIdentity
{
    Provider p = [Identity getProviderCode:self.provider];
    switch (p) {
        case kProviderEmail:
            return self.external_id;
        case kProviderPhone:{
            
            NBPhoneNumberUtil *phoneUtil = [NBPhoneNumberUtil sharedInstance];            
            NSString * isocode = [Util getDeviceCountryCode];
            
            NSError *aError = nil;
            NBPhoneNumber *myNumber = [phoneUtil parse:self.external_id defaultRegion:isocode error:&aError];
            if (aError == nil){
                NBEPhoneNumberFormat fmt = NBEPhoneNumberFormatNATIONAL;
                NSString *rc = [phoneUtil getRegionCodeForNumber:myNumber];
                if (![isocode isEqualToString:rc]) {
                    fmt = NBEPhoneNumberFormatINTERNATIONAL;
                }
                
                NSString *formatted = [phoneUtil format:myNumber numberFormat:fmt error:&aError];
                if (aError == nil) {
                    return formatted;
                }
            }
            return self.external_id;
        }   break;
        case kProviderTwitter:
            return [NSString stringWithFormat:@"@%@", self.external_username];
            break;
        default:
            return [NSString stringWithFormat:@"%@@%@", self.external_username, self.provider];
            break;
    }
    
}

+ (Identity *)identityFromLocalRoughIdentity:(RoughIdentity *)roughIdentity {
    Identity *identity = nil;
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Identity"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"((external_username == %@) AND (provider== %@))", roughIdentity.externalUsername, roughIdentity.provider];
    [request setPredicate:predicate];
    
    RKObjectManager *objectManager = [RKObjectManager sharedManager];
    NSArray *suggestwithselected = [objectManager.managedObjectStore.mainQueueManagedObjectContext executeFetchRequest:request error:nil];
    
    if([suggestwithselected count] > 0){
        identity = [suggestwithselected objectAtIndex:0];
    }
    
    return identity;
}

- (RoughIdentity *)roughIdentityValue {
    RoughIdentity *roughtIdentity = [RoughIdentity identity];
    roughtIdentity.provider = self.provider;
    roughtIdentity.externalUsername = self.external_username;
    roughtIdentity.externalID = self.external_id;
    roughtIdentity.identity = self;
    
    return roughtIdentity;
}

- (BOOL)hasAnyNotificationIdentity {
    Provider provider = [[self class] getProviderCode:self.provider];
    BOOL hasNotification = NO;
    
    switch (provider) {
        case kProviderEmail:
        case kProviderPhone:
        case kProviderTwitter:
        case kProviderFacebook:
            hasNotification = YES;
            break;
        case kProviderInstagram:
        case kProviderFlickr:
        case kProviderDropbox:
        default:
            hasNotification = NO;
            break;
    }
    
    return hasNotification;
}

- (IdentityId *)identityIdValue {
    RKObjectManager *objectManager = [RKObjectManager sharedManager];
    NSEntityDescription *invitationEntity = [NSEntityDescription entityForName:@"IdentityId" inManagedObjectContext:objectManager.managedObjectStore.mainQueueManagedObjectContext];
    IdentityId *identityId = [[IdentityId alloc] initWithEntity:invitationEntity insertIntoManagedObjectContext:objectManager.managedObjectStore.mainQueueManagedObjectContext];
    identityId.identity_id = [NSString stringWithFormat:@"%@@%@", self.external_username, self.provider];
    
    return identityId;
}

- (BOOL)isEqualToIdentity:(Identity *)another {
    return ([self compareWithIdentityId:another] && [self compareWithExternalIdAndProvider:another]);
}

- (BOOL)compareWithIdentityId:(Identity *)another {
    if ([self.identity_id intValue] == [another.identity_id intValue])
        return YES;
    return NO;
}

- (BOOL)compareWithExternalIdAndProvider:(Identity *)another {
    if ([self.external_id isEqualToString:another.external_id] && [self.provider isEqualToString:another.provider])
        return YES;
    return NO;
}

@end
