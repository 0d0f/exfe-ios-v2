//
//  CrossTime+Helper.m
//  EXFE
//
//  Created by Stony Wang on 13-1-4.
//
//

#import "CrossTime+Helper.h"
#import "EFTime.h"
#import "EFTime+Helper.h"
#import "Util.h"
#import "DateTimeUtil.h"

@implementation CrossTime (Helper)


- (NSString*) getTimeTitle{
    if( [self.outputformat intValue] == 1) { //use origin
        return [CrossTime getRaw:self.origin];
    }else{
        if ([self.begin_at hasDate]){
            return [DateTimeUtil GetRelativeTime:[self.begin_at getLocalDateComponent] format:0];
        }else{
            if ([self.begin_at hasTime]) {
                return [self.begin_at getHumanReadableString];
            }else{
                if ([self.begin_at hasTimeWord]  || [self.begin_at hasDateWord]) {
                    return [self.begin_at getHumanReadableString];
                }else{
                    return @"";
                }
            }
        }
    }
}

- (NSString*) getTimeDescription{
    if( [self.outputformat intValue] == 1) { //use origin
        if ([self.begin_at hasDate] && [self.begin_at hasTime]) {
            return [DateTimeUtil GetRelativeTime:[self.begin_at getLocalDateComponent] format:0];
        }else{
            return @"";
        }
    }else{
        if ([self.begin_at hasDate]){
            return [self.begin_at getHumanReadableString];
        }else{
            return @"";
        }
    }
}

- (NSString*) getTimeSingleLine{
    if( [self.outputformat intValue] == 1) { //use origin
        return [CrossTime getRaw:self.origin];
    }else{
        return [self.begin_at getHumanReadableString];
    }
}

+ (BOOL)isQuated:(NSString*)str{
    if (str != nil && [str length] > 1) {
        unichar first = [str characterAtIndex:0];
        unichar last = [str characterAtIndex:[str length] - 1];
        if (first == last) {
            return first == '\'' || first == '"';
        }
    }
    return NO;
}

+ (NSString*) getRaw:(NSString*)orginal{
    if ([CrossTime isQuated:orginal]) {
        return [orginal substringWithRange:NSMakeRange(1, [orginal length] - 2)];
    }
    return orginal;
}

@end
