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

@property (nonatomic, weak) EXFEModel                 *model;

@property (nonatomic, assign) EFNetworkOperationState   state;
@property (nonatomic, copy)   NSString                  *successNotificationName;
@property (nonatomic, copy)   NSString                  *failureNotificationName;
@property (nonatomic, copy)   NSError                   *error;                     // Default as nil. Set failure error when failure hanppens.

@property (nonatomic, strong) NSMutableDictionary       *successUserInfo;           // Default as nil.
@property (nonatomic, strong) NSMutableDictionary       *failureUserInfo;           // Default as nil. if failure happens and error is not nil. this will be {@"error": $error, ...}.

@property (nonatomic, assign) NSUInteger                maxRetry;                   // Default is 3. 0 for NO max limited
@property (nonatomic, assign) NSUInteger                retryCount;                 // 

+ (instancetype)operationWithModel:(EXFEModel *)model;
+ (instancetype)operationWithModel:(EXFEModel *)model dupelicatedFrom:(EFNetworkOperation *)op;
- (id)initWithModel:(EXFEModel *)model;
- (id)initWithModel:(EXFEModel *)model dupelicateFrom:(EFNetworkOperation *)operation;

@end
