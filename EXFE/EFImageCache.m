//
//  EFImageCache.m
//  EXFE
//
//  Created by 0day on 13-6-5.
//
//

#import "EFImageCache.h"

@implementation EFImageCache

+ (EFImageCache *)cache {
    return [[self alloc] init];
}

- (UIImage *)imageForKey:(NSString *)key {
    NSParameterAssert(key);
    NSAssert([NSThread isMainThread], @"MUST called on main thread.");
    
    return [self objectForKey:key];
}

- (void)setImage:(UIImage *)image forKey:(NSString *)key {
    NSParameterAssert(image);
    NSParameterAssert(key);
    NSAssert([NSThread isMainThread], @"MUST called on main thread.");
    
    [self setObject:image forKey:key];
}

@end
