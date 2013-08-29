//
//  EFPostConversationOperation.h
//  EXFE
//
//  Created by Stony Wang on 13-8-27.
//
//

#import "EFNetworkOperation.h"

@interface EFPostConversationOperation : EFNetworkOperation

@property (nonatomic, strong) Exfee      *exfee;
@property (nonatomic, copy)   NSString   *content;
@property (nonatomic, strong) Identity   *byIdentity;

@end
