//
//  Exfee+EXFE.m
//  EXFE
//
//  Created by Stony Wang on 3/13/13.
//
//

#import "Exfee+EXFE.h"
#import "Invitation.h"
#import "Identity.h"

@implementation Exfee (EXFE)


-(NSMutableArray*)getMyInvitationSet
{
    return nil;
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


@end
