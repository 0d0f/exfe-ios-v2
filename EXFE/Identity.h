//
//  Identity.h
//  EXFE
//
//  Created by huoju on 1/29/13.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Identity : NSManagedObject

@property (nonatomic, strong) NSNumber * a_order;
@property (nonatomic, strong) NSString * avatar_filename;
@property (nonatomic, strong) NSString * avatar_updated_at;
@property (nonatomic, strong) NSString * bio;
@property (nonatomic, strong) NSNumber * connected_user_id;
@property (nonatomic, strong) NSString * created_at;
@property (nonatomic, strong) NSString * external_id;
@property (nonatomic, strong) NSString * external_username;
@property (nonatomic, strong) NSNumber * identity_id;
@property (nonatomic, strong) NSString * name;
@property (nonatomic, strong) NSString * nickname;
@property (nonatomic, strong) NSString * provider;
@property (nonatomic, strong) NSString * status;
@property (nonatomic, strong) NSString * type;
@property (nonatomic, strong) NSNumber * unreachable;
@property (nonatomic, strong) NSString * updated_at;

@end
