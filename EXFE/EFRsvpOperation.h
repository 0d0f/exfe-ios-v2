//
//  EFRsvpOperation.h
//  EXFE
//
//  Created by Stony Wang on 13-8-27.
//
//

#import "EFNetworkOperation.h"

@interface EFRsvpOperation : EFNetworkOperation

@property (nonatomic, copy)   NSString   *rsvp;
@property (nonatomic, strong) Exfee      *exfee;
@property (nonatomic, strong) Invitation *invitation;
@property (nonatomic, strong) Identity   *byIdentity;

@end
