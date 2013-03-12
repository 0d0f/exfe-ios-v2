//
//  WidgetExfeeViewController.h
//  EXFE
//
//  Created by Stony Wang on 13-3-11.
//
//

#import <UIKit/UIKit.h>
#import "Invitation.h"
#import "Exfee.h"


typedef enum {
    ScrollDirectionNone,
    ScrollDirectionRight,
    ScrollDirectionLeft,
    ScrollDirectionUp,
    ScrollDirectionDown,
    ScrollDirectionCrazy,
} ScrollDirection;

@interface WidgetExfeeViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate>{
    UITableView* invTable;
    UIScrollView* exfeeContainer;
    Exfee *exfee;
    Invitation* selected_invitation;
    
    CGPoint _lastContentOffset;
}

@end
