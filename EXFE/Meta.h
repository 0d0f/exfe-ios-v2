//
//  Meta.h
//  EXFE
//
//  Created by ju huo on 6/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Meta : NSManagedObject

@property (nonatomic, retain) NSNumber * code;
@property (nonatomic, retain) NSString * errorDetail;
@property (nonatomic, retain) NSString * errorType;

@end
