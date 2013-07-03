//
//  Exfee.h
//  EXFE
//
//  Created by huoju on 1/29/13.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Invitation;

@interface Exfee : NSManagedObject

@property (nonatomic, strong) NSNumber * accepted;
@property (nonatomic, strong) NSNumber * exfee_id;
@property (nonatomic, strong) NSNumber * total;
@property (nonatomic, strong) NSString * type;
@property (nonatomic, strong) NSSet *invitations;
@end

@interface Exfee (CoreDataGeneratedAccessors)

- (void)addInvitationsObject:(Invitation *)value;
- (void)removeInvitationsObject:(Invitation *)value;
- (void)addInvitations:(NSSet *)values;
- (void)removeInvitations:(NSSet *)values;

- (void)debugPrint;
@end
