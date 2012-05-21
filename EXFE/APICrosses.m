//
//  APICross.m
//  EXFE
//
//  Created by ju huo on 5/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "APICrosses.h"
#import "Meta.h"
#import "Cross.h"
#import "Place.h"
#import "Identity.h"

#define API_V2_ROOT @"http://api.local.exfe.com/v2"

@implementation APICrosses
- (void)getCrossById
{    
    
//NSString *endpoint = @"/users/131/crosses?updated_at=2012-05-01%2009:40:26&token=98eddc9c0afc48087f722ca1419c8650";
#ifdef RESTKIT_GENERATE_SEED_DB
    NSString *seedDatabaseName = nil;
    NSString *databaseName = RKDefaultSeedDatabaseFileName;
#else
    NSString *seedDatabaseName = RKDefaultSeedDatabaseFileName;
    NSString *databaseName = @"CoreData.sqlite";
#endif
    RKLogConfigureByName("RestKit/*", RKLogLevelTrace);
    RKObjectManager* manager = [RKObjectManager objectManagerWithBaseURLString:API_V2_ROOT];

    manager.objectStore = [RKManagedObjectStore objectStoreWithStoreFilename:databaseName usingSeedDatabaseName:seedDatabaseName managedObjectModel:nil delegate:self];
    
    RKManagedObjectMapping* identityMapping = [RKManagedObjectMapping mappingForEntityWithName:@"Identity" inManagedObjectStore:manager.objectStore];
    
    identityMapping.primaryKeyAttribute=@"identity_id";
    [identityMapping mapKeyPathsToAttributes:@"id", @"identity_id",
     @"name", @"name", 
     @"nickname", @"nickname",
     @"provider", @"provider", 
     @"external_id", @"external_id", 
     @"external_username", @"external_username", 
     @"connected_user_id", @"connected_user_id",
     @"bio", @"bio", 
     @"avatar_filename", @"avatar_filename",
     @"avatar_updated_at", @"avatar_updated_at", 
     @"created_at", @"created_at", 
     @"updated_at", @"updated_at", 
     nil];
    
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
    
    
    RKManagedObjectMapping* crossMapping = [RKManagedObjectMapping mappingForEntityWithName:@"Cross" inManagedObjectStore:manager.objectStore];
    crossMapping.primaryKeyAttribute=@"cross_id";
    [crossMapping mapKeyPathsToAttributes:@"id", @"cross_id",
     @"title", @"title", 
     @"description", @"cross_description", 
     @"id_base62", @"crossid_base62", 
     @"created_at", @"created_at",
     nil];
    [crossMapping mapRelationship:@"by_identity" withMapping:identityMapping];
    [crossMapping mapRelationship:@"host_identity" withMapping:identityMapping];
    [crossMapping mapRelationship:@"place" withMapping:placeMapping];
    [crossMapping mapRelationship:@"exfee" withMapping:exfeeMapping];
    
    [manager.mappingProvider setObjectMapping:crossMapping forKeyPath:@"response.cross"];
    
    NSString *endpoint = @"/crosses/100209?token=98eddc9c0afc48087f722ca1419c8650";                           

    [manager loadObjectsAtResourcePath:endpoint delegate:self];

    endpoint = @"/crosses/100183?token=98eddc9c0afc48087f722ca1419c8650";                           
    
    [manager loadObjectsAtResourcePath:endpoint delegate:self];

    endpoint = @"/crosses/100203?token=98eddc9c0afc48087f722ca1419c8650";                           
    
    [manager loadObjectsAtResourcePath:endpoint delegate:self];
    
}

- (void)objectLoader:(RKObjectLoader *)objectLoader didLoadObjects:(NSArray *)objects {
    Cross *cross=[objects objectAtIndex:0];
    NSLog(@"load:%@",cross);
//    UsersLogin *result = [objects objectAtIndex:0];
    
//    NSLog(@"Response code=%@, token=[%@], userName=[%@]", [[result meta] code], [result token], [[result user] userName]);
}

- (void)objectLoader:(RKObjectLoader *)objectLoader didFailWithError:(NSError *)error {
    NSLog(@"Error!:%@",error);
}
@end
