//
//  EXAddressBookService.m
//  AddressBookDemo
//
//  Created by 0day on 13-4-10.
//  Copyright (c) 2013年 EXFE. All rights reserved.
//

#import "EXAddressBookService.h"

#import <AddressBook/AddressBook.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <CoreTelephony/CTCarrier.h>
#import <RestKit/RestKit.h>

#import "NSString+Format.h"

#define KeyChoosePeopleLastUpdateDate   @"Key.ChoosePeople.LastUpdateDate"

extern inline LocalContact *LocalContactFromRecordRefAndLastUpdateDate(ABRecordRef recordRef, NSDate *date);

#pragma mark - EFFetchPeopleOperation

typedef void (^EFFetchPeopleSuccessBlock)(NSArray *people);
typedef void (^EFFetchPeopleFailureBlock)(NSError *error);
typedef void (^EFFetchPeopleCompleteBlock)(void);

@interface EFFetchPeopleOperation : NSOperation
@property (nonatomic, assign) NSUInteger pageSize;
@property (nonatomic, copy) EFFetchPeopleSuccessBlock successHandler;
@property (nonatomic, copy) EFFetchPeopleCompleteBlock completeHandler;
@property (nonatomic, copy) EFFetchPeopleFailureBlock failureHandler;
@property (nonatomic, assign) ABAddressBookRef addressBookRef;
@end

@implementation EFFetchPeopleOperation

- (void)main {
    @autoreleasepool {
        if (self.isCancelled)
            return;
        
        if (!_successHandler && !_completeHandler && !_failureHandler)
            return;
        
        if (!_addressBookRef) {
            if (_failureHandler) {
                dispatch_async(dispatch_get_main_queue(), ^{
#warning TODO: custom error
                    _failureHandler(nil);
                });
            }
        } else if (_successHandler || _completeHandler) {
            ABRecordRef source = ABAddressBookCopyDefaultSource(_addressBookRef);
            CFArrayRef peopleRef = ABAddressBookCopyArrayOfAllPeopleInSourceWithSortOrdering(_addressBookRef, source, ABPersonGetSortOrdering());
            CFRelease(source);
            
            CFIndex count = CFArrayGetCount(peopleRef);
            CFIndex pageSize = count >= _pageSize ? _pageSize : count;
            
            if (count == 0) {
                dispatch_sync(dispatch_get_main_queue(), ^{
                    if (_successHandler) {
                        _successHandler([NSArray array]);
                    }
                    if (_completeHandler) {
                        _completeHandler();
                    }
                });
                
                CFRelease(peopleRef);
                
                return ;
            }
            
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            NSDate *lastUpdateDate = [userDefaults valueForKey:KeyChoosePeopleLastUpdateDate];
            [userDefaults setValue:[NSDate date] forKey:KeyChoosePeopleLastUpdateDate];
            
            CFIndex pageNumber = (count / pageSize) + (((count % pageSize) != 0) ? 1 : 0);
            for (CFIndex pageIndex = 0; pageIndex < pageNumber; pageIndex++) {
                if (self.isCancelled)
                    return;
                
                @autoreleasepool {
                    CFIndex currentPageSize = ((pageIndex + 1) * pageSize > count) ? (count - (pageIndex) * pageSize) : pageSize;
                    NSMutableArray *people = [[NSMutableArray alloc] initWithCapacity:currentPageSize];
                    
                    CFIndex startIndex = pageIndex * pageSize;
                    for (CFIndex i = startIndex; i < startIndex + currentPageSize; i++) {
                        if (self.isCancelled)
                            return;
                        
                        ABRecordRef personRef = CFArrayGetValueAtIndex(peopleRef, i);
                        LocalContact *localContact = LocalContactFromRecordRefAndLastUpdateDate(personRef, lastUpdateDate);
                        if (localContact) {
                            [people addObject:localContact];
                        }
                    }
                    
                    if (_successHandler) {
                        dispatch_sync(dispatch_get_main_queue(), ^{
                            _successHandler(people);
                        });
                    }
                    
                }
            }
            
            CFRelease(peopleRef);
            
            if (_completeHandler) {
                dispatch_sync(dispatch_get_main_queue(), ^{
                    _completeHandler();
                });
            }
        }
    }
}

@end

#pragma mark - EXAddressBookService
@interface EXAddressBookService (LocalContact)
- (LocalContact *)localContactFromRecordRef:(ABRecordRef)aRecordRef lastUpdateDate:(NSDate *)date;
@end

@implementation EXAddressBookService {
    ABAddressBookRef    _addressBookRef;
    NSOperationQueue    *_addressBookQueue;
}

#pragma mark - Memory Manage
+ (EXAddressBookService *)defaultService {
    static EXAddressBookService *SharedService;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        SharedService = [[self alloc] init];
    });
    
    return SharedService;
}

- (id)init {
    self = [super init];
    if (self) {
        // queue
        _addressBookQueue = [[NSOperationQueue alloc] init];
        _addressBookQueue.maxConcurrentOperationCount = 1;
        
        [_addressBookQueue addOperationWithBlock:^{
            // addressBookRef
            if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"6.0")) {
                CFErrorRef errorRef = NULL;
                _addressBookRef = ABAddressBookCreateWithOptions(NULL, &errorRef);
                if (!_addressBookRef && errorRef) {
//                    RKLogDebug(@"%@", (NSString *)CFErrorCopyDescription(errorRef));
                }
            } else if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"5.1")) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
                _addressBookRef = ABAddressBookCreate();
#pragma clang diagnostic pop
            }
        }];
        
        [_addressBookQueue waitUntilAllOperationsAreFinished];
    }
    
    return self;
}

- (void)dealloc {
    [_addressBookQueue cancelAllOperations];
}

#pragma mark - Getter && Setter
- (NSUInteger)peopleCount {
    __block NSUInteger count = 0;
    
    [_addressBookQueue addOperationWithBlock:^{
        if (_addressBookRef) {
            count = ABAddressBookGetPersonCount(_addressBookRef);
        }
    }];
    [_addressBookQueue waitUntilAllOperationsAreFinished];
    
    return count;
}

#pragma mark - Check
- (void)checkAddressBookAuthorizationStatusWithCompletionHandler:(void (^)(BOOL granted))handler {
    [_addressBookQueue addOperationWithBlock:^{
        if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"6.0")) {
            if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusNotDetermined) {
                ABAddressBookRequestAccessWithCompletion(_addressBookRef, ^(bool granted, CFErrorRef error) {
                    if (handler) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            handler(granted);
                        });
                    }
                });
            }
            else if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized) {
                if (handler) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        handler(YES);
                    });
                }
            }
        } else if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"5.1")) {
            if (_addressBookRef) {
                if (handler) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        handler(YES);
                    });
                }
            } else {
                if (handler) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        handler(NO);
                    });
                }
            }
        }
    }];
}

#pragma mark - Fetch

- (void)fetchAllPeopleWithSuccessHandler:(void (^)(NSArray *people))success failureHandler:(void (^)(NSError *error))failure {
    if (!success && !failure)
        return;
    
    if (!_addressBookRef) {
        if (failure) {
            dispatch_async(dispatch_get_main_queue(), ^{
#warning TODO: custom error
                failure(nil);
            });
        }
    } else if (success) {
        NSUInteger count = self.peopleCount;
        
        [self fetchPeopleWithPageSize:count
               pageLoadSuccessHandler:success
                    completionHandler:nil
                       failureHandler:failure];
    }
}

- (void)fetchPeopleWithPageSize:(NSUInteger)page
         pageLoadSuccessHandler:(void (^)(NSArray *))pageSuccess
              completionHandler:(void (^)(void))complete
                 failureHandler:(void (^)(NSError *))failure {
    EFFetchPeopleOperation *operation = [[EFFetchPeopleOperation alloc] init];
    operation.addressBookRef = _addressBookRef;
    operation.pageSize = page;
    operation.successHandler = pageSuccess;
    operation.completeHandler = complete;
    operation.failureHandler = failure;
    
    [_addressBookQueue addOperation:operation];
    
}

#pragma mark - Filter

- (void)filterPeopleWithExistPeople:(NSArray *)existPeople
                            keyWord:(NSString *)keyWord
                          predicate:(NSPredicate *)predicate
                     successHandler:(void (^)(NSArray *people))success
                     failureHandler:(void (^)(NSError *error))failure {
    if (!success && !failure)
        return;
    
    if (!_addressBookRef) {
        // address book is nil
        if (failure) {
            dispatch_async(dispatch_get_main_queue(), ^{
#warning TODO: custom error
                failure(nil);
            });
        }
    } else if (success) {
        if (nil == keyWord ||
            0 == keyWord.length ||
            (existPeople && 0 == [existPeople count])) {
            // no key word or existPeople array is empty
            success([NSMutableArray array]);
        } else if (success) {
            if (existPeople) {
                // has exist people
                NSArray *filteredPeople = [existPeople filteredArrayUsingPredicate:predicate];
                dispatch_async(dispatch_get_main_queue(), ^{
                    success(filteredPeople);
                });
            } else {
                // no exist people
                [self fetchAllPeopleWithSuccessHandler:^(NSArray *people){
                    [_addressBookQueue addOperationWithBlock:^{
                        NSArray *filtedPeople = [people filteredArrayUsingPredicate:predicate];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            success(filtedPeople);
                        });
                    }];
                }
                                        failureHandler:^(NSError *error){
                                            if (failure)
                                                failure(error);
                                        }];
            }
        }
    }
}

- (void)filterPeopleWithKeyWord:(NSString *)keyWord successHandler:(void (^)(NSArray *people))success failureHandler:(void (^)(NSError *error))failure {
    if (!success && !failure)
        return;
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"indexfield CONTAINS[cd] %@", keyWord];
    [self filterPeopleWithExistPeople:nil
                              keyWord:keyWord
                            predicate:predicate
                       successHandler:success
                       failureHandler:failure];
}

#pragma mark - Task

- (void)reset {
    [self cancel];
    
    [_addressBookQueue addOperationWithBlock:^{
        if (_addressBookRef) {
            CFRelease(_addressBookRef);
            _addressBookRef = NULL;
        }
        
        // addressBookRef
        if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"6.0")) {
            CFErrorRef errorRef = NULL;
            _addressBookRef = ABAddressBookCreateWithOptions(NULL, &errorRef);
            if (!_addressBookRef && errorRef) {
//                RKLogDebug(@"%@", (NSString *)CFErrorCopyDescription(errorRef));
            }
        } else if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"5.1")) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
            _addressBookRef = ABAddressBookCreate();
#pragma clang diagnostic pop
        }
    }];
    
    [_addressBookQueue waitUntilAllOperationsAreFinished];
}

- (void)cancel {
    [_addressBookQueue cancelAllOperations];
}

@end

#pragma mark - Inline Function

inline LocalContact *LocalContactFromRecordRefAndLastUpdateDate(ABRecordRef recordRef, NSDate *date) {
    __block LocalContact *result = nil;
    
    CTTelephonyNetworkInfo *netInfo = [[CTTelephonyNetworkInfo alloc] init];
    CTCarrier *carrier = [netInfo subscriberCellularProvider];
    NSString *mcc = [carrier mobileCountryCode];
    NSString *isocode =[carrier isoCountryCode];
    
    if (!carrier) {
        // has no cellular provider
        NSLocale *locale = [NSLocale currentLocale];
        isocode = [[locale objectForKey:NSLocaleCountryCode] lowercaseString];
    }
    
    ABMultiValueRef multi_email = ABRecordCopyValue(recordRef, kABPersonEmailProperty);
    ABMultiValueRef multi_socialprofile = ABRecordCopyValue(recordRef, kABPersonSocialProfileProperty);
    ABMultiValueRef multi_im = ABRecordCopyValue(recordRef, kABPersonInstantMessageProperty);
    ABMultiValueRef multi_phone = ABRecordCopyValue(recordRef, kABPersonPhoneProperty);
    
    if (ABMultiValueGetCount(multi_email) > 0 ||
        ABMultiValueGetCount(multi_socialprofile) > 0 ||
        ABMultiValueGetCount(multi_im) > 0 ||
        ABMultiValueGetCount(multi_phone) > 0) {
        __block NSString *indexfield = @"";
        ABRecordID uid = ABRecordGetRecordID(recordRef);
        
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"LocalContact"];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(uid == %i)",uid];
        [request setPredicate:predicate];
        
        __block BOOL needUpdate = YES;
        
        // init localcontact
        RKObjectManager *objectManager = [RKObjectManager sharedManager];
        __block NSArray *localcontacts;
        [objectManager.managedObjectStore.mainQueueManagedObjectContext performBlockAndWait:^{
            localcontacts = [objectManager.managedObjectStore.persistentStoreManagedObjectContext executeFetchRequest:request error:nil];
            
            if ([localcontacts count] > 0) {
                result= [localcontacts objectAtIndex:0];
                
                // check need update
                NSDate *recordModicationDate = CFBridgingRelease(ABRecordCopyValue(recordRef, kABPersonModificationDateProperty));
                if (date && [recordModicationDate timeIntervalSinceDate:date] <= 0) {
                    needUpdate = NO;
                }
            } else {
                NSEntityDescription *localcontactEntity = [NSEntityDescription entityForName:@"LocalContact" inManagedObjectContext:objectManager.managedObjectStore.mainQueueManagedObjectContext];
                RKObjectManager *objectManager = [RKObjectManager sharedManager];
                result = [[LocalContact alloc] initWithEntity:localcontactEntity insertIntoManagedObjectContext:objectManager.managedObjectStore.mainQueueManagedObjectContext];
            }
            
            if (needUpdate) {
                // recordID -> uid
                result.uid = [NSNumber numberWithInt:uid];
                
                // compositeName -> name
                CFStringRef compositeName = ABRecordCopyCompositeName(recordRef);
                if ((__bridge NSString *)compositeName != nil) {
                    result.name = (__bridge NSString *)compositeName;
                    indexfield = [indexfield stringByAppendingString:(__bridge NSString *)compositeName];
                    CFRelease(compositeName);
                }
                
                // kABPersonFirstNamePhoneticProperty
                CFStringRef firstNamePhoneticRef = ABRecordCopyValue(recordRef, kABPersonFirstNamePhoneticProperty);
                if ((__bridge NSString *)firstNamePhoneticRef != nil) {
                    NSString *firstNamePhonetic = [(__bridge NSString *)firstNamePhoneticRef stringWithoutSpace];
                    indexfield = [indexfield stringByAppendingString:firstNamePhonetic];
                    CFRelease(firstNamePhoneticRef);
                }
                
                // kABPersonLastNamePhoneticProperty
                CFStringRef lastNamePhoneticRef = ABRecordCopyValue(recordRef, kABPersonLastNamePhoneticProperty);
                if ((__bridge NSString *)lastNamePhoneticRef != nil) {
                    NSString *lastNamePhonetic = [(__bridge NSString *)lastNamePhoneticRef stringWithoutSpace];
                    indexfield = [indexfield stringByAppendingString:lastNamePhonetic];
                    CFRelease(lastNamePhoneticRef);
                }
                
                // kABPersonMiddleNamePhoneticProperty
                CFStringRef middleNamePhoneticRef = ABRecordCopyValue(recordRef, kABPersonMiddleNamePhoneticProperty);
                if ((__bridge NSString *)middleNamePhoneticRef != nil) {
                    NSString *middleNamePhonetic = [(__bridge NSString *)middleNamePhoneticRef stringWithoutSpace];
                    indexfield = [indexfield stringByAppendingString:middleNamePhonetic];
                    CFRelease(middleNamePhoneticRef);
                }
                
                // thumbnail image -> avatar
                CFDataRef avatarDataRef = ABPersonCopyImageDataWithFormat(recordRef, kABPersonImageFormatThumbnail);
                CGDataProviderRef avatarDataProvider = CGDataProviderCreateWithCFData (avatarDataRef);
                CGImageRef avatarRef = NULL;
                if (avatarDataProvider) {
                    avatarRef = CGImageCreateWithPNGDataProvider(avatarDataProvider, NULL, true, kCGRenderingIntentDefault); // try png
                    if (!avatarRef) {
                        avatarRef = CGImageCreateWithJPEGDataProvider(avatarDataProvider, NULL, true, kCGRenderingIntentDefault);
                    }
                    CFRelease(avatarDataProvider);
                    if(avatarRef != nil){
                        result.avatar = (__bridge NSData *)avatarDataRef;
                        CFRelease(avatarRef);
                    }
                }
                
                // email -> emails
                if (ABMultiValueGetCount(multi_email) > 0) {
                    NSMutableArray *formatedEmails = [[NSMutableArray alloc] initWithCapacity:ABMultiValueGetCount(multi_email)];
                    
                    for (CFIndex i = 0; i < ABMultiValueGetCount(multi_email); i++) {
                        NSString *email = (NSString*)CFBridgingRelease(ABMultiValueCopyValueAtIndex(multi_email, i));
                        if (email != nil) {
                            NSString *formatedEmail = [email stringWithoutSpace];
                            
                            indexfield = [indexfield stringByAppendingFormat:@" %@",formatedEmail];
                            [formatedEmails addObject:formatedEmail];
                        }
                    }
                    if ([formatedEmails count] > 0) {
                        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:formatedEmails];
                        result.emails = data;
                    }
                }
                
                // phone -> phones
                if (ABMultiValueGetCount(multi_phone) > 0) {
                    NSMutableArray *phone_array = [[NSMutableArray alloc] initWithCapacity:ABMultiValueGetCount(multi_phone)];
                    
                    for (CFIndex i = 0; i < ABMultiValueGetCount(multi_phone); i++) {
                        NSString* phone = (NSString*)CFBridgingRelease(ABMultiValueCopyValueAtIndex(multi_phone, i));
                        if (phone != nil) {
                            NSString *clean_phone=@"";
                            clean_phone=[phone stringByReplacingOccurrencesOfString:@"(" withString:@""];
                            clean_phone=[clean_phone stringByReplacingOccurrencesOfString:@")" withString:@""];
                            clean_phone=[clean_phone stringByReplacingOccurrencesOfString:@"-" withString:@""];
                            clean_phone=[clean_phone stringByReplacingOccurrencesOfString:@"-" withString:@""];
                            clean_phone=[clean_phone stringByReplacingOccurrencesOfString:@" " withString:@""];
                            clean_phone=[clean_phone stringByReplacingOccurrencesOfString:@"." withString:@""];
                            
                            NSString *cnphoneregex = @"1([3458]|7[1-8])\\d*";
                            NSPredicate *cnphoneTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", cnphoneregex];
                            NSString *phoneresult = @"";
                            if ([mcc isEqualToString:@"460"] || [isocode isEqualToString:@"cn"]) {
                                if ([[clean_phone substringToIndex:2] isEqualToString:@"00"])
                                    phoneresult = [@"+" stringByAppendingString: [clean_phone substringFromIndex:2]];
                                else if ([[clean_phone substringToIndex:1] isEqualToString:@"+"])
                                    phoneresult = clean_phone;
                                else if ([cnphoneTest evaluateWithObject:clean_phone])
                                    phoneresult = [@"+86" stringByAppendingString:clean_phone];
                            }
                            if ([mcc isEqualToString:@"310"] || [mcc isEqualToString:@"311"] || [isocode isEqualToString:@"us"] || [isocode isEqualToString:@"ca"]) {
                                if ([[clean_phone substringToIndex:1] isEqualToString:@"+"])
                                    phoneresult = clean_phone;
                                else if ([[clean_phone substringToIndex:1] isEqualToString:@"1"])
                                    phoneresult = [@"+" stringByAppendingString:clean_phone];
                                else if ([clean_phone characterAtIndex:0] >= '2' && [clean_phone characterAtIndex:0] <= '9' && [clean_phone length]>=7)
                                    phoneresult = [@"+1" stringByAppendingString:clean_phone];
                            }
                            if ([phoneresult length] > 0) {
                                indexfield = [indexfield stringByAppendingFormat:@" %@",phoneresult];
                                [phone_array addObject:phoneresult];
                            }
                        }
                    }
                    if ([phone_array count] > 0) {
                        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:phone_array];
                        result.phones=data;
                    }
                }
                
                // social -> socail
                NSMutableArray *social_array = [[NSMutableArray alloc] initWithCapacity:ABMultiValueGetCount(multi_socialprofile)];
                for (CFIndex i = 0; i < ABMultiValueGetCount(multi_socialprofile); i++) {
                    NSDictionary *socialprofile = (NSDictionary*)CFBridgingRelease(ABMultiValueCopyValueAtIndex(multi_socialprofile, i));
                    
                    NSMutableDictionary *formatedSocialProfile = [NSMutableDictionary dictionaryWithCapacity:socialprofile.count];
                    [socialprofile enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop){
                        NSString *aKey = [(NSString *)key stringWithoutSpace];
                        if ([obj isKindOfClass:[NSString class]]) {
                            obj = [(NSString *)obj stringWithoutSpace];
                        }
                        
                        [formatedSocialProfile setValue:obj forKey:aKey];
                    }];
                    
                    if ([[formatedSocialProfile objectForKey:@"service"] isEqualToString:@"twitter"] ||  [[formatedSocialProfile objectForKey:@"service"] isEqualToString:@"facebook"]) {
                        [social_array addObject:formatedSocialProfile];
                        
                        NSString *social_username = [formatedSocialProfile objectForKey:@"username"];
                        if (social_username != nil) {
                            if([[formatedSocialProfile objectForKey:@"service"] isEqualToString:@"twitter"])
                                social_username = [@"@" stringByAppendingString:social_username];
                            indexfield = [indexfield stringByAppendingFormat:@" %@",social_username];
                        }
                    }
                }
                
                if ([social_array count] > 0) {
                    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:social_array];
                    result.social=data;
                }
                
                // im -> im
                for (CFIndex i = 0; i < ABMultiValueGetCount(multi_im); i++) {
                    NSMutableArray *im_array = [[NSMutableArray alloc] initWithCapacity:ABMultiValueGetCount(multi_im)];
                    
                    NSDictionary *personim = (NSDictionary*)CFBridgingRelease(ABMultiValueCopyValueAtIndex(multi_im, i));
                    
                    NSMutableDictionary *formatedPersonIm = [NSMutableDictionary dictionaryWithCapacity:personim.count];
                    [personim enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop){
                        NSString *aKey = [(NSString *)key stringWithoutSpace];
                        if ([obj isKindOfClass:[NSString class]]) {
                            obj = [(NSString *)obj stringWithoutSpace];
                        }
                        
                        [formatedPersonIm setValue:obj forKey:aKey];
                    }];
                    
                    if ([formatedPersonIm objectForKey:@"username"] != nil) {
                        if([[formatedPersonIm objectForKey:@"service"] isEqualToString:@"Facebook"]) {
                            [im_array addObject:formatedPersonIm];
                            indexfield = [indexfield stringByAppendingFormat:@" %@",[formatedPersonIm objectForKey:@"username"]];
                        }
                    }
                    
                    if ([im_array count] > 0) {
                        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:im_array];
                        result.im = data;
                    }
                }
                result.indexfield = indexfield;
            }

        }];
    }
    
    CFRelease(multi_phone);
    CFRelease(multi_email);
    CFRelease(multi_socialprofile);
    CFRelease(multi_im);
    
    return result;
}
