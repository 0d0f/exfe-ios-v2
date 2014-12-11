//
//  Identity+EXFE.h
//  EXFE
//
//  Created by Stony Wang on 3/15/13.
//
//

#import "Identity.h"

typedef NS_ENUM(NSUInteger, Provider){
    kProviderUnknown = 0,
    kProviderPhone,
    kProviderFacebook,
    kProviderEmail,
    kProviderTwitter,
    kProviderInstagram,
    kProviderFlickr,
    kProviderDropbox,
    kProviderWechat
} ;

typedef NS_ENUM(NSUInteger, ProviderType){
    kProviderTypeUnknown = 0,
    kProviderTypeVerification,
    kProviderTypeAuthorization
} ;


@class RoughIdentity, IdentityId;
@interface Identity (EXFE)

- (NSString*)getDisplayName;
- (NSString*)getDisplayIdentity;

+ (Provider)getProviderCode:(NSString*)str;
+ (NSString*)getProviderString:(Provider)code;
+ (ProviderType)getProviderTypeByString:(NSString*)str;
+ (ProviderType)getProviderTypeByCode:(Provider)code;
+ (NSString *)getIdentityImageNameByProvider:(Provider)p;
+ (UIImage *)getIdentityImageByProvider:(Provider)p;

// if there's no such identity, return nil.
+ (Identity *)identityFromLocalRoughIdentity:(RoughIdentity *)roughIdentity;
- (RoughIdentity *)roughIdentityValue;
- (BOOL)hasAnyNotificationIdentity;

- (IdentityId *)identityIdValue;

// compare
- (BOOL)isEqualToIdentity:(Identity *)another;  // compareWithIdentityId: && compareWithExternalIdAndProvider:
- (BOOL)compareWithIdentityId:(Identity *)another;
- (BOOL)compareWithExternalIdAndProvider:(Identity *)another;

@end
