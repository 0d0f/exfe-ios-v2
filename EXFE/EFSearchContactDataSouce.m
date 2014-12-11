//
//  EFSearchContactDataSouce.m
//  EXFE
//
//  Created by 0day on 13-6-5.
//
//

#import "EFSearchContactDataSouce.h"

#import "EFContactObject.h"
#import "EFModel.h"
#import "NSString+Format.h"

@interface EFSearchContactDataSouce ()
@property (nonatomic, strong) NSMutableArray *sections;
@property (nonatomic, strong) NSMutableArray *sectionTitles;
@property (nonatomic, strong) NSMutableArray *suggestContactObjects;
@property (nonatomic, copy)   NSString       *suggestKeyword;
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
        self.suggestContactObjects = [NSMutableArray array];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(handleNotification:)
                                                     name:kEFNotificationNameLoadSuggestSuccess
                                                   object:nil];
    }
    
    return self;
}

#pragma mark - Notification Handler

- (void)handleNotification:(NSNotification *)notification {
    NSString *name = notification.name;
    
    if ([name isEqualToString:kEFNotificationNameLoadSuggestSuccess]) {
        if (![self.suggestKeyword isEqualToString:self.searchKeyWord])
            return;
        
        NSDictionary *userInfo = notification.userInfo;
        NSDictionary *metaDict = [userInfo valueForKey:@"meta"];
        if (metaDict && 200 == [[metaDict valueForKey:@"code"] intValue]) {
            AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
            RKObjectManager *objectManager = delegate.model.objectManager;
            
            NSArray *identities = [[userInfo valueForKey:@"response"] valueForKey:@"identities"];
            
            for (NSDictionary *identitydict in identities) {
                NSString *external_id = [identitydict objectForKey:@"external_id"];
                NSString *provider = [identitydict objectForKey:@"provider"];
                NSString *avatar_filename = [identitydict objectForKey:@"avatar_filename"];
                NSString *identity_id = [identitydict objectForKey:@"id"];
                NSString *name = [identitydict objectForKey:@"name"];
                NSString *nickname = [identitydict objectForKey:@"nickname"];
                NSString *external_username = [identitydict objectForKey:@"external_username"];
                
                __block BOOL needInsertNew = NO;
                if ([identity_id intValue] == 0) {
                    // a new one
                    needInsertNew = YES;
                }
                
                if (!needInsertNew) {
                    // update if exist
                    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"identity_id == %@", [NSNumber numberWithInt:[identity_id intValue]]];
                    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Identity"];
                    fetchRequest.predicate = predicate;
                    
                    void (^block)(void) = ^{
                        NSArray *cachedIdentitites = [objectManager.managedObjectStore.mainQueueManagedObjectContext executeFetchRequest:fetchRequest error:nil];
                        if (cachedIdentitites && [cachedIdentitites count]) {
                            // update info
                            Identity *cachedIdentitiy = cachedIdentitites[0];
                            cachedIdentitiy.external_id = external_id;
                            cachedIdentitiy.provider = provider;
                            cachedIdentitiy.avatar_filename = avatar_filename;
                            cachedIdentitiy.name = name;
                            cachedIdentitiy.external_username = external_username;
                            cachedIdentitiy.nickname = nickname;
                            cachedIdentitiy.identity_id = [NSNumber numberWithInt:[identity_id intValue]];
                            
                            EFContactObject *contactObject = [EFContactObject contactObjectWithIdentities:@[cachedIdentitiy]];
                            [self.suggestContactObjects addObject:contactObject];
                        } else {
                            needInsertNew = YES;
                        }
                    };
                    
                    [objectManager.managedObjectStore.mainQueueManagedObjectContext performBlockAndWait:block];
                }
                
                if (needInsertNew) {
                    void (^block)(void) = ^{
                        NSEntityDescription *identityEntity = [NSEntityDescription entityForName:@"Identity" inManagedObjectContext:objectManager.managedObjectStore.mainQueueManagedObjectContext];
                        [objectManager.managedObjectStore.mainQueueManagedObjectContext performBlockAndWait:^{
                            Identity *identity = [[Identity alloc] initWithEntity:identityEntity insertIntoManagedObjectContext:objectManager.managedObjectStore.mainQueueManagedObjectContext];
                            identity.external_id = external_id;
                            identity.provider = provider;
                            identity.avatar_filename = avatar_filename;
                            identity.name = name;
                            identity.external_username = external_username;
                            identity.nickname = nickname;
                            identity.identity_id = [NSNumber numberWithInt:[identity_id intValue]];
                            
                            EFContactObject *contactObject = [EFContactObject contactObjectWithIdentities:@[identity]];
                            [self.suggestContactObjects addObject:contactObject];
                        }];
                    };
                    
                    [objectManager.managedObjectStore.mainQueueManagedObjectContext performBlockAndWait:block];
                }
            }
        }
        
        [self _reloadData];
        
        if (_suggestDidChangeHandler) {
            self.suggestDidChangeHandler();
        }
    }
}

#pragma mark - Getter && Setter

- (void)setSearchKeyWord:(NSString *)searchKeyWord {
    if ([searchKeyWord isEqualToString:_searchKeyWord])
        return;
    
    if (_searchKeyWord) {
        self.suggestKeyword = searchKeyWord;
        _searchKeyWord = nil;
        
        [self.sections removeAllObjects];
        [self.sectionTitles removeAllObjects];
    }
    
    [self.suggestContactObjects removeAllObjects];
    
    searchKeyWord = [searchKeyWord stringWithoutSpace];
    
    if (searchKeyWord && searchKeyWord.length) {
        _searchKeyWord = [searchKeyWord copy];
        
        [self _reloadData];
        
        AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        [delegate.model loadSuggestWithKey:searchKeyWord];
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
    NSParameterAssert(object);
    
    if (NSNotFound != [self.suggestContactObjects indexOfObject:object]) {
        [self.contactDataSource addContactObjectToRecent:object];
    }
    
    [self.contactDataSource selectContactObject:object];
}

- (void)deselectContactObject:(EFContactObject *)object {
    NSParameterAssert(object);
    
    if (NSNotFound != [self.suggestContactObjects indexOfObject:object]) {
        [self.contactDataSource removeContactObjectFromRecent:object];
    }
    
    [self.contactDataSource deselectContactObject:object];
}

#pragma mark - Private

- (void)_reloadData {
    [self.sections removeAllObjects];
    [self.sectionTitles removeAllObjects];
    
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
        
    }
    
    if (self.suggestContactObjects.count) {
        [self.sections addObject:self.suggestContactObjects];
        [self.sectionTitles addObject:NSLocalizedString(@"Suggest", @"search header title")];
    }
}

@end
