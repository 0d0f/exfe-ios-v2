//
//  EFAPIServer+Crosses.h
//  EXFE
//
//  Created by 0day on 13-5-13.
//
//

#import "EFAPIServer.h"

@class Cross;
@interface EFAPIServer (Crosses)

- (void)loadCrossWithCrossId:(NSUInteger)corss_id
                 updatedtime:(NSDate*)updatedtime
                     success:(void (^)(RKObjectRequestOperation *operation, RKMappingResult *mappingResult))success
                     failure:(void (^)(RKObjectRequestOperation *operation, NSError *error))failure;

- (void)gatherCross:(Cross *)cross
            success:(void (^)(RKObjectRequestOperation *operation, RKMappingResult *mappingResult))success
            failure:(void (^)(RKObjectRequestOperation *operation, NSError *error))failure;

- (void)editCross:(Cross *)cross
          success:(void (^)(RKObjectRequestOperation *operation, RKMappingResult *mappingResult))success
          failure:(void (^)(RKObjectRequestOperation *operation, NSError *error))failure;

@end
