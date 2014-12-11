//
//  EFTime.h
//  EXFE
//
//  Created by Stony Wang on 13-7-10.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface EFTime : NSManagedObject

@property (nonatomic, retain) NSString * date;
@property (nonatomic, retain) NSString * date_word;
@property (nonatomic, retain) NSString * time;
@property (nonatomic, retain) NSString * time_word;
@property (nonatomic, retain) NSString * timezone;

@end
