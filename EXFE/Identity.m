//
//  Identity.m
//  EXFE
//
//  Created by ju huo on 5/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Identity.h"

@implementation Identity
@synthesize id = _id;
@synthesize name = _name;
@synthesize nickname = _nickname;
@synthesize provider=_provider;
@synthesize external_id=_external_id;
@synthesize external_username=_external_username;
@synthesize connected_user_id=_connected_user_id;
@synthesize bio=_bio;
@synthesize avatar_filename=_avatar_filename;
@synthesize avatar_updated_at=_avatar_updated_at;
@synthesize created_at=_created_at;
@synthesize updated_at=_updated_at;

- (void)dealloc {
    [_id release];
    [_name release];
    [_nickname release];
    [_provider release];
    [_external_id release];
    [_external_username release];
    [_connected_user_id release];
    [_bio release];
    [_avatar_filename release];
    [_avatar_updated_at release];
    [_created_at release];
    [_updated_at release];
    [super dealloc];
}
@end
