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
+ (User*) getDefaultUser;
@end
