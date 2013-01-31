//
//  AddressBook.m
//  EXFE
//
//  Created by huoju on 11/26/12.
//
//

#import "AddressBook.h"

@implementation AddressBook
@synthesize parentview;
@synthesize contactscount;

- (void) UpdatePeople:(NSDate*)lastsaved{
//    ABAddressBookRef addressBook;

    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"6.0")) {
        addressBook = ABAddressBookCreateWithOptions(NULL, NULL);
    }
    else if(SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"5.1")){
        addressBook = ABAddressBookCreate();
    }
    
    __block BOOL accessGranted = NO;
    if (ABAddressBookRequestAccessWithCompletion != NULL) { // we're on iOS 6
        dispatch_semaphore_t sema = dispatch_semaphore_create(0);
        
        ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
            accessGranted = granted;
            dispatch_semaphore_signal(sema);
        });
        
        dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
        dispatch_release(sema);
    }
    else { // we're on iOS 5 or older
        accessGranted = YES;
    }
    
    if (accessGranted) {
        [self CopyAllPeopleFrom:0];
    }
}

- (void) CopyAllPeopleFrom:(int)idx{
    CFArrayRef allPeople = ABAddressBookCopyArrayOfAllPeople( addressBook );
    CFIndex count= CFArrayGetCount(allPeople);
    if(count>contactscount)
        contactscount=count;
    
    int step=100;
    if(idx+step>contactscount)
        step=contactscount-idx;

    for(int ai=idx;ai<idx+step;ai++){
        ABRecordRef ref = CFArrayGetValueAtIndex( allPeople, ai );
        ABRecordType reftype = ABRecordGetRecordType(ref);

        if(reftype==0){
            ABMultiValueRef multi_email = ABRecordCopyValue(ref, kABPersonEmailProperty);
            ABMultiValueRef multi_socialprofile = ABRecordCopyValue(ref, kABPersonSocialProfileProperty);
            ABMultiValueRef multi_im = ABRecordCopyValue(ref, kABPersonInstantMessageProperty);
            if(ABMultiValueGetCount(multi_email)>0 || ABMultiValueGetCount(multi_socialprofile)>0 || ABMultiValueGetCount(multi_im)>0){
                NSString *indexfield=@"";
                ABRecordID uid=ABRecordGetRecordID(ref);
                LocalContact *localcontact=nil;
                
                NSFetchRequest* request = [LocalContact fetchRequest];
                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(uid == %i)",uid];
                [request setPredicate:predicate];
                NSArray *localcontacts=[[LocalContact objectsWithFetchRequest:request] retain];
                if([localcontacts count]>0)
                    localcontact= [localcontacts objectAtIndex:0];
                else{
                    localcontact=[LocalContact object];
                }
                localcontact.uid=[NSNumber numberWithInt:uid];
                
                CFStringRef compositeName=ABRecordCopyCompositeName(ref);
                if((NSString *)compositeName!=nil){
                    localcontact.name=(NSString *)compositeName;
                    indexfield=[indexfield stringByAppendingString:(NSString *)compositeName];
                }
                
                CFDataRef avatarref=ABPersonCopyImageData(ref);
                UIImage *avatar = [UIImage imageWithData:(NSData *)avatarref];
                if(avatar!=nil){
                    localcontact.avatar=(NSData *)avatarref;
                }

                
            if(ABMultiValueGetCount(multi_email)>0){
                NSMutableArray *emails_array=[[[NSMutableArray alloc] initWithCapacity:ABMultiValueGetCount(multi_email)] autorelease];
                for (CFIndex i = 0; i < ABMultiValueGetCount(multi_email); i++) {
                    NSString* email =(NSString*) ABMultiValueCopyValueAtIndex(multi_email, i);
                    if(email!=nil){
                        indexfield=[indexfield stringByAppendingFormat:@" %@",email];
                        [emails_array addObject:email];
                    }
                }
                if([emails_array count]>0){
                    NSData *data = [NSKeyedArchiver archivedDataWithRootObject: emails_array];
                    localcontact.emails=data;
                }
            }
            NSMutableArray *social_array=[[[NSMutableArray alloc] initWithCapacity:ABMultiValueGetCount(multi_socialprofile)] autorelease];
            for (CFIndex i = 0; i < ABMultiValueGetCount(multi_socialprofile); i++) {
                NSDictionary* socialprofile =( NSDictionary*) ABMultiValueCopyValueAtIndex(multi_socialprofile, i);

                if([[socialprofile objectForKey:@"service"] isEqualToString:@"twitter"] ||  [[socialprofile objectForKey:@"service"] isEqualToString:@"facebook"]){
                    [social_array addObject:socialprofile];
                    
                    NSString *social_username=[socialprofile objectForKey:@"username"];
                    if(social_username!=nil){
                        if([[socialprofile objectForKey:@"service"] isEqualToString:@"twitter"])
                            social_username=[@"@" stringByAppendingString:social_username];
                        indexfield=[indexfield stringByAppendingFormat:@" %@",social_username];
                    }
                }
            }
                if([social_array count]>0){
                    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:social_array];
                    localcontact.social=data;
                }

            for (CFIndex i = 0; i < ABMultiValueGetCount(multi_im); i++) {
                NSMutableArray *im_array=[[[NSMutableArray alloc] initWithCapacity:ABMultiValueGetCount(multi_im)] autorelease];

                NSDictionary* personim =(NSDictionary*) ABMultiValueCopyValueAtIndex(multi_im, i);

                if([personim objectForKey:@"username"]!=nil){
                    if([[personim objectForKey:@"service"] isEqualToString:@"Facebook"]){
                        [im_array addObject:personim];
                        indexfield=[indexfield stringByAppendingFormat:@" %@",[personim objectForKey:@"username"]];
                    }
                }
                
                if([im_array count]>0){
                    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:im_array];
                    localcontact.im=data;
                }
            }
            localcontact.indexfield=indexfield;
            }
        }
    }
    [[LocalContact currentContext] save:nil];
}

+ (NSDictionary*) getDefaultIdentity:(LocalContact*) person{
    NSString *username=@"";
    int type=0;
#define TWITTER_TYPE 1
#define FACEBOOK_TYPE 2
#define EMAIL_TYPE 3
    if(person.social!=nil){
        NSArray *social_array=[NSKeyedUnarchiver unarchiveObjectWithData:person.social];
        if( social_array!=nil && [social_array isKindOfClass:[NSArray class]]){
            for (NSDictionary *socialdict in social_array) {
                if([[socialdict objectForKey:@"service"] isEqualToString:@"twitter"]){
                    username=[socialdict objectForKey:@"username"];
                    type=TWITTER_TYPE;
                }
                if([[socialdict objectForKey:@"service"] isEqualToString:@"facebook"]){
                    username=[socialdict objectForKey:@"username"];
                    type=FACEBOOK_TYPE;
                }
            }
        }
    }
    if(person.im!=nil){
        NSArray *im_array=[NSKeyedUnarchiver unarchiveObjectWithData:person.im];
        if( im_array!=nil && [im_array isKindOfClass: [NSArray class]]){
            for (NSDictionary *imdict in im_array) {
                if([[imdict objectForKey:@"service"] isEqualToString:@"Facebook"]){
                    username=[imdict objectForKey:@"username"];
                    type=FACEBOOK_TYPE;
                }
            }
        }
        
    }
        
    if(person.emails!=nil){
        NSArray *emails_array=[NSKeyedUnarchiver unarchiveObjectWithData:person.emails];
        if(emails_array!=nil && [emails_array isKindOfClass: [NSArray class]]){
            NSString *email=[emails_array objectAtIndex:0];
            username=email;
            type=EMAIL_TYPE;
        }
        
    }

    
    NSString *provider=@"";
    if(type==TWITTER_TYPE)
        provider=@"twitter";
    else if(type==FACEBOOK_TYPE)
        provider=@"facebook";
    else if(type==EMAIL_TYPE)
        provider=@"email";
    return [NSDictionary dictionaryWithObjectsAndKeys:provider,@"provider",username,@"external_id", nil] ;
}

+ (NSArray*) getLocalIdentityObjects:(LocalContact*) person{
    NSMutableArray *identities=[[[NSMutableArray alloc] initWithCapacity:4] autorelease];
    
    if(person.social!=nil){
        NSArray *social_array=[NSKeyedUnarchiver unarchiveObjectWithData:person.social];
        if(social_array!=nil && [social_array isKindOfClass: [NSArray class]]){
            for (NSDictionary *socialdict in social_array) {
                if([[socialdict objectForKey:@"service"] isEqualToString:@"twitter"] ||[[socialdict objectForKey:@"service"] isEqualToString:@"facebook"] ){
                    NSDictionary *dict=[NSDictionary dictionaryWithObjectsAndKeys:[socialdict objectForKey:@"username"],@"external_id",[socialdict objectForKey:@"service"],@"provider", nil];
                    [identities addObject:dict];
                }
            }
        }
    }
    
    if(person.im!=nil){
        NSArray *im_array=[NSKeyedUnarchiver unarchiveObjectWithData:person.im];
        if(im_array!=nil && [im_array isKindOfClass: [NSArray class]]){
            for (NSDictionary *imdict in im_array) {
                if([[imdict objectForKey:@"service"] isEqualToString:@"Facebook"]){
                    NSDictionary *dict=[NSDictionary dictionaryWithObjectsAndKeys:[imdict objectForKey:@"username"],@"external_id",@"facebook",@"provider", nil];
                    [identities addObject:dict];
                }
            }
        }
    }
    
    if(person.emails!=nil){
        NSArray *emails_array=[NSKeyedUnarchiver unarchiveObjectWithData:person.emails];

        if(emails_array!=nil && [emails_array isKindOfClass: [NSArray class]]){
            for (NSString *email in emails_array) {
                NSDictionary *dict=[NSDictionary dictionaryWithObjectsAndKeys:email,@"external_id",@"email",@"provider", nil];
                [identities addObject:dict];
            }
            }
    }
    return identities;
}
- (void)dealloc{
    CFRelease(addressBook);
}

@end
