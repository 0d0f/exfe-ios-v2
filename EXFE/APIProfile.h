//
//  APIProfile.h
//  EXFE
//
//  Created by ju huo on 6/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RestKit/RestKit.h>
#import "AppDelegate.h"


@interface APIProfile : NSObject
+(void) MappingUsers;
+(void) MappingSuggest;
+(void) LoadUsrWithUserId:(int)user_id delegate:(id)delegate;
+(void) LoadSuggest:(NSString*)key delegate:(id)delegate;
@end
