//
//  User.h
//  EXFE
//
//  Created by ju huo on 6/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Identity;

@interface User : NSManagedObject

@property (nonatomic, retain) NSString * avatar_filename;
@property (nonatomic, retain) NSString * bio;
@property (nonatomic, retain) NSNumber * cross_quantity;
@property (nonatomic, retain) NSNumber * user_id;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * timezone;
@property (nonatomic, retain) Identity *default_identity;
@property (nonatomic, retain) NSSet *identities;
@end

@interface User (CoreDataGeneratedAccessors)

- (void)addIdentitiesObject:(Identity *)value;
- (void)removeIdentitiesObject:(Identity *)value;
- (void)addIdentities:(NSSet *)values;
- (void)removeIdentities:(NSSet *)values;

@end
