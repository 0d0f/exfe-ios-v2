//
//  Cross.h
//  EXFE
//
//  Created by ju huo on 5/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class CrossTime, Exfee, Identity, Place;

@interface Cross : NSManagedObject

@property (nonatomic, retain) NSDate * created_at;
@property (nonatomic, retain) NSString * cross_description;
@property (nonatomic, retain) NSNumber * cross_id;
@property (nonatomic, retain) NSString * crossid_base62;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSDate * updated_at;
@property (nonatomic, retain) Identity *by_identity;
@property (nonatomic, retain) Exfee *exfee;
@property (nonatomic, retain) Identity *host_identity;
@property (nonatomic, retain) Place *place;
@property (nonatomic, retain) CrossTime *time;

@end
