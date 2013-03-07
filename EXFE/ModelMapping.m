//
//  ModelMapping.m
//  EXFE
//
//  Created by huoju on 3/7/13.
//
//

#import "ModelMapping.h"
#import <RestKit/RestKit.h>

@implementation ModelMapping
+ (void) buildMapping{
  RKObjectManager *objectManager = [RKObjectManager sharedManager];
  
  RKManagedObjectStore *managedObjectStore= objectManager.managedObjectStore;
  RKEntityMapping *metaMapping = [RKEntityMapping mappingForEntityForName:@"Meta" inManagedObjectStore:managedObjectStore];
  [metaMapping addAttributeMappingsFromArray:@[@"code",@"errorDetail",@"errorType"]];
  RKResponseDescriptor *metaresponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:metaMapping pathPattern:nil keyPath:@"meta" statusCodes:nil];
  [objectManager addResponseDescriptor:metaresponseDescriptor];
  
  RKEntityMapping *identityMapping = [RKEntityMapping mappingForEntityForName:@"Identity" inManagedObjectStore:managedObjectStore];
  identityMapping.identificationAttributes = @[ @"identity_id" ];
  [identityMapping addAttributeMappingsFromDictionary:@{@"id": @"identity_id",@"order": @"a_order"}];
  [identityMapping addAttributeMappingsFromArray:@[@"name",@"nickname",@"provider",@"external_id",@"external_username",@"connected_user_id",@"bio",@"avatar_filename",@"avatar_updated_at",@"created_at",@"updated_at",@"type",@"unreachable",@"status"]];
  
  RKEntityMapping *invitationMapping = [RKEntityMapping mappingForEntityForName:@"Invitation" inManagedObjectStore:managedObjectStore];
  invitationMapping.identificationAttributes = @[ @"invitation_id" ];
  [invitationMapping addAttributeMappingsFromDictionary:@{@"id": @"invitation_id"}];
  [invitationMapping addAttributeMappingsFromArray:@[@"rsvp_status",@"host",@"mates",@"via",@"updated_at",@"created_at",@"type"]];
  
  [invitationMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"identity" toKeyPath:@"identity" withMapping:identityMapping]];
  [invitationMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"invited_by" toKeyPath:@"invited_by" withMapping:identityMapping]];
  [invitationMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"updated_by" toKeyPath:@"updated_by" withMapping:identityMapping]];
  
  RKEntityMapping *exfeeMapping = [RKEntityMapping mappingForEntityForName:@"Exfee" inManagedObjectStore:managedObjectStore];
  exfeeMapping.identificationAttributes = @[ @"exfee_id" ];
  [exfeeMapping addAttributeMappingsFromDictionary:@{@"id": @"exfee_id"}];
  [exfeeMapping addAttributeMappingsFromArray:@[@"total",@"accepted",@"type"]];
  [exfeeMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"invitations" toKeyPath:@"invitations" withMapping:invitationMapping]];
  
  RKEntityMapping *userMapping = [RKEntityMapping mappingForEntityForName:@"User" inManagedObjectStore:managedObjectStore];
  userMapping.identificationAttributes = @[ @"user_id" ];
  [userMapping addAttributeMappingsFromDictionary:@{@"id": @"user_id",
   @"avatar_filename": @"avatar_filename",
   @"bio": @"bio",
   @"cross_quantity": @"cross_quantity",
   @"name": @"name",
   @"timezone": @"timezone"}];
  [userMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"identities" toKeyPath:@"identities" withMapping:identityMapping]];
  RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:userMapping pathPattern:nil keyPath:@"response.user" statusCodes:nil];
  [objectManager addResponseDescriptor:responseDescriptor];
  
  RKEntityMapping *crossMapping = [RKEntityMapping mappingForEntityForName:@"Cross" inManagedObjectStore:managedObjectStore];
  crossMapping.identificationAttributes = @[ @"cross_id" ];
  [crossMapping addAttributeMappingsFromDictionary:@{@"id": @"cross_id",
   @"description": @"cross_description",
   @"id_base62": @"crossid_base62"}];
  [crossMapping addAttributeMappingsFromArray:@[@"title",@"created_at",@"updated",@"widget",@"updated_at",@"conversation_count"]];
  [crossMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"exfee" toKeyPath:@"exfee" withMapping:exfeeMapping]];
  
  RKResponseDescriptor *crossesresponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:crossMapping pathPattern:nil keyPath:@"response.crosses" statusCodes:nil];
  [objectManager addResponseDescriptor:crossesresponseDescriptor];
  
  RKResponseDescriptor *crossresponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:crossMapping pathPattern:nil keyPath:@"response.cross" statusCodes:nil];
  [objectManager addResponseDescriptor:crossresponseDescriptor];
}
@end
