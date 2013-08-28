//
//  EFAccessInfo.m
//  EXFE
//
//  Created by 0day on 13-8-6.
//
//

#import "EFAccessInfo.h"

#import "Cross.h"

#define kDefaultDuration    (7200.0f)

@implementation EFAccessInfo

- (id)initWithCross:(Cross *)cross shouldSaveBreadcrumbs:(BOOL)shouldSave duration:(NSTimeInterval)duration {
    self = [super init];
    if (self) {
        self.cross = cross;
        self.shouldSaveBreadcrumbs = shouldSave;
        self.duration = duration;
    }
    
    return self;
}

- (id)initWithCross:(Cross *)cross shouldSaveBreadcrumbs:(BOOL)shouldSave {
    return [self initWithCross:cross shouldSaveBreadcrumbs:shouldSave duration:kDefaultDuration];
}

- (NSDictionary *)dictionaryValue {
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setValue:[NSNumber numberWithBool:self.shouldSaveBreadcrumbs] forKey:@"save_breadcrumbs"];
    
//    if (self.shouldSaveBreadcrumbs) {
//        [dict setValue:[NSNumber numberWithLong:(long)self.duration] forKey:@"after_in_seconds"];
//    }
    
    return dict;
}

@end
