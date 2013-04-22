//
//  LocalContact+EXFE.m
//  EXFE
//
//  Created by 0day on 13-4-19.
//
//

#import "LocalContact+EXFE.h"
#import "RoughIdentity.h"
#import "EFDataDefines.h"

NSString *kEFProviderNamePhone = @"phone";
NSString *kEFProviderNameEmail = @"email";
NSString *kEFProviderNameFacebook = @"facebook";
NSString *kEFProviderNameTwitter = @"twitter";

@implementation LocalContact (EXFE)

- (NSArray *)roughIdentities {
    NSMutableArray *identities = [[NSMutableArray alloc] init];
    
    // phone
    NSArray *phones = self.phones ? [NSKeyedUnarchiver unarchiveObjectWithData:self.phones] : nil;
    if (phones && [phones count]) {
        for (NSString *phone in phones) {
            RoughIdentity *roughIdentity = [RoughIdentity identity];
            roughIdentity.provider = kEFProviderNamePhone;
            roughIdentity.externalID = phone;
            roughIdentity.externalUsername = self.name;
            
            [identities addObject:roughIdentity];
        }
        
    }
    
    // facebook
    NSArray *ims = self.im ? [NSKeyedUnarchiver unarchiveObjectWithData:self.im] : nil;
    if (ims && [ims count]) {
        for (NSDictionary *imDict in ims) {
            NSString *providerName = [imDict objectForKey:@"service"];
            if ([providerName isEqualToString:@"Facebook"]) {
                RoughIdentity *roughIdentity = [RoughIdentity identity];
                roughIdentity.provider = kEFProviderNameFacebook;
                roughIdentity.externalID = [imDict objectForKey:@"username"];
                roughIdentity.externalUsername = self.name;
                
                [identities addObject:roughIdentity];
            }
        }
    }
    
    // mail
    NSArray *mails = self.emails ? [NSKeyedUnarchiver unarchiveObjectWithData:self.emails] : nil;
    if (mails && [mails count]) {
        for (NSString *email in mails) {
            RoughIdentity *roughIdentity = [RoughIdentity identity];
            roughIdentity.provider = kEFProviderNameEmail;
            roughIdentity.externalID = email;
            roughIdentity.externalUsername = self.name;
            
            [identities addObject:roughIdentity];
        }
    }
    
    // social
    NSArray *socials = self.social ? [NSKeyedUnarchiver unarchiveObjectWithData:self.social] : nil;
    if (socials && [socials count]) {
        for (NSDictionary *socialDict in socials) {
            NSString *providerName = [socials valueForKey:@"service"];
            if ([providerName isEqualToString:@"twitter"]) {
                RoughIdentity *roughIdentity = [RoughIdentity identity];
                roughIdentity.provider = kEFProviderNameTwitter;
                roughIdentity.externalID = [socialDict valueForKey:@"username"];
                roughIdentity.externalUsername = self.name;
                
                [identities addObject:roughIdentity];
            } else if ([providerName isEqualToString:@"facebook"]) {
                RoughIdentity *roughIdentity = [RoughIdentity identity];
                roughIdentity.provider = kEFProviderNameFacebook;
                roughIdentity.externalID = [socialDict valueForKey:@"username"];
                roughIdentity.externalUsername = self.name;
                
                BOOL shouldSkip = NO;
                for (RoughIdentity *identity in identities) {
                    if ([identity isEqualToRoughIdentity:roughIdentity]) {
                        shouldSkip = YES;
                        break;
                    }
                }
                if (!shouldSkip) {
                    [identities addObject:roughIdentity];
                }
            }
        }
    }
    
    NSArray *result = [[identities copy] autorelease];
    [identities release];
    
    return result;
}

@end
