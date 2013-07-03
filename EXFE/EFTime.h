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

@property (nonatomic, strong) NSString * date;
@property (nonatomic, strong) NSString * date_word;
@property (nonatomic, strong) NSString * time;
@property (nonatomic, strong) NSString * time_word;
@property (nonatomic, strong) NSString * timezone;

@end
