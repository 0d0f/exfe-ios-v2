//
//  APIExfee.m
//  EXFE
//
//  Created by Stony Wang on 13-3-25.
//
//

#import "APIExfee.h"
#import "AppDelegate.h"

@implementation APIExfee

+ (void)submitRsvp:(NSString*)status
                on:(Invitation*)invitation
        myIdentity:(int)my_identity_id
           onExfee:(int)exfee_id
           success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
           failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSDictionary *rsvpdict = [NSDictionary dictionaryWithObjectsAndKeys:invitation.identity.identity_id,@"identity_id",my_identity_id,@"by_identity_id",status,@"rsvp_status",@"rsvp",@"type", nil];
    
    NSString *endpoint = [NSString stringWithFormat:@"%@/exfee/%u/rsvp?token=%@",API_ROOT,exfee_id, app.accesstoken];
    
    RKObjectManager *manager=[RKObjectManager sharedManager] ;
    manager.HTTPClient.parameterEncoding = AFJSONParameterEncoding;
    [manager.HTTPClient postPath:endpoint parameters:@{@"rsvps":@[rsvpdict]} success:success failure:failure];
}


+ (void)edit:(Exfee*)exfee
  myIdentity:(int)my_identity_id
     success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
     failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure{
    
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    
    NSString *endpoint = [NSString stringWithFormat:@"%@/exfee/%u/edit?token=%@",API_ROOT, [exfee.exfee_id intValue], app.accesstoken];
    
    
    RKObjectManager *manager=[RKObjectManager sharedManager] ;
    manager.HTTPClient.parameterEncoding = AFJSONParameterEncoding;
    [manager.HTTPClient postPath:endpoint parameters:@{@"by_identity_id":[NSNumber numberWithInt:my_identity_id], @"exfee": exfee} success:success failure:failure];
}

+ (void)addInvitations:(NSArray*)array
                    to:(int)exfee_id
              modifier:(int)identity_id
               success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
               failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure{
    
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    
    NSString *endpoint = [NSString stringWithFormat:@"%@/exfee/%u/edit?token=%@",API_ROOT, exfee_id, app.accesstoken];
    RKObjectManager *manager=[RKObjectManager sharedManager] ;
    manager.HTTPClient.parameterEncoding = AFJSONParameterEncoding;
    [manager.HTTPClient postPath:endpoint parameters:@{@"by_identity_id":[NSNumber numberWithInt:identity_id], @"exfee": @{@"id": [NSNumber numberWithInt:exfee_id], @"type": @"exfee", @"invitations":array}} success:success failure:failure];
    
}

@end
