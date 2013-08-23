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
#import "Cross.h"
#import "Invitation+EXFE.h"

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
    operation.cross = cross;
    
    EFNetworkManagementOperation *managementOperation = [[EFNetworkManagementOperation alloc] initWithNetworkOperation:operation];
    [[EFQueueManager defaultManager] addNetworkManagementOperation:managementOperation completeHandler:nil];
}

- (void)removeInvitation:(Invitation *)invitation fromExfee:(Exfee *)exfee byIdentity:(Identity *)identity
{
    EFRemoveInvitationOperation *operation = [EFRemoveInvitationOperation operationWithModel:self];
    operation.exfee = exfee;
    operation.invitation = invitation;
    operation.byIdentity = identity;
    
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
@end
