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
  NSLog(@"copy more people:%i",idx);
    CFArrayRef allPeople = ABAddressBookCopyArrayOfAllPeople( addressBook );
    CFIndex count= CFArrayGetCount(allPeople);
    if(count>contactscount)
        contactscount=count;
    
    int step=100;
    if(idx+step>contactscount)
        step=contactscount-idx;
  
    CTTelephonyNetworkInfo *netInfo = [[CTTelephonyNetworkInfo alloc] init];
    CTCarrier *carrier = [netInfo subscriberCellularProvider];
    NSString *mcc = [carrier mobileCountryCode];
    NSString *mnc = [carrier mobileNetworkCode];
    NSString *isocode =[carrier isoCountryCode];
    for(int ai=idx;ai<idx+step;ai++){
        ABRecordRef ref = CFArrayGetValueAtIndex( allPeople, ai );
        ABRecordType reftype = ABRecordGetRecordType(ref);

        if(reftype==0){
            ABMultiValueRef multi_email = ABRecordCopyValue(ref, kABPersonEmailProperty);
            ABMultiValueRef multi_socialprofile = ABRecordCopyValue(ref, kABPersonSocialProfileProperty);
            ABMultiValueRef multi_im = ABRecordCopyValue(ref, kABPersonInstantMessageProperty);
            ABMultiValueRef multi_phone = ABRecordCopyValue(ref, kABPersonPhoneProperty);
            if(ABMultiValueGetCount(multi_email)>0 || ABMultiValueGetCount(multi_socialprofile)>0 || ABMultiValueGetCount(multi_im)>0 || ABMultiValueGetCount(multi_phone)>0){
                NSString *indexfield=@"";
                ABRecordID uid=ABRecordGetRecordID(ref);
                LocalContact *localcontact=nil;
              
                NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"LocalContact"];
                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(uid == %i)",uid];
                [request setPredicate:predicate];
                RKObjectManager *objectManager = [RKObjectManager sharedManager];
                NSArray *localcontacts = [objectManager.managedObjectStore.mainQueueManagedObjectContext executeFetchRequest:request error:nil];
                if([localcontacts count]>0)
                    localcontact= [localcontacts objectAtIndex:0];
                else{
                  
                    NSEntityDescription *localcontactEntity = [NSEntityDescription entityForName:@"LocalContact" inManagedObjectContext:objectManager.managedObjectStore.mainQueueManagedObjectContext];
                    RKObjectManager *objectManager=[RKObjectManager sharedManager];
                  localcontact=[[LocalContact alloc] initWithEntity:localcontactEntity insertIntoManagedObjectContext:objectManager.managedObjectStore.mainQueueManagedObjectContext];
                }
//                [localcontacts release];
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
                    CFRelease(avatarref);
                }
              
            if(ABMultiValueGetCount(multi_email)>0){
                NSMutableArray *emails_array=[[[NSMutableArray alloc] initWithCapacity:ABMultiValueGetCount(multi_email)] autorelease];
                for (CFIndex i = 0; i < ABMultiValueGetCount(multi_email); i++) {
                    NSString* email =(NSString*) ABMultiValueCopyValueAtIndex(multi_email, i);
                    if(email!=nil){
                        indexfield=[indexfield stringByAppendingFormat:@" %@",email];
                        [emails_array addObject:email];
                        [email release];
                    }
                }
                if([emails_array count]>0){
                    NSData *data = [NSKeyedArchiver archivedDataWithRootObject: emails_array];
                    localcontact.emails=data;
                }
            }
            if(ABMultiValueGetCount(multi_phone)>0){
              NSMutableArray *phone_array=[[[NSMutableArray alloc] initWithCapacity:ABMultiValueGetCount(multi_phone)] autorelease];
              
              for (CFIndex i = 0; i < ABMultiValueGetCount(multi_phone); i++) {
                NSString* phone =(NSString*) ABMultiValueCopyValueAtIndex(multi_phone, i);
                if(phone!=nil){
                  NSString* clean_phone=@"";
                  clean_phone=[phone stringByReplacingOccurrencesOfString:@"(" withString:@""];
                  clean_phone=[clean_phone stringByReplacingOccurrencesOfString:@")" withString:@""];
                  clean_phone=[clean_phone stringByReplacingOccurrencesOfString:@"-" withString:@""];
                  clean_phone=[clean_phone stringByReplacingOccurrencesOfString:@"-" withString:@""];
                  clean_phone=[clean_phone stringByReplacingOccurrencesOfString:@" " withString:@""];
                  clean_phone=[clean_phone stringByReplacingOccurrencesOfString:@"." withString:@""];
                  
                  NSString *cnphoneregex = @"1([3458]|7[1-8])\\d*";
                  NSPredicate *cnphoneTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", cnphoneregex];
                  NSString *phoneresult=@"";
                  if([mcc isEqualToString:@"460"] || [isocode isEqualToString:@"cn"]){
                    if([[clean_phone substringToIndex:2] isEqualToString:@"00"])
                      phoneresult =[@"+" stringByAppendingString: [clean_phone substringFromIndex:2]];
                    else if([[clean_phone substringToIndex:1] isEqualToString:@"+"])
                      phoneresult=clean_phone;
                    else if([cnphoneTest evaluateWithObject:clean_phone]==YES)
                      phoneresult=[@"+86" stringByAppendingString:clean_phone];
                  }
                  if([mcc isEqualToString:@"310"] ||[mcc isEqualToString:@"311"] || [isocode isEqualToString:@"us"] || [isocode isEqualToString:@"ca"] ){
                    if([[clean_phone substringToIndex:1] isEqualToString:@"+"])
                      phoneresult=clean_phone;
                    else if([[clean_phone substringToIndex:1] isEqualToString:@"1"])
                      phoneresult=[@"+" stringByAppendingString:clean_phone];
                    else if([clean_phone characterAtIndex:0] >= '2' && [clean_phone characterAtIndex:0] <= '9' && [clean_phone length]>=7)
                      phoneresult=[@"+1" stringByAppendingString:clean_phone];
                  }
                  if([phoneresult length]>0){
                    indexfield=[indexfield stringByAppendingFormat:@" %@",phoneresult];
                    [phone_array addObject:phoneresult];
                  }
                  [phone release];
                }
              }
              if([phone_array count]>0){
                NSData *data = [NSKeyedArchiver archivedDataWithRootObject: phone_array];
                localcontact.phones=data;
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
                if(socialprofile!=nil)
                    [socialprofile release];
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
                if(personim!=nil)
                    [personim release];
                
                if([im_array count]>0){
                    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:im_array];
                    localcontact.im=data;
                }
            }
            localcontact.indexfield=indexfield;
            }
            CFRelease(multi_email);
            CFRelease(multi_socialprofile);
            CFRelease(multi_im);
        }
    }
  RKObjectManager *objectManager = [RKObjectManager sharedManager];
  [objectManager.managedObjectStore.mainQueueManagedObjectContext save:nil];
    CFRelease(allPeople);
}

+ (NSDictionary*) getDefaultIdentity:(LocalContact*) person{
    NSString *username=@"";
    int type=0;
#define TWITTER_TYPE 1
#define FACEBOOK_TYPE 2
#define EMAIL_TYPE 3
#define PHONE_TYPE 4
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
  
    if(person.phones!=nil){
      NSArray *phone_array=[NSKeyedUnarchiver unarchiveObjectWithData:person.phones];
      if(phone_array!=nil && [phone_array isKindOfClass: [NSArray class]]){
          NSString *phone=[phone_array objectAtIndex:0];
          username=phone;
          type=PHONE_TYPE;
      }
    }

  
    NSString *provider=@"";
    if(type==TWITTER_TYPE)
        provider=@"twitter";
    else if(type==FACEBOOK_TYPE)
        provider=@"facebook";
    else if(type==EMAIL_TYPE)
        provider=@"email";
    else if(type==PHONE_TYPE)
      provider=@"phone";
  
    return [NSDictionary dictionaryWithObjectsAndKeys:provider,@"provider",username,@"external_id", nil] ;
}

+ (NSArray*) getLocalIdentityObjects:(LocalContact*) person{
    NSMutableArray *identities=[[[NSMutableArray alloc] initWithCapacity:4] autorelease];
    
    if(person.social!=nil){
        NSArray *social_array=[NSKeyedUnarchiver unarchiveObjectWithData:person.social];
        if(social_array!=nil && [social_array isKindOfClass: [NSArray class]]){
            for (NSDictionary *socialdict in social_array) {
                if([[socialdict objectForKey:@"service"] isEqualToString:@"twitter"] ||[[socialdict objectForKey:@"service"] isEqualToString:@"facebook"] ){
                    NSDictionary *dict=[NSDictionary dictionaryWithObjectsAndKeys:[socialdict objectForKey:@"username"],@"external_id",person.name,@"name",[socialdict objectForKey:@"service"],@"provider", nil];
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
                    NSDictionary *dict=[NSDictionary dictionaryWithObjectsAndKeys:[imdict objectForKey:@"username"],@"external_id",person.name,@"name",@"facebook",@"provider", nil];
                    [identities addObject:dict];
                }
            }
        }
    }
    
    if(person.emails!=nil){
        NSArray *emails_array=[NSKeyedUnarchiver unarchiveObjectWithData:person.emails];

        if(emails_array!=nil && [emails_array isKindOfClass: [NSArray class]]){
            for (NSString *email in emails_array) {
                NSDictionary *dict=[NSDictionary dictionaryWithObjectsAndKeys:email,@"external_id",person.name,@"name",@"email",@"provider", nil];
                [identities addObject:dict];
              }
            }
    }
    if(person.phones!=nil){
      NSArray *phones_array=[NSKeyedUnarchiver unarchiveObjectWithData:person.phones];
      
      if(phones_array!=nil && [phones_array isKindOfClass: [NSArray class]]){
        for (NSString *phone in phones_array) {
          NSDictionary *dict=[NSDictionary dictionaryWithObjectsAndKeys:phone,@"external_id",person.name,@"name",@"phone",@"provider", nil];
          [identities addObject:dict];
        }
      }
    }
    return identities;
}
- (void)dealloc{
    if(addressBook!=nil)
        CFRelease(addressBook);
    
    [super dealloc];
}

@end
