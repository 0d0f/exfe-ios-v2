//
//  APIConversation.h
//  EXFE
//
//  Created by ju huo on 5/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RestKit.h"
#import "AppDelegate.h"

@interface APIConversation : NSObject
+(void) MappingConversation;
+(void) LoadConversationWithExfeeId:(int)userid updatedtime:(NSString*)updatedtime delegate:(id)delegate;

@end
