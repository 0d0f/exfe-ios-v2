//
//  ConversationViewController.h
//  EXFE
//
//  Created by ju huo on 5/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Identity.h"
#import "RestKit.h"
#import "UIInputToolbar.h"
#import "ConversationTableView.h"
#import "PostCell.h"

#define kNavBarHeight 44
#define kStatusBarHeight 20
#define kDefaultToolbarHeight 40
#define kKeyboardHeightPortrait 216
#define kKeyboardHeightLandscape 140

@interface ConversationViewController : UIViewController  <RKRequestDelegate,UIInputToolbarDelegate>{
    IBOutlet ConversationTableView* _tableView;
    int exfee_id;
    UIInputToolbar *inputToolbar;
    Identity *identity;
    NSArray* _posts;
}

@property int exfee_id;
@property (retain,nonatomic) Identity* identity;
@property (retain,nonatomic) UIInputToolbar* inputToolbar;

-(void) refreshConversation;
- (void)loadObjectsFromDataStore;
- (void) addPost:(NSString*)content;
@end
