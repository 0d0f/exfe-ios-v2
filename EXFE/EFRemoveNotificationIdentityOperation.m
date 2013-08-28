//
//  EFRemoveNotificationIdentityOperation.m
//  EXFE
//
//  Created by Stony Wang on 13-8-27.
//
//

#import "EFRemoveNotificationIdentityOperation.h"

#import "EFEntity.h"

NSString *kEFNotificationNameRemoveNotificationIdentitySuccess = @"notification.removeNotificationIdentity.success";
NSString *kEFNotificationNameRemoveNotificationIdentityFailure = @"notification.removeNotificationIdentity.failure";

@implementation EFRemoveNotificationIdentityOperation

- (id)initWithModel:(EXFEModel *)model {
    NSParameterAssert(model);
    
    self = [super initWithModel:model];
    if (self) {
        self.successNotificationName = kEFNotificationNameRemoveNotificationIdentitySuccess;
        self.failureNotificationName = kEFNotificationNameRemoveNotificationIdentityFailure;
    }
    
    return self;
}

- (void)operationDidStart {
    [super operationDidStart];
    
    NSAssert(self.model, @"model shouldn't be nill.");
    NSAssert(self.model.apiServer, @"api shouldn't be nill.");
    
    [self.model.apiServer removeNotificationIdentity:self.identityid
                                                from:self.invitation
                                             onExfee:self.exfee
                                             success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                                 if ([operation.HTTPRequestOperation.response statusCode] == 200){
                                                     NSDictionary *result = [mappingResult dictionary];
                                                     if(result)
                                                     {
                                                         Meta *meta = (Meta *)[result objectForKey:@"meta"];
                                                         int code = [meta.code intValue];
                                                         int type = code / 100;
                                                         switch (type) {
                                                             case 2: // HTTP OK
                                                             {
                                                                 self.state = kEFNetworkOperationStateSuccess;
                                                                 NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] initWithDictionary:[mappingResult dictionary]];
                                                                 [userInfo setValue:@"exfee" forKey:@"type"];
                                                                 [userInfo setValue:self.exfee.exfee_id forKey:@"id"];
                                                                 self.successUserInfo = userInfo;
                                                                 
                                                                 [self finish];
                                                                 
                                                             }  break;
                                                             default:{
                                                                 // RKObjectManager *objectManager = [RKObjectManager sharedManager];
                                                                 // [objectManager.managedObjectStore.mainQueueManagedObjectContext rollback];
                                                                 self.state = kEFNetworkOperationStateFailure;
                                                                 NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] initWithDictionary:[mappingResult dictionary]];
                                                                 [userInfo setValue:@"exfee" forKey:@"type"];
                                                                 [userInfo setValue:self.exfee.exfee_id forKey:@"id"];
                                                                 self.failureUserInfo = userInfo;
                                                                 
                                                                 [self finish];
                                                             }  break;
                                                         }
                                                     }
                                                 }
                                             }
                                             failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                                 self.state = kEFNetworkOperationStateFailure;
                                                 NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithCapacity:3];
                                                 [userInfo setValue:@"exfee" forKey:@"type"];
                                                 [userInfo setValue:self.exfee.exfee_id forKey:@"id"];
                                                 self.failureUserInfo = userInfo;
                                                 self.error = error;
                                                 
                                                 [self finish];
                                             }];
}

@end
