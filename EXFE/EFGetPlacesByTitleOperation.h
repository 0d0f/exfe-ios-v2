//
//  EFGetPlacesByTitleOperation.h
//  EXFE
//
//  Created by 0day on 13-6-27.
//
//

#import "EFNetworkOperation.h"

@interface EFGetPlacesByTitleOperation : EFNetworkOperation

@property (nonatomic, copy)     NSString                *title;
@property (nonatomic, assign)   CLLocationCoordinate2D  location;

@end
