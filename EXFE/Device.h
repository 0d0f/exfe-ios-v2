//
//  Device.h
//  EXFE
//
//  Created by Stony Wang on 13-7-10.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Device : NSManagedObject

@property (nonatomic, retain) NSString * brand;
@property (nonatomic, retain) NSString * device_description;
@property (nonatomic, retain) NSNumber * device_id;
@property (nonatomic, retain) NSDate * disconnected_at;
@property (nonatomic, retain) NSDate * first_connected_at;
@property (nonatomic, retain) NSDate * last_connected_at;
@property (nonatomic, retain) NSString * model;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * os_name;
@property (nonatomic, retain) NSString * os_version;
@property (nonatomic, retain) NSNumber * status;

@end
