//
//  EFTime+Helper.h
//  EXFE
//
//  Created by Stony Wang on 12-12-28.
//
//

#import "EFTime.h"

@interface EFTime (Helper)

- (BOOL)hasDate;
- (BOOL)hasTime;
- (void) setLocalDate:(NSString*)date andTime:(NSString*)time;
- (NSString*) getLocalDate;
- (NSString*) getLocalTime;
- (NSTimeZone*) getTargetTimeZone;
- (NSTimeZone*) getTargetTimeZoneWithDST;
- (NSTimeZone*) getLocalTimeZone;
- (NSTimeZone*) getLocalTimeZoneWithDST;


@end
