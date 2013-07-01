//
//  NSString+Format.m
//  EXFE
//
//  Created by 0day on 13-7-1.
//
//

#import "NSString+Format.h"

@implementation NSString (Format)

- (NSString *)stringWithoutSpace {
    return [self stringByReplacingOccurrencesOfString:@" " withString:@""];
}

@end
