//
//  User.h
//  EXFE
//
//  Created by Stony Wang on 13-7-18.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Avatar, Device, Identity;

@interface User : NSManagedObject

@property (nonatomic, retain) NSString * avatar_filename;
@property (nonatomic, retain) NSString * bio;
@property (nonatomic, retain) NSDate * created_at;
@property (nonatomic, retain) NSNumber * cross_quantity;
@property (nonatomic, retain) NSString * locale;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * password;
@property (nonatomic, retain) NSString * timezone;
@property (nonatomic, retain) NSDate * updated_at;
@property (nonatomic, retain) NSNumber * user_id;
@property (nonatomic, retain) NSString * webcal;
@property (nonatomic, retain) Device *devices;
@property (nonatomic, retain) NSSet *identities;
@property (nonatomic, retain) Avatar *avatar;
@end

@interface User (CoreDataGeneratedAccessors)

- (void)addIdentitiesObject:(Identity *)value;
- (void)removeIdentitiesObject:(Identity *)value;
- (void)addIdentities:(NSSet *)values;
- (void)removeIdentities:(NSSet *)values;

@end
