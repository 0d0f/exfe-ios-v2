//
//  EFAPIServer+Exfee.h
//  EXFE
//
//  Created by 0day on 13-5-13.
//
//

#import "EFAPIServer.h"

@class Invitation, Exfee, Identity, Meta;
@interface EFAPIServer (Exfee)

- (void)submitRsvp:(NSString *)status
                on:(Invitation *)invitation
        myIdentity:(Identity *)my_identity
           onExfee:(Exfee *)exfee
           success:(void (^)(RKObjectRequestOperation *operation, RKMappingResult *mappingResult))successHandler
           failure:(void (^)(RKObjectRequestOperation *operation, NSError *error))failureHandler;

- (void)removeNotificationIdentity:(IdentityId *)identityId
                              from:(Invitation *)invitation
                           onExfee:(Exfee *)exfee
                           success:(void (^)(Exfee *editExfee))successHandler
                        apiFailure:(void (^)(Meta *meta))apiFailureHandler
                           failure:(void (^)(NSError *error))failureHandler;

- (void)editExfee:(Exfee *)exfee
       byIdentity:(Identity *)identity
          success:(void (^)(RKObjectRequestOperation *operation, RKMappingResult *mappingResult))successHandler
          failure:(void (^)(RKObjectRequestOperation *operation, NSError *error))failureHandler;

@end
