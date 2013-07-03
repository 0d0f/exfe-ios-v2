//
//  LocalContact.h
//  EXFE
//
//  Created by huoju on 2/21/13.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface LocalContact : NSManagedObject

@property (nonatomic, strong) NSData * avatar;
@property (nonatomic, strong) NSData * emails;
@property (nonatomic, strong) NSData * im;
@property (nonatomic, strong) NSString * indexfield;
@property (nonatomic, strong) NSString * name;
@property (nonatomic, strong) NSData * social;
@property (nonatomic, strong) NSNumber * uid;
@property (nonatomic, strong) NSData * phones;

@end
