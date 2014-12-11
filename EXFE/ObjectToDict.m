//
//  ObjectToDict.m
//  EXFE
//
//  Created by huoju on 8/27/12.
//
//

#import "ObjectToDict.h"

@implementation ObjectToDict
+ (NSMutableDictionary*) ExfeeDict:(Exfee*)exfee{
    NSMutableArray *invitations_array=[[NSMutableArray alloc] initWithCapacity:[exfee.invitations count]];
    NSSet *invitations=exfee.invitations;
    if(invitations !=nil&&[invitations count]>0)
    {
        for(Invitation* invitation in invitations){
            NSMutableDictionary *invitation_dict=[ObjectToDict InvitationDict:invitation];
            [invitations_array addObject:invitation_dict];
        }
    }
    return [NSMutableDictionary dictionaryWithObjectsAndKeys:invitations_array,@"invitations",exfee.accepted,@"accepted",exfee.total,@"total",exfee.exfee_id,@"exfee_id", nil ];
}
+ (NSMutableDictionary*) InvitationDict:(Invitation*)invitation{
    NSMutableDictionary *identity=[ObjectToDict IdentityDict:invitation.identity];
    NSMutableDictionary *by_identity=[ObjectToDict IdentityDict:invitation.updated_by];
    
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
    [format setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *created_at_str = [format stringFromDate:invitation.created_at];
    NSString *updated_at_str = [format stringFromDate:invitation.updated_at];
    
    return [NSMutableDictionary dictionaryWithObjectsAndKeys:created_at_str,@"created_at",invitation.host,@"host",invitation.invitation_id,@"invitation_id",invitation.mates,@"mates",invitation.rsvp_status,@"rsvp_status",updated_at_str,@"updated_at",invitation.via,@"via",identity ,@"identity",by_identity,@"by_identity",nil];
}
+ (NSMutableDictionary*) IdentityDict:(Identity*)identity{

    NSMutableDictionary *dict=[NSMutableDictionary dictionaryWithCapacity:12];
    if(identity.avatar_filename!=nil)
        [dict setObject:identity.avatar_filename forKey:@"avatar_filename"];
    if(identity.bio!=nil)
        [dict setObject:identity.bio forKey:@"bio"];
    if(identity.connected_user_id!=nil)
        [dict setObject:identity.connected_user_id forKey:@"connected_user_id"];
    if(identity.created_at!=nil)
        [dict setObject:identity.created_at forKey:@"created_at"];
    if(identity.external_id!=nil)
        [dict setObject:identity.external_id forKey:@"external_id"];
    if(identity.external_username!=nil)
        [dict setObject:identity.external_username forKey:@"external_username"];
    if(identity.identity_id!=nil)
        [dict setObject:identity.identity_id forKey:@"identity_id"];
    if(identity.name!=nil)
        [dict setObject:identity.name forKey:@"name"];
    if(identity.nickname!=nil)
        [dict setObject:identity.nickname forKey:@"nickname"];
    if(identity.provider!=nil)
        [dict setObject:identity.provider forKey:@"provider"];
    if(identity.updated_at!=nil)
        [dict setObject:identity.updated_at forKey:@"updated_at"];
    
    return dict;
}
@end
