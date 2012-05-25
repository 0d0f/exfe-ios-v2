//
//  CrossDetailViewController.h
//  EXFE
//
//  Created by ju huo on 5/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Cross.h"
#import "APIConversation.h"

@interface CrossDetailViewController : UIViewController <RKRequestDelegate>{
    Cross* cross;
    IBOutlet UILabel* cross_tiltle;
    IBOutlet UILabel* exfee_id;
}
@property (retain,nonatomic) Cross* cross;
@end
