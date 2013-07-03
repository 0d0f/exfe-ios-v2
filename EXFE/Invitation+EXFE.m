//
//  Invitation+EXFE.m
//  EXFE
//
//  Created by Stony Wang on 3/15/13.
//
//

#import <RestKit/RestKit.h>
#import "Invitation+EXFE.h"


@implementation Invitation (EXFE)

+ (RsvpCode)getRsvpCode:(NSString*)str{
    if ([@"ACCEPTED" isEqualToString:str]) {
        return kRsvpAccepted;
    } else if ([@"INTERESTED" isEqualToString:str]) {
        return kRsvpInterested;
    } else if ([@"DECLINED" isEqualToString:str]) {
        return kRsvpDeclined;
    } else if ([@"REMOVED" isEqualToString:str]) {
        return kRsvpRemoved;
    } else if ([@"NOTIFICATION" isEqualToString:str]) {
        return kRsvpNotification;
    } else if ([@"IGNORED" isEqualToString:str]) {
        return kRsvpIgnored;
    } else {
        return kRsvpNoResponse;
    }
}

+ (NSString*)getRsvpString:(RsvpCode)code{
    switch (code) {
        case kRsvpAccepted:
            return @"ACCEPTED";
            //break;
        case kRsvpInterested:
            return @"INTERESTED";
            //break;
        case kRsvpDeclined:
            return @"DECLINED";
            //break;
        case kRsvpRemoved:
            return @"REMOVED";
            //break;
        case kRsvpNotification:
            return @"NOTIFICATION";
            //break;
        case kRsvpIgnored:
            return @"IGNORED";
            //break;
        case kRsvpNoResponse:
            //break; //fall through
        default:
            return @"NORESPONSE";
            break;
    }
    
}

+ (Invitation*)invitationWithIdentity:(Identity*)identity{
    RKObjectManager *objectManager = [RKObjectManager sharedManager];
    NSManagedObjectContext *context = objectManager.managedObjectStore.mainQueueManagedObjectContext;
    NSEntityDescription *invitationEntity = [NSEntityDescription entityForName:@"Invitation" inManagedObjectContext:context];
    Invitation *invitation = [[Invitation alloc] initWithEntity:invitationEntity insertIntoManagedObjectContext:context];
    invitation.rsvp_status = @"NORESPONSE";
    invitation.host = [NSNumber numberWithBool:NO];
    invitation.mates = 0;
    invitation.identity = identity;
    invitation.updated_by = nil;
    invitation.updated_at = [NSDate date];
    invitation.created_at = [NSDate date];
    return invitation;
}

- (void)replaceIdentity:(Identity*)identity{
    self.Identity = identity;
}

@end
