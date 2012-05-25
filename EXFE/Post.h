//
//  Post.h
//  EXFE
//
//  Created by ju huo on 5/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Identity;

@interface Post : NSManagedObject

@property (nonatomic, retain) NSNumber * post_id;
@property (nonatomic, retain) NSString * content;
@property (nonatomic, retain) NSDate * created_at;
@property (nonatomic, retain) NSNumber * postable_id;
@property (nonatomic, retain) NSString * postable_type;
@property (nonatomic, retain) Identity *by_identity;

@end
