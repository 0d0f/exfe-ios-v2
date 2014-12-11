//
//  EFUpdateUserAvatarOperation.h
//  EXFE
//
//  Created by Stony Wang on 13-7-17.
//
//

#import "EFNetworkOperation.h"

@interface EFUpdateUserAvatarOperation : EFNetworkOperation

@property (nonatomic, strong) UIImage    *original;
@property (nonatomic, strong) UIImage    *avatar;
@property (nonatomic, strong) UIImage    *avatar_2x;
@property (nonatomic, copy)   NSString   *ext;


@end
