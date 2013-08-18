//
//  EXFEModel+IdentityAPI.h
//  EXFE
//
//  Created by Stony Wang on 13-7-17.
//
//

#import "EXFEModel.h"

@interface EXFEModel (IdentityAPI)
- (void)updateIdentity:(Identity *)identity withName:(NSString *)name withBio:(NSString *)bio;
- (void)updateIdentity:(Identity *)identity withAvatar:(UIImage *)original withLarge:(UIImage *)avatar_2x withSmall:(UIImage *)avatar withExt:(NSString *)ext;
@end
