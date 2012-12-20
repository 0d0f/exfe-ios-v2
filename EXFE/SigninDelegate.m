//
//  SigninDelegate.m
//  EXFE
//
//  Created by huoju on 8/24/12.
//
//

#import "SigninDelegate.h"

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
    
    AppDelegate *app=(AppDelegate *)[[UIApplication sharedApplication] delegate];
    app.userid=[userid intValue];
    app.accesstoken=token;
    [APIProfile LoadUsrWithUserId:app.userid delegate:self];
}

#pragma mark RKObjectLoaderDelegate methods

- (void)objectLoader:(RKObjectLoader *)objectLoader didLoadObjects:(NSArray *)objects {
//    AppDelegate *app=(AppDelegate *)[[UIApplication sharedApplication] delegate];
//	NSFetchRequest* request = [User fetchRequest];
//    NSPredicate *predicate = [NSPredicate
//                              predicateWithFormat:@"user_id = %u", app.userid];
//    [request setPredicate:predicate];
//	NSArray *users = [[User objectsWithFetchRequest:request] retain];
//    
//    if(users!=nil && [users count] >0)
//    {
//        User* user=[users objectAtIndex:0];
//        NSMutableArray *identities=[[NSMutableArray alloc] initWithCapacity:4];
//        for(Identity *identity in user.identities){
//            [identities addObject:identity.identity_id];
//        }
//        [[NSUserDefaults standardUserDefaults] setObject:identities forKey:@"default_user_identities"];
//        [identities release];
//        
//        [[NSUserDefaults standardUserDefaults] setObject:user.name forKey:@"username"];
//        [[NSUserDefaults standardUserDefaults] synchronize];
//        app.username=user.name;
//        [[NSUserDefaults standardUserDefaults] setObject:app.accesstoken forKey:@"access_token"];
//        [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%i",app.userid] forKey:@"userid"];
//        [[NSUserDefaults standardUserDefaults] synchronize];
//
//    }
//    [users release];
//    if(parent!=nil)
    AppDelegate *app=(AppDelegate *)[[UIApplication sharedApplication] delegate];
	NSFetchRequest* request = [User fetchRequest];
    NSPredicate *predicate = [NSPredicate
                              predicateWithFormat:@"user_id = %u", app.userid];
    [request setPredicate:predicate];
	NSArray *users = [[User objectsWithFetchRequest:request] retain];
    
    if(users!=nil && [users count] >0)
    {
        User* user=[users objectAtIndex:0];
        [SigninDelegate saveSigninData:user];
    }
    [users release];

    [parent performSelector:@selector(SigninDidFinish)];
//    else{
//        [app SigninDidFinish];
//    }
}

+ (void)saveSigninData:(User*)user{
    AppDelegate *app=(AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSMutableArray *identities=[[NSMutableArray alloc] initWithCapacity:4];
    for(Identity *identity in user.identities){
        [identities addObject:identity.identity_id];
    }
    [[NSUserDefaults standardUserDefaults] setObject:identities forKey:@"default_user_identities"];
    [identities release];

    [[NSUserDefaults standardUserDefaults] setObject:user.name forKey:@"username"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    app.username=user.name;
    [[NSUserDefaults standardUserDefaults] setObject:app.accesstoken forKey:@"access_token"];
    [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%i",app.userid] forKey:@"userid"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)objectLoader:(RKObjectLoader *)objectLoader didFailWithError:(NSError *)error {
    NSLog(@"Error!:%@",error);
}

@end
