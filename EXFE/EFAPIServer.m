//
//  EFAPIServer.m
//  EXFE
//
//  Created by Stony Wang on 13-4-17.
//
//

#import "EFAPIServer.h"
#import "Util.h"

@implementation EFAPIServer

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

- (void)getAvailableBackgroundsWithSuccess:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                                   failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    NSString *endpoint = [NSString stringWithFormat:@"Backgrounds/GetAvailableBackgrounds"];
    RKObjectManager *manager = [RKObjectManager sharedManager] ;
    [manager.HTTPClient getPath:endpoint parameters:nil success:success failure:failure];
}

+ (void) checkAppVersionSuccess:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                        failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure{
    [Flurry logEvent:@"API_CHECK_UPDATE"];
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    RKObjectManager *manager = [RKObjectManager sharedManager];
    NSString *endpoint = [NSString stringWithFormat:@"/versions/"];
    
    //    manager.HTTPClient.parameterEncoding = AFJSONParameterEncoding;
    //    manager.requestSerializationMIMEType = RKMIMETypeJSON;
    // Accept HTTP Header; see http://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html#sec14.1
    //	[manager.HTTPClient setDefaultHeader:@"Accept" value:@"application/json"];
    [manager.HTTPClient setDefaultHeader:@"token" value:app.accesstoken];
    [manager.HTTPClient getPath:endpoint parameters:nil success:success failure:failure];
}

- (void)getRegFlagBy:(NSString*)identity
                with:(Provider)provider
             success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
             failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    
    
    NSString *endpoint = [NSString stringWithFormat:@"users/GetRegistrationFlag"];
    RKObjectManager *manager = [RKObjectManager sharedManager] ;
    
    
    NSDictionary* params = @{@"external_username": identity, @"provider": [Identity getProviderString:provider]};
    [manager.HTTPClient getPath:endpoint parameters:params success:success failure:failure];
    
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
    [manager getObject:nil path:endpoint parameters:params success:success failure:failure];

    
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
                             if ([operation.response statusCode] == 200 && [responseObject isKindOfClass:[NSDictionary class]]){
                                 
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
                                 success(operation, responseObject);
                             }
                         }
                         failure:failure];
}

- (void)signOutUsingUdid:(NSString*)udid
                 success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                 failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    NSString *endpoint = [NSString stringWithFormat:@"users/%u/signout?token=%@",self.user_id, self.user_token];
    RKObjectManager *manager = [RKObjectManager sharedManager] ;
    NSDictionary *params = @{@"udid":udid,@"os_name":@"iOS"};
    manager.HTTPClient.parameterEncoding=AFJSONParameterEncoding;
    [manager.HTTPClient postPath:endpoint parameters:params success:success failure:failure];
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
                             if ([operation.response statusCode] == 200 && [responseObject isKindOfClass:[NSDictionary class]]){
                                 
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
                                 success(operation, responseObject);
                             }
                         }
                         failure:failure];
}

- (void)regDevice:(NSString*)pushToken
          success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
          failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    NSString *endpoint = [NSString stringWithFormat:@"users/%u/regdevice?token=%@",self.user_id, self.user_token];
    RKObjectManager *manager = [RKObjectManager sharedManager] ;
    
    NSDictionary *param = @{@"udid":pushToken,
                      @"push_token":pushToken,
                            @"os_name":[[UIDevice currentDevice] systemName],
                            @"brand":@"apple",
                            @"model":[[UIDevice currentDevice] model],
                            @"os_version":[[UIDevice currentDevice] systemVersion]};
    
    manager.HTTPClient.parameterEncoding = AFFormURLParameterEncoding;
    [manager.HTTPClient postPath:endpoint parameters:param success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ([operation.response statusCode] == 200 && [responseObject isKindOfClass:[NSDictionary class]]){
            NSNumber *code = [responseObject valueForKeyPath:@"meta.code"];
            if ([code integerValue] == 200) {
                    [[NSUserDefaults standardUserDefaults] setObject:@"YES" forKey:@"ifdevicetokenSave"];
                    [[NSUserDefaults standardUserDefaults] setObject:pushToken forKey:@"udid"];
            }
        }
        success(operation, responseObject);
    } failure:failure];
}

- (void)loadCrossesAfter:(NSString*)updatedtime
                 success:(void (^)(RKObjectRequestOperation *operation, RKMappingResult *mappingResult))success
                 failure:(void (^)(RKObjectRequestOperation *operation, NSError *error))failure
{
    [self loadCrossesBy:self.user_id updatedtime:updatedtime success:success failure:failure];
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
    
    [[RKObjectManager sharedManager] getObjectsAtPath:endpoint parameters:param success:success failure:failure];
    
}

- (void)loadMeSuccess:(void (^)(RKObjectRequestOperation *operation, RKMappingResult *mappingResult))success
           failure:(void (^)(RKObjectRequestOperation *operation, NSError *error))failure
{
    NSDictionary *param = @{@"token": self.user_token};
    NSString *endpoint = [NSString stringWithFormat:@"users/%u", self.user_id];
    [[RKObjectManager sharedManager] getObjectsAtPath:endpoint parameters:param success:success failure:failure];
}

- (void)loadUserBy:(NSInteger)user_id
           success:(void (^)(RKObjectRequestOperation *operation, RKMappingResult *mappingResult))success
           failure:(void (^)(RKObjectRequestOperation *operation, NSError *error))failure
{
    NSParameterAssert(user_id > 0);
    NSParameterAssert(self.user_token.length > 0);
    NSDictionary *param = @{@"token": self.user_token};
    NSString *endpoint = [NSString stringWithFormat:@"users/%u",user_id];
    [[RKObjectManager sharedManager] getObjectsAtPath:endpoint parameters:param success:success failure:failure];
}
@end
