//
//  User+EXFE.h
//  EXFE
//
//  Created by Stony Wang on 13-3-20.
//
//

#import "User.h"

@interface User (EXFE)

- (BOOL) isMe:(Identity*)my_identity;
- (BOOL) isMeByIdentityId:(NSNumber *)identity_id;
- (NSArray *) sortedIdentiesBy:(NSSortDescriptor*) descriptor;
- (NSArray *) sortedIdentiesById;
- (NSArray *) getIdentitiesForCrossEntry;

+ (User *) getDefaultUser;
+ (User *) getDefaultUserFrom:(EXFEModel*)model;
+ (User *) getUserById:(int)userId;
+ (User *) getUserFrom:(EXFEModel*)model byId:(int)userId;
@end
