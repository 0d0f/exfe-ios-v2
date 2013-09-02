//
//  Exfee+EXFE.m
//  EXFE
//
//  Created by Stony Wang on 3/13/13.
//
//

#import <RestKit/RestKit.h>
#import "Exfee+EXFE.h"
#import "User+EXFE.h"
#import "Invitation+EXFE.h"
#import "DateTimeUtil.h"

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

-(NSArray*)getSortedInvitations:(InvitationSortType)sortType
{
    NSMutableArray *sorted = [[NSMutableArray alloc]  initWithCapacity:self.invitations.count];
    
    NSArray *invitations = [self.invitations sortedArrayUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"invitation_id" ascending:YES]]];
    
    // WALKAROUND: clean duplicate
//    if (invitations != nil) {
//        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
//        for (Invitation *x in invitations) {
//            NSString *key = [x.invitation_id stringValue];
//            Invitation *previous = [dict objectForKey:key];
//            if (previous == nil) {
//                [dict setObject:x forKey:key];
//            } else {
//                if ([x.updated_at timeIntervalSinceDate:previous.updated_at] > 0) {
//                    [dict removeObjectForKey:key];
//                    [dict setObject:x forKey:key];
//                }
//            }
//        }
//        if (invitations.count > dict.count) {
//            invitations = [dict allValues];
//        }
//    }
    
    
    switch (sortType) {
        case kInvitationSortTypeMeAcceptOthers:{
            int myself = 0;
            int accepts = 0;
            
            for(Invitation *invitation in invitations) {
                if ([@"REMOVED" isEqualToString:invitation.rsvp_status] == NO) {
                    if([[User getDefaultUser] isMe:invitation.identity]){
                        [sorted insertObject:invitation atIndex:myself];
                        myself ++;
                    } else if([@"ACCEPTED" isEqualToString:invitation.rsvp_status] == YES){
                        [sorted insertObject:invitation atIndex:(myself + accepts)];
                        accepts ++;
                    } else {
                        [sorted addObject:invitation];
                    }
                }
            }
        }
            break;
        case kInvitationSortTypeMeAcceptNoNotifications:{
            int myself = 0;
            int accepts = 0;
            
            for(Invitation *invitation in invitations) {
                if ([@"REMOVED" isEqualToString:invitation.rsvp_status] == NO && [@"NOTIFICATION" isEqualToString:invitation.rsvp_status] == NO) {
                    if([[User getDefaultUser] isMe:invitation.identity]){
                        [sorted insertObject:invitation atIndex:myself];
                        myself ++;
                    } else if([@"ACCEPTED" isEqualToString:invitation.rsvp_status] == YES){
                        [sorted insertObject:invitation atIndex:(myself + accepts)];
                        accepts ++;
                    } else {
                        [sorted addObject:invitation];
                    }
                }
            }
        }
            break;
        case kInvitationSortTypeHostAcceptOthers:{
            int hosts = 0;
            int accepts = 0;
            
            for(Invitation *invitation in invitations) {
                if ([@"REMOVED" isEqualToString:invitation.rsvp_status] == NO){
                    if([invitation.host boolValue] == YES){
                        [sorted insertObject:invitation atIndex:hosts];
                        hosts ++;
                    } else if([@"ACCEPTED" isEqualToString:invitation.rsvp_status] == YES){
                        [sorted insertObject:invitation atIndex:(hosts + accepts)];
                        accepts ++;
                    } else {
                        [sorted addObject:invitation];
                    }
                }
            }
        }
            break;
        case kInvitationSortTypeHostAcceptNoNotifications:{
            int hosts = 0;
            int accepts = 0;
            
            for(Invitation *invitation in invitations) {
                if ([@"REMOVED" isEqualToString:invitation.rsvp_status] == NO && [@"NOTIFICATION" isEqualToString:invitation.rsvp_status] == NO) {
                    if([invitation.host boolValue] == YES){
                        [sorted insertObject:invitation atIndex:hosts];
                        hosts ++;
                    } else if([@"ACCEPTED" isEqualToString:invitation.rsvp_status] == YES){
                        [sorted insertObject:invitation atIndex:(hosts + accepts)];
                        accepts ++;
                    } else {
                        [sorted addObject:invitation];
                    }
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
    return result;
}

-(NSArray*)getSortedMergedInvitations:(InvitationSortType)sortType
{
    NSArray *invitations = [self.invitations sortedArrayUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"invitation_id" ascending:YES]]];
    
    NSMutableDictionary *users = [NSMutableDictionary dictionaryWithCapacity:self.invitations.count];
    NSMutableArray *host_ids = [NSMutableArray array];
    NSMutableArray *accept_ids = [NSMutableArray array];
    
    for (Invitation *invitation in invitations) {
        RsvpCode rsvp = [Invitation getRsvpCode:invitation.rsvp_status];
        if (rsvp != kRsvpRemoved) {
            NSString *user_id = [invitation.identity.connected_user_id stringValue];
            NSMutableArray *list = [users valueForKey:user_id];
            if (!list) {
                list = [NSMutableArray arrayWithCapacity:5];
                [users setValue:list forKey:user_id];
            }
            
            if (rsvp == kRsvpNotification) {
                [list addObject:invitation];
            } else {
                // insert before kRsvpNotification
                [list insertObject:invitation atIndex:0];
            }
            
            if ([invitation.host boolValue] == YES) {
                [host_ids addObject:user_id];
            }
            if (rsvp == kRsvpAccepted) {
                [accept_ids addObject:user_id];
            }
        }
    }
    
    NSMutableArray *sortedUser = [[NSMutableArray alloc]  initWithCapacity:users.count];
    
    switch (sortType) {
        case kInvitationSortTypeMeAcceptOthers:{
            [accept_ids insertObject:[[User getDefaultUser].user_id stringValue] atIndex:0];
            
            for (NSString* key in accept_ids) {
                NSArray *obj = [users valueForKey:key];
                if (obj) {
                    [sortedUser addObject:obj];
                    [users removeObjectForKey:key];
                }
            }
            
            for (NSArray * list in [users allValues]) {
                Invitation *inv = [list objectAtIndex:0];
                RsvpCode rsvp = [Invitation getRsvpCode:inv.rsvp_status];
                if (rsvp != kRsvpNotification) {
                    [sortedUser addObject:list];
                }
            }
//            [sortedUser addObjectsFromArray:[users allValues]];
        }
            break;
        case kInvitationSortTypeHostAcceptOthers:{
            [host_ids insertObject:[[User getDefaultUser].user_id stringValue] atIndex:0];
            
            for (NSString* key in host_ids) {
                NSArray *obj = [users valueForKey:key];
                if (obj) {
                    [sortedUser addObject:obj];
                    [users removeObjectForKey:key];
                }
            }
            [sortedUser addObjectsFromArray:[users allValues]];
        }
            break;
        case kInvitationSortTypeDefaultById:
        default:
            break;
    }
    
    NSArray* result = [NSArray arrayWithArray:sortedUser];
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
        int identity_id = [inv.identity.identity_id intValue];
        if(identity_id == 0){
            if ([inv.identity.external_id isEqualToString:invitation.identity.external_id]) {
                return YES;
            }
        }else if(identity_id > 0){
            if (identity_id == [invitation.identity.identity_id intValue]){
                return YES;
            }
        }
    }
    return NO;
}

- (void)debugPrint{
#ifdef DEBUG
    NSLog(@"exfee id: %@", self.exfee_id);
    NSLog(@"exfee accepted: %@", self.accepted);
    NSLog(@"exfee total: %@", self.total);
    NSLog(@"exfee invitation count: %i", self.invitations.count);
    for (Invitation *inv in self.invitations) {
        NSLog(@"exfee invitation item: %@", [inv.identity getDisplayName]);
    }
#endif
}


@end
