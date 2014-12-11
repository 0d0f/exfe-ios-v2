//
//  EFReverseGeocodingOperation.h
//  EXFE
//
//  Created by 0day on 13-6-27.
//
//

#import "EFNetworkOperation.h"

@interface EFReverseGeocodingOperation : EFNetworkOperation

@property (nonatomic, assign) CLLocationCoordinate2D location;

@end
