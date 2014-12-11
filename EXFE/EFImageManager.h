//
//  EFImageManager.h
//  EXFE
//
//  Created by 0day on 13-6-5.
//
//

#import <Foundation/Foundation.h>

@class EFImageCache;
@interface EFImageManager : NSObject

@property (nonatomic, strong) EFImageCache *imageCache;
@property (nonatomic, readonly, copy) NSString *cachePath;

+ (EFImageManager *)defaultManager;

- (BOOL)isImagePersistentForKey:(NSString *)imageKey;
- (void)imageForKey:(NSString *)imageKey completionHandler:(void (^)(UIImage *image))handler;
- (void)cacheImage:(UIImage *)image forKey:(NSString *)imageKey;

@end
