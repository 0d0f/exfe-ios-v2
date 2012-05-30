//
//  Invitation.h
//  EXFE
//
//  Created by ju huo on 5/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Identity;

@interface Invitation : NSManagedObject

@property (nonatomic, retain) NSDate * created_at;
@property (nonatomic, retain) NSNumber * invitation_id;
@property (nonatomic, retain) NSString * rsvp_status;
@property (nonatomic, retain) NSDate * updated_at;
@property (nonatomic, retain) NSString * via;
@property (nonatomic, retain) NSNumber * host;
@property (nonatomic, retain) Identity *by_identity;
@property (nonatomic, retain) Identity *identity;

@end
