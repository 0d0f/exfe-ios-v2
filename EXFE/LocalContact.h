//
//  LocalContact.h
//  RestKit
//
//  Created by huoju on 1/30/13.
//  Copyright (c) 2013 RestKit. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface LocalContact : NSManagedObject

@property (nonatomic, retain) NSData * avatar;
@property (nonatomic, retain) NSData * emails;
@property (nonatomic, retain) NSString * indexfield;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSData * social;
@property (nonatomic, retain) NSNumber * uid;
@property (nonatomic, retain) NSData * im;

@end
