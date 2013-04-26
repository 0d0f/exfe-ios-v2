//
//  RoughIdentity.m
//  EXFE
//
//  Created by 0day on 13-4-19.
//
//

#import "RoughIdentity.h"

#import "Identity+EXFE.h"
#import "EFAPIServer.h"

@implementation RoughIdentity
@synthesize key = _key;

+ (RoughIdentity *)identity {
    return [[[self alloc] initWithDictionary:nil] autorelease];
}

+ (RoughIdentity *)identityWithDictionary:(NSDictionary *)dictionary {
    return [[[self alloc] initWithDictionary:dictionary] autorelease];
}

- (id)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    if (self) {
        [dictionary enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop){
            if ([key isEqualToString:@"provider"]) {
                self.provider = obj;
            } else if ([key isEqualToString:@"external_username"]) {
                self.externalUsername = obj;
            } else if ([key isEqualToString:@"external_id"]) {
                self.externalID = obj;
            }
        }];
    }
    
    return self;
}

- (void)dealloc {
    [_identity release];
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

- (NSString *)description {
    return [NSString stringWithFormat:@"provider:%@ externalID:%@ externalUsername:%@", self.provider, self.externalID, self.externalUsername];
}

- (void)setIdentity:(Identity *)identity {
    if (identity == _identity)
        return;
    
    if (_identity) {
        [_identity release];
        _identity = nil;
    }
    if (identity) {
        _identity = [identity retain];
        self.status = kEFRoughIdentityGetIdentityStatusSuccess;
    } else {
        self.status = kEFRoughIdentityGetIdentityStatusReady;
    }
}

- (void)getIdentityWithSuccess:(void (^)(Identity *identity))success failure:(void (^)(NSError *error))failure {
    self.status = kEFRoughIdentityGetIdentityStatusLoading;
    [[EFAPIServer sharedInstance] getIdentitiesWithParams:@[[self dictionaryValue]]
                                                  success:^(NSArray *identities){
                                                      self.identity = identities[0];
                                                      self.status = kEFRoughIdentityGetIdentityStatusSuccess;
                                                      if (success) {
                                                          success(self.identity);
                                                      }
                                                  }
                                                  failure:^(NSError *error){
                                                      self.status = kEFRoughIdentityGetIdentityStatusFailure;
                                                      if (failure) {
                                                          failure(error);
                                                      }
                                                  }];
}

@end
