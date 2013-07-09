//
//  Post.h
//  EXFE
//
//  Created by Stony Wang on 13-7-9.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Identity;

@interface Post : NSManagedObject

@property (nonatomic, retain) NSString * content;
@property (nonatomic, retain) NSDate * created_at;
@property (nonatomic, retain) NSNumber * post_id;
@property (nonatomic, retain) NSNumber * postable_id;
@property (nonatomic, retain) NSString * postable_type;
@property (nonatomic, retain) NSDate * updated_at;
@property (nonatomic, retain) Identity *by_identity;

@end
