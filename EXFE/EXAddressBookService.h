//
//  EXAddressBookService.h
//  AddressBookDemo
//
//  Created by 0day on 13-4-10.
//  Copyright (c) 2013年 EXFE. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "LocalContact.h"

/*!
 * @class EXAddressBookService
 *
 * @discuss All method can called in muti-thread situation. All block params will invoke on main thread.
 */

@interface EXAddressBookService : NSObject

@property (nonatomic, readonly, assign) NSUInteger peopleCount;

+ (EXAddressBookService *)defaultService;

// check
- (void)checkAddressBookAuthorizationStatusWithCompletionHandler:(void (^)(BOOL granted))handler;

// fetch
- (void)fetchAllPeopleWithSuccessHandler:(void (^)(NSArray *people))success failureHandler:(void (^)(NSError *error))failure;
- (void)fetchPeopleWithPageSize:(NSUInteger)page
         pageLoadSuccessHandler:(void (^)(NSArray *))pageSuccess
              completionHandler:(void (^)(void))complete
                 failureHandler:(void (^)(NSError *))failure;

// filter
- (void)filterPeopleWithExistPeople:(NSArray *)existPeople
                            keyWord:(NSString *)keyWord
                          predicate:(NSPredicate *)predicate
                     successHandler:(void (^)(NSArray *people))success
                     failureHandler:(void (^)(NSError *error))failure;
- (void)filterPeopleWithKeyWord:(NSString *)keyWord successHandler:(void (^)(NSArray *people))success failureHandler:(void (^)(NSError *error))failure;

- (void)cancel;

@end
