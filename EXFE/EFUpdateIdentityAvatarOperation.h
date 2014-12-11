//
//  EFUpdateIdentityAvatarOperation.h
//  EXFE
//
//  Created by Stony Wang on 13-7-17.
//
//

#import "EFNetworkOperation.h"

@interface EFUpdateIdentityAvatarOperation : EFNetworkOperation

@property (nonatomic, strong) UIImage    *original;
@property (nonatomic, strong) UIImage    *avatar;
@property (nonatomic, strong) UIImage    *avatar_2x;
@property (nonatomic, copy)   NSString   *ext;
@property (nonatomic, strong) Identity   *identity;

@end
