//
//  EFDataManager.h
//  EXFE
//
//  Created by 0day on 13-6-14.
//
//

#import <Foundation/Foundation.h>

@class EFDataCache, EFQueueManager;
@interface EFDataManager : NSObject

@property (nonatomic, copy) NSString *cachePath;
@property (nonatomic, strong) EFDataCache *dataCache;
@property (nonatomic, strong) EFQueueManager *queueManager;

+ (EFDataManager *)defaultManager;

// Getter
- (BOOL)isDataCachedInMemoryForKey:(NSString *)aKey;
- (NSData *)cachedDataInMemoryForKey:(NSString *)aKey;  // Get the data for key in memory, if it doesn't exsit in memory, return nil.

- (BOOL)isDataCachedInDiskForKey:(NSString *)aKey;
- (void)cachedDataInDiskForKey:(NSString *)aKey completeHandler:(void (^)(NSData *data))handler;          // Get the data for key in disk. This method will find data from disk.

- (BOOL)isDataCachedInLocalForKey:(NSString *)aKey;
- (void)cachedDataInLocalForKey:(NSString *)aKey completeHandler:(void (^)(NSData *data))handler;         // Get the data for key. Firstly find in memory, then find in disk.

// Setter
- (void)cacheData:(NSData *)data forKey:(NSString *)aKey shouldWriteToDisk:(BOOL)writeToDisk;

@end
