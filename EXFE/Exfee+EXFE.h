//
//  Exfee+EXFE.h
//  EXFE
//
//  Created by Stony Wang on 3/13/13.
//
//

#import "Exfee.h"
#import "Invitation+EXFE.h"
#import "Identity+EXFE.h"

typedef NS_ENUM(NSInteger, InvitationSortType){
    kInvitationSortTypeDefaultById,
    kInvitationSortTypeMeAcceptOthers,
    kInvitationSortTypeHostAcceptOthers
};

@interface Exfee (EXFE)

- (Invitation*)getMyInvitation;
- (void) addDefaultInvitationBy:(Identity*)identity;

- (NSArray*)getSortedInvitations;
- (NSArray*)getSortedInvitations:(InvitationSortType)sortType;

- (NSArray*)getMyInvitations;
//-(NSArray*)getMergedInvitationSet;
- (BOOL)hasInvitation:(Invitation*)invitation;

@end
