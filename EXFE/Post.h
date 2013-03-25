//
//  Post.h
//  EXFE
//
//  Created by ju huo on 6/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Identity;

@interface Post : NSManagedObject

@property (nonatomic, retain) NSString * content;
@property (nonatomic, retain) NSString * created_at;
@property (nonatomic, retain) NSNumber * post_id;
@property (nonatomic, retain) NSNumber * postable_id;
@property (nonatomic, retain) NSString * postable_type;
@property (nonatomic, retain) NSString * updated_at;
@property (nonatomic, retain) Identity *by_identity;

@end
