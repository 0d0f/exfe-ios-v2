//
//  EFDataManager+Image.m
//  EXFE
//
//  Created by 0day on 13-6-21.
//
//

#import "EFDataManager+Image.h"

#import "EFQueue.h"

#define kImageCachePath     @"~/Library/Caches/images"

@implementation EFDataManager (Image)

+ (EFDataManager *)imageManager {
    static EFDataManager *Manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Manager = [[self alloc] initImageManager];
    });
    
    return Manager;
}

- (id)initImageManager {
    self = [self init];
    if (self) {
        self.cachePath = [kImageCachePath stringByExpandingTildeInPath];
    }
    
    return self;
}

- (BOOL)isImageCachedInMemoryForKey:(NSString *)aKey {
    NSParameterAssert(aKey);
    
    return [self isDataCachedInMemoryForKey:aKey];
}
- (UIImage *)cachedImageInMemoryForKey:(NSString *)aKey {
    NSParameterAssert(aKey);
    
    NSData *data = [self cachedDataInMemoryForKey:aKey];
    UIImage *image = [UIImage imageWithData:data];
    
    return image;
}

- (BOOL)isImageCachedInDiskForKey:(NSString *)aKey {
    NSParameterAssert(aKey);
    
    return [self isDataCachedInDiskForKey:aKey];
}

- (void)cachedImageInDiskForKey:(NSString *)aKey completeHandler:(void (^)(UIImage *image))handler {
    NSParameterAssert(aKey);
    NSParameterAssert(handler);
    
    [self cachedDataInDiskForKey:aKey
                 completeHandler:^(NSData *data){
                     UIImage *image = [UIImage imageWithData:data];
                     handler(image);
                 }];
}

- (BOOL)isImageCachedInLocalForKey:(NSString *)aKey {
    NSParameterAssert(aKey);
    
    return [self isDataCachedInLocalForKey:aKey];
}

- (void)cachedImageInLocalForKey:(NSString *)aKey completeHandler:(void (^)(UIImage *image))handler {
    NSParameterAssert(aKey);
    NSParameterAssert(handler);
    
    [self cachedDataInLocalForKey:aKey
                  completeHandler:^(NSData *data){
                      UIImage *image = [UIImage imageWithData:data];
                      handler(image);
                  }];
}

- (void)cachedImageForKey:(NSString *)aKey completeHandler:(void (^)(UIImage *image))handler {
    NSParameterAssert(aKey);
    NSParameterAssert(handler);
    
    [self cachedImageInLocalForKey:aKey
                   completeHandler:^(UIImage *image){
                       if (image) {
                           // local
                           handler(image);
                       } else if ([aKey hasPrefix:@"http"]) {
                           // network
                           EFDownloadOperation *downloadOperation = [[EFDownloadOperation alloc] init];
                           downloadOperation.url = [NSURL URLWithString:aKey];
                           EFNetworkManagementOperation *operation = [[EFNetworkManagementOperation alloc] initWithNetworkOperation:downloadOperation];
                           
                           [[EFQueueManager defaultManager] addNetworkManagementOperation:operation
                                                                          completeHandler:^{
                                                                              NSData *data = downloadOperation.data;
                                                                              
                                                                              if (data) {
                                                                                  [self cacheData:data forKey:aKey shouldWriteToDisk:YES];
                                                                                  UIImage *image = [UIImage imageWithData:data];
                                                                                  
                                                                                  handler(image);
                                                                              } else {
                                                                                  handler(nil);
                                                                              }
                                                                          }];
                       } else {
                           handler(nil);
                       }
                   }];
}

// Setter
- (void)cacheImage:(UIImage *)image forKey:(NSString *)aKey shouldWriteToDisk:(BOOL)writeToDisk {
    NSParameterAssert(image);
    NSParameterAssert(aKey);
    
    NSData *data = UIImagePNGRepresentation(image);
    if (!data) {
        data = UIImageJPEGRepresentation(image, 1.0f);
    }
    
    NSAssert(data, @"data should not be nil.");
    
    [self cacheData:data forKey:aKey shouldWriteToDisk:writeToDisk];
}

@end
