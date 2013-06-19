//
//  EFRunLoopOperation.m
//  EXFE
//
//  Created by 0day on 13-6-17.
//
//

#import "EFRunLoopOperation.h"

@interface EFRunLoopOperation ()

@property (nonatomic, assign) EFRunLoopOperationState runLoopOperationState;

@end

@interface EFRunLoopOperation (Private)

- (void)startOnRunLoopThread;
- (void)cancelOnRunLoopThread;

@end

@implementation EFRunLoopOperation

- (id)init {
    self = [super init];
    if (self) {
        self.runLoopOperationState = kEFRunLoopOperationStateInited;
        self.runLoopModes = [NSSet setWithObject:NSDefaultRunLoopMode];
    }
    
    return self;
}

- (void)dealloc {
    NSAssert(kEFRunLoopOperationStateExecuting != self.runLoopOperationState, @"RunLoop should be just inited or finished.");
    [_runLoopModes release];
    [super dealloc];
}

#pragma mark - Core state transitions

- (void)setRunLoopOperationState:(EFRunLoopOperationState)runLoopOperationState {
    @synchronized (self) {
        EFRunLoopOperationState oldState = self.runLoopOperationState;
        EFRunLoopOperationState newState = runLoopOperationState;
        
        if (kEFRunLoopOperationStateExecuting == oldState || kEFRunLoopOperationStateExecuting == newState) {
            [self willChangeValueForKey:@"isExecuting"];
        }
        if (kEFRunLoopOperationStateFinished == newState) {
            [self willChangeValueForKey:@"isFinished"];
        }
        
        _runLoopOperationState = newState;
        
        if (kEFRunLoopOperationStateFinished == newState) {
            [self didChangeValueForKey:@"isFinished"];
        }
        if (kEFRunLoopOperationStateExecuting == oldState || kEFRunLoopOperationStateExecuting == newState) {
            [self didChangeValueForKey:@"isExecuting"];
        }
    }
}

- (void)startOnRunLoopThread {
    if ([self isCancelled]) {
        [self finish];
    } else {
        [self operationDidStart];
    }
}

- (void)cancelOnRunLoopThread {
    if (kEFRunLoopOperationStateExecuting == self.runLoopOperationState) {
        [self finish];
    }
}

- (void)finish {
    [self operationWillFinish];
    self.runLoopOperationState = kEFRunLoopOperationStateFinished;
}

#pragma mark - Subclass override points

- (void)operationDidStart {
    NSAssert(self.runLoopThread, @"RunLoop thread can't be nil");
}

- (void)operationWillFinish {
    NSAssert(self.runLoopThread, @"RunLoop thread can't be nil");
}

#pragma mark - Override

- (BOOL)isConcurrent {
    // any thread
    return YES;
}

- (BOOL)isExecuting {
    // any thread
    return self.runLoopOperationState == kEFRunLoopOperationStateExecuting;
}

- (BOOL)isFinished {
    // any thread
    return self.runLoopOperationState == kEFRunLoopOperationStateFinished;
}

- (void)start {
    // any thread
    
    assert(self.runLoopOperationState == kEFRunLoopOperationStateFinished);
    
    self.runLoopOperationState = kEFRunLoopOperationStateExecuting;
    
    [self performSelector:@selector(startOnRunLoopThread)
                 onThread:self.runLoopThread
               withObject:nil
            waitUntilDone:NO
                    modes:[self.runLoopModes allObjects]];
}

- (void)cancel {
    BOOL    runCancelOnRunLoopThread;
    BOOL    oldValue;
    
    // any thread
    
    // We need to synchronise here to avoid state changes to isCancelled and state
    // while we're running.
    
    @synchronized (self) {
        oldValue = [self isCancelled];
        
        // Call our super class so that isCancelled starts returning true immediately.
        
        [super cancel];
        
        // If we were the one to set isCancelled (that is, we won the race with regards
        // other threads calling -cancel) and we're actually running (that is, we lost
        // the race with other threads calling -start and the run loop thread finishing),
        // we schedule to run on the run loop thread.
        
        runCancelOnRunLoopThread = ! oldValue && self.runLoopOperationState == kEFRunLoopOperationStateExecuting;
    }
    
    if (runCancelOnRunLoopThread) {
        [self performSelector:@selector(cancelOnRunLoopThread)
                     onThread:self.runLoopThread
                   withObject:nil
                waitUntilDone:YES
                        modes:[self.runLoopModes allObjects]];
    }
}



@end
