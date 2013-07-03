//
//  Cross.h
//  EXFE
//
//  Created by huoju on 1/29/13.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class CrossTime, Exfee, Identity, Place;

@interface Cross : NSManagedObject

@property (nonatomic, strong) NSNumber * conversation_count;
@property (nonatomic, strong) NSDate * created_at;
@property (nonatomic, strong) NSString * cross_description;
@property (nonatomic, strong) NSNumber * cross_id;
@property (nonatomic, strong) NSString * crossid_base62;
@property (nonatomic, strong) NSDate * read_at;
@property (nonatomic, strong) NSString * title;
@property (nonatomic, strong) id updated;
@property (nonatomic, strong) NSString * updated_at;
@property (nonatomic, strong) id widget;
@property (nonatomic, strong) Identity *by_identity;
@property (nonatomic, strong) Exfee *exfee;
@property (nonatomic, strong) Identity *host_identity;
@property (nonatomic, strong) Place *place;
@property (nonatomic, strong) CrossTime *time;

@end
