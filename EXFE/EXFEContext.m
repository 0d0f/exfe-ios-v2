//
//  EXFEContext.m
//  EXFE
//
//  Created by Stony Wang on 13-6-13.
//
//

#import "EXFEContext.h"

@implementation EXFEContext

- (id)initWithUserPath:(NSString *)userPath
{
    assert(userPath != nil);
    
    self = [super init];
    if (self != nil) {
        self->_userPath = [userPath copy];
    }
    return self;
}

- (void)dealloc
{
    [self->_userPath release];
    [super dealloc];
}

@synthesize userPath = _userPath;


@end
