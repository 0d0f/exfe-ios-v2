//
//  CrossTime.h
//  EXFE
//
//  Created by ju huo on 5/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class EFTime;

@interface CrossTime : NSManagedObject

@property (nonatomic, retain) NSString * origin;
@property (nonatomic, retain) NSNumber * outputformat;
@property (nonatomic, retain) EFTime *begin_at;

@end
