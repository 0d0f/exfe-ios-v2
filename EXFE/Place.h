//
//  Place.h
//  EXFE
//
//  Created by huoju on 9/9/12.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Place : NSManagedObject

@property (nonatomic, strong) NSDate * created_at;
@property (nonatomic, strong) NSString * external_id;
@property (nonatomic, strong) NSString * lat;
@property (nonatomic, strong) NSString * lng;
@property (nonatomic, strong) NSString * place_description;
@property (nonatomic, strong) NSNumber * place_id;
@property (nonatomic, strong) NSString * provider;
@property (nonatomic, strong) NSString * title;
@property (nonatomic, strong) NSString * type;
@property (nonatomic, strong) NSDate * updated_at;

@end
