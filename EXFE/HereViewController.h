//
//  HereViewController.h
//  EXFE
//
//  Created by huoju on 3/26/13.
//
//

#import <UIKit/UIKit.h>
#import "User.h"
#import "User+EXFE.h"
#import "Identity.h"
#import "Util.h"
#import <stdint.h>


@interface HereViewController : UIViewController <NSStreamDelegate>{
  NSMutableData *_data;
  int byteIndex;
  uint8_t buff[1024];
  
}

- (void) close;
- (void) start;
@end
