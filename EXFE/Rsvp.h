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

@property (nonatomic, strong) NSNumber * identity_id;
@property (nonatomic, strong) NSString * rsvp_status;
@property (nonatomic, strong) NSNumber * by_identity_id;
@property (nonatomic, strong) NSNumber * exfee_id;

@end
