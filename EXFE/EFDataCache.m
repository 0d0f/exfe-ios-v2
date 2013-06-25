//
//  EFDataCache.m
//  EXFE
//
//  Created by 0day on 13-6-14.
//
//

#import "EFDataCache.h"

@implementation EFDataCache

- (NSData *)dataForKey:(NSString *)aKey {
    NSParameterAssert(aKey);
    
    return [self objectForKey:aKey];
}

- (void)setData:(NSData *)data forKey:(NSString *)aKey {
    NSParameterAssert(aKey);
    
    [self setObject:data forKey:aKey];
}

@end
