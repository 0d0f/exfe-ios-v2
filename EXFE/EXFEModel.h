//
//  EXFEModel.h
//  EXFE
//
//  Created by Stony Wang on 13-6-13.
//
//

#import <Foundation/Foundation.h>
#import "EXFEContext.h"

@interface EXFEModel : NSObject{
    NSUInteger                      _sequenceNumber;
}

#pragma mark * Start up and shut down

+ (void)applicationStartup;
// Called by the application delegate at startup time.  This takes care of
// various bits of bookkeeping, including resetting the cache of photos
// if that debugging option has been set.

- (id)init;


@property (nonatomic, retain, readwrite) EXFEContext *              exfeContext;

- (void)start;
// Starts up the gallery (finds or creates a cache database and kicks off the initial
// sync).

- (void)save;
- (void)stop;

#pragma mark * Core Data accessors
@property (nonatomic, retain, readonly ) NSManagedObjectContext *   managedObjectContext;       // observable
@property (nonatomic, retain, readonly ) NSEntityDescription *      crossEntry;
@property (nonatomic, retain, readonly ) NSEntityDescription *      exfeeEntry;





@end
