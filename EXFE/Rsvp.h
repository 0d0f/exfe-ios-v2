//
//  Rsvp.h
//  EXFE
//
//  Created by ju huo on 6/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Rsvp : NSManagedObject

@property (nonatomic, retain) NSNumber * identity_id;
@property (nonatomic, retain) NSString * rsvp_status;
@property (nonatomic, retain) NSNumber * by_identity_id;
@property (nonatomic, retain) NSNumber * exfee_id;

@end
