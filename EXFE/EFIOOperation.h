//
//  EFIOOperation.h
//  EXFE
//
//  Created by 0day on 13-6-18.
//
//

#import "EFRunLoopOperation.h"

#import "EFQueueDefines.h"

@interface EFIOOperation : EFRunLoopOperation

@property (nonatomic, copy)     NSString            *savePath;              // can't be nil. if the path is not exist, operation will create it.
@property (nonatomic, strong)   NSData              *data;                  // can't be nil for write.
@property (nonatomic, assign)   EFIOOperationType   operationType;

@end
