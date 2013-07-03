//
//  EXFEModel+Place.m
//  EXFE
//
//  Created by 0day on 13-6-27.
//
//

#import "EXFEModel+Place.h"

#import "EFKit.h"
#import "EFAPIOperations.h"

@implementation EXFEModel (Place)

- (void)reverseGeocodingWithLocation:(CLLocationCoordinate2D)location {
    EFReverseGeocodingOperation *reverseGeocodingOperation = [EFReverseGeocodingOperation operationWithModel:self];
    reverseGeocodingOperation.location = location;
    
    EFNetworkManagementOperation *managementOperation = [[EFNetworkManagementOperation alloc] initWithNetworkOperation:reverseGeocodingOperation];
    
    [[EFQueueManager defaultManager] addNetworkManagementOperation:managementOperation completeHandler:nil];
    
}

- (void)getPlacesNearbyWithLocation:(CLLocationCoordinate2D)location {

}

- (void)getPlacesByTitle:(NSString *)title location:(CLLocationCoordinate2D)location {
    EFGetPlacesByTitleOperation *getPlacesBytTitleOperation = [EFGetPlacesByTitleOperation operationWithModel:self];
    getPlacesBytTitleOperation.title = title;
    getPlacesBytTitleOperation.location = location;
    
    EFNetworkManagementOperation *managementOperation = [[EFNetworkManagementOperation alloc] initWithNetworkOperation:getPlacesBytTitleOperation];
    
    [[EFQueueManager defaultManager] addNetworkManagementOperation:managementOperation completeHandler:nil];
    
}

@end
