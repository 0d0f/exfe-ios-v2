//
//  CrossTime+Helper.h
//  EXFE
//
//  Created by Stony Wang on 13-1-4.
//
//

#import "CrossTime.h"

@interface CrossTime (Helper)

- (NSString*) getTimeTitle;
- (NSString*) getTimeTitle:(NSUInteger)fmt;
- (NSString*) getTimeDescription;
- (NSString*) getTimeSingleLine;
- (NSString*) getTimeZoneLine;

@end
