//
//  Exfee+EXFE.h
//  EXFE
//
//  Created by Stony Wang on 3/13/13.
//
//

#import "Exfee.h"

typedef NS_ENUM(NSInteger, InvitationSortType){
    kInvitationSortTypeDefaultById,
    kInvitationSortTypeMeAcceptOthers,
    kInvitationSortTypeHostAcceptOthers
};

@interface Exfee (EXFE)

-(Invitation*)getMyInvitation;

-(NSArray*)getSortedInvitations;
-(NSArray*)getSortedInvitations:(InvitationSortType)sortType;

-(NSMutableArray*)getMyInvitationSet;
-(NSArray*)getMergedInvitationSet;

@end
