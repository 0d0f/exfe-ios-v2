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
#import "DateTimeUtil.h"

@implementation Exfee (EXFE)

+ (id)disconnectedEntity {
    NSManagedObjectContext *context = [RKObjectManager sharedManager].managedObjectStore.mainQueueManagedObjectContext;
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"Exfee" inManagedObjectContext:context];
    return [[[self alloc] initWithEntity:entityDescription insertIntoManagedObjectContext:nil] autorelease];
}

- (void)addToContext:(NSManagedObjectContext *)context {
    [context insertObject:self];
}

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
    NSLog(@"exfee id: %@", self.exfee_id);
    NSLog(@"exfee accepted: %@", self.accepted);
    NSLog(@"exfee total: %@", self.total);
    NSLog(@"exfee invitation count: %i", self.invitations.count);
    for (Invitation *inv in self.invitations) {
        NSLog(@"exfee invitation item: %@", [inv.identity getDisplayName]);
    }
}


@end
