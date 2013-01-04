//
//  NSObject+PerformBlockAfterDelay.m
//  EXFE
//
//  Created by huoju on 1/3/13.
//
//

#import "NSObject+PerformBlockAfterDelay.h"

@implementation NSObject (PerformBlockAfterDelay)
- (void)performBlock:(void (^)(void))block
          afterDelay:(NSTimeInterval)delay
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    block = [[block copy] autorelease];
    [self performSelector:@selector(fireBlockAfterDelay:)
               withObject:block
               afterDelay:delay];
}

- (void)fireBlockAfterDelay:(void (^)(void))block {
    block();
}
@end
