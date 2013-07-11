//
//  CrossTime.h
//  EXFE
//
//  Created by Stony Wang on 13-7-10.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class EFTime;

@interface CrossTime : NSManagedObject

@property (nonatomic, retain) NSString * origin;
@property (nonatomic, retain) NSNumber * outputformat;
@property (nonatomic, retain) EFTime *begin_at;

@end
