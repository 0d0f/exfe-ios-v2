//
//  AddressBook.m
//  EXFE
//
//  Created by huoju on 11/26/12.
//
//

#import "AddressBook.h"

@implementation AddressBook
- (NSArray*) UpdatePeople:(NSDate*)lastsaved{
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, NULL);
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
        return [self CopyAllPeople:addressBook];
    }
    return nil;
}

- (NSArray*) CopyAllPeople:(ABAddressBookRef)addressbook{
    CFArrayRef allPeople = ABAddressBookCopyArrayOfAllPeople( addressbook );
    CFIndex count= CFArrayGetCount(allPeople);
    NSMutableArray *contacts=[[NSMutableArray alloc] initWithCapacity:count];
    for(int ai=0;ai<count;ai++){
        ABRecordRef ref = CFArrayGetValueAtIndex( allPeople, ai );
        ABRecordType reftype = ABRecordGetRecordType(ref);
        if(reftype==0){

            ABMultiValueRef multi_email = ABRecordCopyValue(ref, kABPersonEmailProperty);
            ABMultiValueRef multi_socialprofile = ABRecordCopyValue(ref, kABPersonSocialProfileProperty);
            ABMultiValueRef multi_im = ABRecordCopyValue(ref, kABPersonInstantMessageProperty);
            if(ABMultiValueGetCount(multi_email)>0 || ABMultiValueGetCount(multi_socialprofile)>0 || ABMultiValueGetCount(multi_im)>0){
                NSString *indexfield=@"";
                ABRecordID uid=ABRecordGetRecordID(ref);

                NSMutableDictionary *person=[[[NSMutableDictionary alloc] initWithCapacity:3] autorelease];
                [person setObject:[NSNumber numberWithInt:uid] forKey:@"uid"];
                CFStringRef compositeName=ABRecordCopyCompositeName(ref);
                [person setObject:(NSString *)compositeName forKey:@"name"];
                indexfield=[indexfield stringByAppendingString:(NSString *)compositeName];
                
                CFDataRef avatarref=ABPersonCopyImageData(ref);
                UIImage *avatar = [UIImage imageWithData:(NSData *)avatarref];
            if(avatar!=nil)
                [person setObject:avatar forKey:@"avatar"];

            if(ABMultiValueGetCount(multi_email)>0){
                NSMutableArray *emails_array=[[[NSMutableArray alloc] initWithCapacity:ABMultiValueGetCount(multi_email)] autorelease];
                for (CFIndex i = 0; i < ABMultiValueGetCount(multi_email); i++) {
                    NSString* email =(NSString*) ABMultiValueCopyValueAtIndex(multi_email, i);
                    indexfield=[indexfield stringByAppendingFormat:@" %@",email];
                    [emails_array addObject:email];
                }
                if([emails_array count]>0)
                    [person setObject:emails_array forKey:@"emails"];
            }
            NSMutableArray *social_array=[[[NSMutableArray alloc] initWithCapacity:ABMultiValueGetCount(multi_socialprofile)] autorelease];
            for (CFIndex i = 0; i < ABMultiValueGetCount(multi_socialprofile); i++) {
                NSDictionary* socialprofile =( NSDictionary*) ABMultiValueCopyValueAtIndex(multi_socialprofile, i);

                if([[socialprofile objectForKey:@"service"] isEqualToString:@"twitter"] ||  [[socialprofile objectForKey:@"service"] isEqualToString:@"facebook"]){
                    [social_array addObject:socialprofile];
                    NSString *social_username=[socialprofile objectForKey:@"username"];
                    if([[socialprofile objectForKey:@"service"] isEqualToString:@"twitter"])
                        social_username=[@"@" stringByAppendingString:social_username];
                    indexfield=[indexfield stringByAppendingFormat:@" %@",social_username];
                }
            }
            if([social_array count]>0)
                    [person setObject:social_array forKey:@"social"];

            for (CFIndex i = 0; i < ABMultiValueGetCount(multi_im); i++) {
                NSMutableArray *im_array=[[[NSMutableArray alloc] initWithCapacity:ABMultiValueGetCount(multi_im)] autorelease];

                NSDictionary* personim =(NSDictionary*) ABMultiValueCopyValueAtIndex(multi_im, i);

            if([[personim objectForKey:@"service"] isEqualToString:@"Facebook"]){
                [im_array addObject:personim];
                indexfield=[indexfield stringByAppendingFormat:@" %@",[personim objectForKey:@"username"]];
            }
            if([im_array count]>0)
                [person setObject:im_array forKey:@"im"];
            }
            [person setObject:indexfield forKey:@"indexfield"];
            [contacts addObject:person];
            }
        }
    }
    return contacts;
}

+ (NSDictionary*) getDefaultIdentity:(NSDictionary*)person{
//    cell.subtitle=@"";
    NSString *username=@"";
    int type=0;
#define TWITTER_TYPE 1
#define FACEBOOK_TYPE 2
#define EMAIL_TYPE 3
    
    if([person objectForKey:@"social"]!=nil && [[person objectForKey:@"social"] isKindOfClass: [NSArray class]]){
        for (NSDictionary *socialdict in [person objectForKey:@"social"]) {
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
    
    if([person objectForKey:@"im"]!=nil && [[person objectForKey:@"im"] isKindOfClass: [NSArray class]]){
        for (NSDictionary *imdict in [person objectForKey:@"im"]) {
            if([[imdict objectForKey:@"service"] isEqualToString:@"Facebook"]){
                username=[imdict objectForKey:@"username"];
                type=FACEBOOK_TYPE;
            }
        }
    }
    
    if([person objectForKey:@"emails"]!=nil && [[person objectForKey:@"emails"] isKindOfClass: [NSArray class]]){
        NSString *email=[[person objectForKey:@"emails"] objectAtIndex:0];
        if([username isEqualToString:@""] || type!=FACEBOOK_TYPE ){
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

+ (NSArray*) getLocalIdentityObjects:(NSDictionary*) person{
    NSMutableArray *identities=[[[NSMutableArray alloc] initWithCapacity:4] autorelease];
    if([person objectForKey:@"social"]!=nil && [[person objectForKey:@"social"] isKindOfClass: [NSArray class]]){
        for (NSDictionary *socialdict in [person objectForKey:@"social"]) {
            if([[socialdict objectForKey:@"service"] isEqualToString:@"twitter"] ||[[socialdict objectForKey:@"service"] isEqualToString:@"facebook"] ){
                NSDictionary *dict=[NSDictionary dictionaryWithObjectsAndKeys:[socialdict objectForKey:@"username"],@"external_id",[socialdict objectForKey:@"service"],@"provider", nil];
                [identities addObject:dict];
            }
        }
    }
    
    if([person objectForKey:@"im"]!=nil && [[person objectForKey:@"im"] isKindOfClass: [NSArray class]]){
        for (NSDictionary *imdict in [person objectForKey:@"im"]) {
            if([[imdict objectForKey:@"service"] isEqualToString:@"Facebook"]){
                NSDictionary *dict=[NSDictionary dictionaryWithObjectsAndKeys:[imdict objectForKey:@"username"],@"external_id",@"facebook",@"provider", nil];
                [identities addObject:dict];
            }
        }
    }
    
    if([person objectForKey:@"emails"]!=nil && [[person objectForKey:@"emails"] isKindOfClass: [NSArray class]]){
        
        for (NSString *email in [person objectForKey:@"emails"]) {
            NSDictionary *dict=[NSDictionary dictionaryWithObjectsAndKeys:email,@"external_id",@"email",@"provider", nil];
            [identities addObject:dict];
        }
        }
    return identities;
}
@end
