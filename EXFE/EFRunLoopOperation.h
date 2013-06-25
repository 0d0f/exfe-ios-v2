//
//  EFRunLoopOperation.h
//  EXFE
//
//  Created by 0day on 13-6-17.
//
//

#import <Foundation/Foundation.h>

#import "EFQueueDefines.h"

typedef enum {
    kEFRunLoopOperationStateInited = 0,
    kEFRunLoopOperationStateExecuting,
    kEFRunLoopOperationStateFinished
} EFRunLoopOperationState;

@interface EFRunLoopOperation : NSOperation

@property (nonatomic, retain) NSThread                  *runLoopThread;
@property (nonatomic, copy) NSSet                       *runLoopModes;

@property (nonatomic, readonly) EFRunLoopOperationState runLoopOperationState;

// Override points

- (void)operationDidStart;
- (void)operationWillFinish;
- (void)finish;

@end
