//
//  EFDataManager+Image.h
//  EXFE
//
//  Created by 0day on 13-6-21.
//
//

#import "EFDataManager.h"

@interface EFDataManager (Image)

+ (EFDataManager *)imageManager;

// Getter
- (BOOL)isImageCachedInMemoryForKey:(NSString *)aKey;
- (UIImage *)cachedImageInMemoryForKey:(NSString *)aKey;  // Memory

- (BOOL)isImageCachedInDiskForKey:(NSString *)aKey;
- (void)cachedImageInDiskForKey:(NSString *)aKey completeHandler:(void (^)(UIImage *image))handler;          // Disk

- (BOOL)isImageCachedInLocalForKey:(NSString *)aKey;
- (void)cachedImageInLocalForKey:(NSString *)aKey completeHandler:(void (^)(UIImage *image))handler;         // Memory->Disk

- (void)cachedImageForKey:(NSString *)aKey completeHandler:(void (^)(UIImage *image))handler;   // Memory->Disk->Network

// Setter
- (void)cacheImage:(UIImage *)image forKey:(NSString *)aKey shouldWriteToDisk:(BOOL)writeToDisk;

- (void)loadImageForView:(id)view setImageSelector:(SEL)selector placeHolder:(UIImage *)image key:(NSString *)aKey completeHandler:(void (^)(BOOL hasLoaded))handler;
- (void)loadImageForView:(id)view setImageSelector:(SEL)selector size:(CGSize)size placeHolder:(UIImage *)image key:(NSString *)aKey completeHandler:(void (^)(BOOL hasLoaded))handler;
- (void)cancelLoadImageForView:(UIView *)view;

- (UIImage *)resizeImage:(UIImage *)image toSize:(CGSize)size;

@end
