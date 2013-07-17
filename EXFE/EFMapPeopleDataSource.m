//
//  EFMapPeopleDataSource.m
//  MarauderMap
//
//  Created by 0day on 13-7-5.
//  Copyright (c) 2013年 exfe. All rights reserved.
//

#import "EFMapPeopleDataSource.h"

@interface EFMapPeopleDataSource ()

@property (strong) NSMutableArray   *people;
@property (readwrite) NSUInteger peopleCount;
- (void)_updatePeopleCount;

@end

@implementation EFMapPeopleDataSource

- (id)init {
    return [self initWithPeople:nil];
}

- (id)initWithPeople:(NSArray *)people {
    self = [super init];
    if (self) {
        self.people = [[NSMutableArray alloc] init];
        [self _updatePeopleCount];
        
        [self addPeople:people];
    }
    
    return self;
}

#pragma mark - Public

// Collection Operation
- (void)addPeople:(NSArray *)people {
    [self.people addObjectsFromArray:people];
    [self _updatePeopleCount];
}

- (void)removePeople:(NSArray *)people {
    [self.people removeObjectsInArray:people];
    [self _updatePeopleCount];
}

- (void)addPerson:(EFMapPerson *)person {
    [self.people addObject:person];
    [self _updatePeopleCount];
}

- (void)removePerson:(EFMapPerson *)person {
    [self.people removeObject:person];
    [self _updatePeopleCount];
}

- (EFMapPerson *)personAtIndex:(NSUInteger)index {
    NSAssert(index < self.peopleCount, @"index beyonded!");
    
    return [self.people objectAtIndex:index];
}

#pragma mark - Private

- (void)_updatePeopleCount {
    self.peopleCount = self.people.count;
}

@end
