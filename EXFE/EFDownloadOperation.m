//
//  EFDownloadOperation.m
//  EXFE
//
//  Created by 0day on 13-6-24.
//
//

#import "EFDownloadOperation.h"

@implementation EFDownloadOperation

- (void)operationDidStart {
    [super operationDidStart];
    
    NSAssert(self.url, @"url can't be nil.");
    
    NSData *data = [NSData dataWithContentsOfURL:self.url];
    self.data = data;
    
    [self finish];
}

- (void)dealloc {
    [_url release];
    [_data release];
    [super dealloc];
}

@end
