//
//  User+EXFE.m
//  EXFE
//
//  Created by Stony Wang on 13-3-20.
//
//

#import "EFAPIServer.h"

@implementation User (EXFE)

- (BOOL) isMe:(Identity*)my_identity
{
    return [self isMeByIdentityId:my_identity.identity_id];
}

- (BOOL) isMeByIdentityId:(NSNumber *)identity_id
{
    for(Identity *_identity in self.identities){
        if([_identity.identity_id isEqual:identity_id])
            return YES;
    }
    return NO;
}

- (NSArray*) sortedIdentiesBy:(NSSortDescriptor*) descriptor
{
    return [self.identities sortedArrayUsingDescriptors:[NSArray arrayWithObject:descriptor]];
}

- (NSArray*) sortedIdentiesById{
    NSSortDescriptor* descriptor = [NSSortDescriptor sortDescriptorWithKey:@"identity_id" ascending:YES];
    return [self sortedIdentiesBy:descriptor];
}

- (NSArray *) getIdentitiesForCrossEntry
{
    NSArray *identities = [self sortedIdentiesById];
    NSMutableArray *list = [NSMutableArray arrayWithCapacity:identities.count];
    for (Identity *identity in identities) {
        NSString *status = identity.status;
        if ([@"CONNECTED" isEqualToString:status] || [@"REVOKED" isEqualToString:status]) {
            [list addObject:identity];
        }
    }
    return list;
}

+ (User*) getDefaultUser
{
    AppDelegate * app = (AppDelegate*)[UIApplication sharedApplication].delegate;
    return [User getUserById:app.model.userId];
}

+ (User*) getDefaultUserFrom:(EXFEModel*)model
{
    return [User getUserFrom:model byId:model.userId];
}

+ (User*) getUserById:(int)userId
{
    AppDelegate * app = (AppDelegate*)[UIApplication sharedApplication].delegate;
    return [User getUserFrom:app.model byId:userId];
}

+ (User*) getUserFrom:(EXFEModel*)model byId:(int)userId
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"User"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"user_id = %u", userId];
    [request setPredicate:predicate];
    RKObjectManager *objectManager = model.objectManager;
    NSArray *users = [objectManager.managedObjectStore.mainQueueManagedObjectContext executeFetchRequest:request error:nil];
    if(users != nil && [users count] > 0)
    {
        return [users objectAtIndex:0];
    }
    return nil;
}
@end
