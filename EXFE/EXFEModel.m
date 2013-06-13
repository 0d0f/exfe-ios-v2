//
//  EXFEModel.m
//  EXFE
//
//  Created by Stony Wang on 13-6-13.
//
//

#import "EXFEModel.h"

@interface EXFEModel ()

// read/write variants of public properties

@property (nonatomic, retain, readwrite) NSEntityDescription *      crossEntry;
@property (nonatomic, retain, readwrite ) NSEntityDescription *      exfeeEntry;

// private properties
@property (nonatomic, assign, readonly ) NSUInteger                 sequenceNumber;
@property (nonatomic, retain, readwrite) NSTimer *                  saveTimer;

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
static NSString * kNameTemplate = @"user_%.9f.%@";
static NSString * kExtension    = @"exfe";

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
    NSString *          cachesDirectoryPath;
    NSArray *           potentialUserPathNames;
    NSMutableArray *    deletableUserPaths;
    NSMutableArray *    liveGalleryCachePathsAndDates;
    
    fileManager = [NSFileManager defaultManager];
    assert(fileManager != nil);
    
    userDefaults = [NSUserDefaults standardUserDefaults];
    assert(userDefaults != nil);
    
    cachesDirectoryPath = [self cachesDirectoryPath];
    assert(cachesDirectoryPath != nil);
    
    // See if we've been asked to nuke all gallery caches.
    
    clearAllCaches = [userDefaults boolForKey:@"galleryClearCache"];
    if (clearAllCaches) {
//        [[QLog log] logWithFormat:@"gallery clear cache"];
        
        [userDefaults removeObjectForKey:@"galleryClearCache"];
        [userDefaults synchronize];
    }
    
    // Walk the list of gallery caches looking for abandoned ones (or, if we're
    // clearing all caches, do them all).  Add the targeted gallery caches
    // to our list of things to delete.  Also, for any galleries that remain,
    // put the path and the mod date in a list so that we can then find the
    // oldest galleries and delete them.
    
    deletableUserPaths = [NSMutableArray array];
    assert(deletableUserPaths != nil);
    
    potentialUserPathNames = [fileManager contentsOfDirectoryAtPath:cachesDirectoryPath error:NULL];
    assert(potentialUserPathNames != nil);
    
    liveGalleryCachePathsAndDates = [NSMutableArray array];
    assert(liveGalleryCachePathsAndDates != nil);
    
    for (NSString * userPathName in potentialUserPathNames) {
        if ([userPathName hasSuffix:kExtension]) {
            NSString *      galleryCachePath;
            NSString *      galleryInfoFilePath;
            NSString *      galleryDatabaseFilePath;
            
            galleryCachePath = [cachesDirectoryPath stringByAppendingPathComponent:userPathName];
            assert(galleryCachePath != nil);
            
            galleryInfoFilePath = [galleryCachePath stringByAppendingPathComponent:kInfoFileName];
            assert(galleryInfoFilePath != nil);
            
            galleryDatabaseFilePath = [galleryCachePath stringByAppendingPathComponent:kDatabaseFileName];
            assert(galleryDatabaseFilePath != nil);
            
            if (clearAllCaches) {
//                [[QLog log] logWithFormat:@"gallery clear '%@'", galleryCacheName];
                (void) [fileManager removeItemAtPath:galleryInfoFilePath error:NULL];
                [deletableUserPaths addObject:galleryCachePath];
            } else if ( ! [fileManager fileExistsAtPath:galleryInfoFilePath]) {
//                [[QLog log] logWithFormat:@"gallery delete abandoned '%@'", galleryCacheName];
                [deletableUserPaths addObject:galleryCachePath];
            } else {
                NSDate *    modDate;
                
                // This gallery cache isn't abandoned.  Get the modification date of its database.  If
                // that fails, the gallery cache is toast, so just add it to the to-delete list.
                // If that succeeds, add a dictionary containing the gallery cache path and the
                // mod date to the list of live gallery caches.
                
                modDate = [[fileManager attributesOfItemAtPath:galleryDatabaseFilePath error:NULL] objectForKey:NSFileModificationDate];
                if (modDate == nil) {
//                    [[QLog log] logWithFormat:@"gallery delete invalid '%@'", galleryCacheName];
                    [deletableUserPaths addObject:galleryCachePath];
                } else {
                    assert([modDate isKindOfClass:[NSDate class]]);
                    [liveGalleryCachePathsAndDates addObject:[NSDictionary dictionaryWithObjectsAndKeys:
                                                              galleryCachePath,   @"path",
                                                              modDate,            @"modDate",
                                                              nil
                                                              ]];
                }
            }
        }
    }
    
    // See if we've exceeded our gallery cache limit, in which case we keep abandoning the oldest
    // gallery cache until we're under that limit.
    
    [liveGalleryCachePathsAndDates sortUsingDescriptors:[NSArray arrayWithObject:[[[NSSortDescriptor alloc] initWithKey:@"modDate" ascending:YES] autorelease]]];
    while ( [liveGalleryCachePathsAndDates count] > 3 ) {
        NSString *  path;
        
        path = [[liveGalleryCachePathsAndDates objectAtIndex:0] objectForKey:@"path"];
        assert([path isKindOfClass:[NSString class]]);
        
//        [[QLog log] logWithFormat:@"gallery abandon and delete '%@'", [path lastPathComponent]];
        
        [self abandonUserCacheAtPath:path];
        [deletableUserPaths addObject:path];
        
        [liveGalleryCachePathsAndDates removeObjectAtIndex:0];
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
//        static NSOperationQueue *   sGalleryDeleteQueue;
//        RecursiveDeleteOperation *  op;
//        
//        sGalleryDeleteQueue = [[NSOperationQueue alloc] init];
//        assert(sGalleryDeleteQueue != nil);
//        
//        op = [[[RecursiveDeleteOperation alloc] initWithPaths:deletableGalleryCachePaths] autorelease];
//        assert(op != nil);
//        
//        if ( [op respondsToSelector:@selector(setThreadPriority:)] ) {
//            [op setThreadPriority:0.1];
//        }
//        
//        [sGalleryDeleteQueue addOperation:op];
    }
}

- (id)init
{
    
    // The initialisation method is very simple.  All of the heavy lifting is done
    // in -start.
    
    self = [super init];
    if (self != nil) {
        static NSUInteger sNextGallerySequenceNumber;
        
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
    
    [super dealloc];
}

@synthesize sequenceNumber   = _sequenceNumber;

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
        self->_crossEntry = [[NSEntityDescription entityForName:@"Cross" inManagedObjectContext:self.exfeContext] retain];
        assert(self->_crossEntry != nil);
    }
    return self->_crossEntry;
}

@synthesize crossEntry = _crossEntry;

- (NSFetchRequest *)crossesFetchRequest
// Returns a fetch request that gets all of the photos in the database.
{
    NSFetchRequest *    fetchRequest;
    
    fetchRequest = [[[NSFetchRequest alloc] init] autorelease];
    assert(fetchRequest != nil);
    
    [fetchRequest setEntity:self.crossEntry];
    [fetchRequest setFetchBatchSize:20];
    
    return fetchRequest;
}

- (NSString *)galleryCachePathForOurGallery
// Try to find the gallery cache for our gallery URL string.
{
    NSString *          result;
    NSFileManager *     fileManager;
    NSString *          cachesDirectoryPath;
    NSArray *           potentialGalleries;
    NSString *          galleryName;

    
    fileManager = [NSFileManager defaultManager];
    assert(fileManager != nil);
    
    cachesDirectoryPath = [[self class] cachesDirectoryPath];
    assert(cachesDirectoryPath != nil);
    
    // First look through the caches directory for a gallery cache whose info file
    // matches the gallery URL string we're looking for.
    
    potentialGalleries = [fileManager contentsOfDirectoryAtPath:cachesDirectoryPath error:NULL];
    assert(potentialGalleries != nil);
    
    result = nil;
    for (galleryName in potentialGalleries) {

    }
    

    
    return result;
}

- (void)abandonGalleryCacheAtPath:(NSString *)galleryCachePath
// Abandons the specified gallery cache directory.  We do this simply by removing the gallery
// info file.  The directory will be deleted when the application is next launched.
{
    assert(galleryCachePath != nil);
    
//    [[QLog log] logWithFormat:@"gallery %zu abandon '%@'", (size_t) self.sequenceNumber, [galleryCachePath lastPathComponent]];
    
    [[self class] abandonGalleryCacheAtPath:galleryCachePath];
}

- (NSString *)userPath
{
    assert(self.exfeContext != nil);
    return self.exfeContext.userPath;
}

- (BOOL)setupContext
// Attempt to start up the gallery cache for our gallery URL string, either by finding an existing
// cache or by creating one from scratch.  On success, self.galleryCachePath will point to that
// gallery cache and self.galleryContext will be the managed object context for the database
// within the gallery cache.
{
    BOOL                            success;
    NSError *                       error;
    NSFileManager *                 fileManager;
    NSString *                      galleryCachePath;
    NSString *                      photosDirectoryPath;
    BOOL                            isDir;
    NSURL *                         databaseURL;
    NSManagedObjectModel *          model;
    NSPersistentStoreCoordinator *  psc;
    
    
//    [[QLog log] logWithFormat:@"gallery %zu starting", (size_t) self.sequenceNumber];
    
    error = nil;
    
    fileManager = [NSFileManager defaultManager];
    assert(fileManager != nil);
    
    // Find the gallery cache directory for this gallery.
    
    galleryCachePath = [self galleryCachePathForOurGallery];
    success = (galleryCachePath != nil);
    
    // Create the "Photos" directory if it doesn't already exist.
    if (success) {
//        photosDirectoryPath = [galleryCachePath stringByAppendingPathComponent:kPhotosDirectoryName];
//        assert(photosDirectoryPath != nil);
//        
//        success = [fileManager fileExistsAtPath:photosDirectoryPath isDirectory:&isDir] && isDir;
//        if ( ! success ) {
//            success = [fileManager createDirectoryAtPath:photosDirectoryPath withIntermediateDirectories:NO attributes:NULL error:NULL];
//        }
    }
    
    // Start up Core Data in the gallery directory.
    
    if (success) {
        NSString *      modelPath;
        
        modelPath = [[NSBundle bundleForClass:[self class]] pathForResource:@"Photos" ofType:@"mom"];
        assert(modelPath != nil);
        
        model = [[[NSManagedObjectModel alloc] initWithContentsOfURL:[NSURL fileURLWithPath:modelPath]] autorelease];
        success = (model != nil);
    }
    if (success) {
        databaseURL = [NSURL fileURLWithPath:[galleryCachePath stringByAppendingPathComponent:kDatabaseFileName]];
        assert(databaseURL != nil);
        
        psc = [[[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:model] autorelease];
        success = (psc != nil);
    }
    if (success) {
        success = [psc addPersistentStoreWithType:NSSQLiteStoreType
                                    configuration:nil
                                              URL:databaseURL
                                          options:nil
                                            error:&error
                   ] != nil;
        if (success) {
            error = nil;
        }
    }
    
    if (success) {
        EXFEContext *   context;
        
        // Everything has gone well, so we create a managed object context from our persistent
        // store.  Note that we use a subclass of NSManagedObjectContext, PhotoGalleryContext, which
        // carries along some state that the managed objects (specifically the Photo objects) need
        // access to.
        
        context = [[[EXFEContext alloc] initWithUserPath:galleryCachePath] autorelease];
        assert(context != nil);
        
        [context setPersistentStoreCoordinator:psc];
        
        // In older versions of the code various folks observed our photoGalleryContext property
        // and did clever things when it changed.  So it was important to not set that property
        // until everything as fully up and running.  That no longer happens, but I've kept the
        // configure-before-set code because it seems like the right thing to do.
        
        self.exfeContext = context;
        
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
        
        if (galleryCachePath != nil) {
            [self abandonGalleryCacheAtPath:galleryCachePath];
        }
    }
    return success;
}

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
