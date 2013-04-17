//
//  EFAPIServer.m
//  EXFE
//
//  Created by Stony Wang on 13-4-17.
//
//


#import "EFAPIServer.h"

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
        
    });
    return sharedInstance;
}

- (void)getRegFlagBy:(NSString*)identity
                 and:(Provider)provider
             success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
             failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    
    
    NSString *endpoint = [NSString stringWithFormat:@"users/GetRegistrationFlag"];
    RKObjectManager *manager = [RKObjectManager sharedManager] ;
    
    
    NSDictionary* params = @{@"external_username": identity, @"provider": [Identity getProviderString:provider]};
    [manager.HTTPClient getPath:endpoint parameters:params success:success failure:failure];
    
}

@end
