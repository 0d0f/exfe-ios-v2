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
    kInvitationSortTypeMeAcceptNoNotifications,
    kInvitationSortTypeHostAcceptOthers,
    kInvitationSortTypeHostAcceptNoNotifications
};

@interface Exfee (EXFE)

+ (id)disconnectedEntity;
- (void)addToContext:(NSManagedObjectContext *)context;

- (Invitation*)getMyInvitation;
- (void) addDefaultInvitationBy:(Identity*)identity;

- (NSArray*)getSortedInvitations;
- (NSArray*)getSortedInvitations:(InvitationSortType)sortType;

- (NSArray*)getSortedMergedInvitations:(InvitationSortType)sortType;

- (NSArray*)getMyInvitations;
//-(NSArray*)getMergedInvitationSet;
- (BOOL)hasInvitation:(Invitation*)invitation;

@end
