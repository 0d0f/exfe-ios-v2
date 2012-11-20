//
//  OAuthAddIdentityViewController.h
//  EXFE
//
//  Created by huoju on 11/13/12.
//
//

#import <UIKit/UIKit.h>
#import "AddIdentityViewController.h"
#import "MBProgressHUD.h"

@interface OAuthAddIdentityViewController : UIViewController{
    IBOutlet UIWebView *webview;
    NSString *oauth_url;
    UIViewController *parentView;
    UIView *toolbar;
    UIButton *cancelbutton;
    UILabel *titlelabel;
}

@property (nonatomic,retain) NSString* oauth_url;
@property (nonatomic,retain) UIViewController* parentView;
@property (nonatomic,retain) UIWebView* webview;

- (void)cancel;

@end
