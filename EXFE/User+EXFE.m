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

@implementation User (EXFE)

- (BOOL) isMe:(Identity*)my_identity{
    for(Identity *_identity in self.identities){
        if([_identity.identity_id isEqual:my_identity.identity_id])
            return YES;
    }
    return NO;
    
}

+ (User*) getDefaultUser{
    AppDelegate *app=(AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"User"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"user_id = %u", app.userid];
    [request setPredicate:predicate];
    RKObjectManager *objectManager = [RKObjectManager sharedManager];
    NSArray *users = [objectManager.managedObjectStore.mainQueueManagedObjectContext executeFetchRequest:request error:nil];
    if(users != nil && [users count] > 0)
    {
        return [[users objectAtIndex:0] autorelease];
    }
    return nil;
}
@end
