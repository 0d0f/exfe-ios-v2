//
//  EFNetworkOperation.m
//  EXFE
//
//  Created by 0day on 13-6-20.
//
//

#import "EFNetworkOperation.h"

@implementation EFNetworkOperation

+ (instancetype)operationWithModel:(EXFEModel *)model {
    return [[self alloc] initWithModel:model];
}

+ (instancetype)operationWithModel:(EXFEModel *)model dupelicatedFrom:(EFNetworkOperation *)op {
    return [[self alloc] initWithModel:model dupelicateFrom:op];
}

- (id)init {
    self = [self initWithModel:nil];
    return self;
}

- (id)initWithModel:(EXFEModel *)model {
    self = [super init];
    if (self) {
        self.model = model;
        self.state = kEFNetworkOperationStateInited;
        self.maxRetry = 3;
    }
    
    return self;
}

- (id)initWithModel:(EXFEModel *)model dupelicateFrom:(EFNetworkOperation *)operation {
    self = [self initWithModel:model];
    if (self) {
        self.retryCount = operation.retryCount + 1;
    }
    
    return self;
}


- (void)operationDidStart {
    [super operationDidStart];
}

- (void)operationWillFinish {
    [super operationWillFinish];
    
    if (![self isCancelled]) {
        if (kEFNetworkOperationStateSuccess == self.state) {
            if (self.successNotificationName && self.successNotificationName.length) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[NSNotificationCenter defaultCenter] postNotificationName:self.successNotificationName object:nil userInfo:self.successUserInfo];
                });
            }
        } else if (kEFNetworkOperationStateFailure == self.state) {
            if (self.failureNotificationName && self.failureNotificationName.length) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (self.error) {
                        if (self.failureUserInfo) {
                            self.failureUserInfo = [NSMutableDictionary dictionaryWithCapacity:1];
                        }
                        [self.failureUserInfo setValue:self.error forKey:@"error"];
                    }
                    [[NSNotificationCenter defaultCenter] postNotificationName:self.successNotificationName object:nil userInfo:self.failureUserInfo];
                });
            }
        }
    }
}

@end
