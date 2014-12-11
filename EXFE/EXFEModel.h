//
//  EXFEModel.h
//  EXFE
//
//  Created by Stony Wang on 13-6-13.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import <RestKit/RestKit.h>

@class EFAPIServer;

@interface EXFEModel : NSObject{
    NSUInteger                      _sequenceNumber;
}

#pragma mark * Start up and shut down

+ (void)applicationStartup;
// Called by the application delegate at startup time.  This takes care of
// various bits of bookkeeping, including resetting the cache of photos
// if that debugging option has been set.

- (id)initWithUser:(NSInteger)user_id;
- (void)abandonCachePath;


@property (nonatomic, strong, readwrite) NSManagedObjectContext *   exfeContext;
@property (nonatomic, assign, readonly) NSInteger                   userId;
@property (nonatomic, strong, readwrite) NSString *                 userToken;
@property (nonatomic, strong, readonly) NSMutableDictionary *       userConfig;
@property (nonatomic, strong, readonly) RKObjectManager *           objectManager;
@property (nonatomic, strong, readonly) EFAPIServer *               apiServer;

#pragma mark Token and User ID manager

- (void)saveUserData;
- (void)loadUserData;
- (void)clearUserData;
- (BOOL)isLoggedIn;

#pragma mark ---
- (void)start;
// Starts up the gallery (finds or creates a cache database and kicks off the initial
// sync).

- (void)save;
- (void)stop;

#pragma mark * Core Data accessors
@property (nonatomic, strong, readonly ) NSManagedObjectContext *   managedObjectContext;       // observable
@property (nonatomic, strong, readonly ) NSEntityDescription *      crossEntry;
@property (nonatomic, strong, readonly ) NSEntityDescription *      exfeeEntry;

#pragma mark For Cross
@property (nonatomic, strong) NSDate *latestModify;
@property (nonatomic, strong) NSDate *lastQuery;

- (void) clearTimeStamp;


@end
