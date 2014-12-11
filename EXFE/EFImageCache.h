//
//  EFImageCache.h
//  EXFE
//
//  Created by 0day on 13-6-5.
//
//

#import <Foundation/Foundation.h>

@interface EFImageCache : NSCache

+ (EFImageCache *)cache;

// MUST call these methods on main thread.
- (UIImage *)imageForKey:(NSString *)key;
- (void)setImage:(UIImage *)image forKey:(NSString *)key;

@end
