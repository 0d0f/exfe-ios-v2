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

@interface APICrosses : NSObject 
+(void) MappingCross;
+(void) MappingRoute;
+(void) LoadCrossWithUserId:(int)userid updatedtime:(NSString*)updatedtime delegate:(id)delegate source:(NSString*)source;
+(void) GatherCross:(Cross*) cross delegate:(id)delegate;
@end