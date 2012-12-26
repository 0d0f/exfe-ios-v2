//
//  EXRSVPStatusView.h
//  EXFE
//
//  Created by huoju on 12/26/12.
//
//

#import <UIKit/UIKit.h>
#import "Invitation.h"

@interface EXRSVPStatusView : UIView{
    Invitation *invitation;

}
@property (nonatomic,retain) Invitation *invitation;

@end
