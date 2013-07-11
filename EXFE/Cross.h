//
//  Cross.h
//  EXFE
//
//  Created by Stony Wang on 13-7-10.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class CrossTime, Exfee, Identity, Place;

@interface Cross : NSManagedObject

@property (nonatomic, retain) NSNumber * conversation_count;
@property (nonatomic, retain) NSDate * created_at;
@property (nonatomic, retain) NSString * cross_description;
@property (nonatomic, retain) NSNumber * cross_id;
@property (nonatomic, retain) NSString * crossid_base62;
@property (nonatomic, retain) NSDate * read_at;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) id updated;
@property (nonatomic, retain) NSDate * updated_at;
@property (nonatomic, retain) id widget;
@property (nonatomic, retain) Identity *by_identity;
@property (nonatomic, retain) Exfee *exfee;
@property (nonatomic, retain) Identity *host_identity;
@property (nonatomic, retain) Place *place;
@property (nonatomic, retain) CrossTime *time;

@end
