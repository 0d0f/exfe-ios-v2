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
              modifier:(int)identity_id
               success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
               failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure{
    
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    RKObjectMapping *identityrequestMapping = [RKObjectMapping requestMapping];
    [identityrequestMapping addAttributeMappingsFromDictionary:@{@"identity_id": @"id",@"a_order": @"order"}];
    [identityrequestMapping addAttributeMappingsFromArray:@[@"name",@"nickname",@"provider",@"external_id",@"external_username",@"connected_user_id",@"bio",@"avatar_filename",@"avatar_updated_at",@"created_at",@"updated_at",@"type",@"unreachable",@"status"]];
    
    RKObjectMapping *invitationrequestMapping = [RKObjectMapping requestMapping];
    [invitationrequestMapping addAttributeMappingsFromDictionary:@{@"invitation_id": @"id"}];
    [invitationrequestMapping addAttributeMappingsFromArray:@[@"rsvp_status",@"host",@"mates",@"via",@"updated_at",@"created_at",@"type"]];
    [invitationrequestMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"identity" toKeyPath:@"identity" withMapping:identityrequestMapping]];
    [invitationrequestMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"invited_by" toKeyPath:@"invited_by" withMapping:identityrequestMapping]];
    [invitationrequestMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"updated_by" toKeyPath:@"updated_by" withMapping:identityrequestMapping]];
    
    //        RKObjectMapping *mapping = [RKObjectMapping mappingForClass:[NSDictionary class] ];
    //        [mapping addAttributeMappingsFromArray:@[ @"firstName", @"lastName"] ];
    //
    //
    //
    RKRequestDescriptor *requestDescriptor = [RKRequestDescriptor requestDescriptorWithMapping:invitationrequestMapping objectClass:[Invitation class] rootKeyPath:@"invitation"];
    
    NSMutableArray *invJson = [NSMutableArray arrayWithCapacity:array.count];
    for (Invitation *inv in array) {
        NSError* error;
        NSDictionary *parameters = [RKObjectParameterization parametersWithObject:inv requestDescriptor:requestDescriptor error:&error];
        
        // Serialize the object to JSON
        NSData *JSON = [RKMIMETypeSerialization dataFromObject:parameters MIMEType:RKMIMETypeJSON error:&error];
        NSString* newStr = [[NSString alloc] initWithData:JSON
                                                 encoding:NSUTF8StringEncoding];
        
        [invJson addObject:newStr];
    }
    
    
    NSString *endpoint = [NSString stringWithFormat:@"%@/exfee/%u/edit?token=%@",API_ROOT, exfee_id, app.accesstoken];
    RKObjectManager *manager=[RKObjectManager sharedManager] ;
    manager.HTTPClient.parameterEncoding = AFJSONParameterEncoding;
    [manager.HTTPClient postPath:endpoint parameters:@{@"by_identity_id":[NSNumber numberWithInt:identity_id], @"exfee": @{@"id": [NSNumber numberWithInt:exfee_id], @"type": @"exfee", @"invitations":invJson}} success:success failure:failure];
    
}

@end
