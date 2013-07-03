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

@property (nonatomic, strong) NSString * content;
@property (nonatomic, strong) NSString * created_at;
@property (nonatomic, strong) NSNumber * post_id;
@property (nonatomic, strong) NSNumber * postable_id;
@property (nonatomic, strong) NSString * postable_type;
@property (nonatomic, strong) NSString * updated_at;
@property (nonatomic, strong) Identity *by_identity;

@end
