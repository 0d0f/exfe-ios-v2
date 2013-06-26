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
    
    [managementOperation release];
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
    
    [managementOperation release];
}

@end
