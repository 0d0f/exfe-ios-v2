//
//  RoughIdentity.m
//  EXFE
//
//  Created by 0day on 13-4-19.
//
//

#import "RoughIdentity.h"

@implementation RoughIdentity
@synthesize key = _key;

+ (RoughIdentity *)identity {
    return [[[self alloc] init] autorelease];
}

- (void)dealloc {
    [_key release];
    [_provider release];
    [_externalUsername release];
    [_externalID release];
    [super dealloc];
}

- (id)copyWithZone:(NSZone *)zone {
    RoughIdentity *copy = [[RoughIdentity alloc] init];
    copy.provider = self.provider;
    copy.externalID = self.externalID;
    copy.externalUsername = self.externalUsername;
    
    return copy;
}

- (NSString *)key {
    if (_key && _key.length)
        return [[_key copy] autorelease];
    
    NSString *key = nil;
    if (_externalUsername && _externalUsername.length) {
        key = [NSString stringWithFormat:@"%@%@", self.externalUsername, self.provider];
    } else if (_externalID && _externalID.length) {
        key = [NSString stringWithFormat:@"%@%@", self.externalID, self.provider];
    }
    
    NSAssert(key != nil, @"key 为 nil");
    
    _key = [key retain];
    
    return [[key copy] autorelease];
}

- (BOOL)isEqualToRoughIdentity:(RoughIdentity *)anIdentity {
    if ([self.key isEqualToString:anIdentity.key]) {
        return YES;
    } else {
        return NO;
    }
}

- (NSDictionary *)dictionaryValue {
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithCapacity:3];
    [dict setValue:self.provider forKey:@"provider"];
    if (_externalUsername && _externalUsername.length) {
        [dict setValue:self.externalUsername forKey:@"external_username"];
    }
    if (_externalID && _externalID.length) {
        [dict setValue:self.externalID forKey:@"external_id"];
    }
    
    NSDictionary *result = [[dict copy] autorelease];
    [dict release];
    
    return result;
}

@end
