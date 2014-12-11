//
//  EFContactObject.h
//  EXFE
//
//  Created by 0day on 13-6-5.
//
//

#import <Foundation/Foundation.h>

@class User, LocalContact, RoughIdentity;
@interface EFContactObject : NSObject

@property (nonatomic, copy) NSString *searchIndex;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, strong) NSArray *roughIdentities;
@property (nonatomic, copy) NSString *imageKey; // used to get image from cache, nil when has no image.

@property (nonatomic, assign, getter = isSelected) BOOL selected;   // default as NO.

- (void)roughIdentitiesSelectedStateDidChange;

+ (EFContactObject *)contactObjectWithIdentities:(NSArray *)identities;
+ (EFContactObject *)contactObjectWithLocalContact:(LocalContact *)localContact;
+ (EFContactObject *)contactObjectWithRoughIdentity:(RoughIdentity *)roughIdentity;

- (id)initWithIdentities:(NSArray *)identities;
- (id)initWithLocalContact:(LocalContact *)localContact;
- (id)initWithRoughIdentity:(RoughIdentity *)roughIdentity;

- (void)selectRoughtIdentity:(RoughIdentity *)roughIdentity;
- (void)selectRoughtIdentityAtIndex:(NSUInteger)index;

- (void)deselectRoughtIdentity:(RoughIdentity *)roughIdentity;
- (void)deselectRoughtIdentityAtIndex:(NSUInteger)index;

- (BOOL)isEqualToContactObject:(EFContactObject *)object;

@end
