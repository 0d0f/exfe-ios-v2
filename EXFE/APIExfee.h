//
//  APIExfee.h
//  EXFE
//
//  Created by Stony Wang on 13-3-25.
//
//

#import <Foundation/Foundation.h>
#import <RestKit/RestKit.h>
#import "Invitation+EXFE.h"
#import "Identity+EXFE.h"
#import "Exfee+EXFE.h"

@interface APIExfee : NSObject

+ (void)submitRsvp:(NSString*)status
                on:(Invitation*)invitation
        myIdentity:(int)my_identity_id
           onExfee:(int)exfee_id
           success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
           failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;


+ (void)edit:(Exfee*)exfee
  myIdentity:(int)my_identity_id
     success:(void (^)(RKObjectRequestOperation *operation, RKMappingResult *mappingResult))success
     failure:(void (^)(RKObjectRequestOperation *operation, NSError *error))failure;

+ (void)addInvitations:(NSArray*)array
                    to:(int)exfee_id
              modifier:(int)identity_id
               success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
               failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

+ (void)getIdentitiesFromIdentityParams:(NSArray *)identityParams
                                 succes:(void (^)(NSArray *identities))successHandler
                                failure:(void (^)(NSError *error))failureHandler;

@end
