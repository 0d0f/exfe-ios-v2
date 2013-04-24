//
//  SigninDelegate.m
//  EXFE
//
//  Created by huoju on 8/24/12.
//
//

#import "SigninDelegate.h"
#import "EFAPIServer.h"
#import "User+EXFE.h"

@implementation SigninDelegate
@synthesize modalview;
@synthesize parent;

#pragma Mark - OAuthlogin Delegate
- (void)OAuthloginViewControllerDidCancel:(UIViewController *)oauthlogin {
    [oauthlogin dismissModalViewControllerAnimated:YES];
    [oauthlogin release];
    oauthlogin = nil;
}
-(void)OAuthloginViewControllerDidSuccess:(OAuthLoginViewController *)oauthloginViewController userid:(NSString*)userid username:(NSString*)username external_id:(NSString*)external_id token:(NSString*)token
{
    [self loginSuccessWith:token userid:userid username:username];
}

- (void)loginSuccessWith:(NSString *)token userid:(NSString *)userid username:(NSString *)username {
    
    EFAPIServer *server = [EFAPIServer sharedInstance];
    server.user_id = [userid integerValue];
    server.user_token = token;
    [server saveUserData];
    
    [[EFAPIServer sharedInstance] loadUserBy:[userid integerValue]
                                     success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                         
                                         User* user = [User getDefaultUser];
                                         NSParameterAssert(user != nil);
                                         
                                         if(parent!=nil){
                                             [parent performSelector:@selector(SigninDidFinish)];
                                         }
                                     } failure:nil];
}

@end
