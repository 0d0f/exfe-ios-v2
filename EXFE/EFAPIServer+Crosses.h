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

- (void)loadCrossWithCrossId:(int)corss_id
                 updatedtime:(NSString*)updatedtime
                     success:(void (^)(RKObjectRequestOperation *operation, RKMappingResult *mappingResult))success
                     failure:(void (^)(RKObjectRequestOperation *operation, NSError *error))failure;

- (void)gatherCross:(Cross *)cross
            success:(void (^)(RKObjectRequestOperation *operation, RKMappingResult *mappingResult))success
            failure:(void (^)(RKObjectRequestOperation *operation, NSError *error))failure;

- (void)editCross:(Cross *)cross
          success:(void (^)(RKObjectRequestOperation *operation, RKMappingResult *mappingResult))success
          failure:(void (^)(RKObjectRequestOperation *operation, NSError *error))failure;

@end
