//
//  EFRsvpOperation.m
//  EXFE
//
//  Created by Stony Wang on 13-8-27.
//
//

#import "EFRsvpOperation.h"

#import "EFEntity.h"

NSString *kEFNotificationNameRsvpSuccess = @"notification.RSVP.success";
NSString *kEFNotificationNameRsvpFailure = @"notification.RSVP.failure";

@implementation EFRsvpOperation

- (id)initWithModel:(EXFEModel *)model {
    NSParameterAssert(model);
    
    self = [super initWithModel:model];
    if (self) {
        self.successNotificationName = kEFNotificationNameRsvpSuccess;
        self.failureNotificationName = kEFNotificationNameRsvpFailure;
    }
    
    return self;
}

- (void)operationDidStart {
    [super operationDidStart];
    
    NSAssert(self.model, @"model shouldn't be nill.");
    NSAssert(self.model.apiServer, @"api shouldn't be nill.");
    
    [self.model.apiServer submitRsvp:self.rsvp
                                  on:self.invitation
                          myIdentity:self.byIdentity
                             onExfee:self.exfee
                             success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                 
                                 if ([operation.HTTPRequestOperation.response statusCode] == 200){
                                     NSDictionary *result = [mappingResult dictionary];
                                     if(result)
                                     {
                                         Meta *meta = (Meta *)[result objectForKey:@"meta"];
                                         NSInteger code = [meta.code integerValue];
                                         NSInteger type = code / 100;
                                         switch (type) {
                                             case 2: // HTTP OK
                                             {
                                                 self.state = kEFNetworkOperationStateSuccess;
                                                 NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] initWithDictionary:[mappingResult dictionary]];
                                                 [userInfo setValue:@"rsvp" forKey:@"type"];
                                                 [userInfo setValue:self.exfee.exfee_id forKey:@"id"];
                                                 self.successUserInfo = userInfo;
                                                 
                                                 [self finish];
                                             } break;
                                             default:{
                                                 self.state = kEFNetworkOperationStateFailure;
                                                 NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] initWithDictionary:[mappingResult dictionary]];
                                                 [userInfo setValue:@"rsvp" forKey:@"type"];
                                                 [userInfo setValue:self.exfee.exfee_id forKey:@"id"];
                                                 self.failureUserInfo = userInfo;
                                                 
//                                                 [objectManager.managedObjectStore.mainQueueManagedObjectContext rollback];
                                                 
                                                 [self finish];
                                             } break;
                                         }
                                     }
                                 }
                             }
                             failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                 self.state = kEFNetworkOperationStateFailure;
                                 NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithCapacity:3];
                                 [userInfo setValue:@"rsvp" forKey:@"type"];
                                 [userInfo setValue:self.exfee.exfee_id forKey:@"id"];
                                 self.failureUserInfo = userInfo;
                                 self.error = error;
                                 [self finish];
                             }];
}

@end
