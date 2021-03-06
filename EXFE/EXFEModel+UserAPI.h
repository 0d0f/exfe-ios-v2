//
//  EXFEModel+UserAPI.h
//  EXFE
//
//  Created by 0day on 13-6-26.
//
//

#import "EXFEModel.h"

@interface EXFEModel (UserAPI)

- (void)loadMe;
- (void)loadUserByUserId:(NSInteger)userId;
- (void)loadUserByUserId:(NSInteger)userId andToken:(NSString *)token;
- (void)updateUserName:(NSString *)name withBio:(NSString *)bio;
- (void)updateUserAvatar:(UIImage *)original withLarge:(UIImage *)avatar_2x withSmall:(UIImage *)avatar withExt:(NSString *)ext;
@end
