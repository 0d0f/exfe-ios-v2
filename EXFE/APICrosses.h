//
//  APICross.h
//  EXFE
//
//  Created by ju huo on 5/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RestKit/RestKit.h>
#import "AppDelegate.h"
#import "Cross.h"
#import "Invitation.h"
#import "Exfee.h"
#import "Meta.h"

@interface APICrosses : NSObject {
//  RKRequestQueue *queue;
}
//+ (id) sharedManager;
+(void) MappingCross;
+(void) MappingRoute;
+(void) LoadCrossWithUserId:(int)userid updatedtime:(NSString*)updatedtime delegate:(id)delegate source:(NSDictionary*)source;
+(void) LoadCrossWithCrossId:(int)corss_id updatedtime:(NSString*)updatedtime delegate:(id)delegate source:(NSDictionary*)source;
+(void) GatherCross:(Cross*) cross delegate:(id)delegate;

//RESTKIT0.2
//+ (RKManagedObjectMapping*) getPlaceMapping;
//+ (RKManagedObjectMapping*) getInvitationMapping;
//+ (RKManagedObjectMapping*) getCrossMapping;
//+ (RKManagedObjectMapping*) getExfeeMapping;

@end
