//
//  ObjectToDict.h
//  EXFE
//
//  Created by huoju on 8/27/12.
//
//

#import <Foundation/Foundation.h>
#import "Exfee.h"
#import "Invitation.h"
#import "Identity.h"

@interface ObjectToDict : NSObject
+ (NSMutableDictionary*) ExfeeDict:(Exfee*)exfee;
+ (NSMutableDictionary*) InvitationDict:(Invitation*)invitation;
+ (NSMutableDictionary*) IdentityDict:(Identity*)identity;
@end
