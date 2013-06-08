//
//  EFContactObject.m
//  EXFE
//
//  Created by 0day on 13-6-5.
//
//

#import "EFContactObject.h"

#import "User+EXFE.h"
#import "LocalContact+EXFE.h"
#import "Identity+EXFE.h"
#import "EFImageManager.h"
#import "RoughIdentity.h"

@interface EFContactObject (Private)
- (void)_init;
@end

@implementation EFContactObject

+ (EFContactObject *)contactObjectWithIdentities:(NSArray *)identities {
    return [[[self alloc] initWithIdentities:identities] autorelease];
}

+ (EFContactObject *)contactObjectWithLocalContact:(LocalContact *)localContact {
    return [[[self alloc] initWithLocalContact:localContact] autorelease];
}

+ (EFContactObject *)contactObjectWithRoughIdentity:(RoughIdentity *)roughIdentity {
    return [[[self alloc] initWithRoughIdentity:roughIdentity] autorelease];
}

- (id)initWithIdentities:(NSArray *)identities {
    NSParameterAssert(identities && identities.count);
    
    self = [super init];
    if (self) {
        [self _init];
        
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"a_order" ascending:YES];
        identities = [identities sortedArrayUsingDescriptors:@[sortDescriptor]];
        
        NSMutableArray *roughIdentities = [[NSMutableArray alloc] initWithCapacity:identities.count];
        for (Identity *identity in identities) {
            [roughIdentities addObject:[identity roughIdentityValue]];
        }
        self.roughIdentities = roughIdentities;
        [roughIdentities release];
        
        Identity *defaultIdentity = identities[0];
        
        self.name = defaultIdentity.name;
        self.imageKey = defaultIdentity.avatar_filename;
        
        NSMutableString *searchIndex = [[NSMutableString alloc] init];
        for (Identity *identity in identities) {
            [searchIndex appendFormat:@"%@%@%@%@", identity.external_id, identity.external_username, identity.name, identity.provider];
        }
        self.searchIndex = [[searchIndex copy] autorelease];
        [searchIndex release];
    }
    
    return self;
}

- (id)initWithLocalContact:(LocalContact *)localContact {
    NSParameterAssert(localContact);
    
    self = [super init];
    if (self) {
        [self _init];
        
        self.name = localContact.name;
        self.imageKey = localContact.indexfield;
        self.searchIndex = localContact.indexfield;
        
        if (localContact.avatar) {
            UIImage *avatarImage = [UIImage imageWithData:localContact.avatar];
            [[EFImageManager defaultManager] cacheImage:avatarImage forKey:localContact.indexfield];
        }
        
        self.roughIdentities = [localContact roughIdentities];
    }
    
    return self;
}

- (id)initWithRoughIdentity:(RoughIdentity *)roughIdentity {
    NSParameterAssert(roughIdentity);
    
    self = [super init];
    if (self) {
        [self _init];
        
        self.name = roughIdentity.identity ? roughIdentity.identity.name : nil;
        self.imageKey = roughIdentity.identity ? roughIdentity.identity.avatar_filename : nil;
        self.searchIndex = roughIdentity.key;
        
        self.roughIdentities = @[roughIdentity];
    }
    
    return self;
}

- (void)dealloc {
    [_searchIndex release];
    [_name release];
    [_roughIdentities release];
    [_imageKey release];
    [super dealloc];
}

#pragma mark - Getter && Setter

- (void)setSelected:(BOOL)selected {
    if (_selected == selected)
        return;
    
    [self willChangeValueForKey:@"selected"];
    
    _selected = selected;
    NSUInteger roughIdengitiesCount = self.roughIdentities.count;
    for (RoughIdentity *roughIdentity in self.roughIdentities) {
        if (kProviderTwitter == [Identity getProviderCode:roughIdentity.provider] && 1 < roughIdengitiesCount) {
            roughIdentity.selected = NO;
        } else {
            roughIdentity.selected = selected;
        }
    }
    
    [self didChangeValueForKey:@"selected"];
}

#pragma mark -

- (void)selectRoughtIdentity:(RoughIdentity *)roughIdentity {
    NSUInteger index = [self.roughIdentities indexOfObject:roughIdentity];
    [self selectRoughtIdentityAtIndex:index];
}

- (void)selectRoughtIdentityAtIndex:(NSUInteger)index {
    NSParameterAssert(index != NSNotFound);
    RoughIdentity *roughIdentity = [self.roughIdentities objectAtIndex:index];
    roughIdentity.selected = YES;
}

- (void)deselectRoughtIdentity:(RoughIdentity *)roughIdentity {
    NSUInteger index = [self.roughIdentities indexOfObject:roughIdentity];
    [self deselectRoughtIdentityAtIndex:index];
}

- (void)deselectRoughtIdentityAtIndex:(NSUInteger)index {
    NSParameterAssert(index != NSNotFound);
    RoughIdentity *roughIdentity = [self.roughIdentities objectAtIndex:index];
    roughIdentity.selected = NO;
}

- (BOOL)isEqualToContactObject:(EFContactObject *)object {
    if (![self.name isEqualToString:object.name]) {
        return NO;
    }
    if (![self.searchIndex isEqualToString:object.searchIndex]) {
        return NO;
    }
    if (self.roughIdentities.count != object.roughIdentities.count) {
        return NO;
    }
    
    return YES;
}

#pragma mark - Private

- (void)_init {
    self.selected = NO;
}

@end
