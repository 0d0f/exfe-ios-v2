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
@interface EXFEModel (Crosses)

#pragma mark From local storage
- (NSArray *)getCrossList;

#pragma mark From remote api
- (void)loadCrossWithCrossId:(NSUInteger)crossId updatedTime:(NSDate *)updatedTime;
- (void)loadCrossList;
- (void)loadCrossListAfter:(NSDate *)time;
- (void)editCross:(Cross *)cross;
- (void)removeInvitation:(Invitation *)invitation fromExfee:(Exfee *)exfee byIdentity:(Identity *)identity;
- (void)removeSelfInvitation:(Invitation *)invitation fromExfee:(Exfee *)exfee;
@end
