//
//  EXInvitationQuoteView.h
//  EXFE
//
//  Created by huoju on 8/18/12.
//
//

#import "EXQuoteView.h"
#import "Invitation.h"
#import "CTUtil.h"
#import "Util.h"

@interface EXInvitationQuoteView : EXQuoteView{
    Invitation *invitation;
}

@property (nonatomic,retain) Invitation* invitation;
@end
