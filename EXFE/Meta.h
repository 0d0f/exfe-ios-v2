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

@property (nonatomic, strong) NSNumber * code;
@property (nonatomic, strong) NSString * errorDetail;
@property (nonatomic, strong) NSString * errorType;

@end
