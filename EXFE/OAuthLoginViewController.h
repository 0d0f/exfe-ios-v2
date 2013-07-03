//
//  OAuthLoginViewControllerViewController.h
//  EXFE
//
//  Created by ju huo on 5/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Util.h"
#import "MBProgressHUD.h"
#import "EXSpinView.h"
#import "Identity+EXFE.h"

@protocol OAuthLoginViewControllerDelegate;
@interface OAuthLoginViewController : UIViewController
{
    id<OAuthLoginViewControllerDelegate> __weak delegate;
    UIView *toolbar;
//    IBOutlet UIWebView *webView;
    bool firstLoading;
    UIButton *cancelbutton;
    UILabel *titlelabel;
}
@property (nonatomic, weak) id <OAuthLoginViewControllerDelegate> delegate;
@property (nonatomic, strong) IBOutlet UIWebView* webView;
@property (nonatomic, assign) Provider provider;
@property (nonatomic, copy) NSString *oAuthURL;
@property (nonatomic, copy) NSString *matchedURL;
@property (nonatomic, copy) NSString *javaScriptString;

@end


@protocol OAuthLoginViewControllerDelegate
-(void)OAuthloginViewControllerDidCancel:(OAuthLoginViewController *)oauthloginViewController;
-(void)OAuthloginViewControllerDidSuccess:(OAuthLoginViewController *)oauthloginViewController userid:(NSString*)userid username:(NSString*)username external_id:(NSString*)external_id token:(NSString*)token;

@end