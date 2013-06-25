//
//  EFIOManagementOperation.m
//  EXFE
//
//  Created by 0day on 13-6-18.
//
//

#import "EFIOManagementOperation.h"

#import "EFIOOperation.h"
#import "EFQueueManager.h"

@implementation EFIOManagementOperation

- (void)dealloc {
    [_savePath release];
    [_data release];
    
    [super dealloc];
}

- (void)operationDidStart {
    [super operationDidStart];
    
    NSAssert(self.savePath, @"should set a save path");
    
    EFIOOperation *ioOperation = [[EFIOOperation alloc] init];
    ioOperation.savePath = self.savePath;
    ioOperation.data = self.data;
    ioOperation.operationType = self.operationType;
    
    [[EFQueueManager defaultManager] addIOOperation:ioOperation
                                    completeHandler:^{
                                        self.data = ioOperation.data;
                                        [self finish];
                                    }];
}

- (void)operationWillFinish {
    [super operationWillFinish];
}

- (void)finish {
    if (self.completeHandler) {
        self.completeHandler();
    }
    
    [super finish];
}

@end
