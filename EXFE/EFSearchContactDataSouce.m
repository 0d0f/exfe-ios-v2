//
//  EFSearchContactDataSouce.m
//  EXFE
//
//  Created by 0day on 13-6-5.
//
//

#import "EFSearchContactDataSouce.h"

#import "EFContactObject.h"

@interface EFSearchContactDataSouce ()
@property (nonatomic, retain) NSMutableArray *sections;
@property (nonatomic, retain) NSMutableArray *sectionTitles;
@end

@interface EFSearchContactDataSouce (Private)
- (void)_reloadData;
@end

@implementation EFSearchContactDataSouce

#pragma mark - Memory Management

+ (EFSearchContactDataSouce *)defaultDataSource {
    static dispatch_once_t onceToken;
    static EFSearchContactDataSouce *DataSource;
    dispatch_once(&onceToken, ^{
        DataSource = [[self alloc] init];
    });
    
    return DataSource;
}

- (id)init {
    self = [super init];
    if (self) {
        self.sections = [NSMutableArray array];
        self.sectionTitles = [NSMutableArray array];
    }
    
    return self;
}

#pragma mark - Getter && Setter

- (void)setSearchKeyWord:(NSString *)searchKeyWord {
    if ([searchKeyWord isEqualToString:_searchKeyWord])
        return;
    
    if (_searchKeyWord) {
        [_searchKeyWord release];
        _searchKeyWord = nil;
        
        [self.sections removeAllObjects];
        [self.sectionTitles removeAllObjects];
    }
    
    if (searchKeyWord && searchKeyWord.length) {
        _searchKeyWord = [searchKeyWord copy];
        
        [self _reloadData];
    }
    
    if (_keywordDidChangeHandler && _searchKeyWord.length) {
        self.keywordDidChangeHandler();
    }
}

#pragma mark - Public

- (NSUInteger)numberOfSections {
    return self.sections.count;
}

- (NSUInteger)numberOfRowsInSection:(NSUInteger)section {
    NSArray *list = (NSArray *)self.sections[section];
    return list.count;
}

- (NSString *)titleForSection:(NSUInteger)section {
    return self.sectionTitles[section];
}

- (EFContactObject *)contactObjectAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *list = ((NSArray *)self.sections[indexPath.section]);
    return list[indexPath.row];
}

- (void)selectContactObjectAtIndexPath:(NSIndexPath *)indexPath {
    EFContactObject *contactObject = [self contactObjectAtIndexPath:indexPath];
    [self selectContactObject:contactObject];
}

- (void)deselectContactObjectAtIndexPath:(NSIndexPath *)indexPath {
    EFContactObject *contactObject = [self contactObjectAtIndexPath:indexPath];
    [self deselectContactObject:contactObject];
}

- (void)selectContactObject:(EFContactObject *)object {
    object.selected = YES;
}

- (void)deselectContactObject:(EFContactObject *)object {
    object.selected = NO;
}

#pragma mark - Private

- (void)_reloadData {
    NSUInteger sectionCount = [self.contactDataSource numberOfSections];
    
    for (int i = 0; i < sectionCount; i++) {
        NSUInteger rowCount = [self.contactDataSource numberOfRowsInSection:i];
        NSMutableArray *filterdContacts = [[NSMutableArray alloc] initWithCapacity:rowCount];
        
        for (int j = 0; j < rowCount; j++) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:j inSection:i];
            EFContactObject *contactObject = [self.contactDataSource contactObjectAtIndexPath:indexPath];
            NSAssert(contactObject.searchIndex && contactObject.searchIndex.length, @"contact object's search index CANNOT be nil or empty!");
            
            NSRange range = [contactObject.searchIndex rangeOfString:self.searchKeyWord options:NSCaseInsensitiveSearch];
            if (NSNotFound != range.location) {
                [filterdContacts addObject:contactObject];
            }
        }
        
        if (filterdContacts.count) {
            [self.sections addObject:filterdContacts];
            NSString *title = [self.contactDataSource titleForSection:i];
            title = (nil == title) ? @"" : title;
            [self.sectionTitles addObject:title];
        }
        
        [filterdContacts release];
    }
}

@end
