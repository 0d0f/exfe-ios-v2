//
//  EFRemoveMyInvitationOperation.h
//  EXFE
//
//  Created by Stony Wang on 13-8-23.
//
//

#import "EFNetworkOperation.h"

@interface EFRemoveMyInvitationOperation : EFNetworkOperation

@property (nonatomic, strong) Exfee *exfee;
@property (nonatomic, strong) Invitation *invitation;

@end
