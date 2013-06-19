//
//  EFAPIServer+Crosses.m
//  EXFE
//
//  Created by 0day on 13-5-13.
//
//

#import "EFAPIServer+Crosses.h"

#import "Util.h"
#import "Cross.h"
#import "EFKit.h"

@implementation EFAPIServer (Crosses)

- (void)loadCrossWithCrossId:(int)corss_id
                 updatedtime:(NSString*)updatedtime
                     success:(void (^)(RKObjectRequestOperation *operation, RKMappingResult *mappingResult))success
                     failure:(void (^)(RKObjectRequestOperation *operation, NSError *error))failure {
    if (updatedtime != nil && ![updatedtime isEqualToString:@""]) {
        updatedtime = [Util encodeToPercentEscapeString:updatedtime];
    }
    
    NSDictionary *param = @{@"token": self.model.userToken};
    NSString *endpoint = [NSString stringWithFormat:@"crosses/%u?updated_at=%@", corss_id, updatedtime];
    
    [[RKObjectManager sharedManager] getObjectsAtPath:endpoint
                                           parameters:param
                                              success:^(RKObjectRequestOperation *operation, id responseObject){
                                                  [self performSelector:@selector(_handleSuccessWithRequestOperation:andResponseObject:)
                                                             withObject:operation
                                                             withObject:responseObject];
                                                  
                                                  if (success) {
                                                      dispatch_async(dispatch_get_main_queue(), ^{
                                                          success(operation, responseObject);
                                                      });
                                                  }
                                              }
                                              failure:^(RKObjectRequestOperation *operation, NSError *error){
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

- (void)gatherCross:(Cross *)cross
            success:(void (^)(RKObjectRequestOperation *operation, RKMappingResult *mappingResult))success
            failure:(void (^)(RKObjectRequestOperation *operation, NSError *error))failure {
    RKObjectManager* manager =[RKObjectManager sharedManager];
    manager.HTTPClient.parameterEncoding= AFJSONParameterEncoding;
    manager.requestSerializationMIMEType = RKMIMETypeJSON;
    
    NSString *endpoint = [NSString stringWithFormat:@"crosses/gather?token=%@", self.model.userToken];
    
    RKObjectRequestOperation *operation = [manager appropriateObjectRequestOperationWithObject:cross
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
                    EFErrorMessage *errorMessage = [EFErrorMessage errorMessageWithStyle:kEFErrorMessageStyleAlert
                                                                                   title:@"Quota limit exceeded"
                                                                                 message:[NSString stringWithFormat:@"%d people limit on gathering this ·X·. However, we’re glad to eliminate this limit during pilot period in appreciation of your early adaption. Thank you!", [exfeeQuota intValue]]
                                                                             buttonTitle:@"OK"
                                                                     buttonActionHandler:nil];
                    [[EFErrorHandlerCenter defaultCenter] presentErrorMessage:errorMessage];
                }
            }
        }
        
        return object;
    }];
    
    [operation setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, id responseObject){
        [self performSelector:@selector(_handleSuccessWithRequestOperation:andResponseObject:)
                   withObject:operation
                   withObject:responseObject];
        
        if (success) {
            dispatch_async(dispatch_get_main_queue(), ^{
                success(operation, responseObject);
            });
        }
    }
                                     failure:^(RKObjectRequestOperation *operation, NSError *error){
                                         [self performSelector:@selector(_handleFailureWithRequestOperation:andError:)
                                                    withObject:operation
                                                    withObject:error];
                                         
                                         if (failure) {
                                             dispatch_async(dispatch_get_main_queue(), ^{
                                                 failure(operation, error);
                                             });
                                         }
                                     }];
    
    [manager enqueueObjectRequestOperation:operation];
}

- (void)editCross:(Cross *)cross
          success:(void (^)(RKObjectRequestOperation *operation, RKMappingResult *mappingResult))success
          failure:(void (^)(RKObjectRequestOperation *operation, NSError *error))failure {
    RKObjectManager* manager =[RKObjectManager sharedManager];
    manager.HTTPClient.parameterEncoding= AFJSONParameterEncoding;
    manager.requestSerializationMIMEType = RKMIMETypeJSON;
    
    NSString *endpoint = [NSString stringWithFormat:@"crosses/%u/edit?token=%@", [cross.cross_id intValue], self.model.userToken];
    
    [manager postObject:cross
                   path:endpoint
             parameters:nil
                success:^(RKObjectRequestOperation *operation, id responseObject){
                    [self performSelector:@selector(_handleSuccessWithRequestOperation:andResponseObject:)
                               withObject:operation
                               withObject:responseObject];
                    
                    if (success) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            success(operation, responseObject);
                        });
                    }
                }
                failure:^(RKObjectRequestOperation *operation, NSError *error){
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

@end
