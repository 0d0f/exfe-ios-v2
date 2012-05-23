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
+(void) LoadCrossWithUserId:(int)userid updatetime:(NSString*)updatetime delegate:(id)delegate;
@end
