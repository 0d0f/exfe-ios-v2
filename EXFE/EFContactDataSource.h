//
//  EFContactDataSource.h
//  EXFE
//
//  Created by 0day on 13-6-5.
//
//

#import <Foundation/Foundation.h>

typedef void (^ActionBlock)(void);

@class EFContactObject;
@interface EFContactDataSource : NSObject

@property (nonatomic, copy) ActionBlock dataDidChangeHandler;       // default as nil. if set, it'll be invoke on main thread.
@property (nonatomic, copy) ActionBlock selectionDidChangeHandler;  // default as nil. if set, it'll be invoke on main thread.

@property (nonatomic, readonly, getter = isLoading) BOOL loading;
@property (nonatomic, assign, getter = isLoaded) BOOL loaded;
@property (nonatomic, copy) ActionBlock didLoadAPageOfContactHandler;

+ (EFContactDataSource *)defaultDataSource;

- (NSUInteger)numberOfSections;
- (NSUInteger)numberOfRowsInSection:(NSUInteger)section;

- (NSUInteger)numberOfSelectedContactObjects;
- (NSArray *)selectedContactObjects;

- (NSString *)titleForSection:(NSUInteger)section;  // maybe nil.

- (BOOL)isContactObjectAtIndexPathSelected:(NSIndexPath *)indexPath;
- (BOOL)isContactObjectSelected:(EFContactObject *)object;
- (EFContactObject *)contactObjectAtIndexPath:(NSIndexPath *)indexPath;

- (void)selectContactObjectAtIndexPath:(NSIndexPath *)indexPath;
- (void)deselectContactObjectAtIndexPath:(NSIndexPath *)indexPath;
- (void)selectContactObject:(EFContactObject *)object;
- (void)deselectContactObject:(EFContactObject *)object;

- (void)clearRecentData;
- (void)deselectAllData;

- (void)clearData;
- (void)loadData;

- (void)addContactObjectToRecent:(EFContactObject *)contactObject;

@end
