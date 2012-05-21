//
//  Identity.h
//  EXFE
//
//  Created by ju huo on 5/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Identity : NSManagedObject

@property (nonatomic, retain) NSString * updated_at;
@property (nonatomic, retain) NSString * created_at;
@property (nonatomic, retain) NSString * avatar_updated_at;
@property (nonatomic, retain) NSString * avatar_filename;
@property (nonatomic, retain) NSString * bio;
@property (nonatomic, retain) NSNumber * connected_user_id;
@property (nonatomic, retain) NSString * external_username;
@property (nonatomic, retain) NSString * external_id;
@property (nonatomic, retain) NSString * provider;
@property (nonatomic, retain) NSString * nickname;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * id;

@end
