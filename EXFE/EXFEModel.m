//
//  EXFEModel.m
//  EXFE
//
//  Created by Stony Wang on 13-6-13.
//
//

#import "EXFEModel.h"
#import <RestKit/RestKit.h>

#import "EFAPI.h"
#import "RecursiveDeleteOperation.h"
#import "ModelMapping.h"
#import "AFHTTPClient.h"

@interface EXFEModel ()

// read/write variants of public properties
@property (nonatomic, assign, readwrite) NSInteger                  userId;

@property (nonatomic, strong, readwrite) NSEntityDescription *      crossEntry;
@property (nonatomic, strong, readwrite) NSEntityDescription *      exfeeEntry;
@property (nonatomic, strong, readwrite) RKObjectManager *           objectManager;
@property (nonatomic, strong, readwrite) EFAPIServer *               apiServer;

// private properties
@property (nonatomic, assign, readonly ) NSUInteger                 sequenceNumber;
@property (nonatomic, strong, readwrite) NSTimer *                  saveTimer;

@end

@implementation EXFEModel

// Then, within each user directory, there are the following items:
//
// o kInfoFileName is the name of a plist file within the user folder.  If this is missing,
//   the folder has been abandoned (and can be removed at the next startup time).
//
// o kDatabaseFileName is the name of the Core Data file that holds the data
//   model objects.

static NSString * kInfoFileName        = @"exfeInfo.plist";
static NSString * kDatabaseFileName    = @"user.sqlite";
static NSString * kDefaultNameTemplate = @"default.%@";
static NSString * kNameTemplate        = @"user_%i.%@";
static NSString * kExtension           = @"exfe";
//static NSString * kPhotosDirectoryName = @"images";

+ (NSString *)cachesDirectoryPath
// Returns the path to the caches directory.  This is a class method because it's
// used by +applicationStartup.
{
    NSString *      result;
    NSArray *       paths;
    
    result = nil;
    paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    if ( (paths != nil) && ([paths count] != 0) ) {
        assert([[paths objectAtIndex:0] isKindOfClass:[NSString class]]);
        result = [paths objectAtIndex:0];
    }
    return result;
}

+ (NSString *)appSupportDirectoryPath
{
    NSString *      result;
    NSArray *       paths;
    
    result = nil;
    paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
    if ( (paths != nil) && ([paths count] != 0) ) {
        assert([[paths objectAtIndex:0] isKindOfClass:[NSString class]]);
        result = [paths objectAtIndex:0];
    }
    return result;
}

+ (NSString *)exfeUserDirectoryPath
{
    return [[self appSupportDirectoryPath] stringByAppendingPathComponent:@"users"];
}

+ (void)abandonUserCacheAtPath:(NSString *)userPath
{
    (void) [[NSFileManager defaultManager] removeItemAtPath:[userPath stringByAppendingPathComponent:kInfoFileName] error:NULL];
}

+ (void)applicationStartup
// See comment in header.
{
    NSUserDefaults *    userDefaults;
    NSFileManager *     fileManager;
    BOOL                clearAllCaches;
    NSString *          usersDirectoryPath;
    NSArray *           potentialUserPathNames;
    NSMutableArray *    deletableUserPaths;
    NSMutableArray *    liveUserCachePathsAndDates;
    
    fileManager = [NSFileManager defaultManager];
    assert(fileManager != nil);
    
    userDefaults = [NSUserDefaults standardUserDefaults];
    assert(userDefaults != nil);
    
    usersDirectoryPath = [self exfeUserDirectoryPath];
    assert(usersDirectoryPath != nil);
    BOOL isDir  = NO;
    if(![fileManager fileExistsAtPath:usersDirectoryPath isDirectory:&isDir]){
        if(![fileManager createDirectoryAtPath:usersDirectoryPath withIntermediateDirectories:YES attributes:nil error:NULL]){
//            NSLog(@"Error: Create folder failed %@", usersDirectoryPath);
        } else {
//            NSLog(@"OK: Created folder %@", usersDirectoryPath);
        }
    }
    
    
    // Check if need clean up all users' folder
    clearAllCaches = [userDefaults boolForKey:@"userClerCache"];
    if (clearAllCaches) {
        // reset flag
        [userDefaults removeObjectForKey:@"userClerCache"];
        [userDefaults synchronize];
    }
    
    deletableUserPaths = [NSMutableArray array];
    assert(deletableUserPaths != nil);
    
    potentialUserPathNames = [fileManager contentsOfDirectoryAtPath:usersDirectoryPath error:NULL];
    assert(potentialUserPathNames != nil);
    
    liveUserCachePathsAndDates = [NSMutableArray array];
    assert(liveUserCachePathsAndDates != nil);
    
    // Delete abandon users' folder, store live folder
    for (NSString * userPathName in potentialUserPathNames) {
        if ([userPathName hasSuffix:kExtension]) {
            NSString *      userCachePath;
            NSString *      userInfoFilePath;
            NSString *      userDatabaseFilePath;
            
            userCachePath = [usersDirectoryPath stringByAppendingPathComponent:userPathName];
            assert(userCachePath != nil);
            
            userInfoFilePath = [userCachePath stringByAppendingPathComponent:kInfoFileName];
            assert(userInfoFilePath != nil);
            
            userDatabaseFilePath = [userCachePath stringByAppendingPathComponent:kDatabaseFileName];
            assert(userDatabaseFilePath != nil);
            
            if (clearAllCaches) {
//                [[QLog log] logWithFormat:@"gallery clear '%@'", galleryCacheName];
                (void) [fileManager removeItemAtPath:userInfoFilePath error:NULL];
                [deletableUserPaths addObject:userCachePath];
            } else if ( ! [fileManager fileExistsAtPath:userInfoFilePath]) {
//                [[QLog log] logWithFormat:@"gallery delete abandoned '%@'", galleryCacheName];
                [deletableUserPaths addObject:userCachePath];
            } else {
                NSDate *    modDate;
                
                // This gallery cache isn't abandoned.  Get the modification date of its database.  If
                // that fails, the gallery cache is toast, so just add it to the to-delete list.
                // If that succeeds, add a dictionary containing the gallery cache path and the
                // mod date to the list of live gallery caches.
                
                modDate = [[fileManager attributesOfItemAtPath:userDatabaseFilePath error:NULL] objectForKey:NSFileModificationDate];
                if (modDate == nil) {
//                    [[QLog log] logWithFormat:@"gallery delete invalid '%@'", galleryCacheName];
                    [deletableUserPaths addObject:userCachePath];
                } else {
                    assert([modDate isKindOfClass:[NSDate class]]);
                    [liveUserCachePathsAndDates addObject:[NSDictionary dictionaryWithObjectsAndKeys:
                                                              userCachePath,   @"path",
                                                              modDate,            @"modDate",
                                                              nil
                                                              ]];
                }
            }
        }
    }
    
    // Remove old user folders for over limit.
    [liveUserCachePathsAndDates sortUsingDescriptors:[NSArray arrayWithObject:[[NSSortDescriptor alloc] initWithKey:@"modDate" ascending:YES]]];
    while ( [liveUserCachePathsAndDates count] > 3 ) {
        NSString *  path;
        
        path = [[liveUserCachePathsAndDates objectAtIndex:0] objectForKey:@"path"];
        assert([path isKindOfClass:[NSString class]]);
        
//        [[QLog log] logWithFormat:@"gallery abandon and delete '%@'", [path lastPathComponent]];
        
        [self abandonUserCacheAtPath:path];
        [deletableUserPaths addObject:path];
        
        [liveUserCachePathsAndDates removeObjectAtIndex:0];
    }
    
    // Start an operation to delete the targeted gallery caches.  This happens on a
    // thread so that it doesn't prevent the app starting up.  The app will
    // ignore these gallery caches anyway, because we removed their gallery info files.
    // Also, we don't monitor this operation for successful completion.  It
    // just does its stuff and then goes away.  That means that we effectively
    // leak the operation queue.  Not a big deal.  It also means that, if the
    // app quits before the operation is done, it just gets killed.  That's
    // OK too; the delete will pick up where it left off when the app is next
    // relaunched.
    
    if ( [deletableUserPaths count] != 0 ) {
        static NSOperationQueue *   sUserCacheDeleteQueue;
        RecursiveDeleteOperation *  op;
        
        sUserCacheDeleteQueue = [[NSOperationQueue alloc] init];
        assert(sUserCacheDeleteQueue != nil);
        
        op = [[RecursiveDeleteOperation alloc] initWithPaths:deletableUserPaths];
        assert(op != nil);
        
        if ( [op respondsToSelector:@selector(setThreadPriority:)] ) {
            [op setThreadPriority:0.1];
        }
        
        [sUserCacheDeleteQueue addOperation:op];
    }
}

- (id)initWithUser:(NSInteger)user_id
{
    
    // The initialisation method is very simple.  All of the heavy lifting is done
    // in -start.
    
    self = [super init];
    if (self != nil) {
        static NSUInteger sNextGallerySequenceNumber;
        
        self->_userId = user_id;
        self->_sequenceNumber = sNextGallerySequenceNumber;
        sNextGallerySequenceNumber += 1;

        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
        
//        [[QLog log] logWithFormat:@"gallery %zu is %@", (size_t) self->_sequenceNumber, galleryURLString];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
    
    // We should have been stopped before being released, so these properties
    // should be nil by the time -dealloc is called.
    assert(self->_exfeContext == nil);
    assert(self->_crossEntry == nil);
    assert(self->_saveTimer == nil);
    
}

@synthesize sequenceNumber   = _sequenceNumber;


#pragma mark Token and User ID manager

- (void)saveUserData
{
    NSUserDefaults * ud = [NSUserDefaults standardUserDefaults];
    [ud setObject:self.userToken forKey:@"access_token"];
    [ud setObject:[NSString stringWithFormat:@"%i",self.userId] forKey:@"userid"];
    [ud synchronize];
}

- (void)loadUserData
{
    NSUserDefaults * ud = [NSUserDefaults standardUserDefaults];
    [ud synchronize];
    self.userToken = [ud stringForKey:@"access_token"];
    self.userId = [[ud stringForKey:@"userid"] integerValue];
}

- (void)clearUserData
{
    self.userId = 0;
    self.userToken = @"";
    NSUserDefaults * ud = [NSUserDefaults standardUserDefaults];
    [ud removeObjectForKey:@"access_token"];
    [ud removeObjectForKey:@"userid"];
    [ud synchronize];
}

- (BOOL)isLoggedIn
{
    if (self.userId > 0 && self.userToken.length > 0) {
        return YES;
    }
    [self loadUserData];
    if (self.userId > 0 && self.userToken.length > 0) {
        return YES;
    }
    return NO;
}

- (void)didBecomeActive:(NSNotification *)note
{
#pragma unused(note)
    
    // Having the ability to sync on activate makes it easy to test various cases where
    // you want to force a sync in a weird context (like when the PhotoDetailViewController
    // is up).
    
    if ( [[NSUserDefaults standardUserDefaults] boolForKey:@"gallerySyncOnActivate"] ) {
        if (self.exfeContext != nil) {
//            [self startSync];
        }
    }
}

#pragma mark * Core Data wrangling

@synthesize exfeContext = _exfeContext;

+ (NSSet *)keyPathsForValuesAffectingManagedObjectContext
{
    return [NSSet setWithObject:@"galleryContext"];
}

- (NSManagedObjectContext *)managedObjectContext
{
    return self.exfeContext;
}

- (NSEntityDescription *)crossEntry
{
    if (self->_crossEntry == nil) {
        assert(self.exfeContext != nil);
        self->_crossEntry = [NSEntityDescription entityForName:@"Cross" inManagedObjectContext:self.exfeContext];
        assert(self->_crossEntry != nil);
    }
    return self->_crossEntry;
}

@synthesize crossEntry = _crossEntry;

- (NSFetchRequest *)crossesFetchRequest
// Returns a fetch request that gets all of the photos in the database.
{
    NSFetchRequest *    fetchRequest;
    
    fetchRequest = [[NSFetchRequest alloc] init];
    assert(fetchRequest != nil);
    
    [fetchRequest setEntity:self.crossEntry];
    [fetchRequest setFetchBatchSize:20];
    
    return fetchRequest;
}

- (void)abandonCachePath
{
    NSString *cachePath = [self userPath];
//    assert(cachePath != nil);
    [[self class] abandonUserCacheAtPath:cachePath];
}

- (NSString *)userPath
{
    if (self.userId == 0) {
        return [[EXFEModel exfeUserDirectoryPath] stringByAppendingPathComponent: [NSString stringWithFormat:kDefaultNameTemplate, kExtension]];
    }
    return [[EXFEModel exfeUserDirectoryPath] stringByAppendingPathComponent: [NSString stringWithFormat:kNameTemplate, self.userId, kExtension]];
}

- (BOOL)setupContext
{
    BOOL                            success;
    NSError *                       error;
    NSFileManager *                 fileManager;
    NSString *                      userDirectoryPath;
//    NSString *                      plistURL;
//    BOOL                            isDir;
    NSString *                      databasePath;
    NSURL *                         databaseURL;
    NSManagedObjectModel *          model;
    
    
//    [[QLog log] logWithFormat:@"gallery %zu starting", (size_t) self.sequenceNumber];
    
    error = nil;
    
    fileManager = [NSFileManager defaultManager];
    assert(fileManager != nil);
    
    userDirectoryPath = [self userPath];
    success = (userDirectoryPath != nil);
    
    
    // Start up Core Data in the user directory.
    if (success) {
        
        model = [NSManagedObjectModel mergedModelFromBundles:nil];
        success = (model != nil);
    }
    
    if (success) {
        databasePath = [userDirectoryPath stringByAppendingPathComponent:kDatabaseFileName];
        databaseURL = [NSURL fileURLWithPath:databasePath];
        assert(databaseURL != nil);
        
        NSFileManager *fileManager= [NSFileManager defaultManager];
        BOOL isDir  = NO;
        NSString *plistPath = [userDirectoryPath stringByAppendingPathComponent:kInfoFileName];
        if(![fileManager fileExistsAtPath:userDirectoryPath isDirectory:&isDir]){
            if(![fileManager createDirectoryAtPath:userDirectoryPath withIntermediateDirectories:YES attributes:nil error:NULL]){
                //                NSLog(@"Error: Create folder failed %@", userDirectoryPath);
                return NO;
            }
        }
        
        if (self.userId > 0 ) {
            
            if (![fileManager fileExistsAtPath:plistPath isDirectory:&isDir]) {
                // create exfeInfo.plist to prevent abandon
                NSMutableDictionary *exfeInfo = [NSMutableDictionary dictionary];
                [exfeInfo setValue:[NSString stringWithFormat:@"%u", self.userId] forKey:@"user_id"];
                [exfeInfo setObject:[NSNumber numberWithInt:APP_DB_VERSION] forKey:@"db_version"];
                [exfeInfo writeToFile:plistPath atomically:YES];
                
                NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
                [ud removeObjectForKey:@"exfee_updated_at"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                // remove db
                NSError *error = nil;
                if ([fileManager removeItemAtPath:databasePath error:&error]) {
                    
                } else {
                    // error;
                }
            }
            
            // check if need upgrade db
            NSMutableDictionary *exfeInfo = [NSMutableDictionary dictionaryWithContentsOfFile:plistPath];
            NSNumber *app_db_version = [exfeInfo objectForKey:@"db_version"];
            if (app_db_version == nil || [app_db_version intValue] < APP_DB_VERSION) {
                // upgrade db: simple way (delete it)
                NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
                [ud removeObjectForKey:@"exfee_updated_at"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                NSError *error = nil;
                if ([fileManager removeItemAtPath:databasePath error:&error]) {
                    [exfeInfo setObject:[NSNumber numberWithInt:APP_DB_VERSION] forKey:@"db_version"];
                    [exfeInfo writeToFile:plistPath atomically:YES];
                } else {
                    // error;
                }
            } else {
//                NSLog(@"normal start up");
            }
        } else {
            // remove db for default user
            NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
            [ud removeObjectForKey:@"exfee_updated_at"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            NSError *error = nil;
            if ([fileManager removeItemAtPath:databasePath error:&error]) {
                
                
            } else {
                // error;
            }
        }
        
    }
    
    
    if (success) {
        
        NSURL *baseURL = [NSURL URLWithString:API_ROOT];
        RKObjectManager *objectManager = [RKObjectManager managerWithBaseURL:baseURL];
        
        RKManagedObjectStore *managedObjectStore = [[RKManagedObjectStore alloc] initWithManagedObjectModel:model];
        objectManager.managedObjectStore = managedObjectStore;
        [managedObjectStore createPersistentStoreCoordinator];
        
        NSError *error;
        NSPersistentStore *persistentStore = [managedObjectStore addSQLitePersistentStoreAtPath:databasePath fromSeedDatabaseAtPath:nil withConfiguration:nil options:nil error:&error];
        NSAssert(persistentStore, @"Failed to add persistent store with error: %@", error);
        
        // Create the managed object contexts
        [managedObjectStore createManagedObjectContexts];
        
        self.objectManager = objectManager;
        [RKObjectManager setSharedManager:objectManager];
        self.exfeContext = managedObjectStore.persistentStoreManagedObjectContext;
        self.apiServer = [[EFAPIServer alloc] initWithModel:self];
        
        
        
        // Configure a managed object cache to ensure we do not create duplicate objects
        managedObjectStore.managedObjectCache = [[RKInMemoryManagedObjectCache alloc] initWithManagedObjectContext:managedObjectStore.persistentStoreManagedObjectContext];
        
        NSArray *descriptors = objectManager.requestDescriptors;
        if(descriptors==nil || [descriptors count]==0) {
            [ModelMapping buildMapping];
        }
        
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(networkChanged:) name:AFNetworkingReachabilityDidChangeNotification object:self];
        
        // Subscribe to the context changed notification so that we can auto-save.
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(contextChanged:) name:NSManagedObjectContextObjectsDidChangeNotification object:self.managedObjectContext];
        
//        [[QLog log] logWithFormat:@"gallery %zu started '%@'", (size_t) self.sequenceNumber, [self.galleryCachePath lastPathComponent]];
    } else {
        
        // Bad things happened.  Log the error and return NO.
        
        if (error == nil) {
//            [[QLog log] logWithFormat:@"gallery %zu start error", (size_t) self.sequenceNumber];
        } else {
//            [[QLog log] logWithFormat:@"gallery %zu start error %@", (size_t) self.sequenceNumber, error];
        }
        
        // Also, if we found or created a gallery cache but failed to start up in it, abandon it in
        // the hope that our next attempt will work better.
        
        if (userDirectoryPath != nil) {
            [self abandonCachePath];
        }
    }
    return success;
}

//- (void)networkChanged:(NSNotification *)note
//{
//    NSString *name = notificaiton.name;
//    
//    if ([name isEqualToString:AFNetworkingReachabilityDidChangeNotification]) {
//        NSDictionary *userInfo = notificaiton.userInfo;
//        NSNumber *status = [userInfo valueForKey:AFNetworkingReachabilityNotificationStatusItem];
//        NSUInteger *state = [status integerValue];
//        if ((state + 1) / 2 > 0) {
//            // Network ok
//        } else {
//            // Network unreachable
//        }
//        
//    }
//}

- (void)start
// See comment in header.
{
    BOOL                success;
    
    
    // Try to start up.  If this fails, it abandons the gallery cache, so a retry
    // on our part is warranted.
    
    success = [self setupContext];
    if ( ! success ) {
        success = [self setupContext];
    }
    
    // If all went well, start the syncing processing.  If not, the application is dead
    // and we crash.
    
    if (success) {
//        [self startSync];
    } else {
        abort();
    }
}

@synthesize saveTimer = _saveTimer;

- (void)save
// See comment in header.
{
    NSError *       error;
    
    error = nil;
    
    // Disable the auto-save timer.
    
    [self.saveTimer invalidate];
    self.saveTimer = nil;
    
    // Save.
    
    if ( (self.exfeContext != nil) && [self.exfeContext hasChanges] ) {
        BOOL        success;
        
        success = [self.exfeContext save:&error];
        if (success) {
            error = nil;
        }
    }
    
    // Log the results.
    
    if (error == nil) {
//        [[QLog log] logWithFormat:@"gallery %zu saved", (size_t) self.sequenceNumber];
    } else {
//        [[QLog log] logWithFormat:@"gallery %zu save error %@", (size_t) self.sequenceNumber, error];
    }
}

- (void)contextChanged:(NSNotification *)note
// Called when the managed object context changes (courtesy of the
// NSManagedObjectContextObjectsDidChangeNotification notification).  We start an
// auto-save timer to fire in 5 seconds.  This means that rapid-fire changes don't
// cause a flood of saves.
{
#pragma unused(note)
    if (self.saveTimer != nil) {
        [self.saveTimer invalidate];
    }
    self.saveTimer = [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(save) userInfo:nil repeats:NO];
}

- (void)stop
// See comment in header.
//
// Shuts down our access to the gallery cache.  We do this in two situations:
//
// o When the user switches gallery.
// o When the application terminates.
{
//    [self stopSync];
    
    // Shut down the managed object context.
    
    if (self.exfeContext != nil) {
        
        // Shut down the auto save mechanism and then force a save.
        
        [[NSNotificationCenter defaultCenter] removeObserver:self name:NSManagedObjectContextObjectsDidChangeNotification object:self.exfeContext];
        
        [self save];
        
        self.crossEntry = nil;
        self.exfeContext = nil;
    }
//    [[QLog log] logWithFormat:@"gallery %zu stopped", (size_t) self.sequenceNumber];
}

@end
