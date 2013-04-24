//
//  User+EXFE.m
//  EXFE
//
//  Created by Stony Wang on 13-3-20.
//
//

#import "User+EXFE.h"
#import "Identity+EXFE.h"
#import "AppDelegate.h"
#import "EFAPIServer.h"

@implementation User (EXFE)

- (BOOL) isMe:(Identity*)my_identity{
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

- (NSArray*) sortedIdentiesBy:(NSSortDescriptor*) descriptor{
    return [self.identities sortedArrayUsingDescriptors:[NSArray arrayWithObject:descriptor]];
}

- (NSArray*) sortedIdentiesById{
    NSSortDescriptor* descriptor = [NSSortDescriptor sortDescriptorWithKey:@"identity_id" ascending:YES];
    return [self sortedIdentiesBy:descriptor];
}


+ (User*) getDefaultUser{
    return [User getUserById:[EFAPIServer sharedInstance].user_id];
}

+ (User*) getUserById:(int)userId{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"User"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"user_id = %u", userId];
    [request setPredicate:predicate];
    RKObjectManager *objectManager = [RKObjectManager sharedManager];
    NSArray *users = [objectManager.managedObjectStore.mainQueueManagedObjectContext executeFetchRequest:request error:nil];
    if(users != nil && [users count] > 0)
    {
        return [users objectAtIndex:0];
    }
    return nil;
}
@end
