//
//  EFChangeUserBasicProfileOperation.h
//  EXFE
//
//  Created by Stony Wang on 13-7-17.
//
//

#import "EFNetworkOperation.h"

@interface EFChangeUserBasicProfileOperation : EFNetworkOperation

@property (nonatomic, copy)   NSString      *name;
@property (nonatomic, copy)   NSString      *bio;

- (id)initWithModel:(EXFEModel *)model dupelicateFrom:(EFChangeUserBasicProfileOperation *)operation;

@end
