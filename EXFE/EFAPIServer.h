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

// Error domain to generate custom api error
extern NSString *kEFAPIErrorDomain;

@class Exfee;
@class EXFEModel;

@interface EFAPIServer : NSObject

@property (nonatomic, unsafe_unretained) EXFEModel *     model;

#pragma mark Initializtion

- (id)initWithModel:(EXFEModel*)model;
//+ (EFAPIServer *)sharedInstance;

#pragma mark Token and User ID manager

- (void)saveUserData;
- (void)loadUserData;
- (void)clearUserData;
- (BOOL)isLoggedIn;

#pragma mark Public API (Token Free)

- (void)getAvailableBackgroundsWithSuccess:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                                   failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

- (void)checkAppVersionSuccess:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                       failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

- (void)getIdentitiesWithParams:(NSArray *)params success:(void (^)(NSArray *identities))success failure:(void (^)(NSError *error))failure;

#pragma mark Identity, password and token APIs

// endpoint: VerifyIdentity
- (void)verifyIdentity:(NSString*)identity
                  with:(Provider)provider
               success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
               failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

// endpoint: VerifyUserIdentity

// endpoint: ForgotPassword
- (void)forgetPassword:(NSString*)identity
                  with:(Provider)provider
               success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
               failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

// endpoint: ResolveToken

// endpoint: ResetPassword

// endpoint: Set password
- (void)changePassword:(NSString*)current_password
                  with:(NSString*)new_password
               success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
               failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

#pragma mark Sign In, Sign Out, Sign Up and Pre Check APIs

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

- (void)reverseAuth:(Provider)provider
          withToken:(NSString*)token
           andParam:(NSDictionary*) param
            success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
            failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

- (void)regDevice:(NSString*)pushToken
          success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
          failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

#pragma mark Cross API

- (void)loadCrossesAfter:(NSDate*)updatedtime
                 success:(void (^)(RKObjectRequestOperation *operation, RKMappingResult *mappingResult))success
                 failure:(void (^)(RKObjectRequestOperation *operation, NSError *error))failure;

- (void)loadCrossesBy:(NSInteger)user_id
          updatedtime:(NSDate*)updatedtime
              success:(void (^)(RKObjectRequestOperation *operation, RKMappingResult *mappingResult))success
              failure:(void (^)(RKObjectRequestOperation *operation, NSError *error))failure;

- (void) mergeIdentities:(NSArray *)ids
                 byToken:(NSString *)token
                 success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                 failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

- (void)mergeAllByToken:(NSString *)token
                success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

#pragma mark User API
/**
 
 This method load current user profile from api server.
 
 @param success
 @param failure
 @return void
 */
- (void)loadMeAfter:(NSDate *)updatedtime
             success:(void (^)(RKObjectRequestOperation *operation, RKMappingResult *mappingResult))success
              failure:(void (^)(RKObjectRequestOperation *operation, NSError *error))failure;

- (void)loadUserBy:(NSInteger)user_id
             after:(NSDate *)updatedtime
           success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
           failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

- (void)loadUserBy:(NSInteger)user_id
             after:(NSDate *)updatedtime
         withToken:(NSString*)token
           success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
           failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

- (void)verifyUserIdentity:(NSInteger)identity_id
                   success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                   failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

- (void)removeUserIdentity:(NSInteger)identity_id
                   success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                   failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

#pragma mark - Identity API

- (void)updateIdentity:(Identity*)identity
                  name:(NSString*)name
                andBio:(NSString*)bio
               success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
               failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

- (void)updateName:(NSString*)name
            andBio:(NSString*)bio
           success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
           failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

- (void)updateUserAvatar:(UIImage *)fullImage
         withLargeAvatar:(UIImage *)largeImage
         withSmallAvatar:(UIImage *)smallImage
                 withExt:(NSString *)ext
             success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
             failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

- (void)updateIdentityAvatar:(UIImage *)fullImage
             withLargeAvatar:(UIImage *)largeImage
             withSmallAvatar:(UIImage *)smallImage
                     withExt:(NSString *)ext
                 for:(Identity *)identity
             success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
             failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

- (void)updateAvatar:(NSDictionary *)images
             withExt:(NSString *)ext
                 for:(NSNumber *)identity_id
             success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
             failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

- (void)addIdentityBy:(NSString*)external_username
         withProvider:(Provider)provider
              success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
              failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

- (void)addReverseAuthIdentity:(Provider)provider
                     withToken:(NSString*)token
                      andParam:(NSDictionary*) param
                       success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                       failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;


@end


