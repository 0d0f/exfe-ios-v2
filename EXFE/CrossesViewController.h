//
//  CrossesViewController.h
//  EXFE
//
//  Created by ju huo on 5/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "APICrosses.h"

@interface CrossesViewController : UIViewController<RKRequestDelegate>{
    APICrosses *crossapi;
}
   
-(void) refreshCrosses;
@end
