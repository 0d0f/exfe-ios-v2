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


@property (nonatomic, retain, readwrite) NSManagedObjectContext *   exfeContext;
@property (nonatomic, assign, readonly) NSInteger                   userId;
@property (nonatomic, retain, readwrite) NSString *                 userToken;
@property (nonatomic, retain, readonly) NSMutableDictionary *       userConfig;
@property (nonatomic, retain, readonly) RKObjectManager *           objectManager;
@property (nonatomic, retain, readonly) EFAPIServer *               apiServer;

#pragma mark Token and User ID manager

- (void)saveUserData;
- (void)loaduserData;
- (void)clearUserData;
- (BOOL)isLoggedIn;

#pragma mark ---
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
