//
//  Place.m
//  EXFE
//
//  Created by ju huo on 5/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Place.h"

@implementation Place
@synthesize id=_id;
@synthesize description=_description;
@synthesize external_id=_external_id;
@synthesize lat=_lat;
@synthesize lng=_lng;
@synthesize title=_title;
@synthesize provider=_provider;
@synthesize updated_at=_updated_at;
@synthesize created_at=_created_at;

- (void)dealloc {
    [_id release];
    [_description release];
    [_external_id release];
    [_lat release];
    [_lng release];
    [_title release];
    [_provider release];
    [_updated_at release];
    [_created_at release];
    [super dealloc];
}

@end
