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
     success:(void (^)(RKObjectRequestOperation *operation, RKMappingResult *mappingResult))success
     failure:(void (^)(RKObjectRequestOperation *operation, NSError *error))failure{
    
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
     RKObjectManager* manager =[RKObjectManager sharedManager];
    NSString *endpoint = [NSString stringWithFormat:@"%@/exfee/%u/edit?token=%@&by_identity_id=%u",API_ROOT, [exfee.exfee_id intValue], app.accesstoken, my_identity_id];
    
    manager.HTTPClient.parameterEncoding = AFJSONParameterEncoding;
    manager.requestSerializationMIMEType = RKMIMETypeJSON;
    [manager.HTTPClient setDefaultHeader:@"token" value:app.accesstoken];
    [manager postObject:exfee path:endpoint parameters:nil success:success failure:failure];
}

+ (void)addInvitations:(NSArray*)array
                    to:(int)exfee_id
              modifier:(int)my_identity_id
               success:(void (^)(RKObjectRequestOperation *operation, RKMappingResult *mappingResult))success
               failure:(void (^)(RKObjectRequestOperation *operation, NSError *error))failure{
    
//    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
//    Exfee* newExfee = [[Exfee alloc] init];
//    newExfee.exfee_id = [NSNumber numberWithInt:exfee_id];
//    newExfee.invitations = [NSSet setWithArray:array];
//    [self edit:newExfee myIdentity:my_identity_id success:success failure:failure];
}

@end
