//
//  EFDownloadOperation.h
//  EXFE
//
//  Created by 0day on 13-6-24.
//
//

#import "EFNetworkOperation.h"

@interface EFDownloadOperation : EFNetworkOperation

@property (nonatomic, copy)   NSURL     *url;
@property (nonatomic, retain) NSData    *data;

@end
