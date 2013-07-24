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


typedef void (^OAuthAuthenticateSuccess)(NSDictionary *param);
typedef void (^OAuthAuthenticateCancel)();

@interface OAuthLoginViewController : UIViewController
{
    UIView *toolbar;
    bool firstLoading;
    UIButton *cancelbutton;
    UILabel *titlelabel;
}
@property (nonatomic, strong) IBOutlet UIWebView* webView;

@property (nonatomic, assign) Provider provider;
@property (nonatomic, copy) OAuthAuthenticateSuccess onSuccess;
@property (nonatomic, copy) OAuthAuthenticateCancel onCancel;

@property (nonatomic, copy) NSString *oAuthURL;
@property (nonatomic, copy) NSString *matchedURL;
@property (nonatomic, copy) NSString *javaScriptString;



@end