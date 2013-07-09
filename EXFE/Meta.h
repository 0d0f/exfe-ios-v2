//
//  Meta.h
//  EXFE
//
//  Created by Stony Wang on 13-7-9.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Meta : NSManagedObject

@property (nonatomic, retain) NSNumber * code;
@property (nonatomic, retain) NSString * errorDetail;
@property (nonatomic, retain) NSString * errorType;

@end
