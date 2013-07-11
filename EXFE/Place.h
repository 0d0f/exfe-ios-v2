//
//  Place.h
//  EXFE
//
//  Created by Stony Wang on 13-7-10.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Place : NSManagedObject

@property (nonatomic, retain) NSDate * created_at;
@property (nonatomic, retain) NSString * external_id;
@property (nonatomic, retain) NSString * lat;
@property (nonatomic, retain) NSString * lng;
@property (nonatomic, retain) NSString * place_description;
@property (nonatomic, retain) NSNumber * place_id;
@property (nonatomic, retain) NSString * provider;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * type;
@property (nonatomic, retain) NSDate * updated_at;

@end
