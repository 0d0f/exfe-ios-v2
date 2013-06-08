//
//  IdentitySet.h
//  EXFE
//
//  Created by Stony Wang on 13-6-8.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class IdentityId;

@interface IdentitySet : NSManagedObject

@property (nonatomic, retain) NSOrderedSet *identities;
@end

@interface IdentitySet (CoreDataGeneratedAccessors)

- (void)insertObject:(IdentityId *)value inIdentitiesAtIndex:(NSUInteger)idx;
- (void)removeObjectFromIdentitiesAtIndex:(NSUInteger)idx;
- (void)insertIdentities:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeIdentitiesAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInIdentitiesAtIndex:(NSUInteger)idx withObject:(IdentityId *)value;
- (void)replaceIdentitiesAtIndexes:(NSIndexSet *)indexes withIdentities:(NSArray *)values;
- (void)addIdentitiesObject:(IdentityId *)value;
- (void)removeIdentitiesObject:(IdentityId *)value;
- (void)addIdentities:(NSOrderedSet *)values;
- (void)removeIdentities:(NSOrderedSet *)values;
@end
