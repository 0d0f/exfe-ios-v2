//
//  EFAPIServer+Exfee.m
//  EXFE
//
//  Created by 0day on 13-5-13.
//
//

#import "EFAPIServer+Exfee.h"

#import "EFKit.h"
#import "Exfee+EXFE.h"
#import "Identity+EXFE.h"
#import "IdentityId+EXFE.h"
#import "Meta.h"

@implementation EFAPIServer (Exfee)

- (void)submitRsvp:(NSString *)status
                on:(Invitation *)invitation
        myIdentity:(int)my_identity_id
           onExfee:(int)exfee_id
           success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
           failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure {
    NSDictionary *rsvpdict = @{@"identity_id": invitation.identity.identity_id, @"by_identity_id": @(my_identity_id), @"rsvp_status": status, @"type": @"rsvp"};
    NSDictionary *param = @{@"rsvps": @[rsvpdict]};
    
    NSString *endpoint = [NSString stringWithFormat:@"exfee/%u/rsvp?token=%@",exfee_id, self.model.userToken];
    
    RKObjectManager *manager = [RKObjectManager sharedManager];
    manager.HTTPClient.parameterEncoding = AFJSONParameterEncoding;
    
    [manager.HTTPClient postPath:endpoint
                      parameters:param
                         success:^(AFHTTPRequestOperation *operation, id responseObject){
                             [self performSelector:@selector(_handleSuccessWithRequestOperation:andResponseObject:)
                                        withObject:operation
                                        withObject:responseObject];
                             
                             if (success) {
                                 dispatch_async(dispatch_get_main_queue(), ^{
                                     success(operation, responseObject);
                                 });
                             }
                         }
                         failure:^(AFHTTPRequestOperation *operation, NSError *error){
                             [self performSelector:@selector(_handleFailureWithRequestOperation:andError:)
                                        withObject:operation
                                        withObject:error];
                             
                             if (failure) {
                                 dispatch_async(dispatch_get_main_queue(), ^{
                                     failure(operation, error);
                                 });
                             }
                         }];
}

- (void)removeNotificationIdentity:(IdentityId *)identityId
                              from:(Invitation *)invitation
                           onExfee:(Exfee *)exfee
                           success:(void (^)(Exfee *editExfee))successHandler
                           failure:(void (^)(NSError *error))failureHandler
{
    NSDictionary *param = @{@"identity_id": identityId.identity_id};
    
    NSString *endpoint = [NSString stringWithFormat:@"exfee/%u/removenotificationidentity?token=%@", [exfee.exfee_id integerValue], self.model.userToken];
    
    RKObjectManager *manager = self.model.objectManager;
    manager.HTTPClient.parameterEncoding = AFFormURLParameterEncoding;
    
    [manager postObject2:exfee
                    path:endpoint
              parameters:param
                 success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                     [self performSelector:@selector(_handleSuccessWithRequestOperation:andResponseObject:)
                                withObject:operation
                                withObject:mappingResult];
                     
                     if ([operation.HTTPRequestOperation.response statusCode] == 200){
                         NSDictionary *result = [mappingResult dictionary];
                         if(result)
                         {
                             Meta *meta = (Meta *)[result objectForKey:@"meta"];
                             int code = [meta.code intValue];
                             int type = code / 100;
                             switch (type) {
                                 case 2: // HTTP OK
                                 {// no 206
                                     Exfee *respExfee = [[mappingResult dictionary] objectForKey:@"response.exfee"];
                                     
                                     if (successHandler) {
                                         dispatch_async(dispatch_get_main_queue(), ^{
                                             successHandler(respExfee);
                                         });
                                     }
                                     
                                 }
                                     break;
                                 case 4: // Client Error
                                 {
                                     // 400 Over people mac limited
                                     RKObjectManager *objectManager = [RKObjectManager sharedManager];
                                     [objectManager.managedObjectStore.mainQueueManagedObjectContext rollback];
                                     if (failureHandler) {
                                         dispatch_async(dispatch_get_main_queue(), ^{
                                             failureHandler(nil);
                                         });
                                     }
                                 }
                                     break;
                                 case 5: // Server Error
                                 {
                                     RKObjectManager *objectManager = [RKObjectManager sharedManager];
                                     [objectManager.managedObjectStore.mainQueueManagedObjectContext rollback];
                                     if (failureHandler) {
                                         dispatch_async(dispatch_get_main_queue(), ^{
                                             failureHandler(nil);
                                         });
                                     }
                                 }
                                     break;
                                 default:
                                     break;
                             }
                         }
                     }
                 }
                 failure:^(RKObjectRequestOperation *operation, NSError *error) {
                     [self performSelector:@selector(_handleFailureWithRequestOperation:andError:)
                                withObject:operation
                                withObject:error];
                     
                     RKObjectManager *objectManager = [RKObjectManager sharedManager];
                     [objectManager.managedObjectStore.mainQueueManagedObjectContext rollback];
                     if (failureHandler) {
                         dispatch_async(dispatch_get_main_queue(), ^{
                             failureHandler(error);
                         });
                     }
                 }];
}

- (void)editExfee:(Exfee *)exfee
       byIdentity:(Identity *)identity
          success:(void (^)(Exfee *))successHandler
          failure:(void (^)(NSError *error))failureHandler {
    RKObjectManager *manager = [RKObjectManager sharedManager];
    NSString *endpoint = [NSString stringWithFormat:@"exfee/%u/edit?token=%@&by_identity_id=%u", [exfee.exfee_id intValue], self.model.userToken, [identity.identity_id intValue]];
    
    manager.HTTPClient.parameterEncoding = AFJSONParameterEncoding;
    manager.requestSerializationMIMEType = RKMIMETypeJSON;
    
    RKObjectRequestOperation *operation = [manager appropriateObjectRequestOperationWithObject:exfee
                                                                                        method:RKRequestMethodPOST
                                                                                          path:endpoint
                                                                                    parameters:nil];
    
    // warnming handler
    [operation setWillMapDeserializedResponseBlock:^id(id object){
        if ([object isKindOfClass:[NSDictionary class]]) {
            NSDictionary *dictObject = (NSDictionary *)object;
            NSDictionary *responseDict = [dictObject valueForKey:@"response"];
            if (responseDict) {
                NSNumber *exfeeQuota = [responseDict valueForKey:@"exfee_over_quota"];
                if (exfeeQuota) {
                    EFErrorMessage *errorMessage = [[EFErrorMessage alloc] initAlertMessageWithTitle:NSLocalizedString(@"Quota limit exceeded", nil)
                                                                                             message:[NSString stringWithFormat:NSLocalizedString(@"%d people limit on gathering this ·X·. However, we’re glad to eliminate this limit during pilot period in appreciation of your early adaption. Thank you!", nil), [exfeeQuota intValue]]
                                                                                         buttonTitle:NSLocalizedString(@"OK", nil)
                                                                                buttonPressedHandler:nil];
                    
                    [[EFErrorHandlerCenter defaultCenter] presentErrorMessage:errorMessage];
                }
            }
        }
        
        return object;
    }];
    
    // set success && fail handler
    [operation setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult){
        [self performSelector:@selector(_handleSuccessWithRequestOperation:andResponseObject:)
                   withObject:operation
                   withObject:mappingResult];
        
        if ([operation.HTTPRequestOperation.response statusCode] == 200){
            if([[mappingResult dictionary] isKindOfClass:[NSDictionary class]])
            {
                Meta *meta = (Meta *)[[mappingResult dictionary] objectForKey:@"meta"];
                int code = [meta.code intValue];
                int type = code / 100;
                switch (type) {
                    case 2: // HTTP OK
                    {
                        if (206 == code || 200 == code) {
                            Exfee *respExfee = [[mappingResult dictionary] objectForKey:@"response.exfee"];
                            if (successHandler) {
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    successHandler(respExfee);
                                });
                            }
                        }
                    }
                        break;
                    case 4: // Client Error
                    {
                        // 400 Over people mac limited
                        RKObjectManager *objectManager = [RKObjectManager sharedManager];
                        [objectManager.managedObjectStore.mainQueueManagedObjectContext rollback];
                        if (failureHandler) {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                failureHandler(nil);
                            });
                        }
                    }
                        break;
                    case 5: // Server Error
                    {
                        RKObjectManager *objectManager = [RKObjectManager sharedManager];
                        [objectManager.managedObjectStore.mainQueueManagedObjectContext rollback];
                        if (failureHandler) {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                failureHandler(nil);
                            });
                        }
                    }
                        break;
                    default:
                        break;
                }
            }
        }
    }
                                     failure:^(RKObjectRequestOperation *operation, NSError *error){
                                         [self performSelector:@selector(_handleFailureWithRequestOperation:andError:)
                                                    withObject:operation
                                                    withObject:error];
                                         
                                         RKObjectManager *objectManager = [RKObjectManager sharedManager];
                                         [objectManager.managedObjectStore.mainQueueManagedObjectContext rollback];
                                         if (failureHandler) {
                                             dispatch_async(dispatch_get_main_queue(), ^{
                                                 failureHandler(error);
                                             });
                                         }
                                     }];
    
    [manager enqueueObjectRequestOperation:operation];
}

@end
