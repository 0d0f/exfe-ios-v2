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
#import "IdentityId.h"

@implementation RoughIdentity
@synthesize key = _key;

+ (RoughIdentity *)identity {
    return [[self alloc] initWithDictionary:nil];
}

+ (RoughIdentity *)identityWithDictionary:(NSDictionary *)dictionary {
    return [[self alloc] initWithDictionary:dictionary];
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
        
        self.selected = NO;
    }
    
    return self;
}


- (id)copyWithZone:(NSZone *)zone {
    RoughIdentity *copy = [[RoughIdentity alloc] init];
    copy.provider = self.provider;
    copy.externalID = self.externalID;
    copy.externalUsername = self.externalUsername;
    
    return copy;
}

- (NSString *)key {
    NSString *key = nil;
    if (_externalUsername && _externalUsername.length) {
        key = [NSString stringWithFormat:@"%@%@", [self.externalUsername lowercaseString], self.provider];
    } else if (_externalID && _externalID.length) {
        key = [NSString stringWithFormat:@"%@%@", [self.externalID lowercaseString], self.provider];
    } 
    
    NSAssert(key != nil, @"key 为 nil");
    
    _key = key;
    
    return key;
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
    
    NSDictionary *result = [dict copy];
    
    return result;
}

- (IdentityId *)identityIdValue {
    RKObjectManager *objectManager = [RKObjectManager sharedManager];
    NSEntityDescription *invitationEntity = [NSEntityDescription entityForName:@"IdentityId" inManagedObjectContext:objectManager.managedObjectStore.mainQueueManagedObjectContext];
    IdentityId *identityId = [[IdentityId alloc] initWithEntity:invitationEntity insertIntoManagedObjectContext:objectManager.managedObjectStore.mainQueueManagedObjectContext];
    identityId.identity_id = [NSString stringWithFormat:@"%@@%@", self.externalUsername, self.provider];
    
    return identityId;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"provider:%@ externalID:%@ externalUsername:%@", self.provider, self.externalID, self.externalUsername];
}

- (void)setIdentity:(Identity *)identity {
    if (identity == _identity)
        return;
    
    if (_identity) {
        _identity = nil;
    }
    if (identity) {
        _identity = identity;
        self.status = kEFRoughIdentityGetIdentityStatusSuccess;
    } else {
        self.status = kEFRoughIdentityGetIdentityStatusReady;
    }
}

- (void)getIdentityWithSuccess:(void (^)(Identity *identity))success failure:(void (^)(NSError *error))failure {
    self.status = kEFRoughIdentityGetIdentityStatusLoading;
    AppDelegate * app = (AppDelegate*)[UIApplication sharedApplication].delegate;
    [app.model.apiServer getIdentitiesWithParams:@[[self dictionaryValue]]
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
