//
//  EFAPIServer+Exfee.h
//  EXFE
//
//  Created by 0day on 13-5-13.
//
//

#import "EFAPIServer.h"

@class Invitation, Exfee, Identity;
@interface EFAPIServer (Exfee)

- (void)submitRsvp:(NSString *)status
                on:(Invitation *)invitation
        myIdentity:(int)my_identity_id
           onExfee:(int)exfee_id
           success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
           failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

- (void)removeNotificationIdentity:(IdentityId *)identityId
                              from:(Invitation *)invitation
                           onExfee:(Exfee *)exfee
                           success:(void (^)(Exfee *editExfee))successHandler
                           failure:(void (^)(NSError *error))failureHandler;

- (void)editExfee:(Exfee *)exfee
       byIdentity:(Identity *)identity
          success:(void (^)(Exfee *editedExfee))successHandler
          failure:(void (^)(NSError *error))failureHandler;

@end
