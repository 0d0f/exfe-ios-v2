//
//  Card.m
//  EXFE
//
//  Created by 0day on 13-4-2.
//
//

#import "Card.h"

@implementation CardIdentitiy
+ (CardIdentitiy *)cardIdentityWithDictionary:(NSDictionary *)dict {
    return [[[self alloc] initWithDictionary:dict] autorelease];
}

- (id)initWithDictionary:(NSDictionary *)dict {
    self = [super init];
    if (self) {
        self.externalID = [dict valueForKey:@"external_id"];
        self.externalUsername = [dict valueForKey:@"external_username"];
        self.provider = [dict valueForKey:@"provider"];
    }
    return self;
}

- (void)dealloc {
    [_externalID release];
    [_externalUsername release];
    [_provider release];
    [super dealloc];
}

- (NSDictionary *)dictionaryValue {
    NSMutableDictionary *param = [[NSMutableDictionary alloc] initWithCapacity:1];
    [param setValue:self.externalID forKey:@"external_id"];
    [param setValue:self.externalUsername forKey:@"external_username"];
    [param setValue:self.provider forKey:@"provider"];
    
    NSDictionary *result = [param copy];
    [param release];
    
    return result;
}

- (id)copyWithZone:(NSZone *)zone {
    CardIdentitiy *copy = [[CardIdentitiy alloc] initWithDictionary:[self dictionaryValue]];
    return copy;
}

@end

@implementation Card

+ (Card *)cardWithDictionary:(NSDictionary *)dict {
    return [[[self alloc] initWithDictionary:dict] autorelease];
}

- (id)initWithDictionary:(NSDictionary *)dict {
    self = [super init];
    if (self) {
        [dict enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop){
            if ([key isEqualToString:@"id"]) {
                self.cardID = obj;
            } else if ([key isEqualToString:@"name"]) {
                self.userName = obj;
            } else if ([key isEqualToString:@"avatar"]) {
                self.avatarURLString = obj;
            } else if ([key isEqualToString:@"bio"]) {
                self.bio = obj;
            } else if ([key isEqualToString:@"identities"]) {
                NSMutableArray *temp = [[NSMutableArray alloc] initWithCapacity:[obj count]];
                for (NSDictionary *param in obj) {
                    CardIdentitiy *identity = [CardIdentitiy cardIdentityWithDictionary:param];
                    [temp addObject:identity];
                }
                self.identities = [[temp copy] autorelease];
                [temp release];
            } else if ([key isEqualToString:@"is_me"]) {
                self.isMe = [obj boolValue];
            } else if ([key isEqualToString:@"timestamp"]) {
                self.timeStamp = [obj doubleValue];
            }
        }];
    }
    
    return self;
}

- (NSDictionary *)dictionaryValue {
    NSMutableDictionary *param = [[NSMutableDictionary alloc] initWithCapacity:6];
    [param setValue:self.cardID forKey:@"id"];
    [param setValue:self.userName forKey:@"name"];
    [param setValue:self.avatarURLString forKey:@"avatar"];
    [param setValue:self.bio forKey:@"bio"];
    [param setValue:[NSNumber numberWithBool:self.isMe] forKey:@"is_me"];
    NSMutableArray *identities = [[NSMutableArray alloc] initWithCapacity:[self.identities count]];
    for (CardIdentitiy *identity in self.identities) {
        [identities addObject:[identity dictionaryValue]];
    }
    [param setValue:[[identities copy] autorelease] forKey:@"identities"];
    [param setValue:[NSNumber numberWithDouble:self.timeStamp] forKey:@"timestamp"];
    
    NSDictionary *result = [[param copy] autorelease];
    [param release];

    return result;
}

- (id)copyWithZone:(NSZone *)zone {
    Card *copy = [[Card alloc] initWithDictionary:[self dictionaryValue]];
    return copy;
}

- (BOOL)isEqualToCard:(Card *)aCard {
    if (nil == aCard)
        return NO;
    NSAssert(_userName != nil && _userName.length != 0, @"name为空了");
    NSAssert(aCard.userName != nil && aCard.userName.length != 0, @"card参数的name为空了");
    NSAssert(_avatarURLString != nil && _avatarURLString.length != 0, @"avatarUrl为空了");
    NSAssert(aCard.avatarURLString != nil && aCard.avatarURLString.length != 0, @"card参数的avatarUrl为空了");
    
    if ([_userName isEqualToString:aCard.userName] &&
        [_avatarURLString isEqualToString:aCard.avatarURLString]) {
        return YES;
    }
    return NO;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"Me:%d name:%@", self.isMe, self.userName];
}

@end
