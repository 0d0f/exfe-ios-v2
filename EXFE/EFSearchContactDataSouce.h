//
//  EFSearchContactDataSouce.h
//  EXFE
//
//  Created by 0day on 13-6-5.
//
//

#import <Foundation/Foundation.h>

#import "EFContactDataSource.h"

@class EFContactObject;
@interface EFSearchContactDataSouce : NSObject

@property (nonatomic, assign) EFContactDataSource *contactDataSource;
@property (nonatomic, copy) NSString *searchKeyWord;
@property (nonatomic, copy) ActionBlock keywordDidChangeHandler;

+ (EFSearchContactDataSouce *)defaultDataSource;

- (NSUInteger)numberOfSections;
- (NSUInteger)numberOfRowsInSection:(NSUInteger)section;

- (NSString *)titleForSection:(NSUInteger)section;  // maybe nil.

- (EFContactObject *)contactObjectAtIndexPath:(NSIndexPath *)indexPath;

- (void)selectContactObjectAtIndexPath:(NSIndexPath *)indexPath;
- (void)deselectContactObjectAtIndexPath:(NSIndexPath *)indexPath;
- (void)selectContactObject:(EFContactObject *)object;
- (void)deselectContactObject:(EFContactObject *)object;

@end
