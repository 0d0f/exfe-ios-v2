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
#import "CrossesViewController.h"

@interface CrossDetailViewController : UIViewController <RKRequestDelegate,RKObjectLoaderDelegate>{
    Cross* cross;
    BOOL interceptLinks;
    IBOutlet UIWebView *webview;
    ConversationViewController *conversationView;
    UIInputToolbar *inputToolbar;

}
@property (retain,nonatomic) Cross* cross;
@property BOOL interceptLinks;
@property (nonatomic, retain) UIInputToolbar *inputToolbar;
- (NSString*)GenerateHtmlWithEvent;
- (void)toconversation;
@end
