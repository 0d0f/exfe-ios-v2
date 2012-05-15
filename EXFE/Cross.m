//
//  Cross.m
//  EXFE
//
//  Created by ju huo on 5/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Cross.h"

@implementation Cross
@synthesize id = _id;
@synthesize id_base62=_id_base62;
@synthesize title=_title;
@synthesize description=_description;
@synthesize created_at=_created_at;
@synthesize by_identity=_by_identity;
@synthesize host_identity=_host_identity;
@synthesize place=_place;

- (void)dealloc {
    [_id release];
    [_id_base62 release];
    [_title release];
    [_description release];
    [_created_at release];
    [_by_identity release];
    [_host_identity release];
    [_place release];
    [super dealloc];
}

@end
