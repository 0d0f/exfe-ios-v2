//
//  NSObject+PerformBlockAfterDelay.h
//  EXFE
//
//  Created by huoju on 1/3/13.
//
//

#import <Foundation/Foundation.h>

@interface NSObject (PerformBlockAfterDelay)
- (void)performBlock:(void (^)(void))block afterDelay:(NSTimeInterval)delay;
@end
