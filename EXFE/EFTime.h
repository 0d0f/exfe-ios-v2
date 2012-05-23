//
//  EFTime.h
//  EXFE
//
//  Created by ju huo on 5/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
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
