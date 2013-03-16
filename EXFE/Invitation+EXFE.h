//
//  Invitation+EXFE.h
//  EXFE
//
//  Created by Stony Wang on 3/15/13.
//
//

#import "Invitation.h"

typedef NS_ENUM(NSUInteger, RsvpCode){
    kRsvpNoResponse,
    kRsvpAccepted,
    kRsvpInterested,
    kRsvpDeclined,
    kRsvpRmoved,
    kRsvpNotification,
    kRsvpIgnored,
};

@interface Invitation (EXFE)

+ (RsvpCode)getRsvpCode:(NSString*)str;
+ (NSString*)getRsvpString:(RsvpCode)code;

@end
