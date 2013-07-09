//
//  Rsvp.h
//  EXFE
//
//  Created by Stony Wang on 13-7-9.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Rsvp : NSManagedObject

@property (nonatomic, retain) NSNumber * by_identity_id;
@property (nonatomic, retain) NSNumber * exfee_id;
@property (nonatomic, retain) NSNumber * identity_id;
@property (nonatomic, retain) NSString * rsvp_status;

@end
