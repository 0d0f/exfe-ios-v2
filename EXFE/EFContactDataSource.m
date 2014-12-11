//
//  EFContactDataSource.m
//  EXFE
//
//  Created by 0day on 13-6-5.
//
//

#import "EFContactDataSource.h"

#import <CoreData/CoreData.h>
#import <RestKit/RestKit.h>
#import "EFEntity.h"
#import "EFContactObject.h"
#import "EXAddressBookService.h"

@interface EFContactDataSource ()
@property (nonatomic, strong) NSMutableArray *sections;
@property (nonatomic, strong) NSMutableArray *sectionTitles;

@property (nonatomic, strong) NSMutableArray *recentList;
@property (nonatomic, strong) NSMutableArray *exfeeList;
@property (nonatomic, strong) NSMutableArray *contactList;

@end

@interface EFContactDataSource (Private)
- (void)_loadExfees;
- (void)_loadContacts;
@end

@implementation EFContactDataSource

+ (EFContactDataSource *)defaultDataSource {
    static EFContactDataSource *DataSource;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        DataSource = [[self alloc] init];
    });
    
    return DataSource;
}

- (id)init {
    self = [super init];
    if (self) {
        self.sections = [NSMutableArray arrayWithCapacity:2];
        self.recentList = [NSMutableArray arrayWithCapacity:10];
        self.exfeeList = [NSMutableArray arrayWithCapacity:20];
        self.contactList = [NSMutableArray arrayWithCapacity:100];
        
        [self.sections addObject:self.recentList];
        [self.sections addObject:self.exfeeList];
        [self.sections addObject:self.contactList];
        
        self.sectionTitles = [NSMutableArray arrayWithCapacity:3];
        [self.sectionTitles addObject:@""];
        [self.sectionTitles addObject:NSLocalizedString(@"Exfee", @"EFContactDataSouce section Title")];
        [self.sectionTitles addObject:NSLocalizedString(@"Contacts", @"EFContactDataSouce section Title")];
        
        self.loaded = NO;
    }
    
    return self;
}


- (NSUInteger)numberOfSections {
    return self.sections.count;
}

- (NSUInteger)numberOfRowsInSection:(NSUInteger)section {
    NSArray *list = ((NSArray *)self.sections[section]);
    return list.count;
}

- (NSUInteger)numberOfSelectedContactObjects {
    NSUInteger count = 0;
    for (NSArray *list  in self.sections) {
        for (EFContactObject *contactObject in list) {
            if (contactObject.isSelected) {
                ++count;
            }
        }
    }
    
    return count;
}

- (NSArray *)selectedContactObjects {
    NSUInteger count = [self numberOfSelectedContactObjects];
    if (0 == count)
        return nil;
    
    NSMutableArray *objects = [NSMutableArray arrayWithCapacity:count];
    for (NSArray *list in self.sections) {
        for (EFContactObject *contactObject in list) {
            if (contactObject.isSelected) {
                [objects addObject:contactObject];
            }
        }
    }
    
    return objects;
}

- (NSString *)titleForSection:(NSUInteger)section {
    NSArray *list = ((NSArray *)self.sections[section]);
    NSString *title = list.count ? self.sectionTitles[section] : nil;
    return title && title.length ? title : nil;
}

- (BOOL)isContactObjectAtIndexPathSelected:(NSIndexPath *)indexPath {
    EFContactObject *contactObject = [self contactObjectAtIndexPath:indexPath];
    return contactObject.isSelected;
}

- (BOOL)isContactObjectSelected:(EFContactObject *)object {
    return object.isSelected;
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
    
    if (_selectionDidChangeHandler) {
        self.selectionDidChangeHandler();
    }
}

- (void)deselectContactObject:(EFContactObject *)object {
    object.selected = NO;
    
    if (_selectionDidChangeHandler) {
        self.selectionDidChangeHandler();
    }
}

- (void)roughtIdentityDidChangeInContactObjectAtIndexPath:(NSIndexPath *)indexPath {
    EFContactObject *contactObject = [self contactObjectAtIndexPath:indexPath];
    [self roughtIdentityDidChangeInContactObject:contactObject];
}

- (void)roughtIdentityDidChangeInContactObject:(EFContactObject *)object {
    [object roughIdentitiesSelectedStateDidChange];
    
    if (_selectionDidChangeHandler) {
        self.selectionDidChangeHandler();
    }
}

- (void)clearRecentData {
    [self.recentList removeAllObjects];
}

- (void)deselectAllData {
    for (NSArray *list in self.sections) {
        for (EFContactObject *contactObject in list) {
            contactObject.selected = NO;
        }
    }
}

- (void)clearData {
    [self.recentList removeAllObjects];
    [self.exfeeList removeAllObjects];
    [self.contactList removeAllObjects];
    
    self.loaded = NO;
}

- (void)loadData {
    if (self.loaded)
        return;
    self.loaded = YES;
    
    [self _loadExfees];
    [self _loadContacts];
}

- (void)addContactObjectToRecent:(EFContactObject *)contactObject {
    NSParameterAssert(contactObject);
    
    BOOL hasContained = NO;
    for (EFContactObject *object in self.recentList) {
        if ([object isEqualToContactObject:contactObject]) {
            hasContained = YES;
            break;
        }
    }
    
    if (!hasContained) {
        [self.recentList insertObject:contactObject atIndex:0];
        if (_dataDidChangeHandler) {
            self.dataDidChangeHandler();
        }
    }
}

- (void)removeContactObjectFromRecent:(EFContactObject *)contactObject {
    NSParameterAssert(contactObject);
    
    [self.recentList removeObject:contactObject];
    if (_dataDidChangeHandler) {
        self.dataDidChangeHandler();
    }
}

#pragma mark - Private

- (void)_loadExfees {
    void (^block)(void) = ^{
        User *me = [User getDefaultUser];
        
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Identity"];
        
        NSSortDescriptor* descriptor = [NSSortDescriptor sortDescriptorWithKey:@"created_at" ascending:NO];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"provider != %@ AND provider != %@ AND connected_user_id !=0", @"iOSAPN", @"android"];
        
        request.predicate = predicate;
        request.sortDescriptors = @[descriptor];
        
        RKObjectManager *objectManager = [RKObjectManager sharedManager];
        NSArray *exfees = [objectManager.managedObjectStore.mainQueueManagedObjectContext executeFetchRequest:request error:nil];
        NSMutableDictionary *identityDict = [[NSMutableDictionary alloc] initWithCapacity:exfees.count];
        
        for (Identity *identity in exfees) {
            BOOL isMe = NO;
            for (Identity *meIdentity in me.identities) {
                if ([identity isEqualToIdentity:meIdentity]) {
                    isMe = YES;
                    break;
                }
            }
            if (!isMe) {
                NSString *key = [NSString stringWithFormat:@"%d", [identity.connected_user_id intValue]];
                NSMutableArray *identityList = [identityDict valueForKey:key];
                if (!identityList) {
                    identityList = [NSMutableArray array];
                }
                [identityList addObject:identity];
                [identityDict setValue:identityList forKey:key];
            }
        }
        
        NSArray *allValues = identityDict.allValues;
        NSMutableArray *result = [[NSMutableArray alloc] initWithCapacity:allValues.count];
        for (NSArray *identityList in allValues) {
            EFContactObject *contactObject = [EFContactObject contactObjectWithIdentities:identityList];
            [result addObject:contactObject];
        }
        
        
        [self.exfeeList addObjectsFromArray:result];
        
        if (_dataDidChangeHandler) {
            self.dataDidChangeHandler();
        }
    };
    
    if (dispatch_get_current_queue() != dispatch_get_main_queue()) {
        dispatch_sync(dispatch_get_main_queue(), block);
    } else {
        block();
    }
}

- (void)_loadContacts {
    UILogPush(@"Start Loading Contact.");
    [[EXAddressBookService defaultService] reset];
    [[EXAddressBookService defaultService] checkAddressBookAuthorizationStatusWithCompletionHandler:^(BOOL granted){
        if (granted) {
            [[EXAddressBookService defaultService] fetchPeopleWithPageSize:40
                                                    pageLoadSuccessHandler:^(NSArray *people){
                                                        NSMutableArray *filteredContactPeople = [[NSMutableArray alloc] initWithCapacity:[people count]];
                                                        for (LocalContact *localContact in people) {
                                                            if ([localContact hasAnyNotificationIdentity]) {
                                                                EFContactObject *contactObject = [EFContactObject contactObjectWithLocalContact:localContact];
                                                                [filteredContactPeople addObject:contactObject];
                                                            }
                                                        }
                                                        
                                                        [self.contactList addObjectsFromArray:filteredContactPeople];
                                                        
                                                        dispatch_async(dispatch_get_main_queue(), ^{
                                                            if (_dataDidChangeHandler) {
                                                                self.dataDidChangeHandler();
                                                            }
                                                            
                                                            if (_didLoadAPageOfContactHandler) {
                                                                self.didLoadAPageOfContactHandler();
                                                            }
                                                        });
                                                    }
                                                         completionHandler:^{
                                                             dispatch_queue_t fetcth_queue = dispatch_queue_create("queue.fetch", NULL);
                                                             dispatch_async(fetcth_queue, ^{
                                                                 dispatch_async(dispatch_get_main_queue(), ^{
                                                                     if (_dataDidChangeHandler) {
                                                                         self.dataDidChangeHandler();
                                                                     }
                                                                 });
                                                             });
                                                         }
                                                            failureHandler:nil];
        } else {
            // TODO: Add alert
        }
    }];
}

@end
