//
//  Invitation.h
//  EXFE
//
//  Created by Stony Wang on 13-7-10.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Identity, IdentityId;

@interface Invitation : NSManagedObject

@property (nonatomic, retain) NSDate * created_at;
@property (nonatomic, retain) NSNumber * host;
@property (nonatomic, retain) NSNumber * invitation_id;
@property (nonatomic, retain) NSNumber * mates;
@property (nonatomic, retain) NSString * rsvp_status;
@property (nonatomic, retain) NSString * type;
@property (nonatomic, retain) NSDate * updated_at;
@property (nonatomic, retain) NSString * via;
@property (nonatomic, retain) Identity *identity;
@property (nonatomic, retain) Identity *invited_by;
@property (nonatomic, retain) NSOrderedSet *notification_identities;
@property (nonatomic, retain) Identity *updated_by;
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
