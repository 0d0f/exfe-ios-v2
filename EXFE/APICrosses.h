//
//  APICross.h
//  EXFE
//
//  Created by ju huo on 5/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RestKit.h"
#import "AppDelegate.h"

@interface APICrosses : NSObject 
+(void) MappingCross;
+(void) LoadCrossWithUserId:(int)userid updatedtime:(NSString*)updatedtime delegate:(id)delegate source:(NSString*)source;
@end
