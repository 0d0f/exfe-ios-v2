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
#import "MBProgressHUD.h"


@interface AddressBook : NSObject{
    UIView *parentview;
}

@property (nonatomic,retain) UIView *parentview;
- (NSArray*) UpdatePeople:(NSDate*)lastsaved;
- (NSArray*) CopyAllPeople:(ABAddressBookRef)addressbook;
+ (NSDictionary*) getDefaultIdentity:(NSDictionary*)person;
+ (NSArray*) getLocalIdentityObjects:(NSDictionary*) person;
@end
