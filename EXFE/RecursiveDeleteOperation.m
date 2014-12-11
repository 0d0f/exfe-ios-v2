//
//  RecursiveDeleteOperation.m
//  EXFE
//
//  Created by Stony Wang on 13-6-14.
//
//

#import "RecursiveDeleteOperation.h"

@interface RecursiveDeleteOperation ()

// read/write versions of public properties

@property (copy,   readwrite) NSError *     error;

@end

@implementation RecursiveDeleteOperation

- (id)initWithPaths:(NSArray *)paths
// See comment in header.
{
    assert(paths != nil);
    self = [super init];
    if (self != nil) {
        self->_paths = [paths copy];
        assert(self->_paths != nil);
    }
    return self;
}


@synthesize paths = _paths;
@synthesize error = _error;

- (void)main
{
    BOOL                success;
    NSFileManager *     fileManager;
    NSError *           error;
    
    fileManager = [NSFileManager defaultManager];
    assert(fileManager != nil);
    
    success = YES;  // necessary when self.paths is empty, which is a wacky corner case but I decided to allow it
    for (NSString * path in self.paths) {
        success = [fileManager removeItemAtPath:path error:&error];
        if ( ! success ) {
            break;
        }
    }
    
    if ( ! success ) {
        self.error = error;
    }
}


@end
