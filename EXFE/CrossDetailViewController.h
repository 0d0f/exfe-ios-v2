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
#import "ConversationViewController.h"

@interface CrossDetailViewController : UIViewController <RKRequestDelegate>{
    Cross* cross;
    IBOutlet UIWebView *webview;

    ConversationViewController *conversationView;
}
@property (retain,nonatomic) Cross* cross;
- (NSString*)GenerateHtmlWithEvent;
- (void)toconversation;
@end
