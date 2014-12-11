//
//  Exfee.h
//  EXFE
//
//  Created by Stony Wang on 13-7-10.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Invitation;

@interface Exfee : NSManagedObject

@property (nonatomic, retain) NSNumber * accepted;
@property (nonatomic, retain) NSNumber * exfee_id;
@property (nonatomic, retain) NSNumber * total;
@property (nonatomic, retain) NSString * type;
@property (nonatomic, retain) NSSet *invitations;
@end

@interface Exfee (CoreDataGeneratedAccessors)

- (void)addInvitationsObject:(Invitation *)value;
- (void)removeInvitationsObject:(Invitation *)value;
- (void)addInvitations:(NSSet *)values;
- (void)removeInvitations:(NSSet *)values;

@end
