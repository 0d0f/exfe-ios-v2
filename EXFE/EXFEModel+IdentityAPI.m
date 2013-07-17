//
//  EXFEModel+IdentityAPI.m
//  EXFE
//
//  Created by Stony Wang on 13-7-17.
//
//

#import "EXFEModel+IdentityAPI.h"

#import "EFKit.h"
#import "EFAPIOperations.h"

@implementation EXFEModel (IdentityAPI)

- (void)updateIdentity:(Identity *)identity withName:(NSString *)name withBio:(NSString *)bio
{
    EFUpdateIdentityOperation *operation = [EFUpdateIdentityOperation operationWithModel:self];
    operation.identity = identity;
    operation.name = name;
    operation.bio = bio;
    
    EFNetworkManagementOperation *managementOperation = [[EFNetworkManagementOperation alloc] initWithNetworkOperation:operation];
    
    [[EFQueueManager defaultManager] addNetworkManagementOperation:managementOperation completeHandler:nil];
}


- (void)updateIdentity:(Identity *)identity withAvatar:(UIImage *)original withLarge:(UIImage *)avatar_2x withSmall:(UIImage *)avatar
{
    EFUpdateIdentityAvatarOperation *operation = [EFUpdateIdentityAvatarOperation operationWithModel:self];
    operation.identity = identity;
    operation.original = original;
    operation.avatar = avatar;
    operation.avatar_2x = avatar_2x;
    
    
    EFNetworkManagementOperation *managementOperation = [[EFNetworkManagementOperation alloc] initWithNetworkOperation:operation];
    
    [[EFQueueManager defaultManager] addNetworkManagementOperation:managementOperation completeHandler:nil];
}
@end
