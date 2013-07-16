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
    kRsvpRemoved,
    kRsvpNotification,
    kRsvpIgnored,
};



@interface Invitation (EXFE)

@property (nonatomic, readonly, retain) NSArray *notification_identity_array;

+ (RsvpCode)getRsvpCode:(NSString*)str;
+ (NSString*)getRsvpString:(RsvpCode)code;
+ (Invitation*)invitationWithIdentity:(Identity*)identity;


- (void)replaceIdentity:(Identity*)identity;
@end
