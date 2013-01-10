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
- (BOOL)hasDateWord;
- (BOOL)hasTimeWord;

- (void)setLocalDate:(NSString*)date andTime:(NSString*)time;
- (void)setLocalDateComponents:(NSDateComponents *)datetime;
- (NSDateComponents*)getUTCDateComponent;
- (NSDateComponents*)getLocalDateComponent;
- (NSDateComponents*)getDateComponent:(NSTimeZone*)localTimeZone;

- (NSTimeZone*) getTargetTimeZone;
- (NSTimeZone*) getTargetTimeZoneWithDST;
- (NSTimeZone*) getLocalTimeZone;
- (NSTimeZone*) getLocalTimeZoneWithDST;

- (NSString*) getHumanReadableString;

@end
