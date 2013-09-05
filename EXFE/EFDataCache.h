//
//  EFDataCache.h
//  EXFE
//
//  Created by 0day on 13-6-14.
//
//

#import <Foundation/Foundation.h>

@interface EFDataCache : NSObject

@property (nonatomic, assign) NSUInteger    maxSize;    // Default as 200

- (NSData *)dataForKey:(NSString *)aKey;
- (void)setData:(NSData *)data forKey:(NSString *)aKey;

@end
