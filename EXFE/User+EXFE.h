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
- (NSArray*) sortedIdentiesBy:(NSSortDescriptor*) descriptor;
- (NSArray*) sortedIdentiesById;

+ (User*) getDefaultUser;
+ (User*) getUserById:(int)userId;
@end
