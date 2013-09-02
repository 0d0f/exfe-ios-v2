//
//  EFLoadMeOperation.m
//  EXFE
//
//  Created by 0day on 13-6-20.
//
//

#import "EFLoadMeOperation.h"
#import "User+EXFE.h"
#import "Identity+EXFE.h"
#import "EFModel.h"

NSString *kEFNotificationNameLoadMeSuccess = @"notificaiton.loadMe.success";
NSString *kEFNotificationNameLoadMeFailure = @"notification.loadMe.failure";

@implementation EFLoadMeOperation

- (id)initWithModel:(EXFEModel *)model {
    NSParameterAssert(model);
    
    self = [super initWithModel:model];
    if (self) {
        self.successNotificationName = kEFNotificationNameLoadMeSuccess;
        self.failureNotificationName = kEFNotificationNameLoadMeFailure;
    }
    return self;
}

- (void)operationDidStart {
    [super operationDidStart];
    
    NSAssert(self.model, @"model shouldn't be nill.");
    NSAssert(self.model.apiServer, @"api shouldn't be nill.");
    
    NSArray * list = [[User getDefaultUser] getIdentitiesForCrossEntry];

    [self.model.apiServer loadMeAfter:self.lastUpdate
                              success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult){
                                  self.state = kEFNetworkOperationStateSuccess;
                                  
                                  NSArray * newList = [[User getDefaultUser] getIdentitiesForCrossEntry];
                                  BOOL diff = (list.count != newList.count);
                                  if (!diff) {
                                      for (NSUInteger i = 0; i < newList.count; i ++) {
                                          Identity * previous = [list objectAtIndex:i];
                                          Identity * latest = [list objectAtIndex:i];
                                          if (![previous compareWithExternalIdAndProvider:latest]) {
                                              diff = YES;
                                              break;
                                          }
                                      }
                                  }
                                  
                                  if (diff) {
                                      [self.model loadCrossList];
                                  }
                                  
                                  [self finish];
                              }
                              failure:^(RKObjectRequestOperation *operation, NSError *error){
                                  self.state = kEFNetworkOperationStateFailure;
                                  self.error = error;
                                  
                                  [self finish];
                              }];
}

@end
