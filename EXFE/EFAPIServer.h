//
//  EFAPIServer.h
//  EXFE
//
//  Created by Stony Wang on 13-4-17.
//
//

#import <Foundation/Foundation.h>
#import <RestKit/RestKit.h>
#import "Identity+EXFE.h"

@interface EFAPIServer : NSObject


@property (nonatomic, assign) NSInteger user_id;
@property (nonatomic, copy) NSString *user_token;

- (id)init;
+ (EFAPIServer *)sharedInstance;

- (void)getRegFlagBy:(NSString*)identity
                with:(Provider)provider
             success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
             failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

- (void)getAvailableBackgroundsWithSuccess:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                                   failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

- (void)signIn:(NSString*)identity
          with:(Provider)provider
      password:(NSString*)password
       success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
       failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

- (void)signUp:(NSString*)identity
          with:(Provider)provider
          name:(NSString*)name
      password:(NSString*)password
       success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
       failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

- (void) loadCrossesAfter:(NSString*)updatedtime
                   success:(void (^)(RKObjectRequestOperation *operation, RKMappingResult *mappingResult))success
                   failure:(void (^)(RKObjectRequestOperation *operation, NSError *error))failure;

- (void) loadCrossesBy:(NSInteger)user_id
           updatedtime:(NSString*)updatedtime
               success:(void (^)(RKObjectRequestOperation *operation, RKMappingResult *mappingResult))success
               failure:(void (^)(RKObjectRequestOperation *operation, NSError *error))failure;
@end
