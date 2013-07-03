//
//  User.h
//  EXFE
//
//  Created by huoju on 3/1/13.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Identity;

@interface User : NSManagedObject

@property (nonatomic, strong) NSString * avatar_filename;
@property (nonatomic, strong) NSString * bio;
@property (nonatomic, strong) NSNumber * cross_quantity;
@property (nonatomic, strong) NSString * name;
@property (nonatomic, strong) NSString * timezone;
@property (nonatomic, strong) NSNumber * user_id;
@property (nonatomic, strong) NSSet *identities;
@end

@interface User (CoreDataGeneratedAccessors)

- (void)addIdentitiesObject:(Identity *)value;
- (void)removeIdentitiesObject:(Identity *)value;
- (void)addIdentities:(NSSet *)values;
- (void)removeIdentities:(NSSet *)values;

@end
