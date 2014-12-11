//
//  EFIOManagementOperation.h
//  EXFE
//
//  Created by 0day on 13-6-18.
//
//

#import "EFRunLoopOperation.h"

@class EFIOOperation;
@interface EFIOManagementOperation : EFRunLoopOperation

@property (nonatomic, strong)   EFIOOperation       *ioOperation;

@property (nonatomic, copy)     NSString            *savePath;
@property (nonatomic, strong)   NSData              *data;
@property (nonatomic, assign)   EFIOOperationType   operationType;

@property (nonatomic, copy)     CompleteBlock       completeHandler;

@end
