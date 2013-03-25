//
//  Exfee+EXFE.m
//  EXFE
//
//  Created by Stony Wang on 3/13/13.
//
//

#import "Exfee+EXFE.h"
#import "User+EXFE.h"
#import <RestKit/RestKit.h>

@implementation Exfee (EXFE)

-(Invitation*)getMyInvitation{
    Invitation * me = nil;
    for(Invitation *invitation in self.invitations)
    {
        if([[User getDefaultUser] isMe:invitation.identity]){
            if (me){
                if ([Invitation getRsvpCode:me.rsvp_status] == kRsvpNotification && [Invitation getRsvpCode:invitation.rsvp_status] == kRsvpNotification) {
                    me = invitation;
                }
            }else{
                me = invitation;
            }
        }
    }
    return me;
}

- (void) addDefaultInvitationBy:(Identity*)identity{
    
    Invitation *invitation = [Invitation invitationWithIdentity:identity];
    invitation.rsvp_status = @"ACCEPTED";
    invitation.host = [NSNumber numberWithBool:YES];
    invitation.updated_by = identity;
    [self addInvitationsObject:invitation];
}

-(NSArray*)getSortedInvitations{
    return [self getSortedInvitations:kInvitationSortTypeDefaultById];
}

-(NSArray*)getSortedInvitations:(InvitationSortType)sortType;
{
    NSMutableArray *sorted = [[NSMutableArray alloc]  initWithCapacity:self.invitations.count];
    
    NSArray *invitations = [self.invitations sortedArrayUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"invitation_id" ascending:YES]]];
    
    switch (sortType) {
        case kInvitationSortTypeMeAcceptOthers:{
            int myself = 0;
            int accepts = 0;
            
            for(Invitation *invitation in invitations) {
                if([[User getDefaultUser] isMe:invitation.identity]){
                    [sorted insertObject:invitation atIndex:myself];
                    myself ++;
                } else if([@"ACCEPTED" isEqualToString:invitation.rsvp_status] == YES){
                    [sorted insertObject:invitation atIndex:(myself + accepts)];
                    accepts ++;
                } else if ([@"REMOVED" isEqualToString:invitation.rsvp_status] == NO){
                    [sorted addObject:invitation];
                }
            }
        }
            break;
        case kInvitationSortTypeHostAcceptOthers:{
            int hosts = 0;
            int accepts = 0;
            
            for(Invitation *invitation in invitations) {
                if([invitation.host boolValue] == YES){
                    [sorted insertObject:invitation atIndex:hosts];
                    hosts ++;
                } else if([@"ACCEPTED" isEqualToString:invitation.rsvp_status] == YES){
                    [sorted insertObject:invitation atIndex:(hosts + accepts)];
                    accepts ++;
                } else if ([@"REMOVED" isEqualToString:invitation.rsvp_status] == NO){
                    [sorted addObject:invitation];
                }
            }
        }
            break;
        case kInvitationSortTypeDefaultById:
        default:
            [sorted addObjectsFromArray:invitations];
            break;
    }
    
    NSArray* result = [NSArray arrayWithArray:sorted];
    [sorted release];
    return result;
}

-(NSArray*)getMyInvitations
{
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:5];
    for(Invitation *invitation in self.invitations)
    {
        if([[User getDefaultUser] isMe:invitation.identity]){
            [array addObject:invitation];
        }
    }
    return array;
}

-(NSArray*)getMergedInvitationSet
{
    NSMutableDictionary *merged = [NSMutableDictionary dictionaryWithCapacity:self.invitations.count];
    NSArray* set = [self.invitations allObjects];
    for (Invitation *inv in set ) {
        NSNumber *iid = nil;
        if (inv && inv.identity) {
            iid = inv.identity.identity_id;
            
            NSMutableArray *list = [merged objectForKey:iid];
            if (list == nil){
                list = [NSMutableArray array];
                [merged setObject:list forKey:iid];
            }
            [list addObject:inv];
        }
    }
    return [merged allValues];
}

- (BOOL)hasInvitation:(Invitation*)invitation{
    for (Invitation *inv in self.invitations){
        int inv_user_id = [inv.identity.connected_user_id intValue];
        if(inv_user_id == 0){
            if ([inv.identity.external_id isEqualToString:invitation.identity.external_id]) {
                return YES;
            }
        }else if(inv_user_id > 0){
            if (inv_user_id == [invitation.identity.connected_user_id intValue]){
                return YES;
            }
        }
    }
    return NO;
}


@end
