//
//  EFImageManager.m
//  EXFE
//
//  Created by 0day on 13-6-5.
//
//

#import "EFImageManager.h"

#import "EFImageCache.h"
#import "NSString+MD5.h"

@implementation EFImageManager

+ (EFImageManager *)defaultManager {
    static dispatch_once_t onceToken;
    static EFImageManager *Manager;
    dispatch_once(&onceToken, ^{
        Manager = [[self alloc] init];
    });
    
    return Manager;
}

- (id)init {
    self = [super init];
    if (self) {
        self.imageCache = [EFImageCache cache];
    }
    
    return self;
}

#pragma mark - Getter && Setter

- (NSString *)cachePath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:@"/images"];
    
    BOOL writedir = [[NSFileManager defaultManager] isWritableFileAtPath:path];
    if (!writedir) {
        [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    return path;
}

#pragma mark - Public

- (BOOL)isImagePersistentForKey:(NSString *)imageKey {
    NSParameterAssert(imageKey);
    
    NSString *md5ImageKey = [imageKey md5Value];
    NSString *imagePath = [self.cachePath stringByAppendingPathComponent:md5ImageKey];
    if ([[NSFileManager defaultManager] fileExistsAtPath:imagePath]) {
        return YES;
    }
    
    return NO;
}

- (void)imageForKey:(NSString *)imageKey completionHandler:(void (^)(UIImage *image))handler {
    NSParameterAssert(imageKey);
    
    NSString *md5ImageKey = [imageKey md5Value];
    
    if ([self isImagePersistentForKey:imageKey]) {
        // load from cache firstly
        UIImage *image = [self.imageCache imageForKey:md5ImageKey];
        if (image) {
            if (handler) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    handler(image);
                });
            }
            
            return;
        }
        
        // load from disk
        NSString *imagePath = [self.cachePath stringByAppendingPathComponent:md5ImageKey];
        
        dispatch_queue_t fetch_queue = dispatch_queue_create("queue.fetch.image", NULL);
        dispatch_async(fetch_queue, ^{
            NSData *imageData = [NSData dataWithContentsOfFile:imagePath];
            dispatch_async(dispatch_get_main_queue(), ^{
                UIImage *image = [UIImage imageWithData:imageData];
                if (image) {
                    // cache image
                    [self cacheImage:image forKey:imageKey];
                }
                
                if (handler) {
                    handler(image);
                }
            });
        });
        dispatch_release(fetch_queue);
    } else {
    // download
        dispatch_queue_t download_queue = dispatch_queue_create("queue.download.image", NULL);
        dispatch_async(download_queue, ^{
            NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:imageKey]];
            
            
            
            dispatch_async(dispatch_get_main_queue(), ^{
                UIImage *image = [UIImage imageWithData:imageData];
                if (image) {
                    // cache image
                    [self cacheImage:image forKey:imageKey];
                }
                
                if (handler) {
                    handler(image);
                }
             });
        });
        dispatch_release(download_queue);
    }
}

- (void)cacheImage:(UIImage *)image forKey:(NSString *)imageKey {
    NSParameterAssert(image);
    NSParameterAssert(imageKey);
    
    NSString *md5ImageKey = [imageKey md5Value];
    [self.imageCache setImage:image forKey:md5ImageKey];
    
    NSData *imageData = UIImagePNGRepresentation(image);
    if (!imageData) {
        imageData = UIImageJPEGRepresentation(image, 1.0f);
    }
    
    if (imageData) {
        dispatch_queue_t persist_queue = dispatch_queue_create("queue.persist.image", NULL);
        dispatch_async(persist_queue, ^{
            NSString *imagePath = [self.cachePath stringByAppendingPathComponent:md5ImageKey];
            [imageData writeToFile:imagePath atomically:YES];
        });
        dispatch_release(persist_queue);
    }
}

@end
