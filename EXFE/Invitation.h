//
//  Invitation.h
//  EXFE
//
//  Created by Stony Wang on 13-6-8.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Identity, IdentityId;

@interface Invitation : NSManagedObject

@property (nonatomic, strong) NSDate * created_at;
@property (nonatomic, strong) NSNumber * host;
@property (nonatomic, strong) NSNumber * invitation_id;
@property (nonatomic, strong) NSNumber * mates;
@property (nonatomic, strong) NSString * rsvp_status;
@property (nonatomic, strong) NSString * type;
@property (nonatomic, strong) NSDate * updated_at;
@property (nonatomic, strong) NSString * via;
@property (nonatomic, strong) Identity *identity;
@property (nonatomic, strong) Identity *invited_by;
@property (nonatomic, strong) Identity *updated_by;
@property (nonatomic, strong) NSOrderedSet *notification_identities;

@property (nonatomic, readonly, strong) NSArray *notification_identity_array;

@end

@interface Invitation (CoreDataGeneratedAccessors)

- (void)insertObject:(IdentityId *)value inNotification_identitiesAtIndex:(NSUInteger)idx;
- (void)removeObjectFromNotification_identitiesAtIndex:(NSUInteger)idx;
- (void)insertNotification_identities:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeNotification_identitiesAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInNotification_identitiesAtIndex:(NSUInteger)idx withObject:(IdentityId *)value;
- (void)replaceNotification_identitiesAtIndexes:(NSIndexSet *)indexes withNotification_identities:(NSArray *)values;
- (void)addNotification_identitiesObject:(IdentityId *)value;
- (void)removeNotification_identitiesObject:(IdentityId *)value;
- (void)addNotification_identities:(NSOrderedSet *)values;
- (void)removeNotification_identities:(NSOrderedSet *)values;

@end
