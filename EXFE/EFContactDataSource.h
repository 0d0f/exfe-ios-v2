//
//  EFContactDataSource.h
//  EXFE
//
//  Created by 0day on 13-6-5.
//
//

#import <Foundation/Foundation.h>

typedef void (^ActionBlock)(void);

@interface EFContactDataSource : NSObject

@property (nonatomic, copy) ActionBlock didChangeHandler;   // default as nil. if set, it'll be invoke on main thread.
@property (nonatomic, readonly, assign, getter = isLoading) BOOL loading;

+ (EFContactDataSource *)defaultDataSource;

- (NSUInteger)numberOfSections;
- (NSUInteger)numberOfRowsInSection:(NSUInteger)section;

- (NSString *)titleForSection;  // maybe nil.

- (BOOL)isContactObjectAtIndexPathSelected:(NSIndexPath *)indexPath;
- (id)contactObjectAtIndexPath:(NSIndexPath *)indexPath;
- (NSIndexPath *)indexPathForObject;    // if not found, it'll be {NSNotFound, 0}. You should always check the indexPath.location.

- (void)selectContactObjectAtIndexPath:(NSIndexPath *)indexPath;
- (void)deselectContactObjectAtIndexPath:(NSIndexPath *)indexPath;

@end
