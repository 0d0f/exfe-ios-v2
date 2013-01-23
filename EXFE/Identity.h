//
//  Identity.h
//  EXFE
//
//  Created by huoju on 1/23/13.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Identity : NSManagedObject

@property (nonatomic, retain) NSNumber * a_order;
@property (nonatomic, retain) NSString * avatar_filename;
@property (nonatomic, retain) NSString * avatar_updated_at;
@property (nonatomic, retain) NSString * bio;
@property (nonatomic, retain) NSNumber * connected_user_id;
@property (nonatomic, retain) NSString * created_at;
@property (nonatomic, retain) NSString * external_id;
@property (nonatomic, retain) NSString * external_username;
@property (nonatomic, retain) NSNumber * identity_id;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * nickname;
@property (nonatomic, retain) NSString * provider;
@property (nonatomic, retain) NSString * status;
@property (nonatomic, retain) NSString * type;
@property (nonatomic, retain) NSNumber * unreachable;
@property (nonatomic, retain) NSString * updated_at;

@end
