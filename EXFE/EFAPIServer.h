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

#pragma mark Initializtion
- (id)init;
+ (EFAPIServer *)sharedInstance;

#pragma mark Token and User ID manager
- (void)saveUserData;
- (void)loaduserData;
- (void)clearUserData;

#pragma mark Public API (Token Free)
- (void)getAvailableBackgroundsWithSuccess:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                                   failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

#pragma mark Sign In, Sign Out, Sign Up, Pre Check
- (void)getRegFlagBy:(NSString*)identity
                with:(Provider)provider
             success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
             failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

- (void)signIn:(NSString*)identity
          with:(Provider)provider
      password:(NSString*)password
       success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
       failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

- (void)signOutUsingUdid:(NSString*)udid
                 success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                 failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

- (void)signUp:(NSString*)identity
          with:(Provider)provider
          name:(NSString*)name
      password:(NSString*)password
       success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
       failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

#pragma mark Cross API
- (void)loadCrossesAfter:(NSString*)updatedtime
                 success:(void (^)(RKObjectRequestOperation *operation, RKMappingResult *mappingResult))success
                 failure:(void (^)(RKObjectRequestOperation *operation, NSError *error))failure;

- (void)loadCrossesBy:(NSInteger)user_id
          updatedtime:(NSString*)updatedtime
              success:(void (^)(RKObjectRequestOperation *operation, RKMappingResult *mappingResult))success
              failure:(void (^)(RKObjectRequestOperation *operation, NSError *error))failure;

#pragma mark User API
/**
 
 This method load current user profile from api server.
 
 @param success
 @param failure
 @return void
 */
- (void)loadMeSuccess:(void (^)(RKObjectRequestOperation *operation, RKMappingResult *mappingResult))success
              failure:(void (^)(RKObjectRequestOperation *operation, NSError *error))failure;

- (void)loadUserBy:(NSInteger)user_id
           success:(void (^)(RKObjectRequestOperation *operation, RKMappingResult *mappingResult))success
           failure:(void (^)(RKObjectRequestOperation *operation, NSError *error))failure;
@end
