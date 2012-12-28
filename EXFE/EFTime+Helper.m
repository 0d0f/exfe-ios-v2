//
//  EFTime+Helper.m
//  EXFE
//
//  Created by Stony Wang on 12-12-28.
//
//

#import "EFTime+Helper.h"

@implementation EFTime (Helper)

- (BOOL)hasDate{
    return self.date != nil && self.date > 0;
}

- (BOOL)hasTime{
    return self.time != nil && self.date > 0;
}

- (void) setLocalDate:(NSString*)date andTime:(NSString*)time{
    
}

- (NSString*) getLocalDate{
    return @"";    
}

- (NSString*) getLocalTime{
    return @"";
}

- (NSTimeZone*) getTargetTimeZone{
    return nil;
}

- (NSTimeZone*) getTargetTimeZoneWithDST{
    NSError *error = NULL;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"[+-]\\d{1,2}:?\\d{2}" options:NSRegularExpressionCaseInsensitive error:&error];
//    NSUInteger numberOfMatches = [regex numberOfMatchesInString:[self timezone] options:0 range:NSMakeRange(0, [[self timezone] length])];
    NSRange rangeOfFirstMatch = [regex rangeOfFirstMatchInString:[self timezone] options:0 range:NSMakeRange(0, [[self timezone] length])];
    if (!NSEqualRanges(rangeOfFirstMatch, NSMakeRange(NSNotFound, 0))) {
        NSString *machedString = [[self timezone] substringWithRange:rangeOfFirstMatch];
        
    }
    return nil;
}

- (NSTimeZone*) getLocalTimeZone{
    return [self getLocalTimeZoneWithDST];
}

- (NSTimeZone*) getLocalTimeZoneWithDST{
    return [NSTimeZone defaultTimeZone];
}

@end
