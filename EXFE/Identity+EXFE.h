//
//  Identity+EXFE.h
//  EXFE
//
//  Created by Stony Wang on 3/15/13.
//
//

#import "Identity.h"


typedef NS_ENUM(NSUInteger, Provider){
    kProviderUnknown,
    kProviderEmail,
    kProviderPhone,
    kProviderTwitter,
    kProviderFacebook,
    kProviderInstagram,
    kProviderFlickr,
    kProviderDropbox
} ;

@interface Identity (EXFE)

- (NSString*)getDisplayName;
- (NSString*)getDisplayIdentity;

+ (Provider)getProviderCode:(NSString*)str;
+ (NSString*)getProviderString:(Provider)code;

@end