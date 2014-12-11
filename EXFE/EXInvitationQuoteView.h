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
    CGPoint point;
    
}

@property (nonatomic,strong) Invitation* invitation;
@property (nonatomic,strong) NSAttributedString* Line1;
@property (nonatomic,strong) NSAttributedString* Line2;
@property (nonatomic,strong) NSAttributedString* Line3;
@property CGPoint point;


@end
