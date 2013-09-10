//
//  EXFETests.m
//  EXFETests
//
//  Created by Stony Wang on 13-1-22.
//
//

#import "EXFETests.h"
#import <RestKit/CoreData.h>
#import "EFEntity.h"
#import "DateTimeUtil.h"


@interface EXFETests (){
    
    
}

@property (nonatomic, strong) EXFEModel *model;
@property (nonatomic, strong) NSManagedObjectContext *moc;

@end

@implementation EXFETests

- (void)setUp
{
    [super setUp];
    
    // Set-up code here.
    
    //[DateTimeUtil setAppDefaultTimeZone:<#(NSTimeZone *)#>]
    //[DateTimeUtil setNow:<#(NSDate *)#>]
    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    self.model = delegate.model;
    self.moc = self.model.objectManager.managedObjectStore.mainQueueManagedObjectContext;
}

- (void)tearDown
{
    // Tear-down code here.
    [DateTimeUtil clearNow];
    [DateTimeUtil clearAppDefaultTimeZone];
    
    [super tearDown];
}

- (void)testOnce
{
    NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
    [fmt setDateFormat:@"yyyy-MM-dd HH:mm:ss Z"];
    NSDate *now = [fmt dateFromString:@"2013-01-13 08:41:00 +0800"];
    NSDate *then = [NSDate dateWithTimeInterval:20 * 3600 sinceDate:now];
    NSLog(@"%@", [fmt stringFromDate:now]);
    NSLog(@"%@", [fmt stringFromDate:then]);
    int a = [DateTimeUtil daysWithinEraFromDate:now toDate:then];
    NSLog(@"fun1: %i by offset", a);
    int b = [DateTimeUtil daysWithinEraFromDate:now toDate:then baseTimeZone:[NSTimeZone localTimeZone]];
    NSLog(@"fun2: %i %@", b, [NSTimeZone localTimeZone]);
    int c = [DateTimeUtil daysWithinEraFromDate:now toDate:then baseTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
    NSLog(@"fun3: %i UTC", c);
    int d = [DateTimeUtil daysWithinEraFromDate:now toDate:then baseTimeZone:[NSTimeZone timeZoneWithName:@"Asia/Shanghai"]];
    NSLog(@"fun4: %i Asia/Shanghai", d );
    int e = [DateTimeUtil daysWithinEraFromDate:now toDate:then baseTimeZone:[NSTimeZone timeZoneWithName:@"PST8PDT"]];
    NSLog(@"fun4: %i PST8PDT", e );
    STAssertTrue(YES, @"OK");
    
    //STFail(@"Unit tests are not implemented yet in EXFETests");
}


- (void)setNow:(NSString*)nowStr{
    NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
    [fmt setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *now = [fmt dateFromString:nowStr];
    [DateTimeUtil setNow:now];
}

- (void)testThisYearFullDateTime
{
    [self setNow:@"2013-01-12 14:23:05"];
    
    EFTime* eftime = [EFTime object:self.moc];
    eftime.date = @"2013-01-12";
    eftime.time = @"06:20:04";
    eftime.timezone = @"+08:00 CST";
    
    STAssertEqualObjects([eftime getHumanReadableString], @"2:20PM Sat, Jan 12", @"Date time");
}

- (void)testLastYearFullDateTime
{
    [self setNow:@"2013-01-12 14:23:05"];
    
    EFTime* eftime = [EFTime object:self.moc];
    eftime.date = @"2012-01-12";
    eftime.time = @"06:20:04";
    eftime.timezone = @"+08:00 CST";
    
    STAssertEqualObjects([eftime getHumanReadableString], @"2:20PM Thu, Jan 12 2012", @"Date time");
}

- (void)testCrossTimeBasicSecondsAgo
{
    CrossTime *xt = [CrossTime  object:self.moc];
    xt.origin = @"";
    xt.outputformat = [NSNumber numberWithInt:0];
    
    NSDate* today = [NSDate date];
    NSDate* target = [NSDate dateWithTimeInterval:-1 sinceDate:today];
    NSDateFormatter* fmt = [[NSDateFormatter alloc] init];
    EFTime* eftime = [EFTime object:self.moc];
    [fmt setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
    [fmt setDateFormat:@"yyyy-MM-dd"];
    eftime.date = [fmt stringFromDate:target];
    [fmt setDateFormat:@"HH:mm:ss"];
    eftime.time = [fmt stringFromDate:target];
    eftime.timezone = [DateTimeUtil timezoneString: fmt.timeZone];
    xt.begin_at = eftime;
    
    [fmt setTimeZone:[NSTimeZone localTimeZone]];
    [fmt setDateFormat:@"h:mma EEE, MMM d"];
    NSString* expected = [fmt stringFromDate:[NSDate date]];
    STAssertEqualObjects([xt getTimeTitle], @"now", @"Title");
    STAssertEqualObjects([xt getTimeDescription], expected, @"Description");
    STAssertEqualObjects([xt getTimeSingleLine], expected, @"One Line");
}

- (void)testCrossTimeBasicToday
{
    CrossTime *xt = [CrossTime  object:self.moc];
    xt.origin = @"";
    xt.outputformat = [NSNumber numberWithInt:0];
    
    NSDate* today = [NSDate date];
    NSDate* target = [NSDate dateWithTimeInterval:-1 sinceDate:today];
    NSDateFormatter* fmt = [[NSDateFormatter alloc] init];
    EFTime* eftime = [EFTime  object:self.moc];
    [fmt setDateFormat:@"yyyy-MM-dd"];
    eftime.date = [fmt stringFromDate:target];
    eftime.time = @"";
    eftime.timezone = [DateTimeUtil timezoneString: fmt.timeZone];
    xt.begin_at = eftime;
    
    [fmt setDateFormat:@"EEE, MMM d"];
    NSString* expected = [fmt stringFromDate:[NSDate date]];
    STAssertEqualObjects([xt getTimeTitle], @"today", @"Title");
    STAssertEqualObjects([xt getTimeDescription], expected, @"Description");
    STAssertEqualObjects([xt getTimeSingleLine], expected, @"One Line");
}

- (void)testEFTimeFullSuite
{
    [self setNow:@"2013-01-12 14:23:05"];
    
    EFTime *eftime = [EFTime  object:self.moc];
    eftime.timezone = @"+08:00 CST";
    
    // Valid Date & Time
    eftime.date = @"2013-01-12";
    eftime.date_word = @"";
    eftime.time = @"06:23:00";
    eftime.time_word = @"";
    STAssertEqualObjects([eftime getHumanReadableString], @"2:23PM Sat, Jan 12", @"Title");
    STAssertEqualObjects([eftime getTimeZoneString], @"", @"TimeZone");
    
    eftime.date = @"2013-01-12";
    eftime.date_word = @"";
    eftime.time = @"06:23:00";
    eftime.time_word = @"Dinner";
    STAssertEqualObjects([eftime getHumanReadableString], @"Dinner 2:23PM Sat, Jan 12", @"Title");
    STAssertEqualObjects([eftime getTimeZoneString], @"", @"TimeZone");
    
    eftime.date = @"2013-01-12";
    eftime.date_word = @"Super";
    eftime.time = @"06:23:00";
    eftime.time_word = @"";
    STAssertEqualObjects([eftime getHumanReadableString], @"2:23PM Sat, Jan 12 Super", @"Title");
    STAssertEqualObjects([eftime getTimeZoneString], @"", @"TimeZone");
    
    eftime.date = @"2013-01-12";
    eftime.date_word = @"Super";
    eftime.time = @"06:23:00";
    eftime.time_word = @"Dinner";
    STAssertEqualObjects([eftime getHumanReadableString], @"Dinner 2:23PM Sat, Jan 12 Super", @"Title");
    STAssertEqualObjects([eftime getTimeZoneString], @"", @"TimeZone");
    
    // Only Valide Date
    eftime.date = @"2013-01-12";
    eftime.date_word = @"";
    eftime.time = @"";
    eftime.time_word = @"";
    STAssertEqualObjects([eftime getHumanReadableString], @"Sat, Jan 12", @"Title");
    STAssertEqualObjects([eftime getTimeZoneString], @"", @"TimeZone");
    
    eftime.date = @"2013-01-12";
    eftime.date_word = @"Super";
    eftime.time = @"";
    eftime.time_word = @"";
    STAssertEqualObjects([eftime getHumanReadableString], @"Sat, Jan 12 Super", @"Title");
    STAssertEqualObjects([eftime getTimeZoneString], @"", @"TimeZone");
    
    eftime.date = @"2013-01-12";
    eftime.date_word = @"";
    eftime.time = @"";
    eftime.time_word = @"Dinner";
    STAssertEqualObjects([eftime getHumanReadableString], @"Dinner, Sat, Jan 12", @"Title");
    STAssertEqualObjects([eftime getTimeZoneString], @"", @"TimeZone");
    
    eftime.date = @"2013-01-12";
    eftime.date_word = @"Super";
    eftime.time = @"";
    eftime.time_word = @"Dinner";
    STAssertEqualObjects([eftime getHumanReadableString], @"Dinner, Sat, Jan 12 Super", @"Title");
    STAssertEqualObjects([eftime getTimeZoneString], @"", @"TimeZone");
    
    // Only Valide Time
    eftime.date = @"";
    eftime.date_word = @"";
    eftime.time = @"06:23:00";
    eftime.time_word = @"";
    STAssertEqualObjects([eftime getHumanReadableString], @"2:23PM", @"Title");
    STAssertEqualObjects([eftime getTimeZoneString], @"", @"TimeZone");
    
    eftime.date = @"";
    eftime.date_word = @"Someday";
    eftime.time = @"06:23:00";
    eftime.time_word = @"";
    STAssertEqualObjects([eftime getHumanReadableString], @"2:23PM, Someday", @"Title");
    STAssertEqualObjects([eftime getTimeZoneString], @"", @"TimeZone");
    
    eftime.date = @"";
    eftime.date_word = @"";
    eftime.time = @"06:23:00";
    eftime.time_word = @"Dinner";
    STAssertEqualObjects([eftime getHumanReadableString], @"Dinner 2:23PM", @"Title");
    STAssertEqualObjects([eftime getTimeZoneString], @"", @"TimeZone");
    
    eftime.date = @"";
    eftime.date_word = @"Someday";
    eftime.time = @"06:23:00";
    eftime.time_word = @"Dinner";
    STAssertEqualObjects([eftime getHumanReadableString], @"Dinner 2:23PM, Someday", @"Title");
    STAssertEqualObjects([eftime getTimeZoneString], @"", @"TimeZone");
    
    // no Date & Time
    eftime.date = @"";
    eftime.date_word = @"";
    eftime.time = @"";
    eftime.time_word = @"";
    STAssertEqualObjects([eftime getHumanReadableString], @"", @"Title");
    STAssertEqualObjects([eftime getTimeZoneString], @"", @"TimeZone");
    
    eftime.date = @"";
    eftime.date_word = @"";
    eftime.time = @"";
    eftime.time_word = @"Dinner";
    STAssertEqualObjects([eftime getHumanReadableString], @"Dinner", @"Title");
    STAssertEqualObjects([eftime getTimeZoneString], @"", @"TimeZone");
    
    eftime.date = @"";
    eftime.date_word = @"Someday";
    eftime.time = @"";
    eftime.time_word = @"";
    STAssertEqualObjects([eftime getHumanReadableString], @"Someday", @"Title");
    STAssertEqualObjects([eftime getTimeZoneString], @"", @"TimeZone");
    
    eftime.date = @"";
    eftime.date_word = @"Someday";
    eftime.time = @"";
    eftime.time_word = @"Dinner";
    STAssertEqualObjects([eftime getHumanReadableString], @"Dinner, Someday", @"Title");
    STAssertEqualObjects([eftime getTimeZoneString], @"", @"TimeZone");
    
    // Different TimeZone
    eftime.timezone = @"+09:00 JST";
    
    // Valid Date & Time
    eftime.date = @"2013-01-12";
    eftime.date_word = @"";
    eftime.time = @"06:23:00";
    eftime.time_word = @"";
    STAssertEqualObjects([eftime getHumanReadableString], @"2:23PM Sat, Jan 12", @"Title");
    STAssertEqualObjects([eftime getTimeZoneString], @"+08:00", @"TimeZone");
    
    eftime.date = @"2013-01-12";
    eftime.date_word = @"";
    eftime.time = @"06:23:00";
    eftime.time_word = @"Dinner";
    STAssertEqualObjects([eftime getHumanReadableString], @"Dinner 2:23PM Sat, Jan 12", @"Title");
    STAssertEqualObjects([eftime getTimeZoneString], @"+08:00", @"TimeZone");
    
    eftime.date = @"2013-01-12";
    eftime.date_word = @"Super";
    eftime.time = @"06:23:00";
    eftime.time_word = @"";
    STAssertEqualObjects([eftime getHumanReadableString], @"2:23PM Sat, Jan 12 Super", @"Title");
    STAssertEqualObjects([eftime getTimeZoneString], @"+08:00", @"TimeZone");
    
    eftime.date = @"2013-01-12";
    eftime.date_word = @"Super";
    eftime.time = @"06:23:00";
    eftime.time_word = @"Dinner";
    STAssertEqualObjects([eftime getHumanReadableString], @"Dinner 2:23PM Sat, Jan 12 Super", @"Title");
    STAssertEqualObjects([eftime getTimeZoneString], @"+08:00", @"TimeZone");
    
    // Only Valide Date
    eftime.date = @"2013-01-12";
    eftime.date_word = @"";
    eftime.time = @"";
    eftime.time_word = @"";
    STAssertEqualObjects([eftime getHumanReadableString], @"Sat, Jan 12", @"Title");
    STAssertEqualObjects([eftime getTimeZoneString], @"+09:00 JST", @"TimeZone");
    
    eftime.date = @"2013-01-12";
    eftime.date_word = @"Super";
    eftime.time = @"";
    eftime.time_word = @"";
    STAssertEqualObjects([eftime getHumanReadableString], @"Sat, Jan 12 Super", @"Title");
    STAssertEqualObjects([eftime getTimeZoneString], @"+09:00 JST", @"TimeZone");
    
    eftime.date = @"2013-01-12";
    eftime.date_word = @"";
    eftime.time = @"";
    eftime.time_word = @"Dinner";
    STAssertEqualObjects([eftime getHumanReadableString], @"Dinner, Sat, Jan 12", @"Title");
    STAssertEqualObjects([eftime getTimeZoneString], @"+09:00 JST", @"TimeZone");
    
    eftime.date = @"2013-01-12";
    eftime.date_word = @"Super";
    eftime.time = @"";
    eftime.time_word = @"Dinner";
    STAssertEqualObjects([eftime getHumanReadableString], @"Dinner, Sat, Jan 12 Super", @"Title");
    STAssertEqualObjects([eftime getTimeZoneString], @"+09:00 JST", @"TimeZone");
    
    // Only Valide Time
    eftime.date = @"";
    eftime.date_word = @"";
    eftime.time = @"06:23:00";
    eftime.time_word = @"";
    STAssertEqualObjects([eftime getHumanReadableString], @"2:23PM", @"Title");
    STAssertEqualObjects([eftime getTimeZoneString], @"+08:00", @"TimeZone");
    
    eftime.date = @"";
    eftime.date_word = @"Someday";
    eftime.time = @"06:23:00";
    eftime.time_word = @"";
    STAssertEqualObjects([eftime getHumanReadableString], @"2:23PM, Someday", @"Title");
    STAssertEqualObjects([eftime getTimeZoneString], @"+08:00", @"TimeZone");
    
    eftime.date = @"";
    eftime.date_word = @"";
    eftime.time = @"06:23:00";
    eftime.time_word = @"Dinner";
    STAssertEqualObjects([eftime getHumanReadableString], @"Dinner 2:23PM", @"Title");
    STAssertEqualObjects([eftime getTimeZoneString], @"+08:00", @"TimeZone");
    
    eftime.date = @"";
    eftime.date_word = @"Someday";
    eftime.time = @"06:23:00";
    eftime.time_word = @"Dinner";
    STAssertEqualObjects([eftime getHumanReadableString], @"Dinner 2:23PM, Someday", @"Title");
    STAssertEqualObjects([eftime getTimeZoneString], @"+08:00", @"TimeZone");
    
    // no Date & Time
    eftime.date = @"";
    eftime.date_word = @"";
    eftime.time = @"";
    eftime.time_word = @"";
    STAssertEqualObjects([eftime getHumanReadableString], @"", @"Title");
    STAssertEqualObjects([eftime getTimeZoneString], @"+09:00 JST", @"TimeZone");
    
    eftime.date = @"";
    eftime.date_word = @"";
    eftime.time = @"";
    eftime.time_word = @"Dinner";
    STAssertEqualObjects([eftime getHumanReadableString], @"Dinner", @"Title");
    STAssertEqualObjects([eftime getTimeZoneString], @"+09:00 JST", @"TimeZone");
    
    eftime.date = @"";
    eftime.date_word = @"Someday";
    eftime.time = @"";
    eftime.time_word = @"";
    STAssertEqualObjects([eftime getHumanReadableString], @"Someday", @"Title");
    STAssertEqualObjects([eftime getTimeZoneString], @"+09:00 JST", @"TimeZone");
    
    eftime.date = @"";
    eftime.date_word = @"Someday";
    eftime.time = @"";
    eftime.time_word = @"Dinner";
    STAssertEqualObjects([eftime getHumanReadableString], @"Dinner, Someday", @"Title");
    STAssertEqualObjects([eftime getTimeZoneString], @"+09:00 JST", @"TimeZone");
}

- (void)testEFTimeExtendSuite
{
    [self setNow:@"2013-01-12 14:23:05"];
    
    EFTime *eftime = [EFTime object:self.moc];
    eftime.timezone = @"+08:00 CST";
    
    // Valid Date & Time
    eftime.date = @"2013-01-12";
    eftime.date_word = @"";
    eftime.time = @"06:23:00 +0000";
    eftime.time_word = @"";
    STAssertEqualObjects([eftime getHumanReadableString], @"2:23PM Sat, Jan 12", @"Title");
    STAssertEqualObjects([eftime getTimeZoneString], @"", @"TimeZone");
    
    // Valid Date & Time
    eftime.date = @"";
    eftime.date_word = @"";
    eftime.time = @"14:23:00 +0800";
    eftime.time_word = @"";
    STAssertEqualObjects([eftime getHumanReadableString], @"2:23PM", @"Title");
    STAssertEqualObjects([eftime getTimeZoneString], @"", @"TimeZone");
}

- (void)testXRelativeTimeFullSuite
{
    [self setNow:@"2013-01-12 14:23:05"];
    
    EFTime *eftime = [EFTime  object:self.moc];
    eftime.timezone = @"+08:00 CST";
    
    // Same timezone, full date and time
    // seconds ago
    eftime.date = @"2013-01-12";
    eftime.date_word = @"";
    eftime.time = @"06:23:00";
    eftime.time_word = @"";
    STAssertEqualObjects([DateTimeUtil GetRelativeTime:[eftime getLocalDateComponent] format:0], @"seconds ago", @"Title");
    STAssertEqualObjects([DateTimeUtil GetRelativeTime:[eftime getLocalDateComponent] format:1], @"now", @"Title");
    // Now
    eftime.time = @"06:21:00";
    STAssertEqualObjects([DateTimeUtil GetRelativeTime:[eftime getLocalDateComponent] format:0], @"2 minutes ago", @"Title");
    STAssertEqualObjects([DateTimeUtil GetRelativeTime:[eftime getLocalDateComponent] format:1], @"now", @"Title");
    // Just Now
    eftime.time = @"05:39:00";
    STAssertEqualObjects([DateTimeUtil GetRelativeTime:[eftime getLocalDateComponent] format:0], @"44 minutes ago", @"Title");
    STAssertEqualObjects([DateTimeUtil GetRelativeTime:[eftime getLocalDateComponent] format:1], @"just now", @"Title");
    // An hour ago
    eftime.time = @"05:20:00";
    STAssertEqualObjects([DateTimeUtil GetRelativeTime:[eftime getLocalDateComponent] format:0], @"an hour ago", @"Title");
    STAssertEqualObjects([DateTimeUtil GetRelativeTime:[eftime getLocalDateComponent] format:1], @"an hour ago", @"Title");
    // 1.5 hours ago
    eftime.time = @"04:50:00";
    STAssertEqualObjects([DateTimeUtil GetRelativeTime:[eftime getLocalDateComponent] format:0], @"1.5 hours ago", @"Title");
    STAssertEqualObjects([DateTimeUtil GetRelativeTime:[eftime getLocalDateComponent] format:1], @"1.5 hours ago", @"Title");
    // n hours ago, round up
    eftime.time = @"01:3:00";
    STAssertEqualObjects([DateTimeUtil GetRelativeTime:[eftime getLocalDateComponent] format:0], @"5 hours ago", @"Title");
    STAssertEqualObjects([DateTimeUtil GetRelativeTime:[eftime getLocalDateComponent] format:1], @"5 hours ago", @"Title");
    // n hours ago, round down
    eftime.time = @"01:20:00";
    STAssertEqualObjects([DateTimeUtil GetRelativeTime:[eftime getLocalDateComponent] format:0], @"5 hours ago", @"Title");
    STAssertEqualObjects([DateTimeUtil GetRelativeTime:[eftime getLocalDateComponent] format:1], @"5 hours ago", @"Title");
    //
    eftime.date = @"2013-01-11";
    eftime.time = @"16:01:00";
    STAssertEqualObjects([DateTimeUtil GetRelativeTime:[eftime getLocalDateComponent] format:0], @"14 hours ago", @"Title");
    STAssertEqualObjects([DateTimeUtil GetRelativeTime:[eftime getLocalDateComponent] format:1], @"14 hours ago", @"Title");
    // Yesterday
    eftime.date = @"2013-01-11";
    eftime.time = @"13:20:00";
    STAssertEqualObjects([DateTimeUtil GetRelativeTime:[eftime getLocalDateComponent] format:0], @"yesterday", @"Title");
    STAssertEqualObjects([DateTimeUtil GetRelativeTime:[eftime getLocalDateComponent] format:1], @"yesterday", @"Title");
    // Yesterday
    eftime.date = @"2013-01-11";
    eftime.time = @"02:00:00";
    STAssertEqualObjects([DateTimeUtil GetRelativeTime:[eftime getLocalDateComponent] format:0], @"yesterday", @"Title");
    STAssertEqualObjects([DateTimeUtil GetRelativeTime:[eftime getLocalDateComponent] format:1], @"yesterday", @"Title");
    // Two days ago
    eftime.date = @"2013-01-10";
    eftime.time = @"14:00:00";
    STAssertEqualObjects([DateTimeUtil GetRelativeTime:[eftime getLocalDateComponent] format:0], @"two days ago", @"Title");
    STAssertEqualObjects([DateTimeUtil GetRelativeTime:[eftime getLocalDateComponent] format:1], @"two days ago", @"Title");
    // Two days ago
    eftime.date = @"2013-01-10";
    eftime.time = @"03:00:00";
    STAssertEqualObjects([DateTimeUtil GetRelativeTime:[eftime getLocalDateComponent] format:0], @"two days ago", @"Title");
    STAssertEqualObjects([DateTimeUtil GetRelativeTime:[eftime getLocalDateComponent] format:1], @"two days ago", @"Title");
    // 3 days ago
    eftime.date = @"2013-01-09";
    eftime.time = @"14:00:00";
    STAssertEqualObjects([DateTimeUtil GetRelativeTime:[eftime getLocalDateComponent] format:0], @"3 days ago", @"Title");
    STAssertEqualObjects([DateTimeUtil GetRelativeTime:[eftime getLocalDateComponent] format:1], @"3 days ago", @"Title");
    // 29 days ago
    eftime.date = @"2012-12-14";
    eftime.time = @"14:00:00";
    STAssertEqualObjects([DateTimeUtil GetRelativeTime:[eftime getLocalDateComponent] format:0], @"29 days ago", @"Title");
    STAssertEqualObjects([DateTimeUtil GetRelativeTime:[eftime getLocalDateComponent] format:1], @"29 days ago", @"Title");
    // 1 month ago
    eftime.date = @"2012-12-10";
    eftime.time = @"14:00:00";
    STAssertEqualObjects([DateTimeUtil GetRelativeTime:[eftime getLocalDateComponent] format:0], @"1 month ago", @"Title");
    STAssertEqualObjects([DateTimeUtil GetRelativeTime:[eftime getLocalDateComponent] format:1], @"1 month ago", @"Title");
    // 2 month ago
    eftime.date = @"2012-11-15";
    eftime.time = @"14:00:00";
    STAssertEqualObjects([DateTimeUtil GetRelativeTime:[eftime getLocalDateComponent] format:0], @"2 months ago", @"Title");
    STAssertEqualObjects([DateTimeUtil GetRelativeTime:[eftime getLocalDateComponent] format:1], @"2 months ago", @"Title");
    // 12 months ago
    eftime.date = @"2012-01-15";
    eftime.time = @"14:00:00";
    STAssertEqualObjects([DateTimeUtil GetRelativeTime:[eftime getLocalDateComponent] format:0], @"12 months ago", @"Title");
    STAssertEqualObjects([DateTimeUtil GetRelativeTime:[eftime getLocalDateComponent] format:1], @"12 months ago", @"Title");
    // 1 year ago
    eftime.date = @"2011-12-20";
    eftime.time = @"14:00:00";
    STAssertEqualObjects([DateTimeUtil GetRelativeTime:[eftime getLocalDateComponent] format:0], @"1 year ago", @"Title");
    STAssertEqualObjects([DateTimeUtil GetRelativeTime:[eftime getLocalDateComponent] format:1], @"1 year ago", @"Title");
    // 1 year 1 month ago
    eftime.date = @"2011-11-30";
    eftime.time = @"14:00:00";
    STAssertEqualObjects([DateTimeUtil GetRelativeTime:[eftime getLocalDateComponent] format:0], @"1 year 1 month ago", @"Title");
    STAssertEqualObjects([DateTimeUtil GetRelativeTime:[eftime getLocalDateComponent] format:1], @"1 year 1 month ago", @"Title");
    // 1 year 2 months ago
    eftime.date = @"2011-11-15";
    eftime.time = @"14:00:00";
    STAssertEqualObjects([DateTimeUtil GetRelativeTime:[eftime getLocalDateComponent] format:0], @"1 year 2 months ago", @"Title");
    STAssertEqualObjects([DateTimeUtil GetRelativeTime:[eftime getLocalDateComponent] format:1], @"1 year 2 months ago", @"Title");
    // 1 year 12 months ago
    eftime.date = @"2011-01-15";
    eftime.time = @"14:00:00";
    STAssertEqualObjects([DateTimeUtil GetRelativeTime:[eftime getLocalDateComponent] format:0], @"1 year 12 months ago", @"Title");
    STAssertEqualObjects([DateTimeUtil GetRelativeTime:[eftime getLocalDateComponent] format:1], @"1 year 12 months ago", @"Title");
    // 2 years ago
    eftime.date = @"2011-01-10";
    eftime.time = @"14:00:00";
    STAssertEqualObjects([DateTimeUtil GetRelativeTime:[eftime getLocalDateComponent] format:0], @"2 years ago", @"Title");
    STAssertEqualObjects([DateTimeUtil GetRelativeTime:[eftime getLocalDateComponent] format:1], @"2 years ago", @"Title");
    
    
    // in seconds
    eftime.date = @"2013-01-12";
    eftime.date_word = @"";
    eftime.time = @"06:23:13";
    eftime.time_word = @"";
    STAssertEqualObjects([DateTimeUtil GetRelativeTime:[eftime getLocalDateComponent] format:0], @"seconds ago", @"Title");
    STAssertEqualObjects([DateTimeUtil GetRelativeTime:[eftime getLocalDateComponent] format:1], @"now", @"Title");
    // Now
    eftime.time = @"06:25:08";
    STAssertEqualObjects([DateTimeUtil GetRelativeTime:[eftime getLocalDateComponent] format:0], @"in 2 minutes", @"Title");
    STAssertEqualObjects([DateTimeUtil GetRelativeTime:[eftime getLocalDateComponent] format:1], @"in 2 minutes", @"Title");
    // Just Now
    eftime.time = @"07:07:13";
    STAssertEqualObjects([DateTimeUtil GetRelativeTime:[eftime getLocalDateComponent] format:0], @"in 44 minutes", @"Title");
    STAssertEqualObjects([DateTimeUtil GetRelativeTime:[eftime getLocalDateComponent] format:1], @"in 44 minutes", @"Title");
    // In one hour
    eftime.time = @"07:24:00";
    STAssertEqualObjects([DateTimeUtil GetRelativeTime:[eftime getLocalDateComponent] format:0], @"in one hour", @"Title");
    STAssertEqualObjects([DateTimeUtil GetRelativeTime:[eftime getLocalDateComponent] format:1], @"in one hour", @"Title");
    // In 1.5 hours
    eftime.time = @"07:54:00";
    STAssertEqualObjects([DateTimeUtil GetRelativeTime:[eftime getLocalDateComponent] format:0], @"in 1.5 hours", @"Title");
    STAssertEqualObjects([DateTimeUtil GetRelativeTime:[eftime getLocalDateComponent] format:1], @"in 1.5 hours", @"Title");
    // In n hours, round up
    eftime.time = @"11:17:00";
    STAssertEqualObjects([DateTimeUtil GetRelativeTime:[eftime getLocalDateComponent] format:0], @"in 5 hours", @"Title");
    STAssertEqualObjects([DateTimeUtil GetRelativeTime:[eftime getLocalDateComponent] format:1], @"in 5 hours", @"Title");
    // In n hours, round down
    eftime.time = @"11:58:00";
    STAssertEqualObjects([DateTimeUtil GetRelativeTime:[eftime getLocalDateComponent] format:0], @"in 5 hours", @"Title");
    STAssertEqualObjects([DateTimeUtil GetRelativeTime:[eftime getLocalDateComponent] format:1], @"in 5 hours", @"Title");
    //
    eftime.date = @"2013-01-12";
    eftime.time = @"17:51:00";
    STAssertEqualObjects([DateTimeUtil GetRelativeTime:[eftime getLocalDateComponent] format:0], @"in 11 hours", @"Title");
    STAssertEqualObjects([DateTimeUtil GetRelativeTime:[eftime getLocalDateComponent] format:1], @"in 11 hours", @"Title");
    // Yesterday
    eftime.date = @"2013-01-12";
    eftime.time = @"18:30:00";
    STAssertEqualObjects([DateTimeUtil GetRelativeTime:[eftime getLocalDateComponent] format:0], @"tomorrow", @"Title");
    STAssertEqualObjects([DateTimeUtil GetRelativeTime:[eftime getLocalDateComponent] format:1], @"tomorrow", @"Title");
    // Yesterday
    eftime.date = @"2013-01-13";
    eftime.time = @"15:00:00";
    STAssertEqualObjects([DateTimeUtil GetRelativeTime:[eftime getLocalDateComponent] format:0], @"tomorrow", @"Title");
    STAssertEqualObjects([DateTimeUtil GetRelativeTime:[eftime getLocalDateComponent] format:1], @"tomorrow", @"Title");
    // In two days
    eftime.date = @"2013-01-13";
    eftime.time = @"22:00:00";
    STAssertEqualObjects([DateTimeUtil GetRelativeTime:[eftime getLocalDateComponent] format:0], @"in two days", @"Title");
    STAssertEqualObjects([DateTimeUtil GetRelativeTime:[eftime getLocalDateComponent] format:1], @"in two days", @"Title");
    // In two days
    eftime.date = @"2013-01-14";
    eftime.time = @"09:00:00";
    STAssertEqualObjects([DateTimeUtil GetRelativeTime:[eftime getLocalDateComponent] format:0], @"in two days", @"Title");
    STAssertEqualObjects([DateTimeUtil GetRelativeTime:[eftime getLocalDateComponent] format:1], @"in two days", @"Title");
    // In 3 days
    eftime.date = @"2013-01-14";
    eftime.time = @"22:00:00";
    STAssertEqualObjects([DateTimeUtil GetRelativeTime:[eftime getLocalDateComponent] format:0], @"Tue. in 3 days", @"Title");
    STAssertEqualObjects([DateTimeUtil GetRelativeTime:[eftime getLocalDateComponent] format:1], @"Tue. in 3 days", @"Title");
    // In 29 days
    eftime.date = @"2013-02-10";
    eftime.time = @"22:00:00";
    STAssertEqualObjects([DateTimeUtil GetRelativeTime:[eftime getLocalDateComponent] format:0], @"Mon. in 30 days", @"Title");
    STAssertEqualObjects([DateTimeUtil GetRelativeTime:[eftime getLocalDateComponent] format:1], @"Mon. in 30 days", @"Title");
    // In 1 month
    eftime.date = @"2013-02-14";
    eftime.time = @"22:00:00";
    STAssertEqualObjects([DateTimeUtil GetRelativeTime:[eftime getLocalDateComponent] format:0], @"in 1 month", @"Title");
    STAssertEqualObjects([DateTimeUtil GetRelativeTime:[eftime getLocalDateComponent] format:1], @"in 1 month", @"Title");
    // In 2 month
    eftime.date = @"2013-03-09";
    eftime.time = @"22:00:00";
    STAssertEqualObjects([DateTimeUtil GetRelativeTime:[eftime getLocalDateComponent] format:0], @"in 2 months", @"Title");
    STAssertEqualObjects([DateTimeUtil GetRelativeTime:[eftime getLocalDateComponent] format:1], @"in 2 months", @"Title");
    // In 12 months
    eftime.date = @"2014-01-09";
    eftime.time = @"22:00:00";
    STAssertEqualObjects([DateTimeUtil GetRelativeTime:[eftime getLocalDateComponent] format:0], @"in 12 months", @"Title");
    STAssertEqualObjects([DateTimeUtil GetRelativeTime:[eftime getLocalDateComponent] format:1], @"in 12 months", @"Title");
    // In 1 year
    eftime.date = @"2014-02-04";
    eftime.time = @"22:00:00";
    STAssertEqualObjects([DateTimeUtil GetRelativeTime:[eftime getLocalDateComponent] format:0], @"in 1 year", @"Title");
    STAssertEqualObjects([DateTimeUtil GetRelativeTime:[eftime getLocalDateComponent] format:1], @"in 1 year", @"Title");
    // In 1 year 1 month
    eftime.date = @"2014-02-28";
    eftime.time = @"22:00:00";
    STAssertEqualObjects([DateTimeUtil GetRelativeTime:[eftime getLocalDateComponent] format:0], @"in 1 year 1 month", @"Title");
    STAssertEqualObjects([DateTimeUtil GetRelativeTime:[eftime getLocalDateComponent] format:1], @"in 1 year 1 month", @"Title");
    // In 1 year 2 months
    eftime.date = @"2014-3-09";
    eftime.time = @"22:00:00";
    STAssertEqualObjects([DateTimeUtil GetRelativeTime:[eftime getLocalDateComponent] format:0], @"in 1 year 2 months", @"Title");
    STAssertEqualObjects([DateTimeUtil GetRelativeTime:[eftime getLocalDateComponent] format:1], @"in 1 year 2 months", @"Title");
    // In 1 year 12 months
    eftime.date = @"2015-01-09";
    eftime.time = @"22:00:00";
    STAssertEqualObjects([DateTimeUtil GetRelativeTime:[eftime getLocalDateComponent] format:0], @"in 1 year 12 months", @"Title");
    STAssertEqualObjects([DateTimeUtil GetRelativeTime:[eftime getLocalDateComponent] format:1], @"in 1 year 12 months", @"Title");
    // In 2 years
    eftime.date = @"2015-01-14";
    eftime.time = @"22:00:00";
    STAssertEqualObjects([DateTimeUtil GetRelativeTime:[eftime getLocalDateComponent] format:0], @"in 2 years", @"Title");
    STAssertEqualObjects([DateTimeUtil GetRelativeTime:[eftime getLocalDateComponent] format:1], @"in 2 years", @"Title");
    
    // Same timezone, date only
    
    // Same timezone, time only
    
    // Same timezone, 
}

- (void)testCrossTimeOrigin
{
    [self setNow:@"2013-01-12 14:23:05"];
    
    CrossTime *xt = [CrossTime  object:self.moc];
    xt.begin_at = [EFTime  object:self.moc];
    
    // Show original
    xt.origin = @"Original";
    xt.outputformat = [NSNumber numberWithInt:1];
    xt.begin_at = [EFTime  object:self.moc];
    xt.begin_at.timezone = @"+08:00 CST";
    
    xt.begin_at.date = @"";
    xt.begin_at.date_word = @"";
    xt.begin_at.time = @"";
    xt.begin_at.time_word = @"";
    
    STAssertEqualObjects([xt getTimeTitle], @"Original", @"Title");
    STAssertEqualObjects([xt getTimeDescription], @"", @"Description");
    STAssertEqualObjects([xt getTimeSingleLine], @"Original", @"One Line");
    
    // Show original, eat quote
    xt.origin = @"'Original'";
    xt.outputformat = [NSNumber numberWithInt:1];
    xt.begin_at = [EFTime  object:self.moc];
    xt.begin_at.timezone = @"+08:00 CST";
    
    xt.begin_at.date = @"";
    xt.begin_at.date_word = @"";
    xt.begin_at.time = @"";
    xt.begin_at.time_word = @"";
    
    STAssertEqualObjects([xt getTimeTitle], @"Original", @"Title");
    STAssertEqualObjects([xt getTimeDescription], @"", @"Description");
    STAssertEqualObjects([xt getTimeSingleLine], @"Original", @"One Line");
    
    // Shwo original with valid date and time
    xt.origin = @"2013-01-12 14:23:00";
    xt.outputformat = [NSNumber numberWithInt:1];
    xt.begin_at.timezone = @"+08:00 CST";
    xt.begin_at.date = @"2013-01-12";
    xt.begin_at.date_word = @"";
    xt.begin_at.time = @"06:23:00";
    xt.begin_at.time_word = @"";
    
    STAssertEqualObjects([xt getTimeTitle], @"2013-01-12 14:23:00", @"Title");
    STAssertEqualObjects([xt getTimeDescription], @"seconds ago", @"Description");
    STAssertEqualObjects([xt getTimeSingleLine], @"2013-01-12 14:23:00", @"One Line");
    
    // Shwo original with valid date and time, eat double-quote
    xt.origin = @"\"2013-01-12 14:23:00\"";
    xt.outputformat = [NSNumber numberWithInt:1];
    xt.begin_at.timezone = @"+08:00 CST";
    xt.begin_at.date = @"2013-01-12";
    xt.begin_at.date_word = @"";
    xt.begin_at.time = @"06:23:00";
    xt.begin_at.time_word = @"";
    
    STAssertEqualObjects([xt getTimeTitle], @"2013-01-12 14:23:00", @"Title");
    STAssertEqualObjects([xt getTimeDescription], @"seconds ago", @"Description");
    STAssertEqualObjects([xt getTimeSingleLine], @"2013-01-12 14:23:00", @"One Line");
}

- (void)testCrossTimeFullSuite
{
    [self setNow:@"2013-01-12 14:23:05"];
    
    CrossTime *xt = [CrossTime  object:self.moc];
    xt.origin = @"";
    xt.outputformat = [NSNumber numberWithInt:0];
    xt.begin_at = [EFTime  object:self.moc];
    xt.begin_at.timezone = @"+08:00 CST";
    
    xt.begin_at.date = @"2013-01-12";
    xt.begin_at.date_word = @"";
    xt.begin_at.time = @"06:23:00";
    xt.begin_at.time_word = @"";
    
    STAssertEqualObjects([xt getTimeTitle], @"now", @"Title");
    STAssertEqualObjects([xt getTimeDescription], @"2:23PM Sat, Jan 12", @"Description");
    STAssertEqualObjects([xt getTimeSingleLine], @"2:23PM Sat, Jan 12", @"One Line");
    
    xt.begin_at.date = @"2013-01-12";
    xt.begin_at.date_word = @"";
    xt.begin_at.time = @"";
    xt.begin_at.time_word = @"";
    STAssertEqualObjects([xt getTimeTitle], @"today", @"Title");
    STAssertEqualObjects([xt getTimeDescription], @"Sat, Jan 12", @"Description");
    STAssertEqualObjects([xt getTimeSingleLine], @"Sat, Jan 12", @"One Line");
    
    
    xt.begin_at.date = @"2013-01-11";
    xt.begin_at.date_word = @"";
    xt.begin_at.time = @"06:23:00";
    xt.begin_at.time_word = @"";
    STAssertEqualObjects([xt getTimeTitle], @"yesterday", @"Title");
    STAssertEqualObjects([xt getTimeDescription], @"2:23PM Fri, Jan 11", @"Description");
    STAssertEqualObjects([xt getTimeSingleLine], @"2:23PM Fri, Jan 11", @"One Line");
    
    xt.begin_at.date = @"2013-01-11";
    xt.begin_at.date_word = @"";
    xt.begin_at.time = @"";;
    xt.begin_at.time_word = @"";
    STAssertEqualObjects([xt getTimeTitle], @"yesterday", @"Title");
    STAssertEqualObjects([xt getTimeDescription], @"Fri, Jan 11", @"Description");
    STAssertEqualObjects([xt getTimeSingleLine], @"Fri, Jan 11", @"One Line");
}




@end
