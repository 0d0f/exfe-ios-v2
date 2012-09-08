//
//  APICross.m
//  EXFE
//
//  Created by ju huo on 5/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "APICrosses.h"
#import "Mapping.h"
#import "Meta.h"
#import "Cross.h"
#import "Place.h"
#import "Identity.h"
#import "Rsvp.h"
#import "Util.h"


@implementation APICrosses
+ (RKManagedObjectMapping*) getPlaceMapping{
    
    RKObjectManager* manager =[RKObjectManager sharedManager];
    RKManagedObjectMapping* placeMapping = [RKManagedObjectMapping mappingForEntityWithName:@"Place" inManagedObjectStore:manager.objectStore];
    placeMapping.primaryKeyAttribute=@"place_id";
    [placeMapping mapKeyPathsToAttributes:@"id", @"place_id",
     @"title", @"title",
     @"description", @"place_description",
     @"lat", @"lat",
     @"lng", @"lng",
     @"provider", @"provider",
     @"external_id", @"external_id",
     @"created_at", @"created_at",
     @"updated_at", @"updated_at",
     @"type", @"type",
     nil];
    return placeMapping;
}

+ (RKManagedObjectMapping*) getInvitationMapping{
    RKObjectManager* manager =[RKObjectManager sharedManager];
    RKManagedObjectMapping* invitationMapping = [RKManagedObjectMapping mappingForEntityWithName:@"Invitation" inManagedObjectStore:manager.objectStore];
    invitationMapping.primaryKeyAttribute=@"invitation_id";
    [invitationMapping mapKeyPathsToAttributes:@"id", @"invitation_id",
     @"rsvp_status", @"rsvp_status",
     @"host", @"host",
     @"mates", @"mates",
     @"via", @"via",
     @"updated_at", @"updated_at",
     @"created_at", @"created_at",
     @"type", @"type",
     nil];
    [invitationMapping mapRelationship:@"identity" withMapping:[Mapping getIdentityMapping]];
    [invitationMapping mapRelationship:@"by_identity" withMapping:[Mapping getIdentityMapping]];
    return invitationMapping;
}
+ (RKManagedObjectMapping*) getExfeeMapping{
    RKObjectManager* manager =[RKObjectManager sharedManager];
    RKManagedObjectMapping* invitationMapping=[APICrosses getInvitationMapping];
    RKManagedObjectMapping* exfeeMapping = [RKManagedObjectMapping mappingForEntityWithName:@"Exfee" inManagedObjectStore:manager.objectStore];
    exfeeMapping.primaryKeyAttribute=@"exfee_id";
    [exfeeMapping mapKeyPathsToAttributes:@"id", @"exfee_id",@"total",@"total",@"accepted",@"accepted",@"type",@"type",
     nil];
    [exfeeMapping mapRelationship:@"invitations" withMapping:invitationMapping];
    return exfeeMapping;
}

+ (RKManagedObjectMapping*) getCrossMapping{
    RKObjectManager* manager =[RKObjectManager sharedManager];
    RKManagedObjectMapping* identityMapping = [Mapping getIdentityMapping];
    RKManagedObjectMapping* placeMapping =[APICrosses getPlaceMapping];
    RKManagedObjectMapping* invitationMapping=[APICrosses getInvitationMapping];
    RKManagedObjectMapping* exfeeMapping=[APICrosses getExfeeMapping];
    
    RKObjectMapping* invitationSerializationMapping = [invitationMapping inverseMapping];
    [manager.mappingProvider setSerializationMapping:invitationSerializationMapping forClass:[Invitation class]];
    [manager.mappingProvider setObjectMapping:invitationSerializationMapping forKeyPath:@"invitation"];
    
    RKObjectMapping* exfeeSerializationMapping = [exfeeMapping inverseMapping];
    [manager.mappingProvider setSerializationMapping:exfeeSerializationMapping forClass:[Exfee class]];
    [manager.mappingProvider setObjectMapping:exfeeSerializationMapping forKeyPath:@"exfee"];
    
    
    RKManagedObjectMapping* EFMapping = [RKManagedObjectMapping mappingForEntityWithName:@"EFTime" inManagedObjectStore:manager.objectStore];
    [EFMapping mapKeyPathsToAttributes:@"date", @"date",
     @"date_word", @"date_word",
     @"time", @"time",
     @"time_word", @"time_word",
     @"timezone", @"timezone",
     nil];
    
    RKManagedObjectMapping* crosstimeMapping = [RKManagedObjectMapping mappingForEntityWithName:@"CrossTime" inManagedObjectStore:manager.objectStore];
    [crosstimeMapping mapKeyPathsToAttributes:@"origin", @"origin",
     @"outputformat", @"outputformat",
     nil];
    [crosstimeMapping mapRelationship:@"begin_at" withMapping:EFMapping];
    
    
    RKManagedObjectMapping* crossMapping = [RKManagedObjectMapping mappingForEntityWithName:@"Cross" inManagedObjectStore:manager.objectStore];
    crossMapping.primaryKeyAttribute=@"cross_id";
    [crossMapping mapKeyPathsToAttributes:@"id", @"cross_id",
     @"title", @"title",
     @"description", @"cross_description",
     @"id_base62", @"crossid_base62",
     @"created_at", @"created_at",
     @"updated", @"updated",
     @"widget", @"widget",
     @"updated_at", @"updated_at",
     @"conversation_count",@"conversation_count",
     nil];
    [crossMapping mapRelationship:@"by_identity" withMapping:identityMapping];
    [crossMapping mapRelationship:@"host_identity" withMapping:identityMapping];
    [crossMapping mapRelationship:@"place" withMapping:placeMapping];
    [crossMapping mapRelationship:@"exfee" withMapping:exfeeMapping];
    [crossMapping mapRelationship:@"time" withMapping:crosstimeMapping];
    return crossMapping;
}

+(void) MappingCross
{
    RKObjectManager* manager =[RKObjectManager sharedManager];
    RKManagedObjectMapping *crossMapping=[APICrosses getCrossMapping];
    [manager.mappingProvider setObjectMapping:crossMapping forKeyPath:@"response.crosses"];
    [manager.mappingProvider setObjectMapping:crossMapping forKeyPath:@"response.cross"];
    [manager.mappingProvider setObjectMapping:[Mapping getMetaMapping] forKeyPath:@"meta"];
    
    [manager.mappingProvider setObjectMapping:[APICrosses getExfeeMapping] forKeyPath:@"response.exfee"];


    RKManagedObjectMapping* RsvpMapping = [RKManagedObjectMapping mappingForEntityWithName:@"Rsvp" inManagedObjectStore:manager.objectStore];
    [RsvpMapping mapKeyPathsToAttributes:@"identity_id", @"identity_id",
     @"rsvp_status", @"rsvp_status", 
     @"by_identity_id", @"by_identity_id", 
     @"exfee_id", @"exfee_id", 
     nil];
    
    [manager.mappingProvider setSerializationMapping:RsvpMapping forClass:[Rsvp class]]; 

    RKObjectMapping* crossSerializationMapping = [crossMapping inverseMapping];
    [manager.mappingProvider setSerializationMapping:crossSerializationMapping forClass:[Cross class]];
    
    manager.serializationMIMEType = RKMIMETypeJSON;
    NSString *endpoint = [NSString stringWithFormat:@"/crosses/gather"];
    [manager.router routeClass:[Cross class] toResourcePath:endpoint forMethod:RKRequestMethodPOST];

    
}
+(void) MappingRoute {
    
//    RKObjectManager* manager =[RKObjectManager sharedManager];
}

+(void) GatherCross:(Cross*) cross delegate:(id)delegate{
    AppDelegate *app=(AppDelegate *)[[UIApplication sharedApplication] delegate];
    RKObjectManager* manager =[RKObjectManager sharedManager];
    [manager.client setBaseURL:[RKURL URLWithBaseURLString:API_V2_ROOT]];
    [manager.client setValue:app.accesstoken forHTTPHeaderField:@"token"];
    [manager postObject:cross usingBlock:^(RKObjectLoader *loader){
        loader.delegate=delegate;
    }];
}
     
+(void) LoadCrossWithUserId:(int)userid updatedtime:(NSString*)updatedtime delegate:(id)delegate source:(NSDictionary*)source{
//    [[[RKObjectManager sharedManager] requestQueue] cancelRequestsWithDelegate:delegate];
//    [[[RKObjectManager sharedManager] requestQueue] cancelAllRequests];
//    [[[RKClient sharedClient] requestQueue] cancelAllRequests];
//    NSLog(@"manager queue: %i",[RKObjectManager sharedManager].requestQueue.loadingCount );
//    NSLog(@"client queue: %i",[RKClient sharedClient].requestQueue.loadingCount  );
    
    AppDelegate *app=(AppDelegate *)[[UIApplication sharedApplication] delegate];
    if(updatedtime!=nil && ![updatedtime isEqualToString:@""])
        updatedtime=[Util encodeToPercentEscapeString:updatedtime];

    NSString *endpoint = [NSString stringWithFormat:@"/users/%u/crosses?updated_at=%@&token=%@",app.userid,updatedtime,app.accesstoken];
    RKObjectManager* manager =[RKObjectManager sharedManager];
    [manager.client setBaseURL:[RKURL URLWithBaseURLString:API_V2_ROOT]];
        RKObjectLoader *loader = [manager loaderWithResourcePath:endpoint];
        loader.delegate = delegate;
        loader.method = RKRequestMethodGET;
        loader.userData=source;
    	[loader send];
}

@end
