//
//  Exfee.h
//  EXFE
//
//  Created by huoju on 7/17/12.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Invitation;

@interface Exfee : NSManagedObject

@property (nonatomic, retain) NSNumber * exfee_id;
@property (nonatomic, retain) NSNumber * total;
@property (nonatomic, retain) NSNumber * accepted;
@property (nonatomic, retain) NSSet *invitations;
@end

@interface Exfee (CoreDataGeneratedAccessors)

- (void)addInvitationsObject:(Invitation *)value;
- (void)removeInvitationsObject:(Invitation *)value;
- (void)addInvitations:(NSSet *)values;
- (void)removeInvitations:(NSSet *)values;

@end
