//
//  EFNetworkOperation.h
//  EXFE
//
//  Created by 0day on 13-6-20.
//
//

#import "EFRunLoopOperation.h"

#import "EFAPI.h"

typedef enum {
    kEFNetworkOperationStateInited,
    kEFNetworkOperationStateExecuting,
    kEFNetworkOperationStateSuccess,
    kEFNetworkOperationStateFailure,
} EFNetworkOperationState;

@interface EFNetworkOperation : EFRunLoopOperation

@property (nonatomic, assign) EXFEModel                 *model;

@property (nonatomic, assign) EFNetworkOperationState   state;
@property (nonatomic, copy)   NSString                  *successNotificationName;
@property (nonatomic, copy)   NSString                  *failureNotificationName;
@property (nonatomic, copy)   NSError                   *error; // Default as nil. set failure error when failure hanppens;

+ (instancetype)operationWithModel:(EXFEModel *)model;
- (id)initWithModel:(EXFEModel *)model;

@end
