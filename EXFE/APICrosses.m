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
+(void) MappingCross
{
    RKObjectManager* manager =[RKObjectManager sharedManager];
    RKManagedObjectMapping* identityMapping = [Mapping getIdentityMapping];
    
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
     nil];
    
    RKManagedObjectMapping* invitationMapping = [RKManagedObjectMapping mappingForEntityWithName:@"Invitation" inManagedObjectStore:manager.objectStore];
    invitationMapping.primaryKeyAttribute=@"invitation_id";
    [invitationMapping mapKeyPathsToAttributes:@"id", @"invitation_id",
     @"rsvp_status", @"rsvp_status", 
     @"via", @"via", 
     @"updated_at", @"updated_at", 
     @"created_at", @"created_at",
     nil];
    [invitationMapping mapRelationship:@"identity" withMapping:identityMapping];
    [invitationMapping mapRelationship:@"by_identity" withMapping:identityMapping];

    RKManagedObjectMapping* exfeeMapping = [RKManagedObjectMapping mappingForEntityWithName:@"Exfee" inManagedObjectStore:manager.objectStore];
    exfeeMapping.primaryKeyAttribute=@"exfee_id";
    [exfeeMapping mapKeyPathsToAttributes:@"id", @"exfee_id",
     nil];
    [exfeeMapping mapRelationship:@"invitations" withMapping:invitationMapping];
    
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
     nil];
    [crossMapping mapRelationship:@"by_identity" withMapping:identityMapping];
    [crossMapping mapRelationship:@"host_identity" withMapping:identityMapping];
    [crossMapping mapRelationship:@"place" withMapping:placeMapping];
    [crossMapping mapRelationship:@"exfee" withMapping:exfeeMapping];
    [crossMapping mapRelationship:@"time" withMapping:crosstimeMapping];
    
    [manager.mappingProvider setObjectMapping:crossMapping forKeyPath:@"response.crosses"];
    [manager.mappingProvider setObjectMapping:crossMapping forKeyPath:@"response.cross"];

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
//    AppDelegate *app=(AppDelegate *)[[UIApplication sharedApplication] delegate];
//    RKObjectManager* manager =[RKObjectManager sharedManager];
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
     
+(void) LoadCrossWithUserId:(int)userid updatedtime:(NSString*)updatedtime delegate:(id)delegate  source:(NSString*)source{
    AppDelegate *app=(AppDelegate *)[[UIApplication sharedApplication] delegate];
    if(updatedtime!=nil && ![updatedtime isEqualToString:@""])
        updatedtime=[Util encodeToPercentEscapeString:updatedtime];

    NSString *endpoint = [NSString stringWithFormat:@"/users/%u/crosses?updated_at=%@&token=%@",app.userid,updatedtime,app.accesstoken];
    RKObjectManager* manager =[RKObjectManager sharedManager];
        RKObjectLoader *loader = [manager loaderWithResourcePath:endpoint];
        loader.delegate = delegate;
        loader.method = RKRequestMethodGET;
        loader.userData=source;
    	[loader send];
}

@end
