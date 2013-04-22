//
//  RoughIdentity.m
//  EXFE
//
//  Created by 0day on 13-4-19.
//
//

#import "RoughIdentity.h"

@implementation RoughIdentity

+ (RoughIdentity *)identity {
    return [[[self alloc] init] autorelease];
}

- (void)dealloc {
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

- (BOOL)isEqualToRoughIdentity:(RoughIdentity *)anIdentity {
    if (([anIdentity.provider isEqualToString:self.provider] && [anIdentity.externalUsername isEqualToString:self.externalUsername]) ||
        ([anIdentity.provider isEqualToString:self.provider] && [anIdentity.externalID isEqualToString:self.externalID])) {
        return YES;
    } else {
        return NO;
    }
}

@end
