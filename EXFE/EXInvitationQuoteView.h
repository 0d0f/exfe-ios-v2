//
//  EXInvitationQuoteView.h
//  EXFE
//
//  Created by huoju on 8/18/12.
//
//

#import "EXQuoteView.h"
#import "Invitation.h"
#import "Identity.h"
#import "CTUtil.h"
#import "Util.h"

@interface EXInvitationQuoteView : EXQuoteView{
    Invitation *invitation;
    NSAttributedString *Line1;
    NSAttributedString *Line2;
    NSAttributedString *Line3;
}

@property (nonatomic,retain) Invitation* invitation;
@property (nonatomic,retain) NSAttributedString* Line1;
@property (nonatomic,retain) NSAttributedString* Line2;
@property (nonatomic,retain) NSAttributedString* Line3;


@end
