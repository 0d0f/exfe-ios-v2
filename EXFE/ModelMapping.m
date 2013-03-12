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
  
  RKEntityMapping *eftimeMapping = [RKEntityMapping mappingForEntityForName:@"EFTime" inManagedObjectStore:managedObjectStore];
  [eftimeMapping addAttributeMappingsFromArray:@[@"date",@"date_word",@"time",@"time_word",@"timezone"]];

  RKEntityMapping *crosstimeMapping = [RKEntityMapping mappingForEntityForName:@"CrossTime" inManagedObjectStore:managedObjectStore];
  [crosstimeMapping addAttributeMappingsFromArray:@[@"origin",@"outputformat"]];
  [crosstimeMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"begin_at" toKeyPath:@"begin_at" withMapping:eftimeMapping]];
  
  RKEntityMapping *placeMapping = [RKEntityMapping mappingForEntityForName:@"Place" inManagedObjectStore:managedObjectStore];
  placeMapping.identificationAttributes = @[ @"place_id" ];
  [placeMapping addAttributeMappingsFromDictionary:@{@"id": @"place_id",
   @"description": @"place_description"}];
  [placeMapping addAttributeMappingsFromArray:@[@"title",@"lat",@"lng",@"provider",@"external_id",@"created_at",@"updated_at",@"type"]];

  RKEntityMapping *crossMapping = [RKEntityMapping mappingForEntityForName:@"Cross" inManagedObjectStore:managedObjectStore];
  crossMapping.identificationAttributes = @[ @"cross_id" ];
  [crossMapping addAttributeMappingsFromDictionary:@{@"id": @"cross_id",
   @"description": @"cross_description",
   @"id_base62": @"crossid_base62"}];
  [crossMapping addAttributeMappingsFromArray:@[@"title",@"created_at",@"updated",@"widget",@"updated_at",@"conversation_count"]];
  [crossMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"exfee" toKeyPath:@"exfee" withMapping:exfeeMapping]];
  [crossMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"time" toKeyPath:@"time" withMapping:crosstimeMapping]];
  [crossMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"place" toKeyPath:@"place" withMapping:placeMapping]];
  
  RKEntityMapping *conversationMapping = [RKEntityMapping mappingForEntityForName:@"Post" inManagedObjectStore:managedObjectStore];
  conversationMapping.identificationAttributes = @[ @"post_id" ];
  [conversationMapping addAttributeMappingsFromDictionary:@{@"id": @"post_id"}];
  [conversationMapping addAttributeMappingsFromArray:@[@"content",@"created_at",@"updated_at",@"postable_id",@"postable_type"]];
  [conversationMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"by_identity" toKeyPath:@"by_identity" withMapping:identityMapping]];

  RKResponseDescriptor *crossesresponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:crossMapping pathPattern:nil keyPath:@"response.crosses" statusCodes:nil];
  [objectManager addResponseDescriptor:crossesresponseDescriptor];
  
  RKResponseDescriptor *crossresponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:crossMapping pathPattern:nil keyPath:@"response.cross" statusCodes:nil];
  [objectManager addResponseDescriptor:crossresponseDescriptor];
  
  RKResponseDescriptor *conversationresponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:conversationMapping pathPattern:nil keyPath:@"response.conversation" statusCodes:nil];
  [objectManager addResponseDescriptor:conversationresponseDescriptor];
}
@end