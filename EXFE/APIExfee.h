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
           failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure DEPRECATED_ATTRIBUTE_MESSAGE("Use EFAPIServer (Exfee)");


+ (void)edit:(Exfee*)exfee
  myIdentity:(int)my_identity_id
     success:(void (^)(RKObjectRequestOperation *operation, RKMappingResult *mappingResult))success
     failure:(void (^)(RKObjectRequestOperation *operation, NSError *error))failure DEPRECATED_ATTRIBUTE_MESSAGE("Use EFAPIServer (Exfee)");

+ (void)addInvitations:(NSArray*)array
                    to:(int)exfee_id
              modifier:(int)my_identity_id
               success:(void (^)(RKObjectRequestOperation *operation, RKMappingResult *mappingResult))success
               failure:(void (^)(RKObjectRequestOperation *operation, NSError *error))failure DEPRECATED_ATTRIBUTE_MESSAGE("No more invoke ?!");
@end
