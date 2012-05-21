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
    [manager.mappingProvider setObjectMapping:identityMapping forKeyPath:@"response.cross.by_identity"];
    [manager.mappingProvider setObjectMapping:identityMapping forKeyPath:@"response.cross.host_identity"];
    
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
    [manager.mappingProvider setObjectMapping:placeMapping forKeyPath:@"response.cross.place"];
    NSString *endpoint = @"/crosses/100209?token=98eddc9c0afc48087f722ca1419c8650";                           

    [manager loadObjectsAtResourcePath:endpoint delegate:self];

    endpoint = @"/crosses/100183?token=98eddc9c0afc48087f722ca1419c8650";                           
    
    [manager loadObjectsAtResourcePath:endpoint delegate:self];

//    RKObjectMapping *metaMapping = [RKObjectMapping mappingForClass:[Meta class]];
//    [metaMapping mapAttributes:@"code", nil];
//    RKManagedObjectStore* objectStore = [RKManagedObjectStore objectStoreWithStoreFilename:@"MyApp.sqlite"];
    
//    manager.objectStore = objectStore;
//    NSString *seedDatabaseName = RKDefaultSeedDatabaseFileName;
//    NSString *databaseName = @"RKExfeData.sqlite";
//    
//    manager.objectStore = [RKManagedObjectStore objectStoreWithStoreFilename:databaseName usingSeedDatabaseName:seedDatabaseName managedObjectModel:nil delegate:self];
//    RKManagedObjectStore* objectStore = [RKManagedObjectStore objectStoreWithStoreFilename:@"MyApp.sqlite"];
//    manager.objectStore= [RKManagedObjectStore objectStoreWithStoreFilename:@"MyApp.sqlite"];
    
    //????
//    NSEntityDescription *entity=[Identity entity];
    
//    RKManagedObjectMapping *identityMapping =[RKManagedObjectMapping mappingForEntity:[Identity entity] inManagedObjectStore:manager.objectStore];
//    RKManagedObjectMapping *identityMapping =[RKManagedObjectMapping mappingForClass:[Identity class] inManagedObjectStore: manager.objectStore];
//    RKManagedObjectMapping* statusMapping = [RKManagedObjectMapping mappingForClass:[RKTStatus class] inManagedObjectStore:objectManager.objectStore];

    
    //[RKManagedObjectMapping mappingForClass:[Identity class] ];
//    
//    RKObjectMapping *placeMapping = [RKObjectMapping mappingForClass:[Place class]];
//    [placeMapping mapKeyPathsToAttributes:@"id", @"id",
//     @"description", @"description", 
//     @"external_id", @"external_id", 
//     @"lat", @"lat", 
//     @"lng", @"lng",
//     @"title", @"title", 
//     @"provider", @"provider",
//     @"created_at", @"created_at", 
//     @"updated_at", @"updated_at", 
//     nil];
//    
//    RKObjectMapping *crossMapping = [RKObjectMapping mappingForClass:[Cross class]];
//    [crossMapping mapKeyPath:@"id" toAttribute:@"id"];
//    [crossMapping mapKeyPath:@"id_base62" toAttribute:@"id_base62"];
//    [crossMapping mapKeyPath:@"title" toAttribute:@"title"];
//    [crossMapping mapKeyPath:@"description" toAttribute:@"description"];
//    [crossMapping mapKeyPath:@"created_at" toAttribute:@"created_at"];
//    [crossMapping mapKeyPath:@"by_identity" toRelationship:@"by_identity" withMapping:identityMapping];
//    [crossMapping mapKeyPath:@"host_identity" toRelationship:@"host_identity" withMapping:identityMapping];
//    [crossMapping mapKeyPath:@"place" toRelationship:@"place" withMapping:placeMapping];

    
    
//    RKObjectManager* objectManager = [RKObjectManager objectManagerWithBaseURL:@"http://restkit.org"];
//    RKManagedObjectStore* objectStore = [RKManagedObjectStore objectStoreWithStoreFilename:@"MyApp.sqlite"];
//    objectManager.objectStore = objectStore;
    
    
//    NSString *endpoint = @"/crosses/100183?token=98eddc9c0afc48087f722ca1419c8650";                           
//    NSString *endpoint = @"/users/131/crosses?updated_at=2012-05-01%2009:40:26&token=98eddc9c0afc48087f722ca1419c8650";

//    [manager.mappingProvider setMapping:crossMapping forKeyPath:@"response.crosses"];
//    [manager.mappingProvider setObjectMapping:identityMapping forKeyPath:@"response.cross.by_identity"];
//    [manager loadObjectsAtResourcePath:endpoint delegate:self];
    
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
