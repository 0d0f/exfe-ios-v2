//
//  Invitation.m
//  EXFE
//
//  Created by Stony Wang on 13-6-8.
//
//

#import "Invitation.h"
#import "Identity.h"
#import "IdentityId.h"


@implementation Invitation

@dynamic created_at;
@dynamic host;
@dynamic invitation_id;
@dynamic mates;
@dynamic rsvp_status;
@dynamic type;
@dynamic updated_at;
@dynamic via;
@dynamic identity;
@dynamic invited_by;
@dynamic notification_identities;
@dynamic updated_by;

- (NSArray *)notification_identity_array {
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:self.notification_identities.count];
    for (IdentityId *identityId in self.notification_identities) {
        [array addObject:identityId.identity_id];
    }
    
    return array;
}

@end
