//
//  EXFEModel+UserAPI.m
//  EXFE
//
//  Created by 0day on 13-6-26.
//
//

#import "EXFEModel+UserAPI.h"

#import "EFKit.h"
#import "EFAPIOperations.h"

@implementation EXFEModel (UserAPI)

- (void)loadMe {
    EFLoadMeOperation *loadMeOperation = [EFLoadMeOperation operationWithModel:self];
    EFNetworkManagementOperation *managementOperation = [[EFNetworkManagementOperation alloc] initWithNetworkOperation:loadMeOperation];
    
    [[EFQueueManager defaultManager] addNetworkManagementOperation:managementOperation completeHandler:nil];
    
}

- (void)loadUserByUserId:(NSInteger)userId {
    [self loadUserByUserId:userId andToken:self.userToken];
}

- (void)loadUserByUserId:(NSInteger)userId andToken:(NSString *)token {
    NSParameterAssert(token);
    
    EFLoadUserOperation *loadUserOperation = [EFLoadUserOperation operationWithModel:self];
    loadUserOperation.userId = userId;
    loadUserOperation.token = token;
    
    EFNetworkManagementOperation *managementOperation = [[EFNetworkManagementOperation alloc] initWithNetworkOperation:loadUserOperation];
    
    [[EFQueueManager defaultManager] addNetworkManagementOperation:managementOperation completeHandler:nil];
    
}

- (void)updateUserName:(NSString *)name withBio:(NSString *)bio
{
    EFChangeUserBasicProfileOperation *operation = [EFChangeUserBasicProfileOperation operationWithModel:self];
    operation.name = name;
    operation.bio = bio;
    
    EFNetworkManagementOperation *managementOperation = [[EFNetworkManagementOperation alloc] initWithNetworkOperation:operation];
    
    [[EFQueueManager defaultManager] addNetworkManagementOperation:managementOperation completeHandler:nil];
}

- (void)updateUserAvatar:(UIImage *)original withLarge:(UIImage *)avatar_2x withSmall:(UIImage *)avatar
{
    EFUpdateUserAvatarOperation *operation = [EFUpdateUserAvatarOperation operationWithModel:self];
    operation.original = original;
    operation.avatar = avatar;
    operation.avatar_2x = avatar_2x;
    
    EFNetworkManagementOperation *managementOperation = [[EFNetworkManagementOperation alloc] initWithNetworkOperation:operation];
    
    [[EFQueueManager defaultManager] addNetworkManagementOperation:managementOperation completeHandler:nil];
}
@end
