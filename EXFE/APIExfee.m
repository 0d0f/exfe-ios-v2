//
//  APIExfee.m
//  EXFE
//
//  Created by Stony Wang on 13-3-25.
//
//

#import "APIExfee.h"
#import "AppDelegate.h"
#import "Invitation+EXFE.h"
#import "Identity+EXFE.h"

@implementation APIExfee

//Identity *myidentity = [_cross.exfee getMyInvitation].identity;

- (void)submitrsvp:(Invitation*)invitation onExfee:(int)exfee_id success:(void (^)(RKObjectRequestOperation *operation, RKMappingResult *mappingResult))success failure:(void (^)(RKObjectRequestOperation *operation, NSError *error))failure{
    //    NSError *error;
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    
//    NSDictionary *rsvpdict=[NSDictionary dictionaryWithObjectsAndKeys:invitation.identity.identity_id,@"identity_id",myidentity.identity_id,@"by_identity_id",status,@"rsvp_status",@"rsvp",@"type", nil];
//    
//    NSString *endpoint = [NSString stringWithFormat:@"%@/exfee/%u/rsvp?token=%@",API_ROOT,[_cross.exfee.exfee_id intValue],app.accesstoken];
//    
//    RKObjectManager *manager=[RKObjectManager sharedManager] ;
//    manager.HTTPClient.parameterEncoding=AFJSONParameterEncoding;
//    [manager.HTTPClient postPath:endpoint parameters:@{@"rsvps":@[rsvpdict]} su
}

@end
