//
//  EFDataManager.m
//  EXFE
//
//  Created by 0day on 13-6-14.
//
//

#import "EFDataManager.h"

#import "EFKit.h"
#import "NSString+MD5.h"

#define kDefaultCachePath   @"~/Documents/Library/Caches"

@implementation EFDataManager

+ (EFDataManager *)defaultManager {
    static EFDataManager *Manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Manager = [[self alloc] init];
    });
    
    return Manager;
}

- (id)init {
    self = [super init];
    if (self) {
        self.dataCache = [[EFDataCache alloc] init];
        self.queueManager = [EFQueueManager defaultManager];
        self.cachePath = [kDefaultCachePath stringByExpandingTildeInPath];
    }
    
    return self;
}


#pragma mark - Getter

- (BOOL)isDataCachedInMemoryForKey:(NSString *)aKey {
    NSParameterAssert(aKey);
    
    return !![self.dataCache dataForKey:aKey];
}

- (NSData *)cachedDataInMemoryForKey:(NSString *)aKey {
    NSParameterAssert(aKey);
    
    return [self.dataCache dataForKey:aKey];
}

- (BOOL)isDataCachedInDiskForKey:(NSString *)aKey {
    NSParameterAssert(aKey);
    
    NSString *md5Key = [aKey md5Value];
    NSString *dataPath = [self.cachePath stringByAppendingPathComponent:md5Key];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    return [fileManager fileExistsAtPath:dataPath];
}

- (void)cachedDataInDiskForKey:(NSString *)aKey completeHandler:(void (^)(NSData *data))handler {
    NSParameterAssert(aKey);
    NSParameterAssert(handler);
    
    NSString *md5Key = [aKey md5Value];
    NSString *dataPath = [self.cachePath stringByAppendingPathComponent:md5Key];
    
    EFIOManagementOperation *ioManagementOperation = [[EFIOManagementOperation alloc] init];
    ioManagementOperation.operationType = kEFIOOperationTypeRead;
    ioManagementOperation.savePath = dataPath;
    __weak EFDataManager *weakSelf = self;
    [self.queueManager addIOManagementOperation:ioManagementOperation
                                completeHandler:^{
                                    if (ioManagementOperation.data) {
                                        EFDataManager *strongSelf = weakSelf;
                                        if (strongSelf){
                                            [strongSelf cacheData:ioManagementOperation.data forKey:aKey shouldWriteToDisk:NO];
                                        }
                                    }
                                    if (handler) {
                                        handler(ioManagementOperation.data);
                                    }
                                }];
}

- (BOOL)isDataCachedInLocalForKey:(NSString *)aKey {
    NSParameterAssert(aKey);
    
    return [self isDataCachedInMemoryForKey:aKey] || [self isDataCachedInDiskForKey:aKey];
}

- (void)cachedDataInLocalForKey:(NSString *)aKey completeHandler:(void (^)(NSData *data))handler {
    NSParameterAssert(aKey);
    NSParameterAssert(handler);
    
    NSData *data = nil;
    if ([self isDataCachedInDiskForKey:aKey]) {
        data = [self cachedDataInMemoryForKey:aKey];
        
        if (data) {
            handler(data);
        } else {
            [self cachedDataInDiskForKey:aKey
                         completeHandler:^(NSData *data){
                             handler(data);
                         }];
        }
    } else {
        handler(nil);
    }
}

#pragma mark - Setter

- (void)setCachePath:(NSString *)cachePath {
    if ([_cachePath isEqualToString:cachePath]) {
        return;
    }
    
    if (_cachePath) {
        _cachePath = nil;
    }
    if (cachePath) {
        cachePath = [cachePath stringByExpandingTildeInPath];
        _cachePath = [cachePath copy];
        
        if (![[NSFileManager defaultManager] fileExistsAtPath:cachePath]) {
            [[NSFileManager defaultManager] createDirectoryAtPath:cachePath withIntermediateDirectories:YES attributes:NULL error:NULL];
        }
    }
}

- (void)cacheData:(NSData *)data forKey:(NSString *)aKey shouldWriteToDisk:(BOOL)writeToDisk {
    NSParameterAssert(data);
    NSParameterAssert(aKey);
    
    [self.dataCache setData:data forKey:aKey];
    
    if (writeToDisk) {
        NSString *md5Key = [aKey md5Value];
        NSString *dataPath = [self.cachePath stringByAppendingPathComponent:md5Key];
        
        EFIOManagementOperation *operation = [[EFIOManagementOperation alloc] init];
        operation.data = data;
        operation.savePath = dataPath;
        operation.operationType = kEFIOOperationTypeWrite;
        
        [self.queueManager addIOManagementOperation:operation completeHandler:nil];
        
    }
}

@end
