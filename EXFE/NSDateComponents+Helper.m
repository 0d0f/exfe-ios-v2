//
//  NSDateComponents+Helper.m
//  EXFE
//
//  Created by Stony Wang on 13-1-7.
//
//

#import "NSDateComponents+Helper.h"

@implementation NSDateComponents (Helper)

- (BOOL)hasDate{
    return self.year != NSUndefinedDateComponent && self.month != NSUndefinedDateComponent && self.day != NSUndefinedDateComponent;
}

- (BOOL)hasTime{
    return self.hour != NSUndefinedDateComponent && self.minute != NSUndefinedDateComponent && self.second != NSUndefinedDateComponent;
}

- (BOOL)hasTimeZone{
    return self.timeZone != nil;
}

@end
