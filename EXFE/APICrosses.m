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
    
//    RKObjectMapping *metaMapping = [RKObjectMapping mappingForClass:[Meta class]];
//    [metaMapping mapAttributes:@"code", nil];

    RKObjectMapping *identityMapping = [RKObjectMapping mappingForClass:[Identity class]];
    [identityMapping mapKeyPathsToAttributes:@"id", @"id",
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
    
    RKObjectMapping *placeMapping = [RKObjectMapping mappingForClass:[Place class]];
    [placeMapping mapKeyPathsToAttributes:@"id", @"id",
     @"description", @"description", 
     @"external_id", @"external_id", 
     @"lat", @"lat", 
     @"lng", @"lng",
     @"title", @"title", 
     @"provider", @"provider",
     @"created_at", @"created_at", 
     @"updated_at", @"updated_at", 
     nil];
    
    RKObjectMapping *crossMapping = [RKObjectMapping mappingForClass:[Cross class]];
    [crossMapping mapKeyPath:@"id" toAttribute:@"id"];
    [crossMapping mapKeyPath:@"id_base62" toAttribute:@"id_base62"];
    [crossMapping mapKeyPath:@"title" toAttribute:@"title"];
    [crossMapping mapKeyPath:@"description" toAttribute:@"description"];
    [crossMapping mapKeyPath:@"created_at" toAttribute:@"created_at"];
    [crossMapping mapKeyPath:@"by_identity" toRelationship:@"by_identity" withMapping:identityMapping];
    [crossMapping mapKeyPath:@"host_identity" toRelationship:@"host_identity" withMapping:identityMapping];
    [crossMapping mapKeyPath:@"place" toRelationship:@"place" withMapping:placeMapping];
    
    RKObjectManager* manager = [RKObjectManager managerWithBaseURLString:API_V2_ROOT];

//    NSString *endpoint = @"/crosses/100183?token=98eddc9c0afc48087f722ca1419c8650";                           
    NSString *endpoint = @"/users/131/crosses?updated_at=2012-05-01%2009:40:26&token=98eddc9c0afc48087f722ca1419c8650";

    [manager.mappingProvider setMapping:crossMapping forKeyPath:@"response.crosses"];
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
