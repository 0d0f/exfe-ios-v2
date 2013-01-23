//
//  EditCrossDelegate.h
//  EXFE
//
//  Created by Stony Wang on 13-1-21.
//
//

#import <Foundation/Foundation.h>
#import "Invitation.h"

@protocol EditCrossDelegate <NSObject>

@required
- (void) addExfee:(NSArray*) invitations;
- (Invitation*) getMyInvitation;
- (void) setTitle:(NSString*)title Description:(NSString*)desc;
- (void) setTime:(CrossTime*)time;
- (void) setPlace:(Place*)place;

@end
