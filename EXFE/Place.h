//
//  Place.h
//  EXFE
//
//  Created by ju huo on 5/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Place : NSManagedObject

@property (nonatomic, retain) NSNumber * place_id;
@property (nonatomic, retain) NSString * place_description;
@property (nonatomic, retain) NSString * external_id;
@property (nonatomic, retain) NSNumber * lat;
@property (nonatomic, retain) NSNumber * lng;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * provider;
@property (nonatomic, retain) NSDate * updated_at;
@property (nonatomic, retain) NSDate * created_at;

@end
