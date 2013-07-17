//
//  EFMapPeopleDataSource.h
//  MarauderMap
//
//  Created by 0day on 13-7-5.
//  Copyright (c) 2013年 exfe. All rights reserved.
//

#import <Foundation/Foundation.h>

@class EFMapPerson, EFMapPoint;
@interface EFMapPeopleDataSource : NSObject

@property (readonly) NSUInteger peopleCount;

- (id)initWithPeople:(NSArray *)people;

// Collection Operation
- (void)addPeople:(NSArray *)people;
- (void)removePeople:(NSArray *)people;

- (void)addPerson:(EFMapPerson *)person;
- (void)removePerson:(EFMapPerson *)person;

- (EFMapPerson *)personAtIndex:(NSUInteger)index;

@end
