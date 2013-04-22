//
//  RoughIdentity.h
//  EXFE
//
//  Created by 0day on 13-4-19.
//
//

#import <Foundation/Foundation.h>

@interface RoughIdentity : NSObject
<
NSCopying
>

@property (nonatomic, copy) NSString *externalUsername;
@property (nonatomic, copy) NSString *provider;
@property (nonatomic, copy) NSString *externalID;
@property (nonatomic, copy, readonly) NSString *key;

+ (RoughIdentity *)identity;

- (BOOL)isEqualToRoughIdentity:(RoughIdentity *)anIdentity;

@end
