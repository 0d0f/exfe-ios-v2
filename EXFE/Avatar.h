//
//  Avatar.h
//  EXFE
//
//  Created by Stony Wang on 13-7-18.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Avatar : NSManagedObject

@property (nonatomic, retain) NSString * original;
@property (nonatomic, retain) NSString * base;
@property (nonatomic, retain) NSString * base_2x;

@end
