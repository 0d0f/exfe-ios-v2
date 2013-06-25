//
//  EFIOOperation.m
//  EXFE
//
//  Created by 0day on 13-6-18.
//
//

#import "EFIOOperation.h"

@implementation EFIOOperation

- (void)dealloc {
    [_savePath release];
    [_data release];
    [super dealloc];
}

- (void)operationDidStart {
    NSAssert(self.savePath, @"Should set the path to save");
    
    [super operationDidStart];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if (kEFIOOperationTypeWrite == self.operationType) {
        // write
        [fileManager createFileAtPath:self.savePath contents:self.data attributes:nil];
    } else if (kEFIOOperationTypeRead == self.operationType) {
        // read
        self.data = [NSData dataWithContentsOfFile:self.savePath];
    }
    
    [self finish];
}

- (void)operationWillFinish {
    [super operationWillFinish];
}

- (void)finish {
    [super finish];
}

@end
