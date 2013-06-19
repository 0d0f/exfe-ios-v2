//
//  EFQueueManager.h
//  EXFE
//
//  Created by 0day on 13-6-17.
//
//

#import <Foundation/Foundation.h>

#import "EFQueueDefines.h"

@interface EFQueueManager : NSObject

@property (nonatomic, readonly) BOOL isIOInUser;

+ (EFQueueManager *)defaultManager;

// All completeHanlder will invoke on main thread.
- (void)addIOManagementOperation:(NSOperation *)operation completeHandler:(CompleteBlock)completeHandler;
- (void)addIOOperation:(NSOperation *)operation completeHandler:(CompleteBlock)completeHandler;
- (void)addCPUOperation:(NSOperation *)operation completeHandler:(CompleteBlock)completeHandler;

- (void)cancelOperation:(NSOperation *)operation;

@end
