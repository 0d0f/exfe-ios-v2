//
//  EFAPIServer.m
//  EXFE
//
//  Created by Stony Wang on 13-4-17.
//
//

#import "EFAPIServer.h"

#import "Util.h"
#import "Exfee+EXFE.h"
#import "EFKit.h"

@interface EFAPIServer (Private)
- (void)_handleSuccessWithRequestOperation:(NSOperation *)operation andResponseObject:(id)object;
- (void)_handleFailureWithRequestOperation:(NSOperation *)operation andError:(NSError *)error;
@end

@implementation EFAPIServer

#pragma mark Initializtion

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code
        self.user_id = 0;
        self.user_token = @"";
    }
    return self;
}

+ (EFAPIServer *)sharedInstance
{
    static EFAPIServer *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[EFAPIServer alloc] init];
        // Do any other initialisation stuff here
        [sharedInstance loaduserData];
    });
    return sharedInstance;
}

#pragma mark Token and User ID manager

- (void)saveUserData
{
    NSUserDefaults * ud = [NSUserDefaults standardUserDefaults];
    [ud setObject:self.user_token forKey:@"access_token"];
    [ud setObject:[NSString stringWithFormat:@"%i",self.user_id] forKey:@"userid"];
    [ud synchronize];
}

- (void)loaduserData
{
    NSUserDefaults * ud = [NSUserDefaults standardUserDefaults];
    [ud synchronize];
    self.user_token = [ud stringForKey:@"access_token"];
    self.user_id = [[ud stringForKey:@"userid"] integerValue];
}

- (void)clearUserData
{
    self.user_id = 0;
    self.user_token = @"";
    NSUserDefaults * ud = [NSUserDefaults standardUserDefaults];
    [ud removeObjectForKey:@"access_token"];
    [ud removeObjectForKey:@"userid"];
    [ud synchronize];
}

- (BOOL)isLoggedIn
{
    if (self.user_id > 0 && self.user_token.length > 0) {
        return YES;
    }
    [self loaduserData];
    if (self.user_id > 0 && self.user_token.length > 0) {
        return YES;
    }
    return NO;
}

#pragma mark Public API (Token Free)

- (void)getAvailableBackgroundsWithSuccess:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                                   failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    NSString *endpoint = [NSString stringWithFormat:@"Backgrounds/GetAvailableBackgrounds"];
    RKObjectManager *manager = [RKObjectManager sharedManager] ;
    [manager.HTTPClient getPath:endpoint
                     parameters:nil
                        success:^(AFHTTPRequestOperation *operation, id responseObject){
                            [self _handleSuccessWithRequestOperation:operation andResponseObject:responseObject];
                            
                            if (success) {
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    success(operation, responseObject);
                                });
                            }
                        }
                        failure:^(AFHTTPRequestOperation *operation, NSError *error){
                            [self _handleFailureWithRequestOperation:operation andError:error];
                            
                            if (failure) {
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    failure(operation, error);
                                });
                            }
                        }];
}

- (void)checkAppVersionSuccess:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                       failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure {
    [Flurry logEvent:@"API_CHECK_UPDATE"];
    RKObjectManager *manager = [RKObjectManager sharedManager];
    NSString *endpoint = [NSString stringWithFormat:@"/versions/"];
    
    //    manager.HTTPClient.parameterEncoding = AFJSONParameterEncoding;
    //    manager.requestSerializationMIMEType = RKMIMETypeJSON;
    // Accept HTTP Header; see http://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html#sec14.1
    //	[manager.HTTPClient setDefaultHeader:@"Accept" value:@"application/json"];
    [manager.HTTPClient getPath:endpoint
                     parameters:nil
                        success:^(AFHTTPRequestOperation *operation, id responseObject){
                            [self _handleSuccessWithRequestOperation:operation andResponseObject:responseObject];
                            
                            if (success) {
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    success(operation, responseObject);
                                });
                            }
                        }
                        failure:^(AFHTTPRequestOperation *operation, NSError *error){
                            [self _handleFailureWithRequestOperation:operation andError:error];
                            
                            if (failure) {
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    failure(operation, error);
                                });
                            }
                        }];
}

- (void)getIdentitiesWithParams:(NSArray *)params success:(void (^)(NSArray *))success failure:(void (^)(NSError *))failure {
    RKObjectManager *manager =[RKObjectManager sharedManager];
    manager.HTTPClient.parameterEncoding= AFJSONParameterEncoding;
    manager.requestSerializationMIMEType = RKMIMETypeJSON;
    
    NSDictionary *param = @{@"identities": params};
    NSString *path = [NSString stringWithFormat:@"%@identities/get", API_ROOT];
    
    //    [manager postObject:nil
    //                   path:path
    //             parameters:param
    //                success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult){
    //                    if (operation.HTTPRequestOperation.response.statusCode == 200) {
    //                        if([[mappingResult dictionary] isKindOfClass:[NSDictionary class]]) {
    //                            Meta *meta = (Meta *)[[mappingResult dictionary] objectForKey:@"meta"];
    //                            if ([meta.code intValue] == 200) {
    //                                NSArray *identities = [[mappingResult dictionary] objectForKey:@"response.identities"];
    //                                if (success) {
    //                                    success(identities);
    //                                }
    //                            } else if (failure) {
    //                                failure(nil);
    //                            }
    //                        }
    //                    } else if (failure) {
    //                        failure(nil);
    //                    }
    //                }
    //                failure:^(RKObjectRequestOperation *operation, NSError *error){
    //                    if (failure) {
    //                        failure(error);
    //                    }
    //                }];
    
    [manager.HTTPClient postPath:path
                      parameters:param
                         success:^(AFHTTPRequestOperation *operation, id responseObject){
                             [self _handleSuccessWithRequestOperation:operation andResponseObject:responseObject];
                             
                             if ([operation.response statusCode] == 200 && [responseObject isKindOfClass:[NSDictionary class]]) {
                                 NSDictionary *body = (NSDictionary*)responseObject;
                                 id code = [[body objectForKey:@"meta"] objectForKey:@"code"];
                                 if (code) {
                                     if ([code intValue] == 200) {
                                         NSDictionary* response = [body objectForKey:@"response"];
                                         NSArray *identities = [response objectForKey:@"identities"];
                                         NSMutableArray *identityEntities = [[NSMutableArray alloc] initWithCapacity:[identities count]];
                                         
                                         for (NSDictionary *identitydict in identities) {
                                             NSString *external_id = [identitydict objectForKey:@"external_id"];
                                             NSString *provider = [identitydict objectForKey:@"provider"];
                                             NSString *avatar_filename = [identitydict objectForKey:@"avatar_filename"];
                                             NSString *identity_id = [identitydict objectForKey:@"id"];
                                             NSString *name = [identitydict objectForKey:@"name"];
                                             NSString *nickname = [identitydict objectForKey:@"nickname"];
                                             NSString *external_username = [identitydict objectForKey:@"external_username"];
                                             
                                             __block BOOL needInsertNew = NO;
                                             if ([identity_id intValue] == 0) {
                                                 // a new one
                                                 needInsertNew = YES;
                                             }
                                             if (!needInsertNew) {
                                                 // update if exist
                                                 //                                                 NSPredicate *predicate = [NSPredicate predicateWithFormat:@"provider LIKE %@ AND external_id LIKE %@", provider, external_id];
                                                 NSPredicate *predicate = [NSPredicate predicateWithFormat:@"identity_id == %@", [NSNumber numberWithInt:[identity_id intValue]]];
                                                 NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Identity"];
                                                 fetchRequest.predicate = predicate;
                                                 
                                                 void (^block)(void) = ^{
                                                     NSArray *cachedIdentitites = [manager.managedObjectStore.mainQueueManagedObjectContext executeFetchRequest:fetchRequest error:nil];
                                                     if (cachedIdentitites && [cachedIdentitites count]) {
                                                         // update info
                                                         Identity *cachedIdentitiy = cachedIdentitites[0];
                                                         cachedIdentitiy.external_id = external_id;
                                                         cachedIdentitiy.provider = provider;
                                                         cachedIdentitiy.avatar_filename = avatar_filename;
                                                         cachedIdentitiy.name = name;
                                                         cachedIdentitiy.external_username = external_username;
                                                         cachedIdentitiy.nickname = nickname;
                                                         cachedIdentitiy.identity_id = [NSNumber numberWithInt:[identity_id intValue]];
                                                         [identityEntities addObject:cachedIdentitiy];
                                                     } else {
                                                         needInsertNew = YES;
                                                     }
                                                 };
                                                 if (dispatch_get_current_queue() != dispatch_get_main_queue()) {
                                                     dispatch_sync(dispatch_get_main_queue(), block);
                                                 } else {
                                                     block();
                                                 }
                                             }
                                             
                                             if (needInsertNew) {
                                                 void (^block)(void) = ^{
                                                     NSEntityDescription *identityEntity = [NSEntityDescription entityForName:@"Identity" inManagedObjectContext:manager.managedObjectStore.mainQueueManagedObjectContext];
                                                     [manager.managedObjectStore.mainQueueManagedObjectContext performBlockAndWait:^{
                                                         Identity *identity = [[[Identity alloc] initWithEntity:identityEntity insertIntoManagedObjectContext:manager.managedObjectStore.mainQueueManagedObjectContext] autorelease];
                                                         identity.external_id = external_id;
                                                         identity.provider = provider;
                                                         identity.avatar_filename = avatar_filename;
                                                         identity.name = name;
                                                         identity.external_username = external_username;
                                                         identity.nickname = nickname;
                                                         identity.identity_id = [NSNumber numberWithInt:[identity_id intValue]];
                                                         
                                                         [identityEntities addObject:identity];
                                                     }];
                                                 };
                                                 if (dispatch_get_current_queue() != dispatch_get_main_queue()) {
                                                     dispatch_sync(dispatch_get_main_queue(), block);
                                                 } else {
                                                     block();
                                                 }
                                             }
                                         }
                                         
                                         if (success) {
                                             dispatch_async(dispatch_get_main_queue(), ^{
                                                 success(identityEntities);
                                             });
                                         }
                                         [identityEntities release];
                                     } else {
                                         if (failure) {
                                             dispatch_async(dispatch_get_main_queue(), ^{
                                                 failure(nil);
                                             });
                                         }
                                     }
                                 } else {
                                     if (failure) {
                                         dispatch_async(dispatch_get_main_queue(), ^{
                                             failure(nil);
                                         });
                                     }
                                 }  // if (code) {} else {}
                             }
                         }
                         failure:^(AFHTTPRequestOperation *operation, NSError *error){
                             [self _handleFailureWithRequestOperation:operation andError:error];
                             
                             if (failure) {
                                 dispatch_async(dispatch_get_main_queue(), ^{
                                     failure(error);
                                 });
                             }
                         }];
}

#pragma mark Identity, password and token APIs

- (void)verifyIdentity:(NSString*)identity
                  with:(Provider)provider
               success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
               failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    NSString *endpoint = [NSString stringWithFormat:@"users/verifyidentity"];
    RKObjectManager *manager = [RKObjectManager sharedManager] ;
    manager.HTTPClient.parameterEncoding = AFFormURLParameterEncoding;
    
    NSDictionary* params = @{@"external_username": identity, @"provider": [Identity getProviderString:provider]};
    [manager.HTTPClient postPath:endpoint
                      parameters:params
                         success:^(AFHTTPRequestOperation *operation, id responseObject){
                             [self _handleSuccessWithRequestOperation:operation andResponseObject:responseObject];
                             
                             if (success) {
                                 dispatch_async(dispatch_get_main_queue(), ^{
                                     success(operation, responseObject);
                                 });
                             }
                         }
                         failure:^(AFHTTPRequestOperation *operation, NSError *error){
                             [self _handleFailureWithRequestOperation:operation andError:error];
                             
                             if (failure) {
                                 dispatch_async(dispatch_get_main_queue(), ^{
                                     failure(operation, error);
                                 });
                             }
                         }];
}

// endpoint: VerifyUserIdentity

- (void)forgetPassword:(NSString*)identity
                  with:(Provider)provider
               success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
               failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    NSString *endpoint = [NSString stringWithFormat:@"users/forgotpassword"];
    RKObjectManager *manager = [RKObjectManager sharedManager] ;
    manager.HTTPClient.parameterEncoding = AFFormURLParameterEncoding;
    
    NSDictionary* params = @{@"external_username": identity, @"provider": [Identity getProviderString:provider]};
    [manager.HTTPClient postPath:endpoint
                      parameters:params
                         success:^(AFHTTPRequestOperation *operation, id responseObject){
                             [self _handleSuccessWithRequestOperation:operation andResponseObject:responseObject];
                             
                             if (success) {
                                 dispatch_async(dispatch_get_main_queue(), ^{
                                     success(operation, responseObject);
                                 });
                             }
                         }
                         failure:^(AFHTTPRequestOperation *operation, NSError *error){
                             [self _handleFailureWithRequestOperation:operation andError:error];
                             
                             if (failure) {
                                 dispatch_async(dispatch_get_main_queue(), ^{
                                     failure(operation, error);
                                 });
                             }
                         }];
}

// endpoint: ResolveToken

// endpoint: ResetPassword

#pragma mark Sign In, Sign Out, Sign Up and Pre Check APIs

- (void)getRegFlagBy:(NSString*)identity
                with:(Provider)provider
             success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
             failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    
    
    NSString *endpoint = [NSString stringWithFormat:@"users/GetRegistrationFlag"];
    RKObjectManager *manager = [RKObjectManager sharedManager] ;
    
    
    NSDictionary* params = @{@"external_username": identity, @"provider": [Identity getProviderString:provider]};
    [manager.HTTPClient getPath:endpoint
                     parameters:params
                        success:^(AFHTTPRequestOperation *operation, id responseObject){
                            [self _handleSuccessWithRequestOperation:operation andResponseObject:responseObject];
                            
                            if (success) {
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    success(operation, responseObject);
                                });
                            }
                        }
                        failure:^(AFHTTPRequestOperation *operation, NSError *error){
                            [self _handleFailureWithRequestOperation:operation andError:error];
                            
                            if (failure) {
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    failure(operation, error);
                                });
                            }
                        }];
}

// TODO not finished ,use ormapping isntead of httpclient
- (void)getRegFlagBy:(NSString*)identity
                withProvider:(Provider)provider
             success:(void (^)(RKObjectRequestOperation *operation, RKMappingResult *mappingResult))success
             failure:(void (^)(RKObjectRequestOperation *operation, NSError *error))failure
{
    
    
    NSString *endpoint = [NSString stringWithFormat:@"users/GetRegistrationFlag"];
    RKObjectManager *manager = [RKObjectManager sharedManager] ;
    
    
    NSDictionary* params = @{@"external_username": identity, @"provider": [Identity getProviderString:provider]};
    [manager getObject:nil
                  path:endpoint
            parameters:params
               success:^(RKObjectRequestOperation *operation, id responseObject){
                   [self _handleSuccessWithRequestOperation:operation andResponseObject:responseObject];
                   
                   if (success) {
                       dispatch_async(dispatch_get_main_queue(), ^{
                           success(operation, responseObject);
                       });
                   }
               }
               failure:^(RKObjectRequestOperation *operation, NSError *error){
                   [self _handleFailureWithRequestOperation:operation andError:error];
                   
                   if (failure) {
                       dispatch_async(dispatch_get_main_queue(), ^{
                           failure(operation, error);
                       });
                   }
               }];
}

- (void)signIn:(NSString*)identity
          with:(Provider)provider
      password:(NSString*)password
       success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
       failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    NSString *endpoint = [NSString stringWithFormat:@"users/signin"];
    RKObjectManager *manager = [RKObjectManager sharedManager] ;
    NSDictionary *params = @{
                           @"provider": [Identity getProviderString:provider],
                           @"external_username": identity,
                           @"password": password,
                           };
    
    manager.HTTPClient.parameterEncoding = AFFormURLParameterEncoding;
    [manager.HTTPClient postPath:endpoint
                      parameters:params
                         success:^(AFHTTPRequestOperation *operation, id responseObject) {
                             [self _handleSuccessWithRequestOperation:operation andResponseObject:responseObject];
                             
                             if ([operation.response statusCode] == 200 && [responseObject isKindOfClass:[NSDictionary class]]) {
                                 NSNumber *code = [responseObject valueForKeyPath:@"meta.code"];
                                 if ([code integerValue] == 200) {
                                     NSNumber *u = [responseObject valueForKeyPath:@"response.user_id"];
                                     NSString *t = [responseObject valueForKeyPath:@"response.token"];
                                     self.user_id  = [u integerValue];
                                     self.user_token = t;
                                     [self saveUserData];
                                 }
                             }
                             if (success) {
                                 dispatch_async(dispatch_get_main_queue(), ^{
                                     success(operation, responseObject);
                                 });
                             }
                         }
                         failure:^(AFHTTPRequestOperation *operation, NSError *error){
                             [self _handleFailureWithRequestOperation:operation andError:error];
                             if (failure) {
                                 dispatch_async(dispatch_get_main_queue(), ^{
                                     failure(operation, error);
                                 });
                             }
                         }];
}

- (void)signOutUsingUdid:(NSString*)udid
                 success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                 failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    NSString *endpoint = [NSString stringWithFormat:@"users/%u/signout?token=%@",self.user_id, self.user_token];
    RKObjectManager *manager = [RKObjectManager sharedManager] ;
    NSDictionary *params = @{@"udid":udid,@"os_name":@"iOS"};
    manager.HTTPClient.parameterEncoding=AFJSONParameterEncoding;
    [manager.HTTPClient postPath:endpoint
                      parameters:params
                         success:^(AFHTTPRequestOperation *operation, id responseObject){
                             [self _handleSuccessWithRequestOperation:operation andResponseObject:responseObject];
                             
                             if (success) {
                                 dispatch_async(dispatch_get_main_queue(), ^{
                                     success(operation, responseObject);
                                 });
                             }
                         }
                         failure:^(AFHTTPRequestOperation *operation, NSError *error){
                             [self _handleFailureWithRequestOperation:operation andError:error];
                             
                             if (failure) {
                                 dispatch_async(dispatch_get_main_queue(), ^{
                                     failure(operation, error);
                                 });
                             }
                         }];
}

- (void)signUp:(NSString*)identity
          with:(Provider)provider
          name:(NSString*)name
      password:(NSString*)password
       success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
       failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    NSString *endpoint = [NSString stringWithFormat:@"users/signin"];
    RKObjectManager *manager = [RKObjectManager sharedManager] ;
    NSDictionary *params = @{
                             @"provider": [Identity getProviderString:provider],
                             @"external_username": identity,
                             @"password": password,
                             @"name": name
                             };
    
    manager.HTTPClient.parameterEncoding = AFFormURLParameterEncoding;
    [manager.HTTPClient postPath:endpoint
                      parameters:params
                         success:^(AFHTTPRequestOperation *operation, id responseObject) {
                             [self _handleSuccessWithRequestOperation:operation andResponseObject:responseObject];
                             
                             if ([operation.response statusCode] == 200 && [responseObject isKindOfClass:[NSDictionary class]]) {
                                 NSNumber *code = [responseObject valueForKeyPath:@"meta.code"];
                                 if ([code integerValue] == 200) {
                                     NSNumber *u = [responseObject valueForKeyPath:@"response.user_id"];
                                     NSString *t = [responseObject valueForKeyPath:@"response.token"];
                                     self.user_id  = [u integerValue];
                                     self.user_token = t;
                                     [self saveUserData];
                                 }
                             }
                             if (success) {
                                 dispatch_async(dispatch_get_main_queue(), ^{
                                     success(operation, responseObject);
                                 });
                             }
                         }
                         failure:^(AFHTTPRequestOperation *operation, NSError *error){
                             [self _handleFailureWithRequestOperation:operation andError:error];
                             
                             if (failure) {
                                 dispatch_async(dispatch_get_main_queue(), ^{
                                     failure(operation, error);
                                 });
                             }
                         }];
}

- (void)reverseAuth:(Provider)provider
          withToken:(NSString*)token
           andParam:(NSDictionary*) param
            success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
            failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    
    NSParameterAssert(provider != kProviderUnknown);
    NSParameterAssert(token);
    if (provider == kProviderUnknown) {
        return;
    }
    if (token.length == 0) {
        return;
    }
    
    NSString *endpoint = [NSString stringWithFormat:@"/oauth/reverseauth"];
    RKObjectManager *manager = [RKObjectManager sharedManager] ;
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setValue:[Identity getProviderString:provider] forKey:@"provider"];
    [params setValue:token forKey:@"oauth_token"];
    if (param) {
        [params addEntriesFromDictionary:param];
    }
    
    manager.HTTPClient.parameterEncoding = AFFormURLParameterEncoding;
    [manager.HTTPClient postPath:endpoint
                      parameters:params
                         success:^(AFHTTPRequestOperation *operation, id responseObject) {
                             [self _handleSuccessWithRequestOperation:operation andResponseObject:responseObject];
                             
                             if ([operation.response statusCode] == 200 && [responseObject isKindOfClass:[NSDictionary class]]) {
                                 NSNumber *code = [responseObject valueForKeyPath:@"meta.code"];
                                 if ([code integerValue] == 200) {
                                     NSNumber *u = [responseObject valueForKeyPath:@"response.user_id"];
                                     NSString *t = [responseObject valueForKeyPath:@"response.token"];
                                     self.user_id  = [u integerValue];
                                     self.user_token = t;
                                     [self saveUserData];
                                 }
                             }
                             if (success) {
                                 dispatch_async(dispatch_get_main_queue(), ^{
                                     success(operation, responseObject);
                                 });
                             }
                         }
                         failure:^(AFHTTPRequestOperation *operation, NSError *error){
                             [self _handleFailureWithRequestOperation:operation andError:error];
                             
                             if (failure) {
                                 dispatch_async(dispatch_get_main_queue(), ^{
                                     failure(operation, error);
                                 });
                             }
                         }];
}

- (void)regDevice:(NSString*)pushToken
          success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
          failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    NSString *endpoint = [NSString stringWithFormat:@"users/%u/regdevice?token=%@", self.user_id, self.user_token];
    RKObjectManager *manager = [RKObjectManager sharedManager] ;
    
    NSDictionary *param = @{@"udid":pushToken,
                            @"push_token":pushToken,
                            @"os_name":[[UIDevice currentDevice] systemName],
                            @"brand":@"apple",
                            @"model":[[UIDevice currentDevice] model],
                            @"os_version":[[UIDevice currentDevice] systemVersion]};
    
    manager.HTTPClient.parameterEncoding = AFFormURLParameterEncoding;
    [manager.HTTPClient postPath:endpoint
                      parameters:param
                         success:^(AFHTTPRequestOperation *operation, id responseObject) {
                             [self _handleSuccessWithRequestOperation:operation andResponseObject:responseObject];
                             
                             if ([operation.response statusCode] == 200 && [responseObject isKindOfClass:[NSDictionary class]]) {
                                 NSNumber *code = [responseObject valueForKeyPath:@"meta.code"];
                                 if ([code integerValue] == 200) {
                                     [[NSUserDefaults standardUserDefaults] setObject:@"YES" forKey:@"ifdevicetokenSave"];
                                     [[NSUserDefaults standardUserDefaults] setObject:pushToken forKey:@"udid"];
                                     [[NSUserDefaults standardUserDefaults] synchronize];
                                 }
                             }
                             if (success) {
                                 dispatch_async(dispatch_get_main_queue(), ^{
                                     success(operation, responseObject);
                                 });
                             }
                         } failure:^(AFHTTPRequestOperation *operation, NSError *error){
                             [self _handleFailureWithRequestOperation:operation andError:error];
                             
                             if (failure) {
                                 dispatch_async(dispatch_get_main_queue(), ^{
                                     failure(operation, error);
                                 });
                             }
                         }];
}

#pragma mark Cross API

- (void)loadCrossesAfter:(NSString*)updatedtime
                 success:(void (^)(RKObjectRequestOperation *operation, RKMappingResult *mappingResult))success
                 failure:(void (^)(RKObjectRequestOperation *operation, NSError *error))failure
{
    [self loadCrossesBy:self.user_id
            updatedtime:updatedtime
                success:^(RKObjectRequestOperation *operation, id responseObject){
                    [self _handleSuccessWithRequestOperation:operation andResponseObject:responseObject];
                    
                    if (success) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            success(operation, responseObject);
                        });
                    }
                }
                failure:^(RKObjectRequestOperation *operation, NSError *error){
                    [self _handleFailureWithRequestOperation:operation andError:error];
                    
                    if (failure) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            failure(operation, error);
                        });
                    }
                }];
}

- (void)loadCrossesBy:(NSInteger)user_id
          updatedtime:(NSString*)updatedtime
              success:(void (^)(RKObjectRequestOperation *operation, RKMappingResult *mappingResult))success
              failure:(void (^)(RKObjectRequestOperation *operation, NSError *error))failure
{
    NSDictionary *param = nil;
    if (updatedtime != nil && ![updatedtime isEqualToString:@""]){
        updatedtime = [Util encodeToPercentEscapeString:updatedtime];
        param = @{@"token": self.user_token,
                  @"updated_at": updatedtime};
    } else {
        param = @{@"token": self.user_token};
    }
    NSString *endpoint = [NSString stringWithFormat:@"users/%u/crosses", self.user_id];
    
    [[RKObjectManager sharedManager] getObjectsAtPath:endpoint
                                           parameters:param
                                              success:^(RKObjectRequestOperation *operation, id responseObject){
                                                  [self _handleSuccessWithRequestOperation:operation andResponseObject:responseObject];
                                                  
                                                  if (success) {
                                                      dispatch_async(dispatch_get_main_queue(), ^{
                                                          success(operation, responseObject);
                                                      });
                                                  }
                                              }
                                              failure:^(RKObjectRequestOperation *operation, NSError *error){
                                                  [self _handleFailureWithRequestOperation:operation andError:error];
                                                  
                                                  if (failure) {
                                                      dispatch_async(dispatch_get_main_queue(), ^{
                                                          failure(operation, error);
                                                      });
                                                  }
                                              }];
    
}

#pragma mark User API

- (void)loadMeSuccess:(void (^)(RKObjectRequestOperation *operation, RKMappingResult *mappingResult))success
           failure:(void (^)(RKObjectRequestOperation *operation, NSError *error))failure
{
    NSDictionary *param = @{@"token": self.user_token};
    NSString *endpoint = [NSString stringWithFormat:@"users/%u", self.user_id];
    [[RKObjectManager sharedManager] getObjectsAtPath:endpoint
                                           parameters:param
                                              success:^(RKObjectRequestOperation *operation, id responseObject){
                                                  [self _handleSuccessWithRequestOperation:operation andResponseObject:responseObject];
                                                  
                                                  if (success) {
                                                      dispatch_async(dispatch_get_main_queue(), ^{
                                                          success(operation, responseObject);
                                                      });
                                                  }
                                              }
                                              failure:^(RKObjectRequestOperation *operation, NSError *error){
                                                  [self _handleFailureWithRequestOperation:operation andError:error];
                                                  
                                                  if (failure) {
                                                      dispatch_async(dispatch_get_main_queue(), ^{
                                                          failure(operation, error);
                                                      });
                                                  }
                                              }];
}

- (void)loadUserBy:(NSInteger)user_id
           success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
           failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    NSParameterAssert(user_id > 0);
    NSParameterAssert(self.user_token.length > 0);
    NSDictionary *param = @{@"token": self.user_token};
    NSString *endpoint = [NSString stringWithFormat:@"users/%u",user_id];
    [[RKObjectManager sharedManager].HTTPClient getPath:endpoint
                                             parameters:param
                                                success:^(AFHTTPRequestOperation *operation, id responseObject){
                                                    [self _handleSuccessWithRequestOperation:operation andResponseObject:responseObject];
                                                    
                                                    if (success) {
                                                        dispatch_async(dispatch_get_main_queue(), ^{
                                                            success(operation, responseObject);
                                                        });
                                                    }
                                                }
                                                failure:^(AFHTTPRequestOperation *operation, NSError *error){
                                                    [self _handleFailureWithRequestOperation:operation andError:error];
                                                    
                                                    if (failure) {
                                                        dispatch_async(dispatch_get_main_queue(), ^{
                                                            failure(operation, error);
                                                        });
                                                    }
                                                }];
}

- (void)mergeIdentities:(NSArray *)ids
                byToken:(NSString *)token
                success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    NSMutableString *idlist = [NSMutableString stringWithString:@"["];
    BOOL first = YES;
    for (NSNumber* identity_id in ids) {
        if (first) {
            first = NO;
        } else {
            [idlist appendString:@","];
        }
        [idlist appendFormat:@"%u", [identity_id integerValue]];
    }
    [idlist appendString:@"]"];
    NSDictionary *param = @{@"browsing_identity_token":token, @"identity_ids":idlist};
    NSString *endpoint = [NSString stringWithFormat:@"users/%u/mergeIdentities?token=%@", self.user_id, self.user_token];
                     
    [RKObjectManager sharedManager].HTTPClient.parameterEncoding = AFFormURLParameterEncoding;
    [[RKObjectManager sharedManager].HTTPClient postPath:endpoint
                                              parameters:param
                                                 success:^(AFHTTPRequestOperation *operation, id responseObject){
                                                     [self _handleSuccessWithRequestOperation:operation andResponseObject:responseObject];
                                                     
                                                     if (success) {
                                                         dispatch_async(dispatch_get_main_queue(), ^{
                                                             success(operation, responseObject);
                                                         });
                                                     }
                                                 }
                                                 failure:^(AFHTTPRequestOperation *operation, NSError *error){
                                                     [self _handleFailureWithRequestOperation:operation andError:error];
                                                     
                                                     if (failure) {
                                                         dispatch_async(dispatch_get_main_queue(), ^{
                                                             failure(operation, error);
                                                         });
                                                     }
                                                 }];
}

#pragma mark - Identity API

- (void)updateIdentity:(Identity*)identity
                  name:(NSString*)name
                andBio:(NSString*)bio
               success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
               failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure {
    
    NSString *endpoint = [NSString stringWithFormat:@"identities/%i/update?token=%@", [identity.identity_id intValue], self.user_token];
    
    RKObjectManager *objectManager = [RKObjectManager sharedManager];
    [RKObjectManager sharedManager].HTTPClient.parameterEncoding = AFFormURLParameterEncoding;
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:2];
    if (name) {
        [dict setObject:name forKey:@"name"];
    }
    if (bio) {
        [dict setObject:bio forKey:@"bio"];
    }
    [objectManager.HTTPClient postPath:endpoint
                            parameters:dict
                               success:^(AFHTTPRequestOperation *operation, id responseObject){
                                   [self _handleSuccessWithRequestOperation:operation andResponseObject:responseObject];
                                   
                                   if (success) {
                                       dispatch_async(dispatch_get_main_queue(), ^{
                                           success(operation, responseObject);
                                       });
                                   }
                               }
                               failure:^(AFHTTPRequestOperation *operation, NSError *error){
                                   [self _handleFailureWithRequestOperation:operation andError:error];
                                   
                                   if (failure) {
                                       dispatch_async(dispatch_get_main_queue(), ^{
                                           failure(operation, error);
                                       });
                                   }
                               }];
}


- (void)updateName:(NSString*)name
           success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
           failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    
    NSString *endpoint = [NSString stringWithFormat:@"users/update?token=%@",[EFAPIServer sharedInstance].user_token];
    
    RKObjectManager *objectManager = [RKObjectManager sharedManager];
    [RKObjectManager sharedManager].HTTPClient.parameterEncoding = AFFormURLParameterEncoding;
    
    [objectManager.HTTPClient postPath:endpoint
                            parameters:@{@"name":name}
                               success:^(AFHTTPRequestOperation *operation, id responseObject){
                                   [self _handleSuccessWithRequestOperation:operation andResponseObject:responseObject];
                                   
                                   if (success) {
                                       dispatch_async(dispatch_get_main_queue(), ^{
                                           success(operation, responseObject);
                                       });
                                   }
                               }
                               failure:^(AFHTTPRequestOperation *operation, NSError *error){
                                   [self _handleFailureWithRequestOperation:operation andError:error];
                                   
                                   if (failure) {
                                       dispatch_async(dispatch_get_main_queue(), ^{
                                           failure(operation, error);
                                       });
                                   }
                               }];
}

- (void)addIdentityBy:(NSString*)external_username
         withProvider:(Provider)provider
                param:(NSDictionary*)param
              success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
              failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    
    NSString *endpoint = [NSString stringWithFormat:@"users/%u/addIdentity?token=%@",[EFAPIServer sharedInstance].user_id, [EFAPIServer sharedInstance].user_token];
    
    RKObjectManager *objectManager = [RKObjectManager sharedManager];
    [RKObjectManager sharedManager].HTTPClient.parameterEncoding = AFFormURLParameterEncoding;
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params addEntriesFromDictionary:@{@"external_username":external_username, @"provider": [Identity getProviderString:provider]}];
    if (param) {
        [params addEntriesFromDictionary:param];
    }
    
    [objectManager.HTTPClient postPath:endpoint
                            parameters:params
                               success:^(AFHTTPRequestOperation *operation, id responseObject){
                                   [self _handleSuccessWithRequestOperation:operation andResponseObject:responseObject];
                                   
                                   if (success) {
                                       dispatch_async(dispatch_get_main_queue(), ^{
                                           success(operation, responseObject);
                                       });
                                   }
                               }
                               failure:^(AFHTTPRequestOperation *operation, NSError *error){
                                   [self _handleFailureWithRequestOperation:operation andError:error];
                                   
                                   if (failure) {
                                       dispatch_async(dispatch_get_main_queue(), ^{
                                           failure(operation, error);
                                       });
                                   }
                               }];
}

#pragma mark - Private

- (void)_handleSuccessWithRequestOperation:(NSOperation *)operation andResponseObject:(id)object {
    if ([[EFStatusBar defaultStatusBar].currentPresentedMessage isEqualToString:@" Network error "]) {
        [[EFStatusBar defaultStatusBar] dismiss];
    }
}

- (void)_handleFailureWithRequestOperation:(NSOperation *)operation andError:(NSError *)error {
    if ([error.domain isEqualToString:NSURLErrorDomain]) {
        if (NSURLErrorCannotConnectToHost == error.code ||
            NSURLErrorNetworkConnectionLost == error.code ||
            NSURLErrorNotConnectedToInternet == error.code) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [[EFStatusBar defaultStatusBar] presentMessage:@" Network error "
                                                 withTextColor:[UIColor whiteColor]
                                               backgroundColor:[UIColor COLOR_RED_MEXICAN]];
            });
        }
    }
}

@end
