//
//  EXFEModel+Crosses.h
//  EXFE
//
//  Created by 0day on 13-6-26.
//
//

#import "EXFEModel.h"

@class Cross;
@class Invitation;
@class Exfee;
@class IdentityId;
@class CrossTime;

@interface EXFEModel (Crosses)
{}
#pragma mark - From local storage
- (NSArray *)getCrossList;
- (Cross *)getCrossById:(NSUInteger)crossId;
- (Cross *)getCrossById:(NSNumber *)crossId from:(NSManagedObjectContext *)moc;
- (void)deleteCross:(Cross *)cross;

#pragma mark - From remote api
#pragma mark Cross
- (void)loadCrossWithCrossId:(NSUInteger)crossId updatedTime:(NSDate *)updatedTime;
- (void)loadCrossList;
- (void)loadCrossListAfter:(NSDate *)time;
- (void)editCross:(Cross *)cross;
- (void)removeCross:(Cross *)cross;

- (void)updateCrossTime:(CrossTime*)crossTime withCrossId:(NSNumber *)crossId;

#pragma mark Exfee
- (void)editExfee:(Exfee *)exfee;
- (void)changeRsvp:(NSString *)rsvp on:(Invitation *)invitation from:(Exfee *)exfee;
- (void)removeInvitation:(Invitation *)invitation fromExfee:(Exfee *)exfee;
- (void)removeSelfInvitation:(Invitation *)invitation fromExfee:(Exfee *)exfee;
- (void)removeNotificationIdentity:(IdentityId *)identityId from:(Invitation *)invitation onExfee:(Exfee *)exfee;
@end
