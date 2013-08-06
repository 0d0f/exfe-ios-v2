//
//  EFAccessInfo.h
//  EXFE
//
//  Created by 0day on 13-8-6.
//
//

#import <Foundation/Foundation.h>

@class Cross;
@interface EFAccessInfo : NSObject

@property (nonatomic, weak)   Cross             *cross;
@property (nonatomic, assign) BOOL              shouldSaveBreadcrumbs;
@property (nonatomic, assign) NSTimeInterval    duration;   // Default as 7200 secs.

- (id)initWithCross:(Cross *)cross shouldSaveBreadcrumbs:(BOOL)shouldSave duration:(NSTimeInterval)duration;
- (id)initWithCross:(Cross *)cross shouldSaveBreadcrumbs:(BOOL)shouldSave;  // duration use default value.

- (NSDictionary *)dictionaryValue;

@end
