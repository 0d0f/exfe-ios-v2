//
//  Exfee.h
//  EXFE
//
//  Created by ju huo on 5/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Invitation;

@interface Exfee : NSManagedObject

@property (nonatomic, retain) NSNumber * exfee_id;
@property (nonatomic, retain) NSSet *invitations;
@end

@interface Exfee (CoreDataGeneratedAccessors)

- (void)addInvitationsObject:(Invitation *)value;
- (void)removeInvitationsObject:(Invitation *)value;
- (void)addInvitations:(NSSet *)values;
- (void)removeInvitations:(NSSet *)values;

@end
