//
//  EXFEModel+Crosses.m
//  EXFE
//
//  Created by 0day on 13-6-26.
//
//

#import "EXFEModel+Crosses.h"

#import "EFKit.h"
#import "EFAPIOperations.h"
#import "EFEntity.h"
#import "Util.h"

@implementation EXFEModel (Crosses)

- (NSArray *)getCrossList
{
    __block NSArray *xlist = nil;
    RKObjectManager *objectManager = self.objectManager;
    
    // ignore duplicate objects
    [objectManager.managedObjectStore.mainQueueManagedObjectContext performBlockAndWait:^{
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Cross"];
        NSSortDescriptor* descriptor = [NSSortDescriptor sortDescriptorWithKey:@"updated_at" ascending:NO];
        [request setSortDescriptors:[NSArray arrayWithObject:descriptor]];
        NSArray *crosses = [objectManager.managedObjectStore.mainQueueManagedObjectContext executeFetchRequest:request error:nil];
        
        if (crosses.count > 0) {
            Cross *x = [crosses objectAtIndex:0];
            self.latestModify = [self.latestModify laterDate:x.updated_at];
        }
        
        NSMutableArray *filteredCrosses = [[NSMutableArray alloc] initWithCapacity:[crosses count]];
        @autoreleasepool {
            NSMutableDictionary *crossAddDict = [NSMutableDictionary dictionaryWithCapacity:[crosses count]];
            
            for (Cross *cross in crosses) {
                NSString *key = [NSString stringWithFormat:@"%d", [cross.cross_id intValue]];
                if (![crossAddDict valueForKey:key]) {
                    [filteredCrosses addObject:cross];
                    [crossAddDict setValue:@"YES" forKey:key];
                }
            }
        }
        
        xlist = filteredCrosses;
    }];
    return xlist;
}

- (Cross *)getCrossById:(NSUInteger)crossId
{
    RKObjectManager *objectManager = self.objectManager;
    return [self getCrossById:@(crossId) from:objectManager.managedObjectStore.mainQueueManagedObjectContext];
}

- (Cross *)getCrossById:(NSNumber *)crossId from:(NSManagedObjectContext *)moc
{
    __block Cross *x = nil;
    
    [moc performBlockAndWait:^{
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Cross"];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"cross_id = %u", [crossId unsignedIntegerValue]];
        NSSortDescriptor* descUpdateAt = [NSSortDescriptor sortDescriptorWithKey:@"updated_at" ascending:NO];
        NSSortDescriptor* descReadAt = [NSSortDescriptor sortDescriptorWithKey:@"read_at" ascending:NO];
        [request setSortDescriptors:@[descUpdateAt, descReadAt]];
        [request setPredicate:predicate];
        NSArray *crosses = [moc executeFetchRequest:request error:nil];
        if (crosses.count > 0) {
            x = [crosses objectAtIndex:0];
        }
    }];
    return x;
}

- (void)deleteCross:(Cross *)cross
{
    if (cross) {
        //        c.time.begin_at = nil;
        //        c.time = nil;
        [self.objectManager.managedObjectStore.mainQueueManagedObjectContext deleteObject:cross];
        //        [[c managedObjectContext] deleteObject:c];
    }
    // notify the list to reload from local
    [NSNotificationCenter.defaultCenter postNotificationName:EXCrossListDidChangeNotification object:self];
}

- (void)loadCrossWithCrossId:(NSUInteger)crossId updatedTime:(NSDate *)updatedTime
{
    EFLoadCrossOperation *operation = [EFLoadCrossOperation operationWithModel:self];
    operation.crossId = crossId;
    operation.updatedTime = updatedTime;
    
    EFNetworkManagementOperation *managementOperation = [[EFNetworkManagementOperation alloc] initWithNetworkOperation:operation];
    [[EFQueueManager defaultManager] addNetworkManagementOperation:managementOperation completeHandler:nil];
}

- (void)loadCrossList
{
    self.lastQuery = [NSDate date];
    
    EFLoadCrossListOperation *operation = [EFLoadCrossListOperation operationWithModel:self];
    
    EFNetworkManagementOperation *managementOperation = [[EFNetworkManagementOperation alloc] initWithNetworkOperation:operation];
    [[EFQueueManager defaultManager] addNetworkManagementOperation:managementOperation completeHandler:nil];
}

- (void)loadCrossListAfter:(NSDate *)updatedTime
{
    if (self.lastQuery) {
        NSDate * now = [NSDate date];
        if ([now timeIntervalSinceDate:self.lastQuery] < 60) {
            return;
        }
    }
             
    self.lastQuery = [NSDate date];
    
    EFLoadCrossListOperation *operation = [EFLoadCrossListOperation operationWithModel:self];
    operation.updatedTime = updatedTime;
    
    EFNetworkManagementOperation *managementOperation = [[EFNetworkManagementOperation alloc] initWithNetworkOperation:operation];
    [[EFQueueManager defaultManager] addNetworkManagementOperation:managementOperation completeHandler:nil];
}

- (void)editCross:(Cross *)cross
{
    EFEditCrossOperation *operation = [EFEditCrossOperation operationWithModel:self];
//    cross.by_identity = [cross.exfee getMyInvitation].identity;
    operation.cross = cross;
    
    EFNetworkManagementOperation *managementOperation = [[EFNetworkManagementOperation alloc] initWithNetworkOperation:operation];
    [[EFQueueManager defaultManager] addNetworkManagementOperation:managementOperation completeHandler:nil];
}

- (void)removeCross:(Cross *)cross
{
    EFRemoveCrossOperation *operation = [EFRemoveCrossOperation operationWithModel:self];
    operation.cross = cross;
    
    EFNetworkManagementOperation *managementOperation = [[EFNetworkManagementOperation alloc] initWithNetworkOperation:operation];
    [[EFQueueManager defaultManager] addNetworkManagementOperation:managementOperation completeHandler:nil];
}

- (void)updateCrossTime:(CrossTime*)crossTime withCrossId:(NSNumber *)crossId;
{
    EFChangeCrossTimeOperation *operation = [EFChangeCrossTimeOperation operationWithModel:self];
    operation.entityId = [crossId copy];
    operation.entityType = self.crossEntry;
    operation.crossTime = crossTime;
    
    EFNetworkManagementOperation *managementOperation = [[EFNetworkManagementOperation alloc] initWithNetworkOperation:operation];
    [[EFQueueManager defaultManager] addNetworkManagementOperation:managementOperation completeHandler:nil];
}


- (void)editExfee:(Exfee *)exfee
{
    EFEditExfeeOperation *operation = [EFEditExfeeOperation operationWithModel:self];
    operation.exfee = exfee;
    operation.byIdentity = [exfee getMyInvitation].identity;
    
    EFNetworkManagementOperation *managementOperation = [[EFNetworkManagementOperation alloc] initWithNetworkOperation:operation];
    [[EFQueueManager defaultManager] addNetworkManagementOperation:managementOperation completeHandler:nil];
}

- (void)changeRsvp:(NSString *)rsvp on:(Invitation *)invitation from:(Exfee *)exfee
{
    EFRsvpOperation *operation = [EFRsvpOperation operationWithModel:self];
    operation.rsvp = rsvp;
    operation.invitation = invitation;
    operation.exfee = exfee;
    operation.byIdentity = [exfee getMyInvitation].identity;
    
    EFNetworkManagementOperation *managementOperation = [[EFNetworkManagementOperation alloc] initWithNetworkOperation:operation];
    [[EFQueueManager defaultManager] addNetworkManagementOperation:managementOperation completeHandler:nil];
}

- (void)removeInvitation:(Invitation *)invitation fromExfee:(Exfee *)exfee
{
    EFRemoveInvitationOperation *operation = [EFRemoveInvitationOperation operationWithModel:self];
    operation.exfee = exfee;
    operation.invitation = invitation;
    operation.byIdentity = [exfee getMyInvitation].identity;
    
    EFNetworkManagementOperation *managementOperation = [[EFNetworkManagementOperation alloc] initWithNetworkOperation:operation];
    [[EFQueueManager defaultManager] addNetworkManagementOperation:managementOperation completeHandler:nil];
}

- (void)removeSelfInvitation:(Invitation *)invitation fromExfee:(Exfee *)exfee
{
    EFRemoveMyInvitationOperation *operation = [EFRemoveMyInvitationOperation operationWithModel:self];
    operation.exfee = exfee;
    operation.invitation = invitation;
    
    EFNetworkManagementOperation *managementOperation = [[EFNetworkManagementOperation alloc] initWithNetworkOperation:operation];
    [[EFQueueManager defaultManager] addNetworkManagementOperation:managementOperation completeHandler:nil];
}

- (void)removeNotificationIdentity:(IdentityId *)identityId from:(Invitation *)invitation onExfee:(Exfee *)exfee
{
    EFRemoveNotificationIdentityOperation *operation = [EFRemoveNotificationIdentityOperation operationWithModel:self];
    operation.exfee = exfee;
    operation.invitation = invitation;
    operation.identityid = identityId;
    
    EFNetworkManagementOperation *managementOperation = [[EFNetworkManagementOperation alloc] initWithNetworkOperation:operation];
    [[EFQueueManager defaultManager] addNetworkManagementOperation:managementOperation completeHandler:nil];
}

@end
