//
//  EFRemoveNotificationIdentityOperation.h
//  EXFE
//
//  Created by Stony Wang on 13-8-27.
//
//

#import "EFNetworkOperation.h"

@interface EFRemoveNotificationIdentityOperation : EFNetworkOperation

@property (nonatomic, strong) IdentityId *identityid;
@property (nonatomic, strong) Exfee      *exfee;
@property (nonatomic, strong) Invitation *invitation;
@property (nonatomic, strong) Identity   *byIdentity;

@end
