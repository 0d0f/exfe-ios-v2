//
//  EFDataManager+Image.m
//  EXFE
//
//  Created by 0day on 13-6-21.
//
//

#import "EFDataManager+Image.h"

#import "EFQueue.h"
#import "UIImage+Resize.h"

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
        self.loadingMap = [[NSMutableDictionary alloc] initWithCapacity:100];
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
                           NSURL *url = [NSURL URLWithString:aKey];
                           // we expected valid url string for aKey.
                           if (url) {
                               // network
                               EFDownloadOperation *downloadOperation = [[EFDownloadOperation alloc] init];
                               downloadOperation.url = url;
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

- (void)loadImageForView:(id)view setImageSelector:(SEL)selector placeHolder:(UIImage *)placeholder key:(NSString *)aKey completeHandler:(void (^)(BOOL hasLoaded))handler {
    NSParameterAssert(view);
    NSParameterAssert(aKey);
    
    [self.loadingMap setObject:aKey forKey:[NSValue valueWithNonretainedObject:view]];
    
    if ([self cachedImageInMemoryForKey:aKey]) {
        UIImage *image = [self cachedImageInMemoryForKey:aKey];
        NSAssert(image != nil, @"Image MUST exist in memory!");
        
        [view performSelector:selector withObject:image];
        [self.loadingMap removeObjectForKey:[NSValue valueWithNonretainedObject:view]];
        
        if (handler) {
            handler(YES);
        }
    } else {
        [view performSelector:selector withObject:placeholder];
        [self cachedImageForKey:aKey
                completeHandler:^(UIImage *image){
                    NSString *key = [self.loadingMap objectForKey:[NSValue valueWithNonretainedObject:view]];
                    
                    if (key && [key isEqualToString:aKey]) {
                        if (image) {
                            [view performSelector:selector withObject:image];
                            if (handler) {
                                handler(YES);
                            }
                        } else {
                            if (handler) {
                                handler(NO);
                            }
                        }
                    }
                }];
    }
}

- (void)loadImageForView:(id)view setImageSelector:(SEL)selector size:(CGSize)size placeHolder:(UIImage *)placeholder key:(NSString *)aKey completeHandler:(void (^)(BOOL hasLoaded))handler {
    NSString *imageKey = [aKey stringByAppendingFormat:@"_%f_%f", size.width, size.height];
    
    [self.loadingMap setObject:imageKey forKey:[NSValue valueWithNonretainedObject:view]];
    
    if ([self cachedImageInMemoryForKey:imageKey]) {
        UIImage *image = [self cachedImageInMemoryForKey:imageKey];
        NSAssert(image != nil, @"Image MUST exist in memory!");
        
        [view performSelector:selector withObject:image];
        [self.loadingMap removeObjectForKey:[NSValue valueWithNonretainedObject:view]];
        
        if (handler) {
            handler(YES);
        }
    } else {
        [view performSelector:selector withObject:placeholder];
        if ([self isImageCachedInDiskForKey:imageKey]) {
            [self cachedImageInDiskForKey:imageKey
                          completeHandler:^(UIImage *image){
                              NSString *key = [self.loadingMap objectForKey:[NSValue valueWithNonretainedObject:view]];
                              
                              if (key && [key isEqualToString:imageKey]) {
                                  if (image) {
                                      [view performSelector:selector withObject:image];
                                      if (handler) {
                                          handler(YES);
                                      }
                                  } else {
                                      if (handler) {
                                          handler(NO);
                                      }
                                  }
                                  
                                  [self.loadingMap removeObjectForKey:[NSValue valueWithNonretainedObject:view]];
                              }
                          }];
        } else {
            [self cachedImageForKey:aKey
                    completeHandler:^(UIImage *image){
                        UIImage *resizedImage = nil;
                        if (image) {
                            resizedImage = [self resizeImage:image toSize:size];
                            [self cacheImage:resizedImage forKey:imageKey shouldWriteToDisk:YES];
                        }
                        
                        NSString *key = [self.loadingMap objectForKey:[NSValue valueWithNonretainedObject:view]];
                        
                        if (key && [key isEqualToString:imageKey]) {
                            if (resizedImage) {
                                [view performSelector:selector withObject:resizedImage];
                                if (handler) {
                                    handler(YES);
                                }
                            } else {
                                if (handler) {
                                    handler(NO);
                                }
                            }
                            
                            [self.loadingMap removeObjectForKey:[NSValue valueWithNonretainedObject:view]];
                        }
                    }];
        }
    }
}

- (void)cancelLoadImageForView:(UIView *)view {
    [self.loadingMap removeObjectForKey:[NSValue valueWithNonretainedObject:view]];
}

- (UIImage *)resizeImage:(UIImage *)image toSize:(CGSize)size {
    CGFloat scaleFactor = 1.0;
    
    if (image.size.width > size.width || image.size.height > size.height){
        scaleFactor = MAX((size.width / image.size.width), (size.height / image.size.height));
    }
    
    UIGraphicsBeginImageContext(size);
    
    CGRect rect = CGRectMake((size.width / 2 - image.size.width / 2 * scaleFactor),(0 - image.size.height * 198.0f / 495.0f * scaleFactor),image.size.width * scaleFactor,image.size.height * scaleFactor);
    [image drawInRect:rect];
    UIImage *backimg = UIGraphicsGetImageFromCurrentImageContext();
    
    return backimg;
}

@end
