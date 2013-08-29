//
//  AddressBook.h
//  EXFE
//
//  Created by huoju on 11/26/12.
//
//

#import <Foundation/Foundation.h>
#import <AddressBook/AddressBook.h>
#import "EXSpinView.h"
#import "AppDelegate.h"
#import "LocalContact.h"
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <CoreTelephony/CTCarrier.h>

@interface AddressBook : NSObject{
    UIView *parentview;
    ABAddressBookRef addressBook;
    int contactscount;
}

@property (nonatomic,strong) UIView *parentview;
@property int contactscount;

- (void) UpdatePeople:(NSDate*)lastsaved;
- (void) CopyAllPeopleFrom:(int)idx;
+ (NSDictionary*) getDefaultIdentity:(LocalContact*) person;
+ (NSArray*) getLocalIdentityObjects:(LocalContact*) person;
@end
