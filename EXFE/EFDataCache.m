//
//  EFDataCache.m
//  EXFE
//
//  Created by 0day on 13-6-14.
//
//

#import "EFDataCache.h"

#define kDefaultMaxSize     (200)

@interface EFDataCache ()

@property (nonatomic, strong) NSMutableDictionary   *cacheMap;
@property (nonatomic, strong) NSMutableArray *keyQueue;

@end

@implementation EFDataCache

- (id)init {
    self = [super init];
    if (self) {
        self.maxSize = kDefaultMaxSize;
        
        self.cacheMap = [[NSMutableDictionary alloc] init];
        self.keyQueue = [[NSMutableArray alloc] init];
    }
    
    return self;
}

- (NSData *)dataForKey:(NSString *)aKey {
    NSParameterAssert(aKey);
    
    return [self.cacheMap valueForKey:aKey];
}

- (void)setData:(NSData *)data forKey:(NSString *)aKey {
    NSParameterAssert(aKey);
    NSParameterAssert(data);
    
    NSInteger index = [self.keyQueue indexOfObject:aKey];
    if (NSNotFound == index) {
        if (self.keyQueue.count > self.maxSize) {
            NSString *firstKey = self.keyQueue[0];
            [self.cacheMap removeObjectForKey:firstKey];
            [self.keyQueue removeObjectAtIndex:0];
        }
        
        [self.keyQueue addObject:aKey];
    }
    
    [self.cacheMap setValue:data forKey:aKey];
}

@end
