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
#define kDefaultNetworkQueueConcurentOperationCount (4)
#define kDefaultNetworkRunloopThreadPriority        (0.3f)

@interface EFQueueManager ()
@property (nonatomic, strong) NSThread              *ioRunLoopThread;
@property (nonatomic, strong) NSThread              *networkRunLoopThread;

@property (nonatomic, strong) NSOperationQueue      *ioManagementQueue;
@property (nonatomic, strong) NSOperationQueue      *ioQueue;

@property (nonatomic, strong) NSOperationQueue      *networkManagementQueue;
@property (nonatomic, strong) NSOperationQueue      *networkQueue;

@property (nonatomic, strong) NSOperationQueue      *cpuQueue;

@property (nonatomic, strong) NSMutableDictionary   *runningOperationToHandlerMap;

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
        // io
        _ioManagementQueue = [[NSOperationQueue alloc] init];
        _ioManagementQueue.maxConcurrentOperationCount = NSIntegerMax;
        
        _ioQueue = [[NSOperationQueue alloc] init];
        _ioQueue.maxConcurrentOperationCount = kDefaultIOQueueConcurentOperationCount;
        
        _ioRunLoopThread = [[NSThread alloc] initWithTarget:self selector:@selector(ioRunloopThreadEntry) object:nil];
        _ioRunLoopThread.threadPriority = kDefaultIORunloopThreadPriority;
        [_ioRunLoopThread start];
        
        // network
        _networkManagementQueue = [[NSOperationQueue alloc] init];
        _networkManagementQueue.maxConcurrentOperationCount = NSIntegerMax;
        
        _networkQueue = [[NSOperationQueue alloc] init];
        _networkQueue.maxConcurrentOperationCount = kDefaultNetworkQueueConcurentOperationCount;
        
        _networkRunLoopThread = [[NSThread alloc] initWithTarget:self selector:@selector(networkRunLoopThreadEntry) object:nil];
        _networkRunLoopThread.threadPriority = kDefaultNetworkRunloopThreadPriority;
        [_networkRunLoopThread start];
        
        // cpu
        _cpuQueue = [[NSOperationQueue alloc] init];
        _cpuQueue.maxConcurrentOperationCount = 1;
        
        _runningOperationToHandlerMap = [[NSMutableDictionary alloc] init];
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

- (void)networkRunLoopThreadEntry {
    while (YES) {
        @autoreleasepool {
            [[NSRunLoop currentRunLoop] run];
        }
    }
}

#pragma mark - KVO

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
//            CompleteBlock block = Block_copy(handler);
            [self.runningOperationToHandlerMap setObject:handler forKey:[NSValue valueWithNonretainedObject:operation]];
//            Block_release(block);
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
    
    if ([operation respondsToSelector:@selector(setRunLoopThread:)]) {
        if ([(id)operation runLoopThread] == nil) {
            [(id)operation setRunLoopThread:self.ioRunLoopThread];
        }
    }
    [self addOperation:operation toQueue:self.ioManagementQueue completeHandler:completeHandler];
}

- (void)addIOOperation:(NSOperation *)operation completeHandler:(CompleteBlock)completeHandler {
    NSParameterAssert(operation);
    
    if ([operation respondsToSelector:@selector(setRunLoopThread:)]) {
        if ([(id)operation runLoopThread] == nil) {
            [(id)operation setRunLoopThread:self.ioRunLoopThread];
        }
    }
    [self addOperation:operation toQueue:self.ioQueue completeHandler:completeHandler];
}

- (void)addNetworkManagementOperation:(NSOperation *)operation completeHandler:(CompleteBlock)completeHandler {
    NSParameterAssert(operation);
    
    if ([operation respondsToSelector:@selector(setRunLoopThread:)]) {
        if ([(id)operation runLoopThread] == nil) {
            [(id)operation setRunLoopThread:self.networkRunLoopThread];
        }
    }
    [self addOperation:operation toQueue:self.networkManagementQueue completeHandler:completeHandler];
}

- (void)addNetworkOperation:(NSOperation *)operation completeHandler:(CompleteBlock)completeHandler {
    NSParameterAssert(operation);
    
    if ([operation respondsToSelector:@selector(setRunLoopThread:)]) {
        if ([(id)operation runLoopThread] == nil) {
            [(id)operation setRunLoopThread:self.networkRunLoopThread];
        }
    }
    [self addOperation:operation toQueue:self.networkQueue completeHandler:completeHandler];
}

- (void)addCPUOperation:(NSOperation *)operation completeHandler:(CompleteBlock)completeHandler {
    NSParameterAssert(operation);
    
    [self addOperation:operation toQueue:self.cpuQueue completeHandler:completeHandler];
}

- (void)cancelOperation:(NSOperation *)operation {
    if (operation != nil) {
        [operation cancel];
    }
}

@end
