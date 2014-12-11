//
//  EFChangeCrossTimeOperation.m
//  EXFE
//
//  Created by Stony Wang on 13-9-2.
//
//

#import "EFChangeCrossTimeOperation.h"

#import "EFEntity.h"
#import "Util.h"

@interface EFChangeCrossTimeOperation ()

@property (nonatomic, strong) Cross           *cross;

@end;

NSString *kEFNotificationNameChangeCrossTimeSuccess = @"notification.changeCrossTime.success";
NSString *kEFNotificationNameChangeCrossTimeFailure = @"notification.changeCrossTime.failure";

@implementation EFChangeCrossTimeOperation

- (id)initWithModel:(EXFEModel *)model {
    NSParameterAssert(model);
    
    self = [super initWithModel:model];
    if (self) {
        self.successNotificationName = kEFNotificationNameChangeCrossTimeSuccess;
        self.failureNotificationName = kEFNotificationNameChangeCrossTimeFailure;
        self.timestamp = [NSDate date];
        self.moc = [self.model.objectManager.managedObjectStore newChildManagedObjectContextWithConcurrencyType:NSPrivateQueueConcurrencyType tracksChanges:YES];
    }
    
    return self;
}

- (id)initWithModel:(EXFEModel *)model dupelicateFrom:(EFChangeCrossTimeOperation *)operation
{
    self = [super initWithModel:model dupelicateFrom:operation];
    if (self) {
        self.timestamp = operation.timestamp;
        self.entityId = operation.entityId;
        self.entityType = operation.entityType;
        self.crossTime = operation.crossTime;
    }
    return self;
}


- (void)operationDidStart {
    [super operationDidStart];
    
    NSAssert(self.model, @"model shouldn't be nill.");
    NSAssert(self.model.apiServer, @"api shouldn't be nill.");
    
    if (self.crossTime.managedObjectContext == nil) {
        [self.crossTime addToContext:self.moc];
    }
    
//    [self.moc performBlockAndWait:^{
//        NSFetchRequest *request = [[NSFetchRequest alloc] init];
//        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"cross_id = %@", self.entityId];
//        [request setEntity:self.entityType];
//        [request setPredicate:predicate];
//        NSArray *crosses = [self.moc executeFetchRequest:request error:nil];
//        self.cross = [crosses lastObject];
//    }];

    self.cross = [Cross object:self.crossTime.managedObjectContext];
    self.cross.cross_id = [self.entityId copy];
    self.cross.time = self.crossTime;
    
//    self.cross = [self.model getCrossById:self.entityId from:self.crossTime.managedObjectContext];
    
    [self.model.apiServer editCross:self.cross
                            success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                Meta *meta = (Meta *)[[mappingResult dictionary] objectForKey:@"meta"];
                                NSInteger c = [meta.code integerValue];
                                NSInteger t = c / 100;
                                
                                switch (t) {
                                    case 2:{
                                        self.state = kEFNetworkOperationStateSuccess;
                                        NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] initWithDictionary:[mappingResult dictionary]];
                                        [userInfo setValue:@"cross" forKey:@"type"];
                                        [userInfo setValue:self.cross.cross_id forKey:@"id"];
                                        
                                        self.successUserInfo = userInfo;
                                        [self finish];
                                    } break;
                                        
                                    default:{
                                        self.state = kEFNetworkOperationStateFailure;
                                        NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] initWithDictionary:[mappingResult dictionary]];
                                        [userInfo setValue:@"cross" forKey:@"type"];
                                        [userInfo setValue:self.cross.cross_id forKey:@"id"];
                                        self.failureUserInfo = userInfo;
                                        
                                        NSString *title =  [NSString stringWithFormat:NSLocalizedString(@"Failed to update cross time: %@.", nil), self.crossTime.origin];
                                        NSString *message = nil;
                                        
                                        [Util handleRetryBannerFor:self withTitle:title andMessage:message andRetry:YES];
                                    } break;
                                }
                            }
                            failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                
                                if ([NSURLErrorDomain isEqualToString:error.domain] || [AFNetworkingErrorDomain isEqualToString:error.domain]) {
                                    switch (error.code) {
                                        case NSURLErrorCancelled:
                                        case NSURLErrorTimedOut:
                                        case NSURLErrorCannotFindHost:
                                        case NSURLErrorCannotConnectToHost:
                                        case NSURLErrorNetworkConnectionLost:
                                        case NSURLErrorDNSLookupFailed:
                                        case NSURLErrorNotConnectedToInternet:
                                        case NSURLErrorHTTPTooManyRedirects:
                                        case NSURLErrorResourceUnavailable:
                                        case NSURLErrorRedirectToNonExistentLocation:
                                        case NSURLErrorBadServerResponse:
                                        case NSURLErrorZeroByteResource:
                                        case NSURLErrorServerCertificateUntrusted:
                                        {// Retry
                                            self.state = kEFNetworkOperationStateFailure;
                                            NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithCapacity:2];
                                            [userInfo setValue:@"cross" forKey:@"type"];
                                            [userInfo setValue:self.cross.cross_id forKey:@"id"];
                                            self.failureUserInfo = userInfo;
                                            self.error = error;
                                            
                                            NSString *title =  [NSString stringWithFormat:NSLocalizedString(@"Failed to update cross time: %@.", nil), self.crossTime.origin];
                                            NSString *message = nil;
                                            
                                            [Util handleRetryBannerFor:self withTitle:title andMessage:message andRetry:YES];
                                            
                                        }   break;
                                            
                                        default:
                                            break;
                                    }
                                }
                                
                                
                                
                                
                                
                            }];
}

- (void)operationDidRetryFail
{
    [self finish];
    [self.moc rollback];
}

@end
