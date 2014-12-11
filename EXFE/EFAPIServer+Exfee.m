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
#import "CCTemplate.h"
#import "Util.h"

@implementation EFAPIServer (Exfee)

- (void)submitRsvp:(NSString *)status
                on:(Invitation *)invitation
        myIdentity:(Identity *)my_identity
           onExfee:(Exfee *)exfee
           success:(void (^)(RKObjectRequestOperation *operation, RKMappingResult *mappingResult))successHandler
           failure:(void (^)(RKObjectRequestOperation *operation, NSError *error))failureHandler
{
    NSDictionary *rsvpdict = @{@"identity_id": invitation.identity.identity_id, @"by_identity_id": my_identity.identity_id, @"rsvp_status": status, @"type": @"rsvp"};
    NSDictionary *param = @{@"rsvps": @[rsvpdict]};
    
    NSString *endpoint = [NSString stringWithFormat:@"exfee/%u/rsvp?token=%@", [exfee.exfee_id unsignedIntegerValue], self.model.userToken];
    
    RKObjectManager *manager = self.model.objectManager;
    manager.requestSerializationMIMEType = RKMIMETypeJSON;
    
    [manager postObject2:exfee
                    path:endpoint
              parameters:param
                 success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                     [self performSelector:@selector(_handleSuccessWithRequestOperation:andResponseObject:)
                                withObject:operation
                                withObject:mappingResult];
                     
                     if (successHandler) {
                         dispatch_async(dispatch_get_main_queue(), ^{
                             successHandler(operation, mappingResult);
                         });
                     }
                 }
                 failure:^(RKObjectRequestOperation *operation, NSError *error) {
                     [self performSelector:@selector(_handleFailureWithRequestOperation:andError:)
                                withObject:operation
                                withObject:error];
                     
                     if (failureHandler) {
                         dispatch_async(dispatch_get_main_queue(), ^{
                             failureHandler(operation, error);
                         });
                     }
                 }];
}

- (void)removeNotificationIdentity:(IdentityId *)identityId
                              from:(Invitation *)invitation
                           onExfee:(Exfee *)exfee
                           success:(void (^)(RKObjectRequestOperation *operation, RKMappingResult *mappingResult))successHandler
                           failure:(void (^)(RKObjectRequestOperation *operation, NSError *error))failureHandler
{
    NSDictionary *param = @{@"identity_id": identityId.identity_id};
    
    NSString *endpoint = [NSString stringWithFormat:@"exfee/%u/removenotificationidentity?token=%@", [exfee.exfee_id unsignedIntegerValue], self.model.userToken];
    
    RKObjectManager *manager = self.model.objectManager;
    manager.requestSerializationMIMEType = RKMIMETypeFormURLEncoded;
    
    [manager postObject2:exfee
                    path:endpoint
              parameters:param
                 success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                     [self performSelector:@selector(_handleSuccessWithRequestOperation:andResponseObject:)
                                withObject:operation
                                withObject:mappingResult];
                     
                     if (successHandler) {
                         dispatch_async(dispatch_get_main_queue(), ^{
                             successHandler(operation, mappingResult);
                         });
                     }
                 }
                 failure:^(RKObjectRequestOperation *operation, NSError *error) {
                     [self performSelector:@selector(_handleFailureWithRequestOperation:andError:)
                                withObject:operation
                                withObject:error];
                     
                     if (failureHandler) {
                         dispatch_async(dispatch_get_main_queue(), ^{
                             failureHandler(operation, error);
                         });
                     }
                 }];
}

- (void)editExfee:(Exfee *)exfee
       byIdentity:(Identity *)identity
          success:(void (^)(RKObjectRequestOperation *operation, RKMappingResult *mappingResult))successHandler
          failure:(void (^)(RKObjectRequestOperation *operation, NSError *error))failureHandler {
    RKObjectManager *manager = self.model.objectManager;
    NSString *endpoint = [NSString stringWithFormat:@"exfee/%u/edit?token=%@&by_identity_id=%u", [exfee.exfee_id intValue], self.model.userToken, [identity.identity_id intValue]];
    
    manager.requestSerializationMIMEType = RKMIMETypeJSON;
    
    RKObjectRequestOperation *operation = [manager appropriateObjectRequestOperationWithObject:exfee
                                                                                        method:RKRequestMethodPOST
                                                                                          path:endpoint
                                                                                    parameters:nil];
    
    // warning handler
    [operation setWillMapDeserializedResponseBlock:^id(id object){
        if ([object isKindOfClass:[NSDictionary class]]) {
            NSDictionary *dictObject = (NSDictionary *)object;
            NSDictionary *responseDict = [dictObject valueForKey:@"response"];
            if (responseDict) {
                NSNumber *exfeeQuota = [responseDict valueForKey:@"exfee_over_quota"];
                if (exfeeQuota) {
                    EFErrorMessage *errorMessage = [[EFErrorMessage alloc] initAlertMessageWithTitle:NSLocalizedString(@"Quota limit exceeded", nil)
                                                                                             message:[NSString stringWithFormat:[NSLocalizedString(@"%d people limit on gathering this {{X_NOUN}}. However, we’re glad to eliminate this limit during pilot period in appreciation of your early adaption. Thank you!", nil) templateFromDict:[Util keywordDict]], [exfeeQuota intValue]]
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
        
        if (successHandler) {
            dispatch_async(dispatch_get_main_queue(), ^{
                successHandler(operation, mappingResult);
            });
        }
    }
                                     failure:^(RKObjectRequestOperation *operation, NSError *error){
                                         [self performSelector:@selector(_handleFailureWithRequestOperation:andError:)
                                                    withObject:operation
                                                    withObject:error];
                                         
                                         if (failureHandler) {
                                             dispatch_async(dispatch_get_main_queue(), ^{
                                                 failureHandler(operation, error);
                                             });
                                         }
                                     }];
    
    [manager enqueueObjectRequestOperation:operation];
}

@end
