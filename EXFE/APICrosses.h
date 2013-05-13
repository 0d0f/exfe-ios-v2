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
+ (id) sharedManager;

+(void) LoadCrossWithCrossId:(int)corss_id updatedtime:(NSString*)updatedtime success:(void (^)(RKObjectRequestOperation *operation, RKMappingResult *mappingResult))success failure:(void (^)(RKObjectRequestOperation *operation, NSError *error))failure DEPRECATED_ATTRIBUTE_MESSAGE("Use EFAPIServer (Crosses)");


+(void) GatherCross:(Cross*) cross success:(void (^)(RKObjectRequestOperation *operation, RKMappingResult *mappingResult))success failure:(void (^)(RKObjectRequestOperation *operation, NSError *error))failure DEPRECATED_ATTRIBUTE_MESSAGE("Use EFAPIServer (Crosses)");

+(void) EditCross:(Cross*) cross success:(void (^)(RKObjectRequestOperation *operation, RKMappingResult *mappingResult))success failure:(void (^)(RKObjectRequestOperation *operation, NSError *error))failure DEPRECATED_ATTRIBUTE_MESSAGE("Use EFAPIServer (Crosses)");


@end
