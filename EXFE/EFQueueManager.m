//
//  EFQueueManager.m
//  EXFE
//
//  Created by 0day on 13-6-17.
//
//

#import "EFQueueManager.h"

#import "EFRunLoopOperation.h"

#define kDefaultIOQueueConcurentOperationCount      (4)
#define kDefaultIORunloopThreadPriority             (0.3f)

@interface EFQueueManager ()
@property (nonatomic, retain) NSThread              *ioRunLoopThread;

@property (nonatomic, retain) NSOperationQueue      *ioManagementQueue;
@property (nonatomic, retain) NSOperationQueue      *ioQueue;
@property (nonatomic, retain) NSOperationQueue      *cpuQueue;

@property (nonatomic, retain) NSMutableDictionary   *runningOperationToHandlerMap;

@end

@interface EFQueueManager (Private)

- (void)addOperation:(NSOperation *)operation toQueue:(NSOperationQueue *)queue completeHandler:(CompleteBlock)handler;

@end

@implementation EFQueueManager

#pragma mark - Memory Management

+ (EFQueueManager *)defaultManager {
    static EFQueueManager *Manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Manager = [[self alloc] init];
    });
    
    return Manager;
}

- (id)init {
    self = [super init];
    if (self) {
        _ioManagementQueue = [[NSOperationQueue alloc] init];
        _ioManagementQueue.maxConcurrentOperationCount = NSIntegerMax;
        
        _ioQueue = [[NSOperationQueue alloc] init];
        _ioQueue.maxConcurrentOperationCount = kDefaultIOQueueConcurentOperationCount;
        
        _cpuQueue = [[NSOperationQueue alloc] init];
        _cpuQueue.maxConcurrentOperationCount = 1;
        
        _runningOperationToHandlerMap = [[NSMutableDictionary alloc] init];
        
        _ioRunLoopThread = [[NSThread alloc] initWithTarget:self selector:@selector(ioRunloopThreadEntry) object:nil];
        _ioRunLoopThread.threadPriority = kDefaultIORunloopThreadPriority;
        [_ioRunLoopThread start];
    }
    
    return self;
}

#pragma mark - IORunloop

- (void)ioRunloopThreadEntry {
    while (YES) {
        @autoreleasepool {
            [[NSRunLoop currentRunLoop] run];
        }
    }
}

#pragma mark - KVo

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([object isKindOfClass:[NSOperation class]] && [keyPath isEqualToString:@"isFinished"]) {
        NSOperation *operation = (NSOperation *)object;
        CompleteBlock completeBlock = nil;
        
        [operation removeObserver:self forKeyPath:@"isFinished"];
        
        @synchronized (self) {
            completeBlock = [self.runningOperationToHandlerMap objectForKey:[NSValue valueWithNonretainedObject:operation]];
        }
        
        if (completeBlock) {
            [self operationDone:operation];
        }
    }
}

#pragma mark - Private

- (void)addOperation:(NSOperation *)operation toQueue:(NSOperationQueue *)queue completeHandler:(CompleteBlock)handler {
    if (handler) {
        @synchronized (self) {
            [self.runningOperationToHandlerMap setObject:handler forKey:[NSValue valueWithNonretainedObject:operation]];
        }
    }
    
    [operation addObserver:self
                forKeyPath:@"isFinished"
                   options:NSKeyValueObservingOptionNew
                   context:NULL];
    [queue addOperation:operation];
}

- (void)operationDone:(NSOperation *)operation {
    CompleteBlock completeBlock = nil;
    
    @synchronized (self) {
        completeBlock = [self.runningOperationToHandlerMap objectForKey:[NSValue valueWithNonretainedObject:operation]];
        [self.runningOperationToHandlerMap removeObjectForKey:[NSValue valueWithNonretainedObject:operation]];
    }
    
    if (![operation isCancelled] && completeBlock) {
        dispatch_async(dispatch_get_main_queue(), ^{
            completeBlock();
        });
    }
}

#pragma mark - Public

- (void)addIOManagementOperation:(NSOperation *)operation completeHandler:(CompleteBlock)completeHandler {
    NSParameterAssert(operation);
    NSParameterAssert(completeHandler);
    
    if ([operation respondsToSelector:@selector(setRunLoopThread:)]) {
        if ([(id)operation runLoopThread] == nil) {
            [(id)operation setRunLoopThread:self.ioRunLoopThread];
        }
    }
    [self addOperation:operation toQueue:self.ioManagementQueue completeHandler:completeHandler];
}

- (void)addIOOperation:(NSOperation *)operation completeHandler:(CompleteBlock)completeHandler {
    NSParameterAssert(operation);
    NSParameterAssert(completeHandler);
    
    if ([operation respondsToSelector:@selector(setRunLoopThread:)]) {
        if ([(id)operation runLoopThread] == nil) {
            [(id)operation setRunLoopThread:self.ioRunLoopThread];
        }
    }
    [self addOperation:operation toQueue:self.ioQueue completeHandler:completeHandler];
}

- (void)addCPUOperation:(NSOperation *)operation completeHandler:(CompleteBlock)completeHandler {
    NSParameterAssert(operation);
    NSParameterAssert(completeHandler);
    
    [self addOperation:operation toQueue:self.cpuQueue completeHandler:completeHandler];
}

- (void)cancelOperation:(NSOperation *)operation {
    if (operation != nil) {
        [operation cancel];
    }
}

@end
