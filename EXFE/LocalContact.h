//
//  LocalContact.h
//  EXFE
//
//  Created by Stony Wang on 13-7-10.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface LocalContact : NSManagedObject

@property (nonatomic, retain) NSData * avatar;
@property (nonatomic, retain) NSData * emails;
@property (nonatomic, retain) NSData * im;
@property (nonatomic, retain) NSString * indexfield;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSData * phones;
@property (nonatomic, retain) NSData * social;
@property (nonatomic, retain) NSNumber * uid;

@end
