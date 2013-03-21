//
//  EditCrossDelegate.h
//  EXFE
//
//  Created by Stony Wang on 13-1-21.
//
//

#import <Foundation/Foundation.h>
#import "Invitation+EXFE.h"
#import "CrossTime+Helper.h"
#import "Place+Helper.h"

@protocol EditCrossDelegate <NSObject>

@required
- (void) addExfee:(NSArray*) invitations;
- (void) setTitle:(NSString*)title Description:(NSString*)desc;
- (void) setTime:(CrossTime*)time;
- (void) setPlace:(Place*)place;

@end
