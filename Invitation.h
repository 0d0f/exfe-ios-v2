//
//  Invitation.h
//  EXFE
//
//  Created by huoju on 12/29/12.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Identity;

@interface Invitation : NSManagedObject

@property (nonatomic, retain) NSDate * created_at;
@property (nonatomic, retain) NSNumber * host;
@property (nonatomic, retain) NSNumber * invitation_id;
@property (nonatomic, retain) NSNumber * mates;
@property (nonatomic, retain) NSString * rsvp_status;
@property (nonatomic, retain) NSString * type;
@property (nonatomic, retain) NSDate * updated_at;
@property (nonatomic, retain) NSString * via;
@property (nonatomic, retain) Identity *identity;
@property (nonatomic, retain) Identity *invited_by;
@property (nonatomic, retain) Identity *updated_by;

@end
